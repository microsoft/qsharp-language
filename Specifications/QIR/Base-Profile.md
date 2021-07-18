# Basic QIR Profile

## Introduction

This QIR profile is intended for quantum hardware that supports limited control flow but not classical computations otherwise.

## Description

### Program Structure

The QIR representing a quantum program consists of a single file containing the LLVM bitcode. The human readable equivalent of that bitcode can be obtained using standard LLVM tools. The LLVM IR file contains the following, not necessarily in this precise order:

- The declaration of the [`%Qubit` data type](#qubits).
- The definitions of the `measurement_results` global and the `quantum_qir_read_result` and `quantum_qir_write_result` functions; see [below](#classical-bits).
- The declarations of the functions that make up the quantum instruction set. All of these functions start with a `quantum_qis_` prefix.
- The definition of the [entry point function](#entry-point).
- The definitions of [custom functions (subroutines)](#custom-functions).

### Data Types

Integers and double-precision floating point numbers are available as in full QIR;
however, computations using these numeric types are not available.

The QIR result, Pauli, range, string, big integer, array, tuple, and callable types should not be used in the basic profile.

### Qubits

Qubits are represented as pointers to the opaque `%Qubit` type.
In the basic control flow profile, device qubits are not allocated and released;
instead, it is assumed that qubits are identified by an integer
that is the qubit pointer value in "qubit address space".
We conventionally reserve LLVM address space 2 for qubits.

For instance, to initialize a value that identifies device qubit 3,
the following LLVM code would be used:

```llvm
    %qubit3 = inttoptr i32 3 to %Qubit addrspace(2)*
```

The only operations that may be performed on qubits are initializing them
and passing them to functions.
In particular, even though qubits are represented as pointers, it is not
legal to dereference a qubit.

### Classical Bits

The QIR should define storage space for measurements in the form of a byte array that can be accessed via the global variable `measurement_results`.
How that space is used is up to the QIR generator; it may opt to populate some of the bits with classical data representing e.g. constant bit values in the program.

For example, if between 17 and 24 bits are required by a program, the following LLVM code would appear:

```llvm
@measurement_results = global [3 x i8]
```

All classical bits are accessed using the `quantum_qir_read_result` and 
`quantum_qir_write_result` functions, which will be defined in the QIR file as:

```llvm
define i1 @quantum_qir_read_result(i32 bit_number) {
    ; If the measurement_results variable is a single byte, then the following line may be
    ; optimized away as byte_index will always be 0.
    %byte_index = udiv i32 %bit_number, 8
    %bit_index = urem i32 %bit_number, 8
    ; In the following line, "3" should get replaced by the actual number of bytes in the
    ; measurement_results variable.
    %byte_ptr = getelemptr [3 x i8], [3 x i8]* @measurement_results, i64 0, i32 %byte_index
    %orig_byte = load i8, i8* %byte_ptr
    %mask = shl i8 1, %bit_index
    %bit = and i8 %orig_byte, %mask
    %result = icmp ne i8 %bit, 0
    ret %result
}

define void @quantum_qir_write_result(i32 bit_number, i1 value) {
    %byte_index = udiv i32 %bit_number, 8
    %bit_index = urem i32 %bit_number, 8
    %byte_ptr = getelemptr [3 x i8], [3 x i8]* @measurement_results, i64 0, i32 %byte_index
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

Measurements should take an offset into the `measurement_results` global as a parameter.
The measurement result should be stored into the appropriate bit in `measurement_results`.

The LLVM functions that implement the quantum instruction set should all have
names that start with `quantum_qis_`.

QIR does not specify the contents of the quantum instruction set.
However, in order to ensure some amount of uniformity, implementations that provide
any of the following quantum instructions must match the specified definition:

| Operation Name | LLVM Function Declaration  | Description | Matrix |
|----------------|----------------------------|-------------|--------|
| CCx, CCNOT, Toffoli | `quantum_qis_toffoli_body (%Qubit addrspace(2)* control1, %Qubit addrspace(2)* control1, %Qubit addrspace(2)* target)` | Toffoli or doubly-controlled X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+1+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+1+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+1+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Cx, CNOT | `quantum_qis_cnot_body (%Qubit addrspace(2)* control, %Qubit addrspace(2)* target)` | CNOT or singly-controlled X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+1+%5C%5C+0+%26+0+%26+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Cz | `quantum_qis_cz_body (%Qubit addrspace(2)* control, %Qubit addrspace(2)* target)` | Singly-controlled Z | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+1+%26+0+%5C%5C+0+%26+0+%26+0+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |
| H | `quantum_qis_h (%Qubit addrspace(2)* q)` | Hadamard | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cfrac%7B1%7D%7B%5Csqrt%7B2%7D%7D%5Cbegin%7Bbmatrix%7D+1+%26+1+%5C%5C+1+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Mz or Measure | `quantum_qis_mz_body (%Qubit addrspace(2)* q, i32 result_offset)` | Measure a qubit along the the Pauli Z axis |
| Reset | `quantum_qis_reset_body (%Qubit addrspace(2)* q)` | Prepare a qubit in the \|0⟩ state |
| Rx | `quantum_qis_rx_body (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli X axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+-i%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+-i%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Ry | `quantum_qis_ry_body (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli Y axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+-%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Rz | `quantum_qis_rz_body (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli Z axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+e%5E%7B-i+%5Ctheta%2F2%7D+%26+0+%5C%5C+0+%26+e%5E%7Bi+%5Ctheta%2F2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) | |
| S | `quantum_qis_s_body (%Qubit addrspace(2)* q)` | S (phase gate)  | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+i+%5C%5C+%5Cend%7Bbmatrix%7D) |
| S&dagger; | `quantum_qis_s_adj (%Qubit addrspace(2)* q)` | The adjoint of S | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+-i+%5C%5C+%5Cend%7Bbmatrix%7D) |
| T | `quantum_qis_t_body (%Qubit addrspace(2)* q)` | T | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+e%5E%7Bi%5Cpi%2F4%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| T&dagger; | `quantum_qis_t_adj (%Qubit addrspace(2)* q)` | The adjoint of T operation | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+e%5E%7B-i%5Cpi%2F4%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| X | `quantum_qis_x_body (%Qubit addrspace(2)* q)` | Pauli X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+0+%26+1+%5C%5C+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Y | `quantum_qis_y_body (%Qubit addrspace(2)* q)` | Pauli Y | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+0+%26+-i+%5C%5C+i+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Z | `quantum_qis_z_body (%Qubit addrspace(2)* q)` | Pauli Z | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |

### Entry Point

The entry point will be a void LLVM function named `quantum_main`.

In LLVM, this looks like:

```llvm
define void @quantum_main() {
entry:
    ; Function implementation goes here
}
```

### Custom Functions

Custom functions can take integer, double, or qubit parameters.
All custom functions are void; results are communicated through the
global classical register.

Custom functions may not be directly or indirectly recursive.

Names that begin with `quantum_` are reserved for use by the
QIR runtime and the quantum instruction set.
Custom functions should not have names that conflict with these names.

### Control Flow

The only forms of control flow allowed in the basic profile are:

- Branching (if/then/else) based on the contents of a classical bit; and
- Calling a subroutine.

Branching based on Boolean combinations of classical bits should be
expressed by a sequence of branches; for example, to execute a block of
code only if both classical bits 2 and 4 are 1, use LLVM code such as:

```llvm
    %0 = call i1 @quantum_qir_read_result(i32 2)
    br i1 %0, label %block1, label %continue
block1:
    %1 = call i1 @quantum_qir_read_result(i32 4)
    br i1 %0, label %true-block, label %continue
true-block:
    ; Code to execute when measurement_results[2] && measurement_results[4] == 1
    br label %continue
continue:
    ; Function continues here
```

### LLVM Restrictions

The following LLVM IR instructions are allowed in the base profile:

- `ret`
- `br`
- `call`

Other LLVM IR instructions are not allowed.
In particular, no integer arithmetic, comparisons, or memory accesses are allowed, and therefore no loops.
