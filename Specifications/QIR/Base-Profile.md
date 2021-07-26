# Basic QIR Profile

## Introduction

This QIR profile is intended for quantum hardware that supports limited control flow but not classical computations otherwise.

## Description

### Program Structure

The QIR representing a quantum program consists of a single file containing the LLVM bitcode. The human readable equivalent of that bitcode can be obtained using standard LLVM tools. The LLVM IR file contains the following, not necessarily in this precise order:

- The declaration of the [`%Qubit` data type](#qubits) as opaque type.
- The definitions of the `ClassicalStorage` global and the `__quantum__qir__read_result` and `__quantum__qir__write_result` functions, as described in more detail [below](#classical-bits).
- The declarations of the functions that make up the quantum instruction set. All of these functions start with a `__quantum__qis__` prefix.
- The definition of the [entry point and interop functions](#entry-point) as well as the corresponding attributes.
- The definitions of [custom functions (subroutines)](#custom-functions).

### Data Types

Integers and double-precision floating point numbers are available as in full QIR;
however, computations using these numeric types are not available.

The QIR types `%Result`, `%Pauli`, `%Range`, `%String`, `%BigInteger`, `%Array`, `%Tuple`, and `%Callable` and the corresponding pointer types should not be used in the basic profile.

### Qubits

Qubits are represented as pointers to the opaque `%Qubit` type.
In the basic control flow profile, qubits are not allocated and released and the following functions are **not available**:
- `__quantum__rt__qubit_allocate`, 
- `__quantum__rt__qubit_allocate_array`, 
- `__quantum__rt__qubit_release`, 
- `__quantum__rt__qubit_release_array`.

Instead, it is assumed that qubits are identified by an integer
that is the qubit pointer value in "qubit address space".
We conventionally reserve LLVM address space 2 for qubits.

For instance, to initialize a value that identifies device qubit 3,
the following LLVM code would be used:

```llvm
    %qubit3 = inttoptr i32 3 to %Qubit addrspace(2)*
```

Beyond creating a `%Qubit*` in that manner, the only operations that may be performed on qubits are passing them to functions.
In particular, even though qubits are represented as pointers, it is not
legal to dereference a qubit.

### Classical Bits

The QIR should define storage space for measurements in the form of a byte array that can be accessed via the global variable `ClassicalStorage`.
How that space is used is up to the QIR generator; it may opt to populate some of the bits with classical data representing e.g. constant bit values in the program.

The classical storage is allocated as a byte array, meaning the number of classical bits available for storage is expected to be a multiple of 8. 
For example, if between 17 and 24 bits are required by a program, the following LLVM code would appear:

```llvm
@ClassicalStorage = global [3 x i8]
```

All classical bits are accessed using the `__quantum__qir__read_result` and 
`__quantum__qir__write_result` functions, which will be defined in the QIR file as:

```llvm
define i1 @__quantum__qir__read_result(i32 bit_number) {
    ; If the ClassicalStorage variable is a single byte, then the following line may be
    ; optimized away as byte_index will always be 0.
    %byte_index = udiv i32 %bit_number, 8
    %bit_index = urem i32 %bit_number, 8
    ; In the following line, "3" should get replaced by the actual number of bytes in the
    ; ClassicalStorage variable.
    %byte_ptr = getelemptr [3 x i8], [3 x i8]* @ClassicalStorage, i64 0, i32 %byte_index
    %orig_byte = load i8, i8* %byte_ptr
    %mask = shl i8 1, %bit_index
    %bit = and i8 %orig_byte, %mask
    %result = icmp ne i8 %bit, 0
    ret %result
}

define void @__quantum__qir__write_result(i32 bit_number, i1 value) {
    %byte_index = udiv i32 %bit_number, 8
    %bit_index = urem i32 %bit_number, 8
    %byte_ptr = getelemptr [3 x i8], [3 x i8]* @ClassicalStorage, i64 0, i32 %byte_index
    %orig_byte = load i8, i8* %byte_ptr
    %mask = shl i8 1, %bit_index
    br i1 %value, label %set, label %clear
set:
    %new_byte_1 = or i8 %mask, %orig_byte
    br label %update
clear:
    %not_mask = xor i8 %mask, 255
    %new_byte_2 = and i8 %not_mask, %orig_byte
    br label %update
update:
    %new_byte = phi i8 [ %new_byte_1, %set ], [ %new_byte_2, %clear ]
    store i8 %new_byte, i8* %byte_ptr
    ret void
}
```

If either or both of these functions aren't used in the program,
the QIR generator may omit them from the LLVM file.

### Quantum Instruction Set

All quantum instructions are represented by LLVM external functions.
Quantum instructions may take qubits, doubles, or integers as parameters,
and should all have no return; that is, they should be void.

Measurements should take an offset into the `ClassicalStorage` global as a parameter.
The measurement result should be stored into the corresponding bit in `ClassicalStorage`.

The LLVM functions that implement the quantum instruction set should all have
names that start with `__quantum__qis__`.

QIR does not specify the contents of the quantum instruction set.
However, in order to ensure some amount of uniformity, implementations that provide
any of the following quantum instructions must match the specified definition:

| Operation Name | LLVM Function Declaration  | Description | Matrix |
|----------------|----------------------------|-------------|--------|
| CCx, CCNOT, Toffoli | `__quantum__qis__toffoli__body (%Qubit addrspace(2)* control1, %Qubit addrspace(2)* control1, %Qubit addrspace(2)* target)` | Toffoli or doubly-controlled X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+1+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+1+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+1+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Cx, CNOT | `__quantum__qis__cnot__body (%Qubit addrspace(2)* control, %Qubit addrspace(2)* target)` | CNOT or singly-controlled X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+1+%5C%5C+0+%26+0+%26+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Cz | `__quantum__qis__cz__body (%Qubit addrspace(2)* control, %Qubit addrspace(2)* target)` | Singly-controlled Z | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+1+%26+0+%5C%5C+0+%26+0+%26+0+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |
| H | `__quantum__qis__h__body (%Qubit addrspace(2)* q)` | Hadamard | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cfrac%7B1%7D%7B%5Csqrt%7B2%7D%7D%5Cbegin%7Bbmatrix%7D+1+%26+1+%5C%5C+1+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Mz or Measure | `__quantum__qis__mz__body (%Qubit addrspace(2)* q, i32 result_offset)` | Measure a qubit along the the Pauli Z axis |
| Reset | `__quantum__qis__reset__body (%Qubit addrspace(2)* q)` | Prepare a qubit in the \|0⟩ state |
| Rx | `__quantum__qis__rx__body (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli X axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+-i%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+-i%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Ry | `__quantum__qis__ry__body (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli Y axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+-%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Rz | `__quantum__qis__rz__body (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli Z axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+e%5E%7B-i+%5Ctheta%2F2%7D+%26+0+%5C%5C+0+%26+e%5E%7Bi+%5Ctheta%2F2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) | |
| S | `__quantum__qis__s__body (%Qubit addrspace(2)* q)` | S (phase gate)  | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+i+%5C%5C+%5Cend%7Bbmatrix%7D) |
| S&dagger; | `__quantum__qis__s_adj (%Qubit addrspace(2)* q)` | The adjoint of S | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+-i+%5C%5C+%5Cend%7Bbmatrix%7D) |
| T | `__quantum__qis__t__body (%Qubit addrspace(2)* q)` | T | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+e%5E%7Bi%5Cpi%2F4%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| T&dagger; | `__quantum__qis__t__adj (%Qubit addrspace(2)* q)` | The adjoint of T operation | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+e%5E%7B-i%5Cpi%2F4%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| X | `__quantum__qis__x__body (%Qubit addrspace(2)* q)` | Pauli X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+0+%26+1+%5C%5C+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Y | `__quantum__qis__y__body (%Qubit addrspace(2)* q)` | Pauli Y | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+0+%26+-i+%5C%5C+i+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Z | `__quantum__qis__z__body (%Qubit addrspace(2)* q)` | Pauli Z | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |

### Control Flow

The only forms of control flow allowed in the basic profile are:

- Branching (if/then/else) based on the contents of a classical bit; and
- Calling a subroutine.

Branching based on Boolean combinations of classical bits should be
expressed by a sequence of branches; for example, to execute a block of
code only if both classical bits 2 and 4 are 1, use LLVM code such as:

```llvm
    %0 = call i1 @__quantum__qir__read_result(i32 2)
    br i1 %0, label %block1, label %continue
block1:
    %1 = call i1 @__quantum__qir__read_result(i32 4)
    br i1 %0, label %true-block, label %continue
true-block:
    ; Code to execute when ClassicalStorage[2] && ClassicalStorage[4] == 1
    br label %continue
continue:
    ; Function continues here
```

### Custom Functions

Custom functions can take integer, double, or qubit parameters.
All custom functions are void; results are communicated through the
global classical register.

Custom functions may not be directly or indirectly recursive.

Names that begin with `__quantum__` are reserved for use by the
QIR runtime and the quantum instruction set.
Custom functions should not have names that conflict with these names.

### Entry Point and Interop Functions

For the purpose of interoperability with other languages and to facilitate command line handling, 
a QIR generator may choose to generate C-callable wrapper functions that call into QIR code but do not adhere to the QIR specification.
Such functions may only be called from external code, meaning they may not be called by anything within QIR itself. 
They are marked with at least one of the following custom attributes:

```llvm
attributes #1 = { "InteropFriendly" }
attributes #3 = { "EntryPoint" }
```

### LLVM Restrictions

Aside from within entry point and interop functions, 
the following LLVM IR instructions are the only ones allowed in the base profile:

- `ret`
- `br`
- `call`

Other LLVM IR instructions are not allowed.
In particular, no integer arithmetic, comparisons, or memory accesses are allowed, and therefore no loops.
