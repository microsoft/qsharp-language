# Statements

Q# distinguishes between statements and expressions. Q# programs consist of a mixture of classical and quantum computations, and the implementation looks much like any other classical programming language. Some statements, such as the `let` and `mutable` bindings, are well-known from classical languages, while others, such qubit allocations, are unique to the quantum domain.

The following statements are currently available in Q#:

* **Expression statement**  
    Contains a Q# expression to be run, such as a call to an operation. If the last statement in a block is an expression statement, it may have its trailing semicolon omitted to give the block the evaluated value of the contained expression.

* **Variable declaration**  
    Defines one or more local variables that are valid for the remainder of the current scope, and binds them to the specified values. Variables can be permanently bound or declared to be reassignable later on. See [Variable declarations and reassignments](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#variable-declarations-and-reassignments) for more details.

* **Qubit allocation**  
    Instantiates and initializes qubits, or arrays of qubits, and binds them to the declared variables. The statement can optionally be used with a specified block of code, in which the qubit allocations are valid. Otherwise the allocations are valid for the enclosing scope. Qubits are automatically released at the end of the appropriate scope.
    See [Quantum memory management](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md#quantum-memory-management) for more details.

← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
