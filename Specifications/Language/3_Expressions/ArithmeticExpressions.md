# Arithmetic expressions

Arithmetic operators are addition (`+`), subtraction (`-`), multiplication (`*`), division (`/`), negation (`-`), and exponentiation (`^`). They can be applied to operands of type `Int`, `BigInt`, or `Double`. Additionally, for integral types (`Int` and `BigInt`), an operator computing the modulus (`%`) is available.

For binary operators, the type of both operands must match, except for exponentiation; an exponent for a value of type `BigInt` must be of type `Int`. The type of the entire expression matches the type of the left operand. For exponentiation of `Int` and `BitInt`, the behavior is undefined if the exponent is negative or requires more than 32 bits to represent (that is, if it is larger than 2147483647).

Division and modulus for values of type `Int` and `BigInt` follow the following behavior for
negative numbers:

 `A` | `B` | `A / B` | `A % B`
---------|----------|---------|---------
 5 | 2 | 2 | 1
 5 | -2 | -2 | 1
 -5 | 2 | -2 | -1
 -5 | -2 | 2 | -1

That is, `a % b` always has the same sign as `a`, and `b * (a / b) + a % b` always equals `a`.

Q# does not support automatic conversions between arithmetic data types or any other data types for that matter. This is of importance especially for the `Result` data type and facilitates restricting how runtime information can propagate. It has the benefit of avoiding accidental errors, such as ones related to precision loss.

← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
