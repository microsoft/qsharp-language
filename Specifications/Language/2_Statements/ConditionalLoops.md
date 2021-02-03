# Conditional Loops

Much like most classical programming languages, Q# supports loops that break based on a condition, i.e. loops for which the number of iterations is unknown and may vary from run to run. Since the instruction sequence is unknown at compile time, these kinds of loops need to be handled with particular care in a quantum runtime. 

As long as the condition does not depend on quantum measurements, such loops can be handled without issues by doing a just-in-time compilation before sending off the instruction sequence to the quantum processor. 
In particular, their use within functions is unproblematic, since code within functions can always be executed on conventional (non-quantum) hardware. 
Q# therefore supports to use of traditional `while`-loops within functions. 

Additionally, Q# allows to express control flow that depends on the results of quantum measurements.
This capability enables probabilistic implementations that can significantly reduce the computational costs.
A common example are *repeat-until-success* patterns, which repeat a computation until a certain condition - which usually depends on a measurement - is satisfied. 
Such `repeat`-loops are widely used in particular classes of quantum algorithms, and Q# hence has a dedicated language construct to express them, despite that they still pose a challenge for execution on quantum hardware. 

## Repeat-Statement

The `repeat`-statement takes the following form:
```qsharp
repeat {
    // ...
}
until condition
fixup {
    // ...
}
```
or alternatively
```qsharp
repeat {
    // ...
}
until condition;
```
where `condition` is an arbitrary expression of type `Bool`.

The `repeat`-statement executes a block of statements before evaluating a condition. If the condition evaluates to true, the loop exists. If the condition evaluates to false, an addition block of statements defined as part of an optional `fixup`-block, if present, is executed prior to entering the next loop iteration. 

All parts of the `repeat`-statement (both blocks and the condition) are treated as a single scope for each repetition; i.e. symbols that are defined within the `repeat`-block are visible both to the condition and within the `fixup`-block. As for other loops, symbols go out of scope after each iteration, such that symbols defined in the `fixup`-block are not visible in the `repeat`-block.

### *Target-Specific Restrictions*

Loops that break based on a condition are a challenge to process on quantum hardware if the condition depends on measurement outcomes, since the length of the instruction sequence to execute is not known ahead of time. 

Despite their common presence in particular classes of quantum algorithms, current hardware does not yet provide native support for these kind of control flow constructs. Execution on quantum hardware can potentially be supported in the future by imposing a maximum number of iterations.

## While-Loop

A more familiar looking statement for classical computations is the `while`-loop. It is supported only within functions. 

A `while` statement consists of the keyword `while`, an expression of type `Bool`, and a statement block. 
For example, if `arr` is an array of positive integers,
```qsharp
mutable (item, index) = (-1, 0);
while index < Length(arr) && item < 0 {
    set item = arr[index];
    set index += 1;
}
```
The statement block is executed as long as the condition evaluates to `true`.


### *Discussion*
>Due to the challenge they pose for execution, we would like to discourage the use of loops that break based on a condition and hence do not support while-loops within operations. We may consider allowing the use of `while`-loops within operations in the future, imposing that the condition cannot depend on the outcomes of quantum measurements. 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)