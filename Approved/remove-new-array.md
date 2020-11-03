---
title: Remove default-initialized new array expressions
description: The `new Type[N]` array expression is deprecated and removed from Q#.
author: Sarah Marshall
date: November 3, 2020
---

# Proposal

The `new Type[N]` expression, which creates an array of `N` values using the default value of `Type`, will be deprecated and removed from Q#.
With the exception of the empty array, creating an array requires that the value of each item is given explicitly by the user; arrays are no longer initialized implicitly using default values.
With the removal of `new Type[N]`, the concept of each type having a default value will also be removed from Q#.

# Justification

The existence of `new Type[N]` has negative effects on the language.

The most important negative effect is the assumption that every type has a default value.
This is not a reasonable assumption, because it is not possible to define useful default values of types like `Qubit` and `a -> b`.
Their current default values are invalid and will trigger an error if they are used.
But the syntax is the same both for types with valid default values, and those without, which is misleading: while `new Int[3]` is a well-defined value whose items can be used safely, `new Qubit[3]` creates a potential trap that will crash the program if any item in the array is used before being set to a valid value first.

This assumption is also invalid in the presence of uninhabited types such as `Void`.
If Q# requires that every type has a default value, then uninhabited types are not possible to express properly.
This can even cause subtle bugs in the soundness of a type system, as demonstrated by [this bug in Java's generics](https://hackernoon.com/java-is-unsound-28c84cb2b3f) that happened because of the existence of a value (specifically `null`) for a type that should have been uninhabited.

Finally, the use of the `new` keyword is inconsistent with other ways to create values in Q#.
`new` is required only when creating a default-initialized array, not when using a square bracket array literal or when creating values of other types.

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

The syntax above will be removed.
The same functionality can be accomplished with functions in the standard library:

```qsharp
// Create an empty arra of type Int[].
let empty = EmptyArray<Int>();

// Create an array of length 10 of type Bool[] where every value is false.
let bools = ConstantArray(10, false);
```

# Implementation

The `new Type[N]` syntax can be deprecated and removed with the next major version of Q#.

The library functions `EmptyArray` and `ConstantArray` are already present in the `Microsoft.Quantum.Arrays` namespace of the standard library.
Since the only built-in way to create an empty array was `new Type[0]`, `EmptyArray` must be intrinsic; however, this is already the case, so no additional work is needed.

While `ConstantArray` can be written in pure Q# using array concatenation, this is not the most efficient implementation.
A native implementation of `ConstantArray` should be added that allocates the whole array before initializing the items with the given value.
The pure Q# implementation should remain as a fallback in case the native implementation is not available.

## Timeline

N/A

# Further Considerations

## Related Mechanisms

N/A

## Impact on Existing Mechanisms

N/A

## Anticipated Interactions with Future Modifications

Improved type inference will allow the empty array to be expressed as `[]` instead of `EmptyArray<a>()`.

## Alternatives

N/A

# Raised Concerns

N/A
