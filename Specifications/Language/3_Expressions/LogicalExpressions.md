# Logical expressions

Logical operators are expressed as keywords.
Q# supports the standard logical operators *AND* (`and`), *OR* (`or`), and *NOT* (`not`). Currently, there is not an operator for a logical *XOR*. All of these operators act on operands of type `Bool`, and result in an expression of type `Bool`.
As is common in most languages, the evaluation of *AND* and *OR* short-circuits, meaning if the first expression of *OR* evaluates to `true`, the second expression is not evaluated, and the same holds if the first expression of *AND* evaluates to `false`. The behavior of conditional expressions in a sense is similar, in that only ever the condition and one of the two expressions is evaluated.


