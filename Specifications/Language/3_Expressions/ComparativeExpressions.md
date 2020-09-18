# Equality Comparison

Equality and inequality comparison is currently limited to the following data types: `Int`, `BigInt`, `Double`, `String`, `Bool`, `Result`, `Pauli`, and `Qubit`. The comparison for equality of arrays, tuples, ranges, user defined types, or callables is currently not supported. 

In the future, we may support the comparisons of ranges, as well as arrays, tuples, and user defined types, provided their items support comparison. 
As for all types, the comparison will be by value, meaning two values are considered equal if all of their items are. For values of user defined type, additionally their type also needs to match. Future support for the comparison of values of type `Range` follows the same logic; they should be equal as long as they produce the same sequence of integers, meaning the two ranges 
```qsharp
    let r1 = 0..2..5; // generates the sequence 0,2,4
    let r2 = 0..2..4; // generates the sequence 0,2,4
```
should be considered equal.

Conversely, there is a good reason not to allow the comparison of callables as the behavior would be ill-defined. 
Suppose we will introduce the capability to define functions locally via a possible syntax
```qsharp
    let f1 = (x -> Bar(x)); // not yet supported
    let f2 = Bar;
```
for some globally declared function `Bar`. The first line defines a new anonymous function that takes an argument `x` and invokes a function `Bar` with it and assigns it to the variable `f1`. The second line assigns the function `Bar` to `f2`. Since invoking `f1` and invoking `f2` will do the same thing, it should be possible to replace those with each other without changing the behavior of the program. This wouldn't be the case if the equality comparison for functions was supported and `f1 == f2` evaluates to `false`. If conversely `f1 == f2` were to evaluate to `true`, then this leads to the question of determining whether two callable will have the same side effects and evaluate to the same value for all inputs, which is not possible to reliably determine. Therefore, if we would like to be able to replace `f1` with `f2`, we can't allow equality comparisons for callables.  

# Quantitative Comparison

The operators less-than, less-than-or-equal,  greater-than, and greater-than-or-equal define quantitative comparisons. They can only be applied to data types that support such comparisons. As of the time of writing, these are the same data types that can also support arithmetics. 
