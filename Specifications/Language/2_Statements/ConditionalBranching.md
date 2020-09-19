# Conditional Branching

In contrast to embedded languages that predominately leverage a classical host language to provide expressiveness for control flow constructs, Q# integrates these constructs seamlessly with quantum computations. 
Conditional branching is expressed in the form of `if`-statements, that may optionally contain zero or more `elif`-clauses and an `else`-block that is executed if none of the conditions evaluate to true. 
Additionally, Q# also allows to express simple branching in the form of a [conditional expression](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language).

A tight integration between control-flow constructs and quantum computations of course poses a challenge for current hardware. Certain quantum processors do not support branching based on measurement outcomes. Comparison for values of type `Result` will hence always result in a compilation error for Q# programs that are targeted to execute on that hardware. 
Other quantum processors support specific kinds of branching based on measurement outcomes. The more general `if`-statements supported in Q# are compiled into suitable instructions that can be executed on such processors. The imposed restrictions are that values of type `Result` may only be compared as part of the condition within if-statements in operations. The conditionally executed blocks furthermore cannot contain any return statements or update mutable variables that are declared outside that block. 

