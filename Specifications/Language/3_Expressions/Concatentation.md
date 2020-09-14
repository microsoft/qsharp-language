# Concatenation

Concatenations are supported for arrays and values of type `String`. 
Even though a common base type for all array items is determined when constructing an array literal, concatenating two arrays requires that both operands are of the exact same type - same as for strings. This is due to the fact that arrays are treated as [invariant](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SuptypingAndVariance.md). The type of the entire expression matches the type of the operands.
