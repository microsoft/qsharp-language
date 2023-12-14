# Item access

Q# supports item access for array items and for items in user defined types. In both cases, the access is read-only; the value cannot be changed without creating a new instance using a [copy-and-update expression](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions).

## Array item access and array slicing

Given an array expression and an expression of type `Int` or `Range`, a new expression may be formed using the array item access operator consisting of `[` and `]`.

If the expression inside the brackets is of type `Int`, then the new expression contains the array item at that index.
For example, if `arr` is of type `Double[]` and contains five or more items, then `arr[4]` is an expression of type `Double`.

If the expression inside the brackets is of type `Range`, then the new expression contains an array of all the items indexed by the specified `Range`. If the `Range` is empty, then the resulting array is empty.
For example,

```qsharp
let arr = [10, 11, 36, 49];
let ten = arr[0]; // contains the value 10
let odds = arr[1..2..4]; // contains the value [11, 49]
let reverse = arr[...-1...]; // contains the value [49, 36, 11, 10]
```

In the last line of the example, the start and end value of the range have been omitted for convenience. For more information, see [Contextual expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions).

If the array expression is not a simple identifier, it must be enclosed in parentheses in order to extract an item or a slice.
For instance, if `arr1` and `arr2` are both arrays of integers, an item from the concatenation would be expressed as `(arr1 + arr2)[13]`. For more information, see [Precedence and associativity](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#precedence-and-associativity).

All arrays in Q# are zero-based, that is, the first element of an array `arr` is always `arr[0]`.
An exception is thrown at runtime if the index or one of the indices used for slicing is outside the bounds of the array, for example, if it is less than zero or larger or equal to the length of the array.

## Item access for user-defined types

(For more information about how to define custom types containing one or more named or anonymous items, see [Type declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md#type-declarations)).

The contained items can be accessed via their name or by deconstruction, illustrated by the following statements that may be used as part of an operation or function implementation:

```qsharp
    let complex = Complex(1., 0.); // create a value of type Complex
    let (re, _) = complex!;       // item access via deconstruction
    let im = complex::Imaginary;  // item access via name
```

The item access operator (`::`) retrieves named items, as illustrated by the following example:

```qsharp
newtype TwoStrings = (str1 : String, str2 : String);

operation LinkTwoStrings(str : TwoStrings) : String {
    let s1 = str::str1;
    let s2 = str::str2;
    return s1 + s2;
}
```

While named items can be accessed by their name or via deconstruction, anonymous items can only be accessed by the latter. Since deconstruction relies on all of the contained items, the use of anonymous items is discourage when these items need to be accessed outside the compilation unit in which the type is defined.

Access via deconstruction makes use of the unwrap operator (`!`). The unwrap operator returns a tuple of all contained items, where the shape of the tuple matches the one defined in the declaration, and a single item tuple is equivalent to the item itself (see [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md#singleton-tuple-equivalence)).

For example, for a value `nested` of type `Nested` that is defined as follows

```qsharp
newtype Nested = (Double, (ItemName : Int, String));
```

the expression `nested!` return a value of type `(Double, (Int, String))`.

The `!` operator has lower [precedence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#modifiers-and-combinators) than both item access operators, but higher precedence than any other operator. For a complete list of precedences, see [Precedence and associativity](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#precedence-and-associativity).

← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
