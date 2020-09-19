## Classical Runtime

Most functions in the classical runtime are defined in the
[Data Types](https://github.com/microsoft/qsharp-language/blob/main/Specifications/QIR/Data-Types.md)
specification.

### Memory Management

The quantum runtime is not required to provide garbage collection.
Rather, the compiler should generate code that generates proper allocation
for values on the stack or heap, and ensure that heap space is properly
released when no longer necessary.

We define the following functions for allocating and releasing heap memory,
They should provide the same behavior as the standard C library functions malloc and free.

| Function              | Signature   | Description |
|-----------------------|-------------|-------------|
| quantum.rt.heap_alloc | `i8*(i32)`  | Allocate a block of memory on the heap. |
| quantum.rt.heap_free  | `void(i8*)` | Release a block of allocated heap memory. |

### Termination

| Function              | Signature         | Description |
|-----------------------|-------------------|-------------|
| quantum.rt.fail       | `void(%String*)`  | Fail the computation with the given error message. |
