# Operators

Operators in a sense are nothing but dedicated syntax for particular functions. 
Even though Q# is not yet expressive enough to formally capture the capabilities of each operator in the form of a backing function declaration, that should be remedied in the future. There are currently no operators that correspond to operations; i.e. all Q# operators at the time of writing are fully deterministic and do not have any side effects. 

Precedence and associativity define the order in which operators are applied. Operators with higher precedence will be bound to their arguments (operands) first, while operators with the same precedence will bind be bound in the direction of their associativity. 
For example, the expression `1+2*3` according to the precedence for addition and multiplication is equivalent to `1+(2*3)`, and `2^3^4` equals `2^(3^4)` since exponentiation is right-associative. 
The following table lists the available operators, as well as their precedence and associativity. 
Additional modifiers and combinators are listed further below and bind tighter than any of these operators. 

| Description | Syntax | Operator | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| [copy-and-update operator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md) | `w/` `<-` | ternary | left  | 1  |
| [range operator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md) | `..` | infix | left | 2 |
| [conditional operator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ConditionalExpressions.md) | `?` `|` | ternary | right | 5 |
| logical OR | `or` | infix | left | 10 |
| logical AND | `and` | infix | left | 11 |
| bitwise OR | `|||` | infix | left | 12 |
| bitwise XOR | `^^^` | infix | left | 13 |
| bitwise AND | `&&&` | infix | left | 14 |
| equality | `==` | infix | left | 20 |
| inequality | `!=` | infix | left | 20 |
| less-than-or-equal | `<=` | infix | left | 25 |
| less-than | `<` | infix | left | 25 |
| greater-than-or-equal | `>=` | infix | left | 25 |
| greater-than | `>` | infix | left | 25 |
| right shift | `>>>` | infix | left | 28 |
| left shift | `<<<` | infix | left | 28 |
| addition or concatenation | `+` | infix | left | 30 |
| subtraction | `-` | infix | left | 30 |
| multiplication | `*` | infix | left | 35 |
| division | `/` | infix | left | 35 |
| modulus | `%` | infix | left | 35 |
| exponentiation | `^` | infix | right | 40 |
| bitwise NOT | `~~~` | prefix | right | 45 |
| logical NOT | `not` | prefix | right | 45 |
| negative | `-` | prefix | right | 45 |


Copy-and-update expressions necessarily need to have the lowest precedence to ensure a consistent behavior of the corresponding [evaluate-and-reassign statement](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndUpdates.md#evaluate-and-reassign-statements). 
Similar considerations hold for the range operator to ensure a consistent behavior of the corresponding [contextual expression](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md).


# Modifiers and Combinators

In addition to the operators listed in the table above, there are other constructs that can be applied to certain expressions only. We can assign them an artificial precedence to capture their behavior. We'll refer to these constructs as *modifiers*. One or more modifiers can be applied to expressions that are either identifiers, array item access expressions, named item access expressions, or an expression within parenthesis which is the same as a single item tuple (see [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md)). 
They can either precede (prefix) the expression or follow (postfix) the expression. They are thus special unary operators that bind tighter than function or operation calls, but less tight than any kind of item access. 
In a sense, function calls and item access can also be seen as a special kind of operator; we refer to them as *combinators*. 
Functors are treated at prefix modifiers. Additionally, the unwrap operator (`!`) is treated as a postfix modifier, the purpose of which is explained in [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md#item-access-for-user-defined-types). 

The artificial precedence of these operators is listed in \ref{tab:modifiers_and_combinators}, which also shows how the precedence of operators and modifiers relates to how tight item access combinators (`[`,`]` and `::` respectively) and call combinators (`(`, `)`) bind.

| Description | Syntax | Operator | Associativity | Precedence |
| --- | --- | --- | --- | --- |
| [Call combinator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md) | `(` `)` | n/a | right | 900 | 
| [Adjoint functor](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md) | `Adjoint` | prefix | right | 950 |
| [Controlled functor](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md) | `Controlled` | prefix | right | 950 |
| [Unwrap application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md#item-access-for-user-defined-types) | `!` | postfix | left | 1000 |
| Array item access | `[` `]` | n/a | left | 1100 |
| [Named item access](https://github.com/microsoft/qsharp-language/blob/beheim/specs/Specifications/Language/3_Expressions/ItemAccessExpressions.md#item-access-for-user-defined-types) | `::` | n/a | left | 1100 |  

Suppose we have a unitary operation `DoNothing` as defined in [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md), a callable `GetStatePrep` that returns a unitary operation, and an array `algorithms` containing items of type `Algorithm` defined as follows

```qsharp
    newtype Algorithm = (
        Register : LittleEndian,
        Initialize : Transformation,
        Apply : Transformation
    );

    newtype Transformation = (
        LittleEndian => Unit is Adj + Ctl
    );
```

where `LittleEndian` is defined in [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md). 
Then the following expressions are all valid: 
```qsharp
    (GetStatePrep())(arg)
    (Transformation(GetStatePrep()))!(arg)
    Adjoint DoNothing()
    Controlled Adjoint DoNothing(cs, ())
    Controlled algorithms[0]::Apply!(cs, _)
    algorithms[0]::Register![i]
```
Looking at the precedences defined in the table above, we see that the parentheses around `(Transformation(GetStatePrep()))` are necessary for the subsequent unwrap operator to be applied to the `Transformation` value rather than the returned operation. 
Similarly, the syntax `GetStatePrep()(arg)` doesn't lead to a valid expression; parenthesis are required around the `GetStatePrep` call in order to invoke the returned callable. 
Functor applications on the other hand don't require parentheses around them in order to invoke the corresponding specialization. Neither do array or named item access expressions, such that an expression `arr2D[i][j]` is perfectly valid, just like `algorithms[0]::Register![i]` is.
