---
description: Provides more convenient syntax for allocating qubits.
author: Sarah Marshall
date: 2020-10-29
---

# QEP 4: Support for Lambda Expressions

## Proposal

This proposal introduces a new kind of expression that constructs an anonymous
callable, which we refer to as a "lambda" in this proposal. A lambda can be
either a function or an operation, but cannot be type parametrized.

A lambda expression consists of a symbol or a symbol tuple, followed by either
an `->` in the case of a lambda function or an `=>` in the case of a lambda
operation, and a single expression that defines the value that is returned when
the lambda is invoked. Custom implementations for adjoint and controlled
versions cannot be defined as part of a lambda expression.

## Justification

The current mechanism of constructing anonymous callables locally is [partial
application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PartialApplication.md).
While rather powerful, it requires a declaration at a global scope based on
which new callables can be constructed locally. The suggested lambda expressions
would allow to avoid having to declare a callable specifically to construct a
suitable anonymous callable via partial applications. Example 1 in the section
on the [current status](#current-status) illustrates this based on an example from the [standard
libraries](https://github.com/microsoft/QuantumLibraries/blob/main/Standard/src/Canon/Combinators/Curry.qs).


## Description

The signature of the lambda, including its input type, return type and
characteristics, are inferred based on usage. The necessary functor support is
automatically created by the compiler. Example 1 in the section on the [proposed
modification](#proposed-modification) illustrates this.


For more details, see the
section on [implementation](#implementation).

... see example...

In the second case for the initially suggested introduction of lambda expressions as suggested in this proposal, the operation `f` will have to be declared as a (internal) global callable, as it is the case with the current language support. In the future we may choose to remove that need by introducing e.g. support to add type annotations to expressions. That should be worked out in a separate proposal as a related feature.

Local bindings in Q# are at this time never recursive. That means that in particular that something like the following is not supported:

```qsharp
operation NotValid1 (q : Qubit) : Unit {

    let f = arg -> f(arg, 1);
}
```

As long as Q# does not support recursive types or recursive local bindings, which it currently doesn't, it is not possible for lambdas to ever be recursive whether explicitly or implicitly.

```qsharp
operation NotValid (q : Qubit) : Unit {

    let f = (f, x) -> x > 0 ? f(f, x - 1) + f(f, x - 2) | 1;
    let g = f(f, _);
}
```


All immutable variables that are in scope when the lambda is defined may be used within the body of the lambda; variables used in this way are captured by the definition of the lambda. Like partial applications, they can capture qubits, and variables are captured by value when the lambda is defined. Lambdas cannot capture mutable variables.
The expression that defines the body of the lambda is evaluated every time that the lambda is called.

mutable a = 1;
let pa = Foo(a, _);
set a += 1;
pa(1); // what is Foo called with Foo(1, 1)

The call combinator has higher precedence than the lambda construction, meaning `a => b()` is the same as `a => (b())` opposed to `(a => b)()`.

The same shadowing rules apply to the symbols declared as part of the lambda expression as for all other symbol declarations in Q#. Note that since the symbols are not valid past the evaluation of the lambda, the following is valid as long as no symbol named `f` is already in scope: `let f = f => f();`


TBD: to be supported

```qsharp
use q = Qubit();
let f = op => op(q);
Adjoint f(X); // error
```

partial application of lambdas...

### Current Status

Currently, the only way to define a callable locally is by supplying some but
not all of the arguments to a globally defined callable. There is no mechanism
to create a new callable that makes use of operators, modifiers and combinators
in Q#. The QDK libraries hence contain a many internal callable declarations that
serve the sole purpose of defining the implementation for callables returned by
by another public callable.

#### Examples

Example 1: <br/>
The function `WithFirstInputApplied` is declared purely to construct a suitable function to return in `CurriedOp` via partial application. This additional global declaration becomes unnecessary if lambda expressions are available.

```qsharp
    internal function WithFirstInputApplied<'T, 'U> (
        op : ('T, 'U) => Unit, arg1 : 'T) : ('U => Unit) {
        return op(arg1, _);
    }

    function CurriedOp<'T, 'U> (
        op : (('T, 'U) => Unit)) : ('T -> ('U => Unit)) {
        return WithFirstInputApplied(op, _);
    }
```

Example 2: <br/>
Library methods that take a callable value as argument, such as the function [`Mapped`](https://github.com/microsoft/QuantumLibraries/blob/6f41efc6fcac82a3b24bf8252859bf640c0f9280/Standard/src/Arrays/Map.qs#L34)
in the standard libraries, can currently only be
invoked if a suitable global declaration for the desired argument exists.

```qsharp
    internal function SquaredItem (value : Int) : Int {
        return value * value;
    }

    function Squares (n : Int) : Int[] {
        let seq = MappedByIndex(Fst, [0, size = n]);  // creates [1,2,..,n]
        return Mapped(SquaredItem, seq);              // returns [1,4,..,n*n]
    }
```

Example 3: <br/>
The use case in Example 2 is particularly cumbersome when one wants to leverage
Q# operators since Q# currently does not support type classes or a mechanism
that would permit to constrain a type parameter. The use of the multiplication
operator in the returned expression of the function `SquaredItem` for example is
invalid.

```qsharp
    internal function SquaredItem<'T> (value : 'T) : 'T {
        return value * value; // results in a compilation error
    }

    internal function Squares<'T> (convert : Int -> 'T, n : Int) : 'T[] {
        let seqI = MappedByIndex(Fst, [0, size = n]);
        let seqT = Mapped(convert, seqI);
        return Mapped(SquaredItem, seqT);
    }

    function SquaresL (n : Int) : BigInt[] {
        return Squares(IntAsBigInt, n);
    }

    function SquaresD (n : Int) : Double[] {
        return Squares(IntAsDouble, n);
    }
```

### Proposed Modification

The proposed modification is to introduce a new kind of expression for defining
a new callable locally.

#### Examples

Example 1: <br/>
...

```qsharp
    function CurriedOp<'T, 'U> (
        op : (('T, 'U) => Unit)) : ('T -> ('U => Unit)) {
        return arg1 -> op(arg1, _);
    }
```

Example 2: <br/>
The function `Increment` returns a function that adds `i` to a given value.

```qsharp
function Increment (i : Int) : Int -> Int {
    return a -> a + i; // the input type can be inferred in this case
}
```

Example 3: <br/>
The function `Squares` creates a new array of length `n`,
where the element at index `i` is set to converted to a type `'T` and then squared.

```qsharp
    internal function Squares<'T> (convert : Int -> 'T, n : Int) : 'T[] {
        return MappedByIndex(
            (i, _) -> convert(i) * convert(i),
            [0, size = n]);
    }

    function SquaresL (n : Int) : BigInt[] {
        return Squares(IntAsBigInt, n);
    }

    function SquaresD (n : Int) : Double[] {
        return Squares(IntAsDouble, n);
    }
```

Example 4: <br/>
The input type, return type and characteristics of a lambda are inferred based on first usage.

```qsharp
operation Unitary(q : Qubit) : Unit is Adj + Ctl {}
operation NotUnitary(q : Qubit) : Unit {}

operation Supported (q : Qubit) : Unit {

    let f = op => op(q);
    f(NotUnitary);          // type of op is inferred as Qubit => Unit
    f(Unitary);             // this invocation does not change that type
}

operation NotInitiallySupported (q : Qubit) : Unit {

    let f = op => op(q);
    f(Unitary);
    f(NotUnitary); // this will cause an error
}
```

partially applying lambdas

## Implementation

A new case should be added to the expression kinds to represent a lambda, where the same case covers function and operation lambdas. The added case contains they symbol or symbol tuple, the expression describing its body, as well as whether the lambda is a function or operation. As part of compilation, all lambdas are compiled away by lifting them into the global scope. The captured values are determined as part of that lifting and added to the argument of the callable. Lambdas are hence ultimately replaced by partial applications during compilation.

The proposed type inference for lambdas is the following:
At the time of the lambda creation, first fresh type variables are created for all symbols declared as part of the lambda, then the type of the body is determined, based on which the callable type is determined. For an operation lambda, its characteristics are given by the intersection of the characteristics of all operations called within its body.

When the type of a call expression is inferred, the type of the called expression is inferred to be a callable with an input type that matches the argument type, and a freshly created type variable for the return type. If the call expression is within a function the lambda needs to be a function, too. If the call is within an operation on the other hand, additionally a fresh characteristics variable should be created and added to the constraint for the callable type.


NP-completeness,
clauses from unification

let f = (op1, op2, q) => op1(Adjoint op2(q));


### Timeline

## Further Considerations

We choose to introduce lambda expressions independent on whether we potentially introduce the more general concept of a lambda that may have a statement or statement block as a body. The reasoning is that even if we supported e.g. `a => { statements }`, there is still enough benefit to having a syntactic sugar of `a => a + 1` over requiring to express this as `a => { return a + 1; }` to merit the introduction of a dedicated syntax.

Alternatively, one could consider extending the support for declaring anonymous local callables to include callables with a body that consists of several statements. A dedicated syntax when the body of the anonymous callable merely consists of a single expression allows to define a more concise syntax for this case.

Supporting to construct anonymous local callables with a body that rather than consisting of a single expression consists of a block of statements is to be considered as part of considering related features. A dedicated syntax for the suggested special case potentially introduces a redundant way to express the same functionality in the future. I believe the benefit of having a less verbose way of expressing what I expect to be a very common use case nonetheless merits that in this case.


### Related Mechanisms

```qsharp
operation Example() : Unit {

    mutable const2 = 5;
    // let f2 = (x, y) -> x * y + const2; // not allowed
    set const2 += 1;
    // f2(2, 3);

    let const = 10;
    let f = (x, y) -> x * y + const;

    let g = f(3, _);
    let res = g(5);
}
```

```qsharp

function Lifted((const : Int), (x : Int, y : Int)) : Int {
    return x * y + const;
}

operation Example() : Unit {

    let const = 10;
    let f = Lifted(const, _);
    let g = f(3, _);
    let res = g(5);
}
```

Partial application

maybe related:

support for parameterizations over op characteristics, and are "free" to support once we have type classes?
Next time: need for intersections?

operation Foo (op : 'T => Unit is #C) : Unit is #C * Adj { ... }
operation Foo (op : 'T => Unit is #C + Adj) : Unit is #C { ... }


### Impact on Existing Mechanisms

Adding characteristics parameters ... -> elaborate.

### Anticipated Interactions with Future Modifications

Type annotations for all expressions?
lowest precedence for those

mention lambdas with bodies?

arr w/ 0 <- foo : Int[]
is the same as
(arr w/ 0 <- foo) : Int[]

and
set arr w/= 0 <- foo : Int[];
same as:
set arr = (arr w/ 0 <- foo) : Int[];

Parameterizations over operation characteristic polymorphism...


### Alternatives

Mostly just syntax
Introduce the option to have similar callable declarations locally like they exist globally.

#### Alternative 1: Introduce leading character(s) to clearly mark the start of lambda

#### Alternative 2:

Decided against it:

    The type inference - at least initially - will infer the characteristics of the lambda expression at the time of its creation. That means that the type inference for the characteristic in certain cases may be inferred to be more restrictive than necessary.

    ```qsharp
    use q = Qubit();
    let f = op => op(q);
    Adjoint f(X); // error
    ```

#### Alternative 3:

## Raised Concerns
