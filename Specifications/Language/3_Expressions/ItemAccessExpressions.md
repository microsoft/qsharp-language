# Item Access 

Q# supports item access for array items and for items in user defined types. In both cases, the access is read-only, i.e. the value cannot be changed without creating a new instance using a [copy-and-update expression](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions).

## Array Item Access and Array Slicing

Given an array expression and an expression of type `Int` or `Range`, a new expression may be formed using the array item access operator consisting of `[` and `]`. 

If the expression inside the brackets is of type `Int` then the new expression will contain the array item at that index.   
For instance, if `arr` is of type `Double[]` and contains five or more items, then `arr[4]` is an expression of type `Double`. 

If the expression inside the brackets is fo type `Range` then the new expression will contain an array of all items indexed by the specified `Range`. If the `Range` is empty, then the resulting array will be empty.   
For instance, 
```qsharp
let arr = [10, 11, 36, 49];
let ten = arr[0]; // contains the value 10
let odds = arr[1..2..4]; // contains the value [11, 49]
let reverse = arr[...-1...]; // contains the value [49, 36, 11, 10]
```
In the last line, the start and end value of the range have been omitted for convenience; see [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions) for more detail. 

If the array expression is not a simple identifier, it must be enclosed in parentheses in order to extract an item or a slice, see also the section on [precedence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#precedence-and-associativity).
For instance, if `arr1` and `arr2` are both arrays of integers, an item from the concatenation would be expressed as `(arr1 + arr2)[13]`.

All arrays in Q# are zero-based. That is, the first element of an array `arr` is always `arr[0]`. 
An exception will be thrown at runtime if the index or one of the indices used for slicing is outside the bounds of the array, i.e. if it is less than zero or larger or equal to the length of the array.

## Item Access for User Defined Types

[This section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md#type-declarations) describes how to define custom types, containing one or more named or anonymous items. 

The contained items can be accessed via their name or by deconstruction, illustrated by the following statements that may be used as part of a operation or function implementation:

```qsharp
    let complex = Complex(1.,0.); // create a value of type Complex
    let (re, _) = complex!;       // item access via deconstruction
    let im = complex::Imaginary;  // item access via name
```

The item access operator (`::`) retrieves named items. For example, it can be used to unpack a newtype operation parameter in a neater way than with individual item extraction: 

```qsharp
newtype TwoStrings = (str1: String, str2: String);

operation LinkTwoStrings(str : TwoStrings) : String {
    let s1 = str::str1;
    let s2 = str::str2:
    return s1 + s2;
}
```
While named items can be accessed by their name or via deconstruction, anonymous items can only be accessed by the latter. Since deconstruction relies on all of the contained items, the usage anonymous items is discourage when these items need to be accessed outside the compilation unit in which the type is defined. 

Access via deconstruction makes use of the unwrap operator (`!`). That operator will return a tuple of all contained items, where the shape of the tuple matches the one defined in the declaration, and a single item tuple is equivalent to the item itself (see [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md#singleton-tuple-equivalence)).  

For example, for a value `nested` of type `Nested` defined as follows
```qsharp
newtype Nested = (Double, (ItemName : Int, String)); 
```
the expression `nested!` return a value of type `(Double, (Int, String))`. 

The `!` operator has lower [precedence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#modifiers-and-combinators) than both item access operators, but higher precedence than any other operator. A complete list of precedences can be found [here](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#precedence-and-associativity). 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
