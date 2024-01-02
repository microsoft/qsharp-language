# Precedence and associativity

Precedence and associativity define the order in which operators are applied. Operators with higher precedence are bound to their arguments (operands) first, while operators with the same precedence bind in the direction of their associativity.
For example, the expression `1+2*3` according to the precedence for addition and multiplication is equivalent to `1+(2*3)`, and `2^3^4` equals `2^(3^4)` since exponentiation is right-associative.

## Operators

The following table lists the available operators in Q#, as well as their precedence and associativity.
Additional [modifiers and combinators](#modifiers-and-combinators) are also listed, and bind tighter than any of these operators.

| Description | Syntax | Operator | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| [copy-and-update operator](xref:microsoft.quantum.qsharp.copyandupdateexpressions#copy-and-update-expressions) | `w/` `<-` | ternary | left  | 1 |
| [range operator](xref:microsoft.quantum.qsharp.valueliterals#range-literals) | `..` | infix | left | 2 |
| [conditional operator](xref:microsoft.quantum.qsharp.conditionalexpressions#conditional-expressions) | `? \|` | ternary | right | 3 |
| [logical OR](xref:microsoft.quantum.qsharp.logicalexpressions#logical-expressions) | `or` | infix | left | 4 |
| [logical AND](xref:microsoft.quantum.qsharp.logicalexpressions#logical-expressions) | `and` | infix | left | 5 |
| [bitwise OR](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `\|\|\|` | infix | left | 6 |
| [bitwise XOR](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `^^^` | infix | left | 7 |
| [bitwise AND](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `&&&` | infix | left | 8 |
| [equality](xref:microsoft.quantum.qsharp.comparativeexpressions#equality-comparison) | `==` | infix | left | 9 |
| [inequality](xref:microsoft.quantum.qsharp.comparativeexpressions#equality-comparison) | `!=` | infix | left | 9 |
| [less-than-or-equal](xref:microsoft.quantum.qsharp.comparativeexpressions#quantitative-comparison) | `<=` | infix | left | 10 |
| [less-than](xref:microsoft.quantum.qsharp.comparativeexpressions#quantitative-comparison) | `<` | infix | left | 11 |
| [greater-than-or-equal](xref:microsoft.quantum.qsharp.comparativeexpressions#quantitative-comparison) | `>=` | infix | left | 11 |
| [greater-than](xref:microsoft.quantum.qsharp.comparativeexpressions#quantitative-comparison) | `>` | infix | left | 11 |
| [right shift](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `>>>` | infix | left | 12 |
| [left shift](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `<<<` | infix | left | 12 |
| [addition](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) or [concatenation](xref:microsoft.quantum.qsharp.concatenationexpressions#concatenation) | `+` | infix | left | 13 |
| [subtraction](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `-` | infix | left | 13 |
| [multiplication](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `*` | infix | left | 14 |
| [division](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `/` | infix | left | 14 |
| [modulus](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `%` | infix | left | 14 |
| [exponentiation](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `^` | infix | right | 15 |
| [bitwise NOT](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `~~~` | prefix | right | 16 |
| [logical NOT](xref:microsoft.quantum.qsharp.logicalexpressions#logical-expressions) | `not` | prefix | right | 16 |
| [negative](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `-` | prefix | right | 16 |

Copy-and-update expressions necessarily need to have the lowest precedence to ensure a consistent behavior of the corresponding [evaluate-and-reassign statement](xref:microsoft.quantum.qsharp.variabledeclarationsandreassignments#evaluate-and-reassign-statements).
Similar considerations hold for the range operator to ensure a consistent behavior of the corresponding [contextual expression](xref:microsoft.quantum.qsharp.contextualexpressions#contextual-and-omitted-expressions).

## Modifiers and combinators

Modifiers can be seen as special operators that can be applied to certain expressions only. They can be assigned an artificial precedence to capture their behavior.

For more information, see [Expressions](xref:microsoft.quantum.qsharp.expressions-overview#expressions).

This artificial precedence is listed in the following table, along with how the precedence of operators and modifiers relates to how tightly item access combinators (`[`,`]` and `::` respectively) and call combinators (`(`, `)`) bind.

| Description | Syntax | Operator | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| [Call combinator](xref:microsoft.quantum.qsharp.callstatements#call-expressions) | `(` `)` | n/a | left | 17 |
| [Adjoint functor](xref:microsoft.quantum.qsharp.callstatements#call-expressions) | `Adjoint` | prefix | right | 18 |
| [Controlled functor](xref:microsoft.quantum.qsharp.callstatements#call-expressions) | `Controlled` | prefix | right | 18 |
| [Unwrap application](xref:microsoft.quantum.qsharp.itemaccessexpression#item-access-for-user-defined-types) | `!` | postfix | left | 19 |
| [Named item access](xref:microsoft.quantum.qsharp.itemaccessexpression#item-access-for-user-defined-types) | `::` | n/a | left | 20 |  
| [Array item access](xref:microsoft.quantum.qsharp.itemaccessexpression#array-item-access-and-array-slicing) | `[` `]` | n/a | left | 20 |
| [Function lambda](xref:microsoft.quantum.qsharp.closures#lambda-expressions) | `->` | n/a | right | 21 |
| [Operation lambda](xref:microsoft.quantum.qsharp.closures#lambda-expressions) | `=>` | n/a | right | 21 |

To illustrate the implications of the assigned precedences, suppose you have a unitary operation `DoNothing` (as defined in [Specialization declarations](xref:microsoft.quantum.qsharp.specializationdeclarations#specialization-declarations)), a callable `GetStatePrep` that returns a unitary operation, and an array `algorithms` that contains items of type `Algorithm` defined as follows

```qsharp
    newtype Algorithm = (
        Register : LittleEndian,
        Initialize : Transformation,
        Apply : Transformation
    );

    newtype Transformation =
        LittleEndian => Unit is Adj + Ctl;
```

where `LittleEndian` is defined in [Type declarations](xref:microsoft.quantum.qsharp.typedeclarations#type-declarations).

The following expressions, then, are all valid:

```qsharp
    GetStatePrep()(arg)
    (Transformation(GetStatePrep()))!(arg)
    Adjoint DoNothing()
    Controlled Adjoint DoNothing(cs, ())
    Controlled algorithms[0]::Apply!(cs, _)
    algorithms[0]::Register![i]
```

Looking at the precedences defined in the table above, you can see that the parentheses around `(Transformation(GetStatePrep()))` are necessary for the subsequent unwrap operator to be applied to the `Transformation` value rather than the returned operation.
However, parentheses are not required in `GetStatePrep()(arg)`; functions are applied left-to-right, so this expression is equivalent to `(GetStatePrep())(arg)`.
Functor applications also don't require parentheses around them in order to invoke the corresponding specialization, nor do array or named item access expressions. Thus, the expression `arr2D[i][j]` is perfectly valid, as is `algorithms[0]::Register![i]`.


