# Comparative expressions

## Equality comparisons

*Equality comparisons* (`==`) and *inequality comparisons* (`!=`) are currently limited to the following data types: `Int`, `BigInt`, `Double`, `String`, `Bool`, `Result`, `Pauli`, and `Qubit`. Equality comparisons of arrays, tuples, ranges, user-defined types, or callables are currently not supported. 

Equality comparison for values of type `Qubit` evaluates whether the two expressions identify the same qubit. There is no notion of a quantum state in Q#; equality comparison, in particular, does *not* access, measure, or modify the quantum state of the qubits.

Equality comparisons for `Double` values may be misleading due to rounding effects.
For instance, the following comparison evaluates to `false` due to rounding errors: `49.0 * (1.0/49.0) == 1.0`.

>[!NOTE]
>In the future, Q# may support the comparisons of ranges, as well as arrays, tuples, and user-defined types provided their items support comparison. As for all types, the comparison would be by value, meaning two values are considered equal if all of their items are. For values of user-defined type, their type also needs to match. Future support for the comparison of values of type `Range` follows the same logic; they should be equal as long as they produce the same sequence of integers, meaning the two ranges 
>```qsharp
>    let r1 = 0..2..5; // generates the sequence 0,2,4
>    let r2 = 0..2..4; // generates the sequence 0,2,4
>```
>should be considered equal.
>
>Conversely, there is a good reason not to allow the comparison of callables, as the behavior would be ill-defined. Suppose the capability is introduced to define functions locally via a possible syntax
>```qsharp
>    let f1 = (x -> Bar(x)); // not yet supported
>    let f2 = Bar;
>```
>for some globally declared function `Bar`. The first line defines a new anonymous function that takes an argument `x`, invokes a function `Bar` with it, and then assigns it to the variable `f1`. The second line assigns the function `Bar` to `f2`. Since invoking `f1` or `f2` does the same thing, it should be possible to interchange `f1` and `f2` with each other without changing the behavior of the program. This wouldn't be the case if the equality comparison for functions was supported and `f1 == f2` evaluated to `false`. Conversely, if `f1 == f2` evaluates to `true`, then this leads to determining whether two callables have the same side effects and evaluate to the same value for all inputs, which is not possible to determine reliably. Therefore, if we want to be able to replace `f1` with `f2`, we can't allow equality comparisons for callables.  

## Quantitative comparison

The operators *less-than* (`<`), *less-than-or-equal* (`<=`), *greater-than* (`>`), and *greater-than-or-equal* (`>=`) define quantitative comparisons. They can only be applied to data types that support such comparisons, that is, the same data types that can also support [arithmetic expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions). 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)