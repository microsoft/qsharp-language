# Iterations

Loops that iterate over a sequence of values are expressed as `for` loops in Q#. A `for` loop in Q# does not break based on a condition but instead corresponds to an iteration, or what is often expressed as `foreach` or `iter` in other languages. There are currently two data types in Q# that support iteration: arrays and ranges.

The expression consists of the keyword `for`, followed by a symbol or symbol tuple, the keyword `in`, an expression of array or `Range` type, and a statement block.

The statement block (the body of the loop) is run repeatedly, with one or more loop variables bound to each value in the range or array. The same deconstruction rules apply to the defined loop variables as to any other variable assignment, such as bindings in `let`, `mutable`, `set`, `use` and `borrow` statements. The loop variables themselves are immutably bound, cannot be reassigned within the body of the loop, and go out of scope when the loop terminates.
The expression over which the loop iterates is evaluated before entering the loop and does not change while the loop is running.

This is illustrated in the following example. Suppose `qubits` is a value of type `Qubit[]`, then

```qsharp
for qubit in qubits {
    H(qubit);
}

mutable results : (Int, Result)[] = [];
for index in 0 .. Length(qubits) - 1 {
    set results += [(index, M(qubits[index]))];
}

mutable accumulated = 0;
for (index, measured) in results {
    if measured == One {
        set accumulated += 1 <<< index;
    }
}
```

## Target-specific restrictions

Because there are no `break` or `continue` primitives in Q#, the length of the loop is known as soon as the iteration value is known. As such, `for` loops can be run on all quantum hardware.


