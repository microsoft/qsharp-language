# Closures

Closures are callables that capture variables from the enclosing environment.
Both function and operation closures can be created.
An operation closure can be created inside a function, but it can only be applied in an operation.

Q# has two mechanisms for creating closures: lambda expressions and partial application.

## Lambda expressions

A lambda expression creates an anonymous function or operation.
The basic syntax is a symbol tuple to bind the parameters, an arrow (`->` for a function and `=>` for an operation), and an expression to evaluate when applied.

```qsharp
// Function that captures 'x':
y -> x + y

// Operation that captures 'qubit':
deg => Rx(deg * PI() / 180.0, qubit)

// Function that captures nothing:
(x, y) -> x + y
```

### Parameters

Parameters are bound using a symbol tuple that is identical to the left-hand side of a [variable declaration statement](xref:microsoft.quantum.qsharp.variabledeclarationsandreassignments).
The type of the parameter tuple is implicit.
Type annotations are not supported; if type inference fails, you may need to create a top-level callable declaration and use partial application instead.

### Mutable capture variables

Mutable variables cannot be captured.
If you only need to capture the value of a mutable variable at the instant the lambda expression is created, you can create an immutable copy:

```qsharp
// ERROR: 'variable' cannot be captured.
mutable variable = 1;
let f = () -> variable;

// OK.
let value = variable;
let g = () -> value;
```

### Characteristics

The characteristics of an anonymous operation are inferred based on the applications of the lambda. If the lambda is used with a functor application, or in a context that expects a characteristic, the lambda is then inferred to have that characteristic.
For example:

```qsharp
operation NoOp(q : Qubit) : Unit is Adj {}
operation Main() : Unit {
    use q = Qubit();
    let foo = () => NoOp(q);
    foo(); // Has type Unit => Unit with no characteristics

    let bar = () => NoOp(q);
    Adjoint bar(); // Has type Unit => Unit is Adj
}
```

If you need different characteristics for an operation lambda than what was inferred, you will need to create a top-level operation declaration instead.

## Partial application

Partial application is a convenient shorthand for applying some, but not all, of a callable's arguments.
The syntax is the same as a call expression, but unapplied arguments are replaced with `_`.
Conceptually, partial application is equivalent to a lambda expression that captures the applied arguments and takes in the unapplied arguments as parameters.

For example, given that `f` is a function and `o` is an operation, and the captured variable `x` is immutable:

| Partial application    | Lambda expression                     |
| ---------------------- | ------------------------------------- |
| `f(x, _)`              | `a -> f(x, a)`                        |
| `o(x, _)`              | `a => o(x, a)`                        |
| `f(_, (1, _))`         | `(a, b) -> f(a, (1, b))`[^1]          |
| `f((_, _, x), (1, _))` | `((a, b), c) -> f((a, b, x), (1, c))` |

### Mutable capture variables

Unlike lambda expressions, partial application can automatically capture a copy of the value of a mutable variable:

```qsharp
mutable variable = 1;
let f = Foo(variable, _);
```

This is equivalent to the following lambda expression:

```qsharp
mutable variable = 1;
let value = variable;
let f = x -> Foo(value, x);
```

---



[^1]: The parameter tuple is strictly written `(a, (b))`, but [`(b)` is equivalent to `b`](xref:microsoft.quantum.qsharp.singletontupleequivalence).
