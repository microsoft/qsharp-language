# Quantum Instruction Set and Runtime

## Runtime Failure

There are several error conditions that are specified as causing a runtime failure.
The `quantum__rt__fail` function is the mechanism to use to cause a runtime failure;
it is documented in the [Classical Runtime](Classical-Runtime.md) section.

## Standard Operations (Gates)

As recommended by the [LLVM documentation](https://llvm.org/docs/ExtendingLLVM.html),
we do not define new LLVM instructions for quantum operations.
Instead, we expect each target to define a set of quantum operations as LLVM functions
that may be used by language-specific compilers.

## Qubits

We define the following functions for managing qubits:

| Function                            | Signature       | Description |
|-------------------------------------|-----------------|-------------|
| __quantum__rt__qubit_allocate       | `%Qubit*()`     | Allocates a single qubit. |
| __quantum__rt__qubit_allocate_array | `%Array*(i64)`  | Creates an array of the given size and populates it with newly-allocated qubits. |
| __quantum__rt__qubit_release        | `void(%Qubit*)` | Releases a single qubit. |
| __quantum__rt__qubit_release_array  | `void(%Array*)` | Releases an array of qubits; each qubit in the array is released, and the array itself is unreferenced. |

Passing a null `%Qubit*` or `%Array*` to the `release` functions should
cause a runtime failure.

The language-specific compiler may assume that qubits are always allocated in a zero-state. Since individual targets may give different guarantees regarding the qubit state upon allocation, the target-specific compilation phase should insert the code required to ensure that the state of qubits is set appropriately. 

Any measurements or resets applied upon release are at the discretion of the target as well; for the quantum algorithm to be correct, the qubits that are to be released hence should be unentangled from qubits that remain live prior to invoking the release function.

---
_[Back to index](README.md)_
