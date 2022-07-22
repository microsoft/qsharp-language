# Conditional branching

Conditional branching is expressed in the form of `if` statements. 
An `if` statement consists of an `if` clause, followed by zero or more `elif` clauses and optionally an else-block.
Each clause follows the pattern

```
keyword condition {
    <statements>
}
```

where `keyword` is replaced with `if` or `elif` respectively, `condition` is an expression of type `Bool`, and `<statements>` is to be replaced with zero or more statements. The optional `else`-block consists of the keyword `else` followed by zero or more statements enclosed in braces, `{`  `}`.

The first block for which the `condition` evaluates to `true` will run. The `else` block, if present, runs if none of the conditions evaluate to `true`. 
The block is executed in its own scope, meaning any bindings made as part of the statement block are not visible after the block ends.

For example, suppose `qubits` is value of type `Qubit[]` and `r1` and `r2` are of type `Result`,

```qsharp
if r1 == One {
    let q = qubits[0];
    H(q);
} 
elif r2 == One {
    let q = qubits[1];
    H(q);
} 
else {
    H(qubits[2]);
}
```

You can also express simple branching in the form of a [conditional expression](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ConditionalExpressions.md#conditional-expressions).

## *Target-specific restrictions*

The tight integration between control-flow constructs and quantum computations poses a challenge for current quantum hardware. Certain quantum processors do not support branching based on measurement outcomes. As such, comparison for values of type `Result` will always result in a compilation error for Q# programs that are targeted to run on such hardware. 

Other quantum processors support specific kinds of branching based on measurement outcomes. The more general `if` statements supported in Q# are compiled into suitable instructions that can be run on such processors. The imposed restrictions are that values of type `Result` may only be compared as part of the condition within `if` statements in operations. Furthermore, the conditionally run blocks cannot contain any return statements or update mutable variables that are declared outside that block. 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)