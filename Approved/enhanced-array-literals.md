---
title: Enhanced array literals and removal of default-initialized array constructors
description: Array literals are enhanced to support empty and repeated constant arrays, and the default-initialized array constructor `new Type[n]` is removed.
author: Sarah Marshall
date: December 21, 2020
---

# Proposal

* The empty array literal, `[]`, is supported.
* The repeated constant array literal, `[x, size = n]`, is added.
* The default-initialized `new Type[n]` array constructor is deprecated and will be removed in the next major version of Q#.
  With it, the concept that every type has a default value is also deprecated and will be removed.

# Justification

## Removing default-initialized array constructors

The `new Type[n]` array constructor has two issues:

1. The `new` keyword is not used anywhere else in Q#.
   Its use with default-initialized arrays is inconsistent with other type constructors.
2. It requires every type to have a default value with which to initialize each item in the array.

### Default values

It is not possible to define reasonable default values of types like `Qubit` and `a -> b`.
Their current default values are invalid and will trigger an error if they are used.
But the syntax is the same both for types with valid default values, and those without: while `new Int[3]` is a well-defined value whose items can be used safely, `new Qubit[3]` creates a trap that will crash the program if any item in the array is used before being set to a valid value first.

This assumption is also invalid for uninhabited types such as `Void` in other languages.
If Q# requires that every type has a default value, then uninhabited types are not possible to express properly.
This can even cause subtle bugs in the soundness of a type system, as demonstrated by [this bug in Java's generics](https://hackernoon.com/java-is-unsound-28c84cb2b3f) that happened because of the existence of a value (specifically `null`) for a type that should have been uninhabited.

Removing default-initialized array constructors, and the requirement that every type has a default value, resolves these problems.

## Enhancing array literals

With the removal of default-initialized array constructors, alternatives are needed to create empty arrays and arrays with a repeated initial value.
The alternative for `new T[n]` is `[x, size = n]`, where `x` is the initial value of each item.
In the case where `n` = 0, the alternative for `new T[0]` is `[]`.

# Description

## Current Status

Q# currently supports this syntax:

```qsharp
// Create an empty array of type Int[].
let empty = new Int[0];

// Create an array of length 10 of type Bool[] where every value is false.
let bools = new Bool[10];
```

## Proposed Modification

The syntax above will be deprecated and removed.
It is replaced by the constructs described below.

### Empty arrays

The empty array literal, `[]`, will be supported.
Unlike `new T[0]`, this literal does not specify the type of the array to be created.
Its type will be inferred based on its first usage.

```qsharp
function SumI(xs : Int[]) : Int {
    return Fold(PlusI, 0, xs);
}

function SumD(xs : Double[]) : Int {
    return Fold(PlusD, 0.0, xs);
}

function Example() : Unit {
    // The type of [] is inferred to be Int[] based on its position as the argument to SumI.
    let x = SumI([]);

    // The type of empty1 is inferred to be Int[] based on its position as the argument to SumI.
    let empty1 = [];
    let y = SumI(empty1);

    // The following line contains a compilation error, because empty1 is of type Int[], not
    // Double[].
    let z = SumD(empty1);

    // Since empty2 is not used, its type cannot be inferred.
    // This is a compilation error.
    let empty2 = [];

    // While empty3 is used, its usage does not provide any information about its concrete type.
    // This is a compilation error.
    let empty3 = [];
    Message($"Empty array: {empty3}");

    // In cases where the type of [] cannot be inferred, either [x, size = 0] or
    // Microsoft.Quantum.Arrays.EmptyArray can be used instead.
    // The following code is valid.
    let empty4 = [0, size = 0];
    let empty5 = EmptyArray<Int>();
    Message($"Empty Int arrays: {empty4}, {empty5}");
}
```

### Repeated constant arrays

The semantics of `[x, size = n]` are identical to `new T[n]`, except that the initial value is now given by `x`:

1. `n` is an expression of type `Int`.
2. If `n` is negative, a runtime error occurs.

```qsharp
// Create an array of length 10 of type Bool[] where every value is false.
let bools = [false, size = 10];

// The following examples are syntax errors:
let wrong1 = [size = 10, false];
let wrong2 = [false, true, size = 10];
let wrong3 = [false, size = 10, true];
```

# Implementation

The implementation of `[x, size = n]` should be a relatively straightforward extension of the current implementation for `new T[n]`.
It will require parser and syntax tree changes, as well as changes to code generation and potentially a small amount of runtime support.

The implementation for `[]` will require enhancements to type inference.
One possible approach is to create a placeholder type variable for each usage of `[]`.
When an expression with a placeholder type variable is used in a context that requires a specific type, this context can refine the placeholder type.
Once all placeholders are refined, they can be replaced with their concrete types if one was determined.
Since all specialization signatures must have explicit parameter and return types, the type inference for a placeholder variable cannot extend beyond its containing specialization.

## Timeline

The bulk of the work is expected to be in implementing type inference for the empty array literal.
However, since it is limited to only the empty array literal, and bounded by the scope of a specialization, the complexity should be managable within a month or two of work.
The remaining work of adding repeated constant array literals and deprecating the old array literals should not take much time.

# Further Considerations

## Related Mechanisms

The syntax for allocating arrays of qubits is similar to the existing default-initialized array constructor syntax:

```qsharp
use qs = Qubit[n];
```

For consistency, it may make sense to change this syntax as well.
The [proposal for allocatable types and generalization of initializers](https://github.com/microsoft/qsharp-language/pull/41) is addressing this.

## Impact on Existing Mechanisms

The [`Default`](https://docs.microsoft.com/en-us/qsharp/api/qsharp/microsoft.quantum.core.default) function depends on default-initialized array constructors, and it will also be deprecated.

## Anticipated Interactions with Future Modifications

### Named arguments

The syntax for repeated constant arrays is designed to be similar to the syntax for named arguments, a feature that Q# does not currently support (and for which there is currently no suggestion or proposal).
This proposal makes the assumption that the syntax for named arguments, if Q# supports them, will be:

```qsharp
Foo(firstArgument, secondArgument, namedArgument = "foo");
```

### Type inference

In the future, the type inference used for empty array literals may be extended to all expressions, allowing calls to polymorphic functions where not all type variables are determined by their arguments.

### Partial application

We may want to consider supporting partial application for array literals in the future:

```qsharp
let f = ["foo", size = _];
// f : Int -> String[]
// f(3) == ["foo", "foo", "foo"]

let g = [_, size = 3];
// g : 'a -> 'a[]
// g("foo") == ["foo", "foo", "foo"]

let h = [_, "middle", _];
// h : (String, String) -> String[]
// h("first", "last") == ["first", "middle", "last"]
```

### Multidimensional arrays

The array literals in this proposal can be extended to support multidimensional arrays.
See the [𝑛-d array proposal](https://github.com/microsoft/qsharp-language/pull/49).

Empty multidimensional arrays can be created with `#[]` for 2D, `##[]` for 3D, etc.
(Note: this syntax is still subject to change.)

Both multidimensional and nested (jagged) arrays could be created with the repeated constant array literal syntax.
For example, `#[0, size = (2, 2)]` could create a 2x2 multidensional array, while `[[0, size = 2], size = 2]` could create a 2x2 nested array.
This is why the more general term `size` is used here instead of `length`.

### Array comprehensions

Another possible enhancement to array literals is support for array comprehensions.
This would complement repeated constant array literals, and could be used in conjunction with them.
For example:

```qsharp
// An array containing the first 10 squares.
[x * x for x in 1 .. 10]

// An array containing arrays of the first 10 squares.
[[x * x for x in 1 .. 10], size = 3]
```

## Alternatives

The new syntax for empty arrays and repeated constant arrays is not strictly necessary.
The standard library functions `EmptyArray` and `ConstantArray` provide this functionality already.
However, the new syntax is more concise.

# Raised Concerns

While the new syntax for repeated constant arrays is designed to be similar to a more general syntax for named arguments, its use in array literals is a special case that needs to specifically be added to the Q# grammar.
This special case adds additional complexity to array literals, especially when potentially combined with array comprehensions in the future.
However, it only provides a small benefit to conciseness compared to traditional syntax like `ConstantArray(n, x)`.

By adding special support for constant array syntax to the compiler, it makes it possible to add non-standard handling of types that can't be expressed in Q#'s type system, like what is currently done for arithmetic operators.
For simplicity and to avoid problems with type inference and partial application in the future, we should be careful to avoid behavior that can't be expressed by the current type system or by future extensions to the type system.
In particular, we should be careful about supporting expressions like `[0, size = 3] : Int[]` and `[0, size = (2, 3)] : Int[][]`, where the type of the resulting array is determined by the arity of the `size` tuple, since overloading on tuple arity is difficult to support in the type system.
