A Dyn Type For Runtime Values
=====

## Proposal

This proposal introduces a `dyn` type to reflect values that are only known at runtime.

## Description

The `dyn` type doesn't require any user annotation as it is inferred by the compiler. The `dyn` type is used with global callables. `dyn` values come from intrinsic operations. Functions can't introduce `dyn` values, but can pass them. The Result type is always a `dyn`. A `dyn` Result can be converted to a `dyn` Bool.  The `dyn` static analysis replaces mutable variable and result analysis.

## Use Cases

Below use cases explain how a developer interacts with the `dyn` type and describe the functionalities of the new type.

### Allow to pass the values created at runtime to other callables

```qsharp
operation Reset(q : Qubit, m : Result) : Unit {
    if m == One {
        X(q);
    }
}

operation MeasureAndReset(q : Qubit) : Unit {
    let res = M(q); // create a dynamic value (res)
    Reset(q, res); // pass the dynamic value to another operation
}
```

Without the proposed modification, the implementation of `Reset` would need to be manually inlined into `MeasureAndReset`.

### Allow callables to return the values created at runtime

```qsharp
operation MeasureAsInt(q : Qubit) : Int {
    return M(q) == One ? 1 | 0;
}

operation CountOnes(qs : Qubit[]) : Int {
    mutable count = 0;
    for q in qs {
        set count += MeasureAsInt(q);
    }
    return count;
}
```

Without the proposed modification, dynamic values can only be returned by the entry point, but not by other callables.

Without introducing dynamic types, callables defined in libraries could only be used for computing compile time known values, but not for manipulating runtime values; Ultimately, application code then would need to be mostly contained in the entry point callable and code cannot be structured into several subroutines.

### Dynamic values require runtime support

The example generates an error when calling `Foo` with a dynamic value as argument `i` unless the target supports arrays.

The developer can create values at runtime by measuring a qubit and then pass these values to other callables that process it further and return it.

> Define the array index as a callable input parameter

```qsharp
operation Foo(b : Bool, i : Int) : Int {
    return [1, 2, 3][i]; // This needs runtime support if i is dynamic
}

operation Bar() : Int {
// get a dynamic value (usually by measuring a qubit)
    use q = Qubit();
    H(q);
    let val = M(q) == Zero ? 0 : 1; // val is of type dyn Int

    let res = Foo(true, val); // requires that the runtime supports arrays
    return res; // res is of type dyn Int
}
```

> Define the lifting operator for the array index

```qsharp
lift_i Foo : (Bool, dyn Int) => dyn Int
```

> The array index is lifted into dyn. The result value of the operation is also a dyn.


### Lift a boolean into dyn

> Define the boolean as a callable input parameter

```qsharp
operation Foo(b : Bool, i : Int) : Int {
    use q = Qubit();
    if b { X(q); }
    return [1, 2, 3][i];
}
```

> Define the lifting operator for the boolean

```qsharp
lift_b Foo : (dyn Bool, Int) => Int
```

> The boolean is lifted into `dyn`. The result value of the operation is not `dyn`. The result is opaque as `b` is used to branch for a gate.

### Cannot lift anonymous parameters into dyn

> Define anonymous parameters as a callable input parameter

```qsharp
operation Foo(Bool, Int) : Int {
    use q = Qubit();
    if b { X(q); }
        return [1, 2, 3][i];
}
```

> It is not possible to define the lifting operator for the anonymous

```qsharp
(Bool, Int) => Int
```        
> The anonymous parameter is not lifted into dyn

### Compiler injects values into dyn

> The developer sets up a conditional statement for the injection

```qsharp
If x : T, then inject x : dyn T
```

> The compiler automatically injects compile-time values into dyn

## Implementation

The implementation will be informed by below design goals:
> Goal 1: Keep compilation and optimization logic within llvm as much as possible, rather than replicating it in the Q# compiler

> Goal 2: Q# functions serve the same purpose as const functions in other languages, i.e. we basically want to guarantee that a function can be evaluated when and as soon as all arguments are known. This in particular means that unless an argument is `dyn`, we expect that the function call will be fully evaluated/evaluatable at compile time.


### Keep the same AST or IR representation for dyn and non-dyn

While conceptually, all global callables effectively become implicitly type parameterized to permit that any argument can be either of non-dyn or dyn type, there is no need to "monomorphize" with respect to this "axis" of the type system; we do not see much value in either a different AST or a different IR representation for dyn vs non-dyn values. This reflects the design goal of alignment with the llvm compilation and optimization logic.

### AST representation needed at validation time

The only place where such a representation is needed is to run the validation (analyzers that run after the initial compilation has been built); what is needed specifically is an AST representation for a specific callable that contains the proper type distinction between dyn and non-dyn types for the purpose of properly propagating that information throughout the implementation such that the analyzers can make use of it. This AST representation can, however, be discarded after the analysis passes for this callable have completed, and is not needed for more than one callable at a time (we do a bottom-up inference). 

### Analyzer pass on each callable parameter

The analyzers are run for one callable at a time (same as it is the case today). They will be run once in (more or less) the same way as they are today, and produce the same attribute they are today - i.e. the first pass of the analyzers analyzes the requirements of the callable under the assumption that all arguments are non-dyn values.

Additionally, we will run the analyzers once for each parameter of the callable. This pass will produce an additional attribute per parameter that indicates the required runtime capability if a specific parameter is `dyn` instead of non-`dyn`. We hence end up with n+1 attribute on the callable, where n is the number of parameters. For each call to the callable, the required capability for that call is given by the sum of the required capabilities for the callable itself plus those for of the `dyn` arguments.

The n+1 attributes need to be manually declared for intrinsic callables (same as it is the case today, just more attributes).

## Approximations

For the purpose of type inference (i.e. how `dyn` is propagated), we make the below approximations.

### Operations always return a dyn

The return type of an operation is always `dyn`. While it is conceivable to write an operation that has a non-`dyn` return value, it is also always possible - and arguably best practice - to split out any computation of a non-`dyn` return value into a function instead.

### Functions return dyn only if one argument is dyn

The return type of a function is `dyn` if and only if one of the arguments is `dyn`; since `dyn` values are ultimately produced (only) by calls to operations, it is not possibly for a function to generate a `dyn` value as part of its implementation. The only way that a returned value can be `dyn` is hence if an argument was `dyn`.

### Dyn applies to all items in an array or tuple

For now (i.e. for the initial implementation), we make the simplification that `dyn` always applies to the entire container (a container being e.g. a tuple/array). The fact that a `dyn` container necessarily requiring that all contained items should be considered `dyn` is expected to be a permanent and necessary choice; accessing an item in a `dyn` container requires access via a `dyn` value.

## Limitations

The required target capability can be computed for each callable parameter separately, and the overall capability requirements for the callable is a sum (not the product!) of the capability requirement for each parameter + the capability requirement for the callable itself (i.e. the capability requirement due to runtime values the callable itself introduces).

This in particular means that we do not intend to distinguish, now or in the future, if e.g. a targeted backend supports comparing a dynamic value against a constant, but not comparing two dynamic values with each other.

Concretely, we do not intend to distinguish the ability to execute the following two pieces of code:

```qsharp
if (M(q) == Zero) {
    X(q);
}
```

compared to

```qsharp
if (M(q1) != M(q2)) {
    X(q);
}
```

