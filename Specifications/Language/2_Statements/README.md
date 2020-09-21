# Statements

Q# distinguishes between statements and expressions. Q# programs consist of a mixture of classical and quantum computations and the implementation looks much like in any other classical programming language. Some statements, such as the `let` and `mutable` bindings, are well-known from classical languages, while others such as conjugations or qubit allocations are unique to the quantum domain.

The following statements are currently available in Q#:

* **Expression Statement**    
    An expression statement consists of an operation or function call returning `Unit`. The invoked callable needs to satisfy the requirements imposed by the current context. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md#call-statements) for more details.

* **Return Statement**    
    A return statement terminates the execution within the current callable context and returns control to the caller. Any finalizing tasks are executed after the return value is evaluated but before control is returned. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ReturnsAndTermination.md#returns-and-termination) for more details.

* **Fail Statement**    
    A fail statement aborts the execution of the entire program, collecting information about the current program state before terminating in an error. It aggregates the collected information and presents it to the user along with the message specified as part of the statement. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ReturnsAndTermination.md#returns-and-termination) for more details.

* **Variable Declaration**    
    Defines one or more local variables that will be valid for the remainder of the current scope, and binds them to the specified values. Variables can be permanently bound or declared to be reassignable later on. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#variable-declarations-and-reassignments) for more details.

* **Variable Reassignment**    
    Variables that have been declared as being reassignable can be rebound to contain different values. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#variable-declarations-and-reassignments) for more details.

* **Iteration**    
    An iteration is a loop-like statement that during each iteration assigns the declared loop variables to the next item in a sequence (a value of array or `Range` type) and executes a specified block of statements. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Iterations.md#iterations) for more details.
    
* **While Statement**    
    If a specified condition evaluates to `true`, a block of statements is executed. The execution is repeated indefinitely until the condition evaluates to `false`. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalLoops.md#conditional-loops) for more details.

* **Repeat Statement**    
    Quantum-specific loop that breaks based on a condition. The statement consists of an initial block of statements that is executed before a specified condition is evaluated. If the condition evaluates to `false`, a subsequent `fixup`-block is executed before entering the next iteration of the loop. The loop terminates only once the condition evaluates to `true`. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalLoops.md#conditional-loops) for more details.

* **If Statement**    
    The statement consists of one or more blocks of statements, each preceded by a boolean expression. The first block for which the boolean expression evaluates to `true` is executed. Optionally, a block of statements can be specified that is executed if none of the conditions evaluates to `true`. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalBranching.md#conditional-branching) for more details.

* **Conjugation**    
    A conjugations is a special quantum-specific statement, where a block of statements that applies a unitary transformation to the quantum state is executed, followed by another statement block, before the transformation applied by the first block is reverted again. In mathematical notation, conjugations describe transformations of the form *U†VU* to the quantum state. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Conjugations.md#conjugations) for more details.

* **Qubit Allocation**    
    Instantiates and initializes qubits and/or arrays of qubits, and binds them to the declared variables. Executes a block of statements.
    The instantiated qubits are available for the duration of the block, and will be automatically released when the statement terminates. See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md#quantum-memory-management) for more details.
