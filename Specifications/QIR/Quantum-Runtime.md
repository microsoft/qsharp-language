## Quantum Instruction Set and Runtime

### Standard Operations

As recommended by the [LLVM documentation](https://llvm.org/docs/ExtendingLLVM.html),
we do not define new LLVM instructions for quantum operations.
Instead, we expect each target to define a set of quantum operations as LLVM functions
that may be used by language-specific compilers.

### Qubit Management Functions

We define the following functions for managing qubits:

| Function                            | Signature       | Description |
|-------------------------------------|-----------------|-------------|
| __quantum__rt__qubit_allocate       | `%Qubit*()`     | Allocates a single qubit. |
| __quantum__rt__qubit_allocate_array | `%Array*(i64)`  | Creates an array of the given size and populates it with newly-allocated qubits. |
| __quantum__rt__qubit_release        | `void(%Qubit*)` | Releases a single qubit. |
| __quantum__rt__qubit_release_array  | `void(%Array*)` | Releases and array of qubits; each qubit in the array is released, and the array itself is unreferenced. |

Allocated qubits are not guaranteed to be in any particular state.
If a language guarantees that allocated qubits will be in a specific state, the compiler
should insert the code required to set the state of the qubits returned from `alloc`.
Qubits should be unentangled -- measured out -- before they are released.

---
_[Back to index](README.md)_
