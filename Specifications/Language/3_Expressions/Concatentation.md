# Concatenation

Concatenations are supported for values of type `String` and arrays. In both cases they are expressed via the operator `+`. 
For instance, `"Hello " + "world!"` evaluates to `"Hello world!"`, and `[1,2,3] + [4,5,6]` evaluates to `[1,2,3,4,5,6]`.

Given two arrays of the same type, the binary operator `+` may be used to form a new array that is the concatenation of the two arrays.

Concatenating two arrays requires that both arrays are of the same type, in contrast to constructing an [array literal](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ValueLiterals.md#array-literals) where a common base type for all array items is determined. This is due to the fact that arrays are treated as [invariant](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SuptypingAndVariance.md). The type of the entire expression matches the type of the operands.
