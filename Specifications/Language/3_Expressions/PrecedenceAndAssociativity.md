# Precedence and Associativity

Precedence and associativity define the order in which operators are applied. Operators with higher precedence will be bound to their arguments (operands) first, while operators with the same precedence will bind be bound in the direction of their associativity. 
For example, the expression `1+2*3` according to the precedence for addition and multiplication is equivalent to `1+(2*3)`, and `2^3^4` equals `2^(3^4)` since exponentiation is right-associative. 

## Operators

The following table lists the available operators, as well as their precedence and associativity. 
Additional modifiers and combinators are listed further below and bind tighter than any of these operators. 

| Description | Syntax | Operator | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| [copy-and-update operator](xref:microsoft.quantum.qsharp.copyandupdateexpressions#copy-and-update-expressions) | `w/` `<-` | ternary | left  | 1  |
| [range operator](xref:microsoft.quantum.qsharp.valueliterals#range-literals) | `..` | infix | left | 2 |
| [conditional operator](xref:microsoft.quantum.qsharp.conditionalexpressions#conditional-expressions) | `?` `\|` | ternary | right | 5 |
| [logical OR](xref:microsoft.quantum.qsharp.logicalexpressions#logical-expressions) | `or` | infix | left | 10 |
| [logical AND](xref:microsoft.quantum.qsharp.logicalexpressions#logical-expressions) | `and` | infix | left | 11 |
| [bitwise OR](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `\|\|\|` | infix | left | 12 |
| [bitwise XOR](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `^^^` | infix | left | 13 |
| [bitwise AND](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `&&&` | infix | left | 14 |
| [equality](xref:microsoft.quantum.qsharp.comparativeexpressions#equality-comparison) | `==` | infix | left | 20 |
| [inequality](xref:microsoft.quantum.qsharp.comparativeexpressions#equality-comparison) | `!=` | infix | left | 20 |
| [less-than-or-equal](xref:microsoft.quantum.qsharp.comparativeexpressions#quantitative-comparison) | `<=` | infix | left | 25 |
| [less-than](xref:microsoft.quantum.qsharp.comparativeexpressions#quantitative-comparison) | `<` | infix | left | 25 |
| [greater-than-or-equal](xref:microsoft.quantum.qsharp.comparativeexpressions#quantitative-comparison) | `>=` | infix | left | 25 |
| [greater-than](xref:microsoft.quantum.qsharp.comparativeexpressions#quantitative-comparison) | `>` | infix | left | 25 |
| [right shift](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `>>>` | infix | left | 28 |
| [left shift](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `<<<` | infix | left | 28 |
| [addition](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) or [concatenation](xref:microsoft.quantum.qsharp.concatenationexpressions#concatenation) | `+` | infix | left | 30 |
| [subtraction](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `-` | infix | left | 30 |
| [multiplication](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `*` | infix | left | 35 |
| [division](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `/` | infix | left | 35 |
| [modulus](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `%` | infix | left | 35 |
| [exponentiation](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `^` | infix | right | 40 |
| [bitwise NOT](xref:microsoft.quantum.qsharp.bitwiseexpressions#bitwise-expressions) | `~~~` | prefix | right | 45 |
| [logical NOT](xref:microsoft.quantum.qsharp.logicalexpressions#logical-expressions) | `not` | prefix | right | 45 |
| [negative](xref:microsoft.quantum.qsharp.arithmeticexpressions#arithmetic-expressions) | `-` | prefix | right | 45 |


Copy-and-update expressions necessarily need to have the lowest precedence to ensure a consistent behavior of the corresponding [evaluate-and-reassign statement](xref:microsoft.quantum.qsharp.variabledeclarationsandreassignments#evaluate-and-reassign-statements). 
Similar considerations hold for the range operator to ensure a consistent behavior of the corresponding [contextual expression](xref:microsoft.quantum.qsharp.contextualexpressions#contextual-and-omitted-expressions).

## Modifiers and Combinators

Modifiers can be seen as special operators that can be applied to certain expressions only (see [this section](xref:microsoft.quantum.qsharp.expressions-overview#expressions) for more detail). We can assign them an artificial precedence to capture their behavior. 

This artificial precedence is listed in the table below, which also shows how the precedence of operators and modifiers relates to how tight item access combinators (`[`,`]` and `::` respectively) and call combinators (`(`, `)`) bind.

| Description | Syntax | Operator | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| [Call combinator](xref:microsoft.quantum.qsharp.callstatements#call-statements) | `(` `)` | n/a | left | 900 | 
| [Adjoint functor](xref:microsoft.quantum.qsharp.callstatements#call-statements) | `Adjoint` | prefix | right | 950 |
| [Controlled functor](xref:microsoft.quantum.qsharp.callstatements#call-statements) | `Controlled` | prefix | right | 950 |
| [Unwrap application](xref:microsoft.quantum.qsharp.itemaccessexpression#item-access-for-user-defined-types) | `!` | postfix | left | 1000 |
| [Named item access](xref:microsoft.quantum.qsharp.itemaccessexpression#item-access-for-user-defined-types) | `::` | n/a | left | 1100 |  
| [Array item access](xref:microsoft.quantum.qsharp.itemaccessexpression#array-item-access-and-array-slicing) | `[` `]` | n/a | left | 1100 |

To illustrate the implications of the assigned precedences, suppose we have a unitary operation `DoNothing` as defined in [this section](xref:microsoft.quantum.qsharp.specializationdeclarations#specialization-declarations), a callable `GetStatePrep` that returns a unitary operation, and an array `algorithms` containing items of type `Algorithm` defined as follows

```qsharp
    newtype Algorithm = (
        Register : LittleEndian,
        Initialize : Transformation,
        Apply : Transformation
    );

    newtype Transformation =
        LittleEndian => Unit is Adj + Ctl;
```

where `LittleEndian` is defined in [this section](xref:microsoft.quantum.qsharp.typedeclarations#type-declarations). 
Then the following expressions are all valid: 
```qsharp
    GetStatePrep()(arg)
    (Transformation(GetStatePrep()))!(arg)
    Adjoint DoNothing()
    Controlled Adjoint DoNothing(cs, ())
    Controlled algorithms[0]::Apply!(cs, _)
    algorithms[0]::Register![i]
```
Looking at the precedences defined in the table above, we see that the parentheses around `(Transformation(GetStatePrep()))` are necessary for the subsequent unwrap operator to be applied to the `Transformation` value rather than the returned operation. 
However, parentheses are not required in `GetStatePrep()(arg)`; functions are applied left-to-right, so this expression is equivalent to `(GetStatePrep())(arg)`.
Functor applications also don't require parentheses around them in order to invoke the corresponding specialization. Neither do array or named item access expressions, such that an expression `arr2D[i][j]` is perfectly valid, just like `algorithms[0]::Register![i]` is.


