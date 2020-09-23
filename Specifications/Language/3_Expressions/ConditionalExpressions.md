# Conditional Expressions

Conditional expressions consist of three sub-expressions, where the left-most one is of type `Bool` and determines which one of the two other sub-expressions is evaluated. They are of the form 
```qsharp
cond ? ifTrue | ifFalse
``` 

Specifically, if `cond` evaluates to `true` then the conditional expression evaluates to the `ifTrue` expressions, and otherwise it evaluates to the `ifFalse` expression. The other expression (the `ifFalse` and `ifTrue` expression respectively) is never evaluated, much like for the branches in an `if`-statement.
For instance, in an expression `a == b ? C(qs) | D(qs)`, if `a` equals `b` then the callable `C` will be invoked, and otherwise `D` will be invoked.

The types of the `ifTrue` and the `ifFalse` expression have to have a [common base type](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SubtypingAndVariance.md#subtyping-and-variance). Independent of which one of the two ultimately yields the value to which the expression evaluates, its type will always match the determined base type. 

For example, if 
- `Op1` is of type `(Qubit[] => Unit is Adj)`
- `Op2` is of type `(Qubit[] => Unit is Ctl)`
- `Op3` is of type `(Qubit[] => Unit is Adj + Ctl)`

then

- `cond ? Op1 | Op2` is of type `(Qubit[] => Unit)`
- `cond ? Op1 | Op3` is of type `(Qubit[] => Unit is Adj)`
- `cond ? Op2 | Op3` is of type `(Qubit[] => Unit is Ctl)`

See the section on [subtyping](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SubtypingAndVariance.md#subtyping-and-variance) for more detail.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
