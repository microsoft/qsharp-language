# Arithmetic Expressions

Arithmetic operators are addition, subtraction, multiplication, division, negation, exponentiation. 
They can be applied to operands of type `Int`, `BigInt`, or `Double`. Additionally, for integral types (`Int` and `BigInt`) an operator computing the modulus is available. For binary operators, the type of both operands has to match, expect for exponentiation; an exponent for a value of type `BigInt` always has to be of type `Int`. The type of the entire expression matches the type of the left operand. 

Currently, Q# does not support any automatic conversions between arithmetic data types -- or any other data types for that matter. This has the benefit of avoiding accidental errors, but also constitutes an inconvenience. While certain data types such as `Result` are used to restrict how runtime information can propagate and hence likely will never be automatically cast, we may revise the casting and conversion behavior between other data types such as, e.g., between `Int` and `Double` in the future.  
