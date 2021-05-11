# Statements

Q# distinguishes between statements and expressions. Q# programs consist of a mixture of classical and quantum computations, and the implementation looks much like any other classical programming language. Some statements, such as the `let` and `mutable` bindings, are well-known from classical languages, while others, such as conjugations or qubit allocations, are unique to the quantum domain.

The following statements are currently available in Q#:

* **Call statement**    
    A call statement consists of an operation or function call returning `Unit`. The invoked callable needs to satisfy the requirements imposed by the current context. See [Call statements](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md#call-statements) for more details.

* **Return statement**    
    A return statement terminates the execution within the current callable context and returns control to the caller. Any finalizing tasks are run after the return value is evaluated but before control is returned. See [Returns and termination](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ReturnsAndTermination.md#returns-and-termination) for more details.

* **Fail statement**    
    A fail statement stops the run of the entire program and collects information about the current program state before terminating in an error. It aggregates the collected information and presents it to the user along with the message specified as part of the statement. See [returns and termination](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ReturnsAndTermination.md#returns-and-termination) for more details.

* **Variable declaration**    
    Defines one or more local variables that are valid for the remainder of the current scope, and binds them to the specified values. Variables can be permanently bound or declared to be re-assignable later on. See [Variable declarations and reassignments](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#variable-declarations-and-reassignments) for more details.

* **Variable reassignment**    
    Variables that have been declared as being re-assignable can be rebound to contain different values. See [Variable declarations and reassignments](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#variable-declarations-and-reassignments) for more details.

* **Iteration**    
    An iteration is a loop-like statement that, during each iteration, assigns the declared loop variables to the next item in a sequence (a value of array or `Range` type) and runs a specified block of statements. See [Iterations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Iterations.md#iterations) for more details.
    
* **While statement**    
    If a specified condition evaluates to `true`, a block of statements is run. The run is repeated indefinitely until the condition evaluates to `false`. See [Conditional loops](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalLoops.md#conditional-loops) for more details.

* **Repeat statement**    
    A quantum-specific loop that breaks based on a condition. The statement consists of an initial block of statements that is run before a specified condition is evaluated. If the condition evaluates to `false`, an optional subsequent `fixup` block is run before entering the next iteration of the loop. The loop only terminates when the condition evaluates to `true`. See [Conditional loops](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalLoops.md#conditional-loops) for more details.

* **If statement**    
    The if statement consists of one or more blocks of statements, each preceded by a boolean expression. The first block in which the boolean expression evaluates to `true` is run. Optionally, you can specify a block of statements that will run if none of the conditions evaluate to `true`. See [Conditional branching](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalBranching.md#conditional-branching) for more details.

* **Conjugation**    
    A conjugation is a special quantum-specific statement, where a block of statements that applies a unitary transformation to the quantum state is run, followed by another statement block, before the transformation applied by the first block is reverted again. In mathematical notation, conjugations describe transformations of the form *U†VU* to the quantum state. See [Conjugations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Conjugations.md#conjugations) for more details.

* **Qubit allocation**    
    Instantiates and initializes qubits, or arrays of qubits, binds them to the declared variables and runs a block of statements.
    The instantiated qubits are available for the duration of the block, and will be automatically released when the statement terminates. See [Quantum memory management](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md#quantum-memory-management) for more details.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
