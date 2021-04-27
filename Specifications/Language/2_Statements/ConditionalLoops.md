# Conditional Loops

Like most classical programming languages, Q# supports loops that break based on a condition: loops for which the number of iterations is unknown and may vary from run to run. Since the instruction sequence is unknown at compile-time, you need to handle these conditional loops with particular care in a quantum runtime. 

As long as the condition does not depend on quantum measurements, conditional loops can be handled without issues by doing a just-in-time compilation before sending the instruction sequence to the quantum processor. 
In particular, using conditional loops within functions is unproblematic since code within functions can always run on conventional (non-quantum) hardware. 
Q#, therefore, supports to use of traditional `while` loops within functions. 

Q# also allows you to express control flow that depends on the results of quantum measurements.
This capability enables probabilistic implementations that can significantly reduce computational costs.
A common example is the *repeat-until-success* pattern, which repeats a computation until a certain condition - which usually depends on a measurement - is satisfied. 
Such `repeat` loops are widely used in particular classes of quantum algorithms.  Q# hence has a dedicated language construct to express them, despite that they still pose a challenge for execution on quantum hardware. 

## Repeat-Statement

The `repeat` statement takes the following form

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

The `repeat` statement runs a block of statements before evaluating a condition. If the condition evaluates to true, the loop exits. If the condition evaluates to false, an additional block of statements defined as part of an optional `fixup` block, if present, is run prior to entering the next loop iteration. 

The compiler treats all parts of the `repeat` statement (both blocks and the condition) as a single scope for each repetition; symbols that are defined within the `repeat` block are visible both to the condition and within the `fixup` block. As for other loops, symbols go out of scope after each iteration, such that symbols defined in the `fixup` block are not visible in the `repeat` block.

### Target-Specific Restrictions

Loops that break based on a condition are challenging to process on quantum hardware if the condition depends on measurement outcomes since the length of the instruction sequence to run is not known ahead of time. 

Despite their common presence in particular classes of quantum algorithms, current hardware does not yet provide native support for these kinds of control flow constructs. Running on quantum hardware can potentially be supported in the future by imposing a maximum number of iterations.

## While-Loop

A more familiar-looking statement for classical computations is the `while` loop. It is supported only within functions. 

A `while` statement consists of the keyword `while`, an expression of type `Bool`, and a statement block. 
For example, if `arr` is an array of positive integers,

```qsharp
mutable (item, index) = (-1, 0);
while index < Length(arr) && item < 0 {
    set item = arr[index];
    set index += 1;
}
```

The statement block is run as long as the condition evaluates to `true`.

> [!NOTE]Due to the challenge they pose for execution, we discourage the use of loops that break based on a condition and hence do not support `while` loops within operations. The use of `while` loops within operations may be considered in the future, with the restriction that the condition cannot depend on the outcome of a quantum measurement. 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)