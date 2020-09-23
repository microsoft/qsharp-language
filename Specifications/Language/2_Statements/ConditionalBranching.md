# Conditional Branching

Conditional branching is expressed in the form of `if`-statements. 
An `if`-statement consists of an `if`-clause, followed by zero or more `elif`-clauses and optionally an else-block.
Each clause follows the patter
```
keyword (condition) {
    <statements>
}
```
where `keyword` is to be replaced with `if` or `elif` respectively, `condition` is an expression of type `Bool`, and `<statements>` is to be replaced with zero or more statements. The optional `else`-block consists of the keyword `else` followed by zero or more statements enclosed in `{` and `}`.

The first block for which the `condition` evaluates to `true` will be executed. The `else`-block, if present, is executed if none of the conditions evaluate to `true`. 
The block is executed in its own scope, meaning any bindings made as part of the statement block are not visible after its end.

For example, suppose `qubits` is value of type `Qubit[]` and `r1` and `r2` are of type `Result`,

```qsharp
if (r1 == One) {
    let q = qubits[0];
    H(q);
} 
elif (r2 == One) {
    let q = qubits[1];
    H(q);
} 
else {
    H(qubits[2]);
}
```

Additionally, Q# also allows to express simple branching in the form of a [conditional expression](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ConditionalExpressions.md#conditional-expressions).

## *Target-Specific Restrictions*

A tight integration between control-flow constructs and quantum computations poses a challenge for current quantum hardware. Certain quantum processors do not support branching based on measurement outcomes. Comparison for values of type `Result` will hence always result in a compilation error for Q# programs that are targeted to execute on such hardware. 

Other quantum processors support specific kinds of branching based on measurement outcomes. The more general `if`-statements supported in Q# are compiled into suitable instructions that can be executed on such processors. The imposed restrictions are that values of type `Result` may only be compared as part of the condition within if-statements in operations. The conditionally executed blocks furthermore cannot contain any return statements or update mutable variables that are declared outside that block. 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)