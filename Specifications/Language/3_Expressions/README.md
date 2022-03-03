# Expressions

At the core, Q# expressions are either [value literals](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ValueLiterals.md) or [identifiers](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Identifiers.md#identifiers), where identifiers can refer to either locally declared variables or to globally declared callables (there are currently no global constants in Q#).
Operators, combinators, and modifiers can be used to combine these into a wider
variety of expressions. Additionally, [lambda expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/LambdaExpressions.md#lambda-expressions) permit to define a
function or operation as part of an expression.

- *Operators* in a sense are nothing but dedicated syntax for particular callables.
    >Even though Q# is not yet expressive enough to formally capture the capabilities of each operator in the form of a backing callable declaration, that should be remedied in the future.

- *Modifiers* can only be applied to certain expressions. One or more modifiers can be applied to expressions that are either identifiers, array item access expressions, named item access expressions, or an expression within parenthesis which is the same as a single item tuple (see [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md#singleton-tuple-equivalence)).
They can either precede (prefix) the expression or follow (postfix) the expression. They are thus special unary operators that bind tighter than function or operation calls, but less tight than any kind of item access.
Concretely, [functors](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/FunctorApplication.md#functor-application) are prefix modifiers, whereas the [unwrap operator](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md#item-access-for-user-defined-types) is a postfix modifier.

- Like modifiers, function and operation calls as well as item access can be seen as a special kind of operator subject to the same restrictions regarding where they can be applied; we refer to them as *combinators*.

The section on [precedence and associativity](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md) contains a complete [list of all operators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#operators) as well as a complete [list of all modifiers and combinators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#modifiers-and-combinators).


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
