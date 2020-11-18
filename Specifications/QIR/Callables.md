## Callables

We use to term _callable_ to mean a subroutine in the source language.
Different source languages use different names for this concept.

### Runtime Failure

There are several error conditions that are specified as causing a runtime failure.
The `quantum__rt__fail` function is the mechanism to use to cause a runtime failure;
it is documented in the [Classical Runtime](Classical-Runtime.md) section.

### Basics

Callables are represented by up to four different LLVM functions to handle different
combinations of functors: one for the base version and one each for the adjoint,
controlled, and controlled-adjoint specializations.
A callable that does not have a specific specialization would not have the
corresponding LLVM function.

The names of the functions should be the namespace-qualified name of the
callable with each period replaced by two underscores, '__', then another
two underscores, followed by `body` for the base version, `adj` for the adjoint
specialization, `ctl` for the controlled specialization, and `ctladj` for the
controlled adjoint specialization.

The signatures of the callables should match the source language signature.
For instance, the base version of a callable that takes a floating-point number
"theta" and a qubit "qb" and returns a result would generate:

```LLVM
define %Result *Some__Namespace__Symbol__body (double theta, %Qubit *qb)
{
  ; code goes here
}
```

Direct invocations of callables should be generated into normal LLVM function
calls.

### Callable Values

In order to support lambda captures and partial application, as well as
applying functors to callable values (function pointers), such values need to
be represented by a more complex data structure than simply a standard function
pointer.
These values are represented by a pointer to an opaque LLVM type, `%Callable`.

#### Wrapper Functions

Because LLVM doesn't support generics, the LLVM function pointers used to
initialize a `%Callable` have to be of a single type.
To accomplish this, we create a new "wrapper" function for each of the
callable's specializations.
All such wrapper functions have the same signature and so are of the same
LLVM type.
The name of a wrapper function should be the same as the name of the function
it is wrapping, with "__wrapper" appended.

The four specializations of a callable are:

- The "body", which is the normal, unmodified callable.
- The "adj", which implements the adjoint of the quantum operation defined by
  the callable.
- The "ctl", which implements the controlled version of the quantum operation
  defined by the callable.
- The "ctladj", which implements the adjoint of the controlled version.

A callable may define a "ctladj" specialization if and only if it defines both
"adj" and "ctl" specializations.

There is no need to create wrappers for callables that are never pointed to.
That is, **a callable that is never turned into a callable value doesn't need wrapper functions**.

Each wrapper is an LLVM function that takes three tuple header pointers as input and
returns no output; that is, `void(%TupleHeader*, %TupleHeader*, %TupleHeader*)`.
The first input is the capture tuple, which used for closures.
The second input is the argument tuple.
The third input points to the result tuple, which will be allocated by the caller.
If the callable has `Unit` result, then the result tuple pointer will be null.

Each wrapper function should start with a prologue that decomposes the argument and
capture tuples.
Depending on the result type, it should end with an epilogue that fills in the result tuple.
If the result tuple contains another container such as an array, it may be simpler and more
efficient to fill in the sub-container in-line in the implementation, rather than creating
a separate array and then copying it to the result tuple.

We use a caller-allocates strategy for the result tuple because this allows us to
avoid a heap allocation in many cases.
If the callee allocates space for the result tuple, that space has to be on the heap
because a stack-based allocation would be released when the callee returns.
The caller can usually allocate the result tuple on the stack, or reuse the
result tuple pointer it received for tail calls.

For instance, for a callable named `Some.Namespace.Symbol` with all four
specializations, the compiler should generate the following in LLVM:

```LLVM
define void Some__Namespace__Symbol__body__wrapper (%TupleHeader* capture,
    %TupleHeader* args, %TupleHeader* result)
{
  ; code to get arguments out of the args and capture tuples goes here
  ; call to Some__Namespace__Symbol__body() goes here
  ; code to fill in the result tuple goes here
  ret void;
}

define void Some__Namespace__Symbol__adj__wrapper (%TupleHeader* capture,
    %TupleHeader* args, %TupleHeader* result)
{
  ; code to get arguments out of the args and capture tuples goes here
  ; call to Some__Namespace__Symbol__adj() goes here
  ; code to fill in the result tuple goes here
  ret void;
}

define void Some__Namespace__Symbol__ctl__wrapper (%TupleHeader* capture,
    %TupleHeader* args, %TupleHeader* result)
{
  ; code to get arguments out of the args and capture tuples goes here
  ; call to Some__Namespace__Symbol__ctl() goes here
  ; code to fill in the result tuple goes here
  ret void;
}

define void Some__Namespace__Symbol__ctladj__wrapper (%TupleHeader* capture,
    %TupleHeader* args, %TupleHeader* result)
{
  ; code to get arguments out of the args and capture tuples goes here
  ; call to Some__Namespace__Symbol__ctladj() goes here
  ; code to fill in the result tuple goes here
  ret void;
}
```

#### Implementation Table

For each callable that is used to create a callable value, a table is created
with pointers to the four wrapper functions; specializations that don't exist
for a specific callable have a null pointer in that place.
The table is defined as a global constant whose name is the namespace-qualified
name of the callable with periods replaced by double underscores, "__".

There is no need to create wrappers or an implementation table for callables
that are never pointed to.
That is, **a callable that is never turned into a callable value doesn't need either wrapper functions or an implementation table**.

For the example above, the following would be generated:

```LLVM
@Some__Namespace__Symbol = constant 
  [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]
  [
    void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*
        @Some__Namespace__Symbol__body,
    void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*
        @Some__Namespace__Symbol__adj,
    void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* 
        @Some__Namespace__Symbol__ctl,
    void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* 
        @Some__Namespace__Symbol__ctladj
  ]
```

### Creating Callable Values

As mentioned above, callable values are represented by a pointer to an opaque
LLVM structure , `%Callable`.
These values are created using the `__quantum__rt__callable_create` or
`__quantum__rt__callable_copy` runtime functions.

The `__quantum__rt__callable_create` function takes an implementation table
and a capture tuple and returns a pointer to a new `%Callable`.
The capture tuple in the `%Callable` is passed as the first argument to the
wrapper function when the callable value is invoked.
It is intended to hold values captured by a lambda or provided values
in a partial application.
If there are no captured values, a null pointer should be passed.

The `__quantum__rt__callable_copy` function creates a copy of an existing
`%Callable`.
It is most often used before using the `__quantum__rt__callable_make_adjoint`
or `__quantum__rt__callable_make_controlled` functions to apply a functor
to a callable value.

### Invoking a Callable Value

As mentioned above, direct invocations of callables should be generated into
normal LLVM function calls.

To invoke a callable value represented as a `%Callable*`,
the `__quantum__rt__callable_invoke` runtime function should be used.
This function uses the information in the callable value to invoke the proper
implementation with the appropriate parameters.
To satisfy LLVM's strong typing, this function requires the arguments to be
assembled into a tuple and passed to the runtime function as a tuple pointer.

### Applying Functors to Callable Values

The Adjoint and Controlled functors are important for expressing quantum
algorithms.
They are implemented by the `__quantum__rt__callable_make_adjoint` and
`__quantum__rt__callable_make_control` runtime functions, which update a
`%Callable` in place by applying the `Adjoint` or `Controlled` functors
respectively.

To support cases where the original, unmodified `%Callable` is still needed
after functor application, the `__quantum__rt__callable_copy` routine may be
used to create a new copy of the original `%Callable`; the functor may then be
applied to the new `%Callable`.
For instance, to implement the following:

```qsharp
let f = someOp;
let g = Adjoint f;
// ... code that uses both f and g ...
```

The following snippet of LLVM code could be generated:

```LLVM
%f = call %__quantum__rt__callable_create(
  [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @someOp,
  %TupleHeader* null)
%g = call %__quantum__rt__callable_copy(%f)
call %__quantum__rt__callable_make_adjoint(%g)
```

The actual implementation of the `%Callable` needs to support the following
behavior:

- For `__quantum__rt__callable_make_adjoint`, the parity of the number of
  times this function has been applied should be tracked. The `Adjoint` functor
  is its own inverse, so applying it twice is the same as not applying it at all.
  Applying this function to a `%Callable` whose implementation table has a null
  "adj" entry should cause a runtime failure.
- For `__quantum__rt__callable_make_control`, the count of the number of 
  times the function has been applied must be tracked. The `Controlled` functor
  is not its own inverse.
  Applying this function to a `%Callable` whose implementation table has a null
  "ctl" entry should cause a runtime failure.
- The order of applying these two functions does not need to be tracked. The
  `Adjoint` and `Controlled` functors commute.

When `__quantum__rt__callable_invoke` is called, the entry in the callable's
implementation table to be used is selected as follows:

- If the adjoint parity is even and the controlled count is zero, the "body"
  entry (index 0) should be used.
- If the adjoint parity is odd and the controlled count is zero, the "adj"
  entry (index 1) should be used.
- If the adjoint parity is even and the controlled count is greater than zero,
  the "ctl" entry (index 2) should be used.
- If the adjoint parity is odd and the controlled count is greater than zero,
  the "ctladj" entry (index 3) should be used.

If the controlled count is greater than one, then `__quantum__rt__callable_invoke`
also needs to do some manipulation of the input tuple.
Each application of the `Controlled` functor modifies the signature of the
specialization by adding replacing the current argument tuple with a two-tuple
containing the array of control qubits as the first element and a tuple of
the remaining arguments as the second tuple.

For instance, if the base callable expects an argument tuple
`{ %TupleHeader, i64, %Qubit* }`, then the `Controlled` version expects
`{ %TupleHeader, %Array*, { %TupleHeader, i64, %Qubit* }* }`, and the twice-`Controlled`
version expects
`{ %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, i64, %Qubit* }* }* }`.
The "ctl" implementation function always expects
`{ %TupleHeader, %Array*, { %TupleHeader, i64, %Qubit* }* }`.
Thus, if the controlled count is greater than 1,
`__quantum__rt__callable_invoke` needs to disassemble the argument tuple,
concatenate the control qubit arrays, and form the expected argument tuple.

One additional complexity is that the above is modified slightly if the base
callable expects an argument tuple with exactly one element.
In this case, the `Controlled` version expects a two-element tuples as
above, but with the actual base argument as the second element.
For instance, if the base callable expects `{ %TupleHeader, %Qubit* }`,
the singly-`Controlled` version expects `{ %TupleHeader, %Array*, %Qubit* }`
rather than `{ %TupleHeader, %Array*, { %TupleHeader, %Qubit* }* }`.
This means that the second element of the singly-`Controlled` argument tuple
is not always a pointer to a struct, and in particular may have variable length
up to the size of a `%Range`.

To resolve this, `__quantum__rt__callable_invoke` needs to have access to the
length of the inner argument tuple once it has unwrapped down to that point.
This could be stored in the `%TupleHeader` by `__quantum__rt__tuple_create`,
or it could be provided by the classical runtime from the length originally
provided for the heap allocation.

The "ctl" implementation function can't do this manipulation itself because
it doesn't have access to the controlled count and so can't tell what the actual
argument tuple's structure is.
Similarly, while the calling code knows the exact signature, it also doesn't
have access to the controlled count, and so can't unambiguously determine the
expected argument tuple; specifically, it can't tell if an inner tuple is the
result of an application of `Controlled` or just part of the base signature.

#### Implementing Lambdas

The language-specific compiler should generate a new top-level callable of the
appropriate type with implementation provided by the anonymous body of the lambda;
this is known as "lifting" the lambda. 
A unique name should be generated for this callable.
Lifted callables can support functors, just like any other callable.
The language-specific compiler is responsible for determining the set of functors
that should be supported by the lifted callable and generating code for them accordingly.

At the point where a lambda is created as a value in the code, a new callable data
structure should be created with the appropriate contents.
Any values referenced inside the lambda that are defined in a scope external to the
lambda should be added to the lambda's capture tuple.
The language-specific compiler is responsible for having references within the lambda
to the captured values refer to the capture tuple.

#### Implementing Partial Application and Currying

Partial application and currying are alternative forms of closures; that is, both create a
lambda values, although the source syntax is different from a lambda expression.

Partial applications and curried functions should be rewritten into lambdas by the
language-specific compiler.
The lambda body may need to include additional code that performs argument tuple
construction before calling the underlying callable.

### External Callables

Callables may be specified as external; that is, they are declared in the
quantum source, but are defined in an external component that is statically
or dynamically linked with the compiled quantum code.
Such callables are also sometimes referred to as "intrinsic".

In particular, the quantum instruction set supported by a particular target
should be represented as a set of external callables.

The source compiler should generate appropriate LLVM declarations for any
external callables referred to by the generated code.
Declarations for other external callables can be included if desired.

Generating the proper linkage is the responsibility of the target-specific
compilation phase.

### Generics

QIR does not provide support for generic or type-parameterized callables.
It relies on the language-specific compiler to generate a new, uniquely-named
callable for each combination of concrete type parameters.
The LLVM representation treats these generated callables as the actual
callables to generate code for; the original callables with open type
parameters are not represented in LLVM.

### Runtime Functions

The following functions are provided by the classical runtime to support
callable values:

| Function                        | Signature                                  | Description |
|---------------------------------|--------------------------------------------|-------------|
| __quantum__rt__callable_create  | `%Callable*([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]*, %TupleHeader*)` | Initializes the callable with the provided function table and capture tuple. The capture tuple pointer should be null if there is no capture. |
| __quantum__rt__callable_copy    | `%Callable*(%Callable*)`             | Initializes the first callable to be the same as the second callable. |
| __quantum__rt__callable_invoke  | `void(%Callable*, %TupleHeader*, %TupleHeader*)` | Invokes the callable with the provided argument tuple and fills in the result tuple. |
| __quantum__rt__callable_make_adjoint | `void(%Callable*)`                         | Updates the callable by applying the Adjoint functor. |
| __quantum__rt__callable_make_controlled | `void(%Callable*)`                      | Updates the callable by applying the Controlled functor. |
| __quantum__rt__callable_reference | `void(%Callable*)`                      | Indicates that a new reference has been added. |
| __quantum__rt__callable_unreference | `void(%Callable*)`                      | Indicates that an existing reference has been removed and potentially releases the callable value. |

For all of these other than `reference` and `unreference`, if a null
`%Callable*` is passed in, a runtime failure should result.
It is expected that the `%TupleHeader*` parameters to `invoke` may be null
if the callable either takes no arguments or returns `Unit`.

---
_[Back to index](README.md)_
