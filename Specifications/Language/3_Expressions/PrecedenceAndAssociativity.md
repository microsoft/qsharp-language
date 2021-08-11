# Precedence and associativity

Precedence and associativity define the order in which operators are applied. Operators with higher precedence are bound to their arguments (operands) first, while operators with the same precedence bind in the direction of their associativity. 
For example, the expression `1+2*3` according to the precedence for addition and multiplication is equivalent to `1+(2*3)`, and `2^3^4` equals `2^(3^4)` since exponentiation is right-associative. 

## Operators

The following table lists the available operators in Q#, as well as their precedence and associativity. 
Additional [modifiers and combinators](#modifiers-and-combinators) are also listed, and bind tighter than any of these operators. 

| Description | Syntax | Operator | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| [copy-and-update operator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions) | `w/` `<-` | ternary | left  | 1  |
| [range operator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ValueLiterals.md#range-literals) | `..` | infix | left | 2 |
| [conditional operator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ConditionalExpressions.md#conditional-expressions) | `?` `\|` | ternary | right | 5 |
| [logical OR](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/LogicalExpressions.md#logical-expressions) | `or` | infix | left | 10 |
| [logical AND](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/LogicalExpressions.md#logical-expressions) | `and` | infix | left | 11 |
| [bitwise OR](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md#bitwise-expressions) | `\|\|\|` | infix | left | 12 |
| [bitwise XOR](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md#bitwise-expressions) | `^^^` | infix | left | 13 |
| [bitwise AND](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md#bitwise-expressions) | `&&&` | infix | left | 14 |
| [equality](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md#equality-comparison) | `==` | infix | left | 20 |
| [inequality](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md#equality-comparison) | `!=` | infix | left | 20 |
| [less-than-or-equal](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md#quantitative-comparison) | `<=` | infix | left | 25 |
| [less-than](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md#quantitative-comparison) | `<` | infix | left | 25 |
| [greater-than-or-equal](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md#quantitative-comparison) | `>=` | infix | left | 25 |
| [greater-than](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md#quantitative-comparison) | `>` | infix | left | 25 |
| [right shift](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md#bitwise-expressions) | `>>>` | infix | left | 28 |
| [left shift](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md#bitwise-expressions) | `<<<` | infix | left | 28 |
| [addition](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions) or [concatenation](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Concatentation.md#concatenation) | `+` | infix | left | 30 |
| [subtraction](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions) | `-` | infix | left | 30 |
| [multiplication](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions) | `*` | infix | left | 35 |
| [division](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions) | `/` | infix | left | 35 |
| [modulus](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions) | `%` | infix | left | 35 |
| [exponentiation](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions) | `^` | infix | right | 40 |
| [bitwise NOT](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md#bitwise-expressions) | `~~~` | prefix | right | 45 |
| [logical NOT](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/LogicalExpressions.md#logical-expressions) | `not` | prefix | right | 45 |
| [negative](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions) | `-` | prefix | right | 45 |


Copy-and-update expressions necessarily need to have the lowest precedence to ensure a consistent behavior of the corresponding [evaluate-and-reassign statement](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#evaluate-and-reassign-statements). 
Similar considerations hold for the range operator to ensure a consistent behavior of the corresponding [contextual expression](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions).

## Modifiers and combinators

Modifiers can be seen as special operators that can be applied to certain expressions only. You can assign them an artificial precedence to capture their behavior. 

For more information, see [Expressions](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/3_Expressions#expressions).

This artificial precedence is listed in the following table, along with how the precedence of operators and modifiers relates to how tightly item access combinators (`[`,`]` and `::` respectively) and call combinators (`(`, `)`) bind.

| Description | Syntax | Operator | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| [Call combinator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md#call-statements) | `(` `)` | n/a | left | 900 | 
| [Adjoint functor](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md#call-statements) | `Adjoint` | prefix | right | 950 |
| [Controlled functor](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md#call-statements) | `Controlled` | prefix | right | 950 |
| [Unwrap application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md#item-access-for-user-defined-types) | `!` | postfix | left | 1000 |
| [Named item access](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md#item-access-for-user-defined-types) | `::` | n/a | left | 1100 |  
| [Array item access](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md#array-item-access-and-array-slicing) | `[` `]` | n/a | left | 1100 |

To illustrate the implications of the assigned precedences, suppose you have a unitary operation `DoNothing` (as defined in [Specialization declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md#specialization-declarations)), a callable `GetStatePrep` that returns a unitary operation, and an array `algorithms` that contains items of type `Algorithm` defined as follows

```qsharp
    newtype Algorithm = (
        Register : LittleEndian,
        Initialize : Transformation,
        Apply : Transformation
    );

    newtype Transformation =
        LittleEndian => Unit is Adj + Ctl;
```

where `LittleEndian` is defined in [Type declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md#type-declarations). 

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


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)