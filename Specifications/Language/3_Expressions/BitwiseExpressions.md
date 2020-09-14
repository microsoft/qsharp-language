# Bitwise Expressions

Bitwise operators are expressed as three non-letter characters. 
In addition to bitwise versions for *AND*, *OR*, and *NOT*, a bitwise *XOR* exists as well. 
They expect operands of type `Int` or `BigInt`, and for binary operators, the type of both operands has to match. The type of the entire expression equals the type of the operand(s). 

Additionally, left- and right-shift operators exist, multiplying or dividing the given left-hand-side (lhs) expression by powers of two. The expression `lhs <<< 3` shifts the bit representation of `lhs` by three, meaning `lhs` is multiplied by `2^3`, provided that is still within the valid range for the data type of `lhs`. The lhs may be of type `Int` or `BigInt`. The right-hand-side expression always has to be of type `Int`. The resulting expression will be of the same type as the lhs operand. 
