## Classical Runtime

Most functions in the classical runtime are defined in the
[Data Types](Data-Types.md) specification.

### Memory Management

The quantum runtime is not required to provide garbage collection.
Rather, the compiler should generate code that generates proper allocation
for values on the stack or heap, and ensure that heap space is properly
released when no longer necessary.

We define the following functions for allocating and releasing heap memory,
They should provide the same behavior as the standard C library functions malloc and free.

| Function                  | Signature   | Description |
|---------------------------|-------------|-------------|
| __quantum__rt__heap_alloc | `i8*(i32)`  | Allocate a block of memory on the heap. |
| __quantum__rt__heap_free  | `void(i8*)` | Release a block of allocated heap memory. |

### Logging and Termination

| Function                  | Signature         | Description |
|---------------------------|-------------------|-------------|
| __quantum__rt__message    | `void(%String*)`  | Include the given message in the computation's execution log or equivalent. |
| __quantum__rt__fail       | `void(%String*)`  | Fail the computation with the given error message. |

---
_[Back to index](README.md)_
