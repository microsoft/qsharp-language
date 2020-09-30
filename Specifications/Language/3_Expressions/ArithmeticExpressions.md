# Arithmetic Expressions

Arithmetic operators are addition (`+`), subtraction (`-`), multiplication (`*`), division (`/`), negation (`-`), exponentiation (`^`). 
They can be applied to operands of type `Int`, `BigInt`, or `Double`. Additionally, for integral types (`Int` and `BigInt`) an operator computing the modulus (`%`) is available. 

For binary operators, the type of both operands has to match, except for exponentiation; an exponent for a value of type `BigInt` always has to be of type `Int`. 
The type of the entire expression matches the type of the left operand. 
For exponentiation of `Int` and `BitInt`, the behavior is undefined if the exponent is negative or if it requires more than 32 bits to represent (i.e. it is larger than 2147483647). 

Division and modulus for values of type `Int` and `BigInt` follow the following behavior for
negative numbers:

 `A` | `B` | `A / B` | `A % B`
---------|----------|---------|---------
 5 | 2 | 2 | 1
 5 | -2 | -2 | 1
 -5 | 2 | -2 | -1
 -5 | -2 | 2 | -1

That is, `a % b` will always have the same sign as `a`,
and `b * (a / b) + a % b` will always equal `a`.

Q# does not support any automatic conversions between arithmetic data types - or any other data types for that matter. This is of importance especially for the `Result` data type, and facilitates to restrict how runtime information can propagate. It has the benefit of avoiding accidental errors e.g. related to precision loss. 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
