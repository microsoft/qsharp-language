# Conditional Expressions

Conditional expressions consist of three sub-expressions, where the left-most one is of type `Bool` and determines which one of the two other sub-expressions is evaluated. They are of the form `cond ? ifTrue | ifFalse`.
The types of the `ifTrue` and the `ifFalse` expression have to have a common base type. Independent of which one of the two ultimately yields the value to which the expression evaluates, its type will always match the determined base type. 

