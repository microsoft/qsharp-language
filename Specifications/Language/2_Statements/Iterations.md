# Iterations

Loops that iterate over a sequence of values are expressed as `for`-loops in Q#. A `for`-loop in Q# does not break based on a condition, but instead corresponds to what is often expressed as `foreach` or `iter` in other languages. There are currently two data types in Q# that support iteration: arrays and ranges. 

The statement consists of the keyword `for`, an open parenthesis `(`, followed by a symbol or symbol tuple, the keyword `in`, an expression of array or `Range` type, a close parenthesis `)`, and a statement block.

The statement block (the body of the loop) is executed repeatedly, with the defined symbol(s) (the loop variable(s)) bound to each value in the range or array.
The same deconstruction rules apply to the defined loop variable(s) as to any other variable assignment, such as bindings in `let`-, `mutable`-, `set`-, `using`- and `borrowing`-statements. The loop variables themselves are immutably bound, cannot be reassigned within the body of the loop, and go out of scope when the loop terminates.
The expression over which the loop iterates is fully evaluated before entering the loop, and will not change while the loop is executing.

Supposing `qubits` is a value of type `Qubit[]`. The following examples illustrate what is described above:

```qsharp
for (qubit in qubits) {  
    H(qubit);
}

mutable results = new (Int, Results)[Length(qubits)];
for (index in 1 .. Length(qubits)) {  
    set results += [(index-1, M(qubits[index]))]; 
}

mutable accumulated = 0;
for ((index, measured) in results) { 
    if (measured == One) {
        set accumulated += 1 <<< index;
    }
}
```

## *Target-Specific Restrictions*

There are no `break`- or `continue`-primitives in Q#, such that the length of the loop is perfectly predictable as soon as the value to iterate over is known. Such `for`-loops can hence be executed on all quantum hardware.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)