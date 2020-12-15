---
title: Enhanced array literals and removal of default-initialized array constructors
description: Array literals are enhanced to support empty and repeated constant arrays, and the default-initialized array constructor `new Type[n]` is removed.
author: Sarah Marshall
date: December 14, 2020
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

This assumption is also invalid for uninhabited types such as `Void`.
If Q# requires that every type has a default value, then uninhabited types are not possible to express properly.
This can even cause subtle bugs in the soundness of a type system, as demonstrated by [this bug in Java's generics](https://hackernoon.com/java-is-unsound-28c84cb2b3f) that happened because of the existence of a value (specifically `null`) for a type that should have been uninhabited.

## Enhancing array literals

With the removal of default-initialized array constructors, alternatives are needed to create empty arrays and arrays with a repeated initial value.
The alternative for `new T[0]` is `[]`.
The alternative for `new T[n]` where `n > 0` is `[x, size = n]`, where `x` is the initial value of each item.

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
The replacement for each case is different.

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

    // The following line contains a compilation error, because empty1 is of type Int[], not Double[].
    let z = SumD(empty1);

    // Since empty2 is not used, its type cannot be inferred.
    // This is a compilation error.
    let empty2 = [];

    // While empty3 is used, its usage does not provide any information about its concrete type.
    // This is a compilation error.
    let empty3 = [];
    Message($"Empty array: {empty3}");

    // In cases where the type of [] cannot be inferred, Microsoft.Quantum.Arrays.EmptyArray can be used instead.
    // The following code is valid.
    let empty4 = EmptyArray<Int>();
    Message($"Empty array: {empty4}");
}
```

### Repeated constant arrays

The semantics of `[x, size = n]` are identical to `new T[n]`, except that the initial value is now given by `x`:

1. `n` may be an integer literal or a variable of integer type.
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

TODO

## Alternatives

TODO

# Raised Concerns

TODO
