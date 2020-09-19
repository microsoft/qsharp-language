## Quantum Instruction Set and Runtime

### Standard Operations

As recommended by the [LLVM documentation](https://llvm.org/docs/ExtendingLLVM.html),
we do not define new LLVM instructions for quantum operations.
Instead, we expect each target to define a set of quantum operations as LLVM functions
that may be used by language-specific compilers.

### Qubit Management Functions

We define the following functions for managing qubits:

| Function                        | Signature       | Description |
|---------------------------------|-----------------|-------------|
| quantum.rt.qubit_allocate       | `%Qubit*()`     | Allocates a single qubit. |
| quantum.rt.qubit_allocate_array | `%Array*(i64)`  | Allocates an array of qubits. |
| quantum.rt.qubit_release        | `void(%Qubit*)` | Release a single qubit. |
| quantum.rt.qubit_release_array  | `void(%Array*)` | Release an array of qubits. |

Allocated qubits are not guaranteed to be in any particular state.
If a language guarantees that allocated qubits will be in a specific state, the compiler
should insert the code required to set the state of the qubits returned from `alloc`.
Qubits should be unentangled -- measured out -- before they are released.

If borrowing qubits is supported, then the following runtime functions should also be provided:

| Function                        | Signature       | Description |
|---------------------------------|-----------------|-------------|
| quantum.rt.qubit_borrow         | `%Qubit*()`     | Borrow a single qubit. |
| quantum.rt.qubit_borrow_array   | `%Array*(i64)`  | Borrow an array of qubits. |
| quantum.rt.qubit_return         | `void(%Qubit*)` | Return a borrowed qubit. |
| quantum.rt.qubit_return_array   | `void(%Array*)` | Return an array of borrowed qubits. |

Borrowing qubits means supplying qubits that are guaranteed not to be otherwise
accessed while they are borrowed.
The code that borrows the qubits guarantees that the state of the qubits when
returned is identical, including entanglement, to their state when borrowed.
It is always acceptable to satisfy `borrow` by allocating new qubits.

*__Discussion__*
>It will likely be useful to provide usage hints to `alloc` and `borrow`.
>Since we don't know yet what form these hints may take, we leave defining them
>for future work.

---
_[Back to index](README.md)_
