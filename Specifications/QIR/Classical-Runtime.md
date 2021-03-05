# Classical Runtime

Most functions in the classical runtime are defined in the
[Data Types](Data-Types.md) specification.

Additionally, QIR requires the following functions to be present for the purpose of logging and program termination:

| Function                  | Signature         | Description |
|---------------------------|-------------------|-------------|
| __quantum__rt__message    | `void(%String*)`  | Include the given message in the computation's execution log or equivalent. |
| __quantum__rt__fail       | `void(%String*)`  | Fail the computation with the given error message. |

## Memory Management

QIR does not require the runtime to provide garbage collection. Instead, it specifies a set of runtime functions that can be used by the language specific compiler to implement a reference counting scheme if needed, if the source language requires automatic memory management.

### Reference and Alias Counting

QIR specifies a set of runtime functions for types that are represented as pointers that may be used by the language-specific compiler to expose them as immutable types in the language. The exception is the `%Qubit*` type, for which no such functions exist since the management of quantum memory is distinct from classical memory management, see [here](Quantum-Runtime.md#qubits) for more detail.

To ensure that unnecessary copying of data can be avoided, QIR distinguishes two kinds of counts that can be tracked: reference counts and alias counts. 

Reference counts track the number of handles that allow access to a certain value *in LLVM*. They hence determine when the value can be released by the runtime; values are allocated with a reference count of 1, and will be released when their reference count reaches 0. 

Alias counts, on the other hand, track how many handles to a value exist *in the source language*. 
They determine when the runtime needs to copy data; when copy functions are invoked, the copy is executed only if the alias count is larger than 0, or the copy is explicitly forced. Alias counts are useful for optimizing the handling of data types that are represented as pointers in QIR, but are value types, i.e. immutable, within the source language. 

The compiler is responsible for generating code that tracks both counts correctly by injecting the corresponding calls to modify them. A call to modify such counts will only ever modify the count for the given instance itself and not for any inner items such as the elements of a tuple or an array, or a value captured by a callable; the compiler is responsible for injecting calls to update counts for inner items as needed.
A runtime implementation is free to provide another mechanism for garbage collection and to treat calls to modify reference counts as hints or as simple no-ops.

- Runtime routines that create a new instance always initialize the instance
  with a reference count of 1, and an alias count of 0.
- For each pointer type, with the exception of `%Qubit*`, 
  a runtime function ending in `_update_reference_count` exists that can be used to modify the reference count of an instance as needed. If the reference count reaches 0, the instance may be released. Decreasing the reference count below 0 or accessing a value after its reference count has reached 0 results in undefined behavior.
- For all data types that support a runtime function to create a shallow copy, 
  a runtime function ending in `_update_alias_count` exists that can be used to modify the alias count of an instance as needed. These functions exist for `%Tuple*`, `%Array*`, and `%Callable*` types. The alias count can never be negative; decreasing the alias count below 0 results in a runtime failure.
- The functions that modify reference and alias count should accept a 
  null instance pointer and simply ignore the call if the pointer is null.

---
_[Back to index](README.md)_
