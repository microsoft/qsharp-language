# Functor Application

Functors are factories that allow to access particular specialization implementations of a callable. 
For an operation `ApplyUnitary` that defines a unitary transformation *U* of the quantum state, `Adjoint ApplyUnitary` accesses the implementation of *U†* and `Controlled ApplyUnitary` accesses the implementation that applies *U* conditional on all qubits in an array of control qubits being in a state |1⟩. 
Concretely, if `cs` contains an array of qubits, and `q1` and `q2` are two qubits, then the operation call `Controlled SWAP(cs, (q1, q2))`, with `SWAP` as defined [here](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md#specialization-declarations), exchanges the state of `q1` and `q2` if all qubits in `cs` are in a |1⟩ state. 
