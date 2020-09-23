# Variable Declarations and Reassignments

Values can be bound to symbols via `let`- and `mutable`-statements. 
Such bindings provide a convenient way to access a value via the defined handle. 
Despite the somewhat misleading terminology, borrowed from other languages, we will call handles that are declared on a local scope and contain values *variables*.
The reason that this may be somewhat misleading is that `let`-statements define "single-assignment handles", i.e. handles that for the duration of their validity will always be bound to the same value. Variables that can be re-bound to different values at different points in the code need to be explicitly declared as such, as specific by the `mutable`-statement. 

```qsharp
    let var1 = 3; 
    mutable var2 = 3; 
    set var2 = var2 + 1; 
```

Line 1 declares a variable named `var1` that cannot be reassigned and will always contain the value `3`. Line 2 on the other hand defines a variable `var2` that is temporarily bound to the value `3`, but can be reassigned to a different value later on. Such a reassignment can be done via a `set`-statement, as shown in Line 3. The same could have been expressed with the shorter version `set var2 += 1;` explained further below, as it is common in other languages as well. 

For all three statements, the left hand side consists of a symbol or a symbol tuple.
It may contain nested symbols and/or omitted symbols, indicated by an underscore. 
This is in fact obeyed by all assignments in Q#, including, e.g., qubit allocations and loop-variable assignments. 

To summarize:
* `let` is used to create an immutable binding.
* `mutable` is used to create a mutable binding.
* `set` is used to change the value of a mutable binding.

For both kinds of binding, the types of the variables are inferred from the right-hand side of the binding. The type of a variable always remains the same and a `set`-statement cannot change it.
Local variable can be declared as either being mutable or immutable, with some exceptions like loop-variables in `for`-loops for which the behavior is predefined and cannot be specified.
Function and operation arguments are always immutably bound; in combination with the lack of reference types, as discussed in the section on [immutability](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md#immutability), that means that a called function or operation can never change any values on the caller side. 
Since the states of `Qubit` values are not defined or observable from within Q#, this does not preclude the accumulation of quantum side effects, that are observable (only) via measurements (see also [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md#qubits)).

Independent on how a value is bound, the values themselves are immutable. 
It is worth pointing out explicitly that this in particular also holds for arrays and array items. 
In contrast to popular classical languages where arrays often are reference types, arrays - like all type - are value types in Q# and always immutable; they cannot be modified after initialization.
Changing the values accessed by variables of array type thus requires explicitly constructing a new array and reassigning it to the same symbol, see also the section on [immutability](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md) and [copy-and-update expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions) for more details.

## Evaluate-and-Reassign Statements

Statements of the form `set intValue += 1;` are common in many other languages. Here, `intValue` needs to be a mutably bound variable of type `Int`. Similar statements in fact exist for a wide range of [operators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#operators). More precisely, such evaluate-and-reassign statements exist for all operators where the type of the left-most sub-expression matches the expression type.
This is the case for [copy-and-update expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions), for binary logical and bitwise operators including right and left shift, for arithmetic expressions including exponentiation and modulus, as well as for concatenations. The `set` keyword in this case needs to be followed by a single mutable variable, which is inserted as the left-most sub-expression by the compiler. 

The section on [contextual expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions) contains other examples where expressions can be omitted in a certain context when a suitable expression can be inferred by the compiler.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)