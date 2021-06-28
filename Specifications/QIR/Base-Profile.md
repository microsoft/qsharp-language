# Basic QIR Profile

## Introduction

This QIR profile is intended to work well with current NISQ hardware with limited classical capabilities.
It roughly matches [OpenQASM 2.0](https://github.com/Qiskit/openqasm/tree/OpenQASM2.x), but should be suitable
for a wide variety of hardware using a variety of programming languages.

## Description

### Program Structure

The QIR representing a quantum program consists of a single file containing the LLVM bitcode. The human readable equivalent of that bitcode can be obtained using standard LLVM tools, and consists of a header

The LLVM IR file contains the following, not necessarily in this precise order:

- The declaration of the [`%Qubit` data type](#qubits).
- The definitions of the `quantum_results` global and the `quantum_qir_read_qresult` and `quantum_qir_write_qresult` functions; see [below](#classical-bits).
- The declarations of the functions that make up the quantum instruction set. All of these functions start with a `quantum_qis_` prefix.
- The definition of the [entry point function](#entry-point).
- The definitions of [custom functions (subroutines)](#custom-functions), if any.
- The declarations and definitions of various data types and globals for full QIR compatibility, such as the `%Result`, `%Array`, and `%Tuple` types and the `%ResultZero` and `%ResultOne` globals. These may be ignored for this profile.

### Data Types

Integers and double-precision floating point numbers are available as in full QIR;
however, computations using these numeric types are not available.

The QIR result, Pauli, range, string, big integer, array, tuple, and callable types
should not be used in the basic profile.

### Qubits

Qubits are represented as pointers to the opaque `%Qubit` type.
In the basic profile, device qubits are not allocated and released;
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

All classical bits get mapped to a single global variable named `quantum_results`.
The QIR generator should compute the total required number of classical bits,
round that up to a full byte, and define `quantum_results` as a global byte array of the
required size (or larger).

For example, if between 17 and 24 bits are required, the following LLVM code would appear:

```llvm
@quantum_results = global [3 x i8]
```

The classical bits for all classical registers are stored together in the
`quantum_results` global.
The QIR generator is responsible for mapping bits in specific classical registers
to bits within the `quantum_results` global.

All classical bits are accessed using the `quantum_qir_read_qresult` and 
`quantum_qir_write_qresult` functions, which will be defined in the QIR file as:

```llvm
define i1 @quantum_qir_read_qresult(i32 bit_number) {
    ; If the quantum_results variable is a single byte, then the following line may be
    ; optimized away as byte_index will always be 0.
    %byte_index = udiv i32 %bit_number, 8
    %bit_index = urem i32 %bit_number, 8
    ; In the following line, "3" should get replaced by the actual number of bytes in the
    ; quantum_results variable.
    %byte_ptr = getelemptr [3 x i8], [3 x i8]* @quantum_results, i64 0, i32 %byte_index
    %orig_byte = load i8, i8* %byte_ptr
    %mask = shl i8 1, %bit_index
    %bit = and i8 %orig_byte, %mask
    %result = icmp ne i8 %bit, 0
    ret %result
}

define void @quantum_qir_write_qresult(i32 bit_number, i1 value) {
    %byte_index = udiv i32 %bit_number, 8
    %bit_index = urem i32 %bit_number, 8
    %byte_ptr = getelemptr [3 x i8], [3 x i8]* @quantum_results, i64 0, i32 %byte_index
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

Measurements should take an offset into the `quantum_results` global as a parameter.
The measurement result should be stored into the appropriate bit in `quantum_results`.

The LLVM functions that implement the quantum instruction set should all have
names that start with `quantum_qis_`.

QIR does not specify the contents of the quantum instruction set.
However, in order to ensure some amount of uniformity, implementations that provide
any of the following quantum instructions must match the specified definition:

| Operation Name | LLVM Function Declaration  | Description | Matrix |
|----------------|----------------------------|-------------|--------|
| CCx, CCNOT, Toffoli | `quantum_qis_toffoli (%Qubit addrspace(2)* control1, %Qubit addrspace(2)* control1, %Qubit addrspace(2)* target)` | Toffoli or doubly-controlled X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+1+%26+0+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+1+%26+0+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+1+%5C%5C+0+%26+0+%26+0+%26+0+%26+0+%26+0+%26+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Cx, CNOT | `quantum_qis_cnot (%Qubit addrspace(2)* control, %Qubit addrspace(2)* target)` | CNOT or singly-controlled X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+0+%26+1+%5C%5C+0+%26+0+%26+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Cz | `quantum_qis_cz (%Qubit addrspace(2)* control, %Qubit addrspace(2)* target)` | Singly-controlled Z | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%26+0+%26+0+%5C%5C+0+%26+1+%26+0+%26+0+%5C%5C+0+%26+0+%26+1+%26+0+%5C%5C+0+%26+0+%26+0+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |
| H | `quantum_qis_h (%Qubit addrspace(2)* q)` | Hadamard | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cfrac%7B1%7D%7B%5Csqrt%7B2%7D%7D%5Cbegin%7Bbmatrix%7D+1+%26+1+%5C%5C+1+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Mz or Measure | `quantum_qis_mz (%Qubit addrspace(2)* q, i32 result_offset)` | Measure a qubit along the the Pauli Z axis |
| Reset | `quantum_qis_reset (%Qubit addrspace(2)* q)` | Prepare a qubit in the \|0⟩ state |
| Rx | `quantum_qis_rx (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli X axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+-i%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+-i%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Ry | `quantum_qis_ry (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli Y axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+-%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Csin+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%26+%5Ccos+%5Cfrac+%7B%5Ctheta%7D+%7B2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Rz | `quantum_qis_rz (%Qubit addrspace(2)* q, double theta)` | Rotate a qubit around the Pauli Z axis | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+e%5E%7B-i+%5Ctheta%2F2%7D+%26+0+%5C%5C+0+%26+e%5E%7Bi+%5Ctheta%2F2%7D+%5C%5C+%5Cend%7Bbmatrix%7D) | |
| S | `quantum_qis_s (%Qubit addrspace(2)* q)` | S (phase gate)  | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+i+%5C%5C+%5Cend%7Bbmatrix%7D) |
| S&dagger; | `quantum_qis_s_adj (%Qubit addrspace(2)* q)` | The adjoint of S | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+-i+%5C%5C+%5Cend%7Bbmatrix%7D) |
| T | `quantum_qis_t (%Qubit addrspace(2)* q)` | T | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+e%5E%7Bi%5Cpi%2F4%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| T&dagger; | `quantum_qis_t_adj (%Qubit addrspace(2)* q)` | The adjoint of T operation | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+e%5E%7B-i%5Cpi%2F4%7D+%5C%5C+%5Cend%7Bbmatrix%7D) |
| X | `quantum_qis_x (%Qubit addrspace(2)* q)` | Pauli X | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+0+%26+1+%5C%5C+1+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Y | `quantum_qis_y (%Qubit addrspace(2)* q)` | Pauli Y | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+0+%26+-i+%5C%5C+i+%26+0+%5C%5C+%5Cend%7Bbmatrix%7D) |
| Z | `quantum_qis_z (%Qubit addrspace(2)* q)` | Pauli Z | ![latex](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+-1+%5C%5C+%5Cend%7Bbmatrix%7D) |

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
    %0 = call i1 @quantum_qir_read_qresult(i32 2)
    br i1 %0, label %block1, label %continue
block1:
    %1 = call i1 @quantum_qir_read_qresult(i32 4)
    br i1 %0, label %true-block, label %continue
true-block:
    ; Code to execute when quantum_results[2] && quantum_results[4] == 1
    br label %continue
continue:
    ; Function continues here
```

### LLVM Restrictions

The following LLVM IR instructions are allowed in the base profile:

- `ret`
- `br`
- `call`
- Floating-point arithmetic (`fadd`, `fsub`, `fmul`, and `fdiv`), but one parameter must be a constant literal.

Other LLVM IR instructions are not allowed.
In particular, no integer arithmetic, comparisons, or memory accesses are allowed, and therefore no loops.

## Sample Programs

In all of the samples, we have dropped the QIR declarations that are not used in the base profile.
We have inserted some explanatory comments in the QIR LLVM code.
We have followed a style of inserting the qubit assignments as late as possible, but they could instead
all appear at the start of `qmain`.

### [OpenQASM 2.0 QFT](https://github.com/Qiskit/openqasm/blob/OpenQASM2.x/examples/qft.qasm)

In OpenQASM:

```qasm
// quantum Fourier transform
OPENQASM 2.0;
include "qelib1.inc";
qreg q[4];
creg c[4];
x q[0]; 
x q[2];
barrier q;
h q[0];
cu1(pi/2) q[1],q[0];
h q[1];
cu1(pi/4) q[2],q[0];
cu1(pi/2) q[2],q[1];
h q[2];
cu1(pi/8) q[3],q[0];
cu1(pi/4) q[3],q[1];
cu1(pi/2) q[3],q[2];
h q[3];
measure q -> c;
```

In the QIR base profile:

```llvm
; a total of 4 classical bits are used, so one byte is sufficient
@quantum_results = global [1 x i8]

; Since neither read_qresult nor write_qresult are used in this example,
; the QIR generator is free to not include their implementations.

; Definition of the cu1 function from [qelib1.inc](https://github.com/Qiskit/openqasm/blob/OpenQASM2.x/examples/qelib1.inc)
define void @cu1(double %theta, %Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b) {
entry:
    %theta_2 = fdiv double %theta, 2.0
    call void quantum_qis_rz(double %theta_2, %Qubit addrspace(2)* %a)
    call void quantum_qis_cnot(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b);
    %neg_theta_2 = fsub double 0.0, %theta_2
    call void quantum_qis_rz(double %neg_theta_2, %Qubit addrspace(2)* %a)
    call void quantum_qis_cnot(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b);
    call void quantum_qis_rz(double %theta_2, %Qubit addrspace(2)* %b)
}

; The main OpenQASM program
define void @quantum_main() {
entry:
    ; The "q" qubit array is mapped to device qubits 0-3
    %q0 = inttoptr i32 0 to %Qubit addrspace(2)*
    call void @quantum_qis_x(%Qubit addrspace(2)* %q0)
    %q2 = inttoptr i32 0 to %Qubit addrspace(2)*
    call void @quantum_qis_x(%Qubit addrspace(2)* %q2)
    ; We assume barrier is a quantum instruction, rather than using the LLVM fence instruction
    call void @quantum_qis_barrier()
    call void @quantum_qis_h(%Qubit addrspace(2)* %q0)

    %q1 = inttoptr i32 1 to %Qubit addrspace(2)*
    call void @cu1(double 1.5707963267948966192313216916398, %q1, %q0)
    call void @quantum_qis_h(%Qubit addrspace(2)* %q1)

    call void @cu1(double 0.78539816339744830961566084581988, %q2, %q0)
    call void @cu1(double 1.5707963267948966192313216916398, %q2, %q1)
    call void @quantum_qis_h(%Qubit addrspace(2)* %q2)

    %q3 = inttoptr i32 3 to %Qubit addrspace(2)*
    call void @cu1(double 0.39269908169872415480783042290994, %q3, %q0)
    call void @cu1(double 0.78539816339744830961566084581988, %q3, %q1)
    call void @cu1(double 1.5707963267948966192313216916398, %q3, %q2)
    call void @quantum_qis_h(%Qubit addrspace(2)* %q3)

    call void quantum_qis_mz(%Qubit addrspace(2)* %q0, 0)
    call void quantum_qis_mz(%Qubit addrspace(2)* %q1, 1)
    call void quantum_qis_mz(%Qubit addrspace(2)* %q2, 2)
    call void quantum_qis_mz(%Qubit addrspace(2)* %q3, 3)
}
```

### [OpenQASM 2.0 Adder](https://github.com/Qiskit/openqasm/blob/OpenQASM2.x/examples/adder.qasm)

In OpenQASM:

```qasm
// quantum ripple-carry adder from Cuccaro et al, quant-ph/0410184
OPENQASM 2.0;
include "qelib1.inc";
gate majority a,b,c 
{ 
  cx c,b; 
  cx c,a; 
  ccx a,b,c; 
}
gate unmaj a,b,c 
{ 
  ccx a,b,c; 
  cx c,a; 
  cx a,b; 
}
qreg cin[1];
qreg a[4];
qreg b[4];
qreg cout[1];
creg ans[5];
// set input states
x a[0]; // a = 0001
x b;    // b = 1111
// add a to b, storing result in b
majority cin[0],b[0],a[0];
majority a[0],b[1],a[1];
majority a[1],b[2],a[2];
majority a[2],b[3],a[3];
cx a[3],cout[0];
unmaj a[2],b[3],a[3];
unmaj a[1],b[2],a[2];
unmaj a[0],b[1],a[1];
unmaj cin[0],b[0],a[0];
measure b[0] -> ans[0];
measure b[1] -> ans[1];
measure b[2] -> ans[2];
measure b[3] -> ans[3];
measure cout[0] -> ans[4];
```

In the QIR base profile:

```llvm
; a total of 5 classical bits are used, so one byte is sufficient
@quantum_results = global [1 x i8]

; Since neither read_qresult nor write_qresult are used in this example,
; the QIR generator is free to not include their implementations.

; The "majority" custom gate
define void @majority(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b, %Qubit addrspace(2)* %c) {
    call void quantum_qis_cnot(%Qubit addrspace(2)* %c, %Qubit addrspace(2)* %b);
    call void quantum_qis_cnot(%Qubit addrspace(2)* %c, %Qubit addrspace(2)* %a);
    call void quantum_qis_toffoli(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b, %Qubit addrspace(2)* %c);
}

; The "unmaj" custom gate
define void @unmaj(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b, %Qubit addrspace(2)* %c) {
    call void quantum_qis_toffoli(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b, %Qubit addrspace(2)* %c);
    call void quantum_qis_cnot(%Qubit addrspace(2)* %c, %Qubit addrspace(2)* %a);
    ; This line matches the OpenQASM sample, but is incorrect. The first qubit should be %c, not %a.
    call void quantum_qis_cnot(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b);
}

; The main OpenQASM program
define void @quantum_main() {
entry:
    ; The "cin" qubit register is mapped to device qubit 0.
    ; The "a" qubit register is mapped to device qubits 1-4.
    ; The "b" qubit register is mapped to device qubit2 5-8.
    ; The "cout" qubit register is mapped to device qubit 9.
    %a0 = inttoptr i32 1 to %Qubit addrspace(2)*
    call void @quantum_qis_x(%Qubit addrspace(2)* %a0)

    %b0 = inttoptr i32 5 to %Qubit addrspace(2)*
    call void @quantum_qis_x(%Qubit addrspace(2)* %b0)
    %b1 = inttoptr i32 6 to %Qubit addrspace(2)*
    call void @quantum_qis_x(%Qubit addrspace(2)* %b1)
    %b2 = inttoptr i32 7 to %Qubit addrspace(2)*
    call void @quantum_qis_x(%Qubit addrspace(2)* %b2)
    %b3 = inttoptr i32 8 to %Qubit addrspace(2)*
    call void @quantum_qis_x(%Qubit addrspace(2)* %b3)

    %cin = inttoptr i32 0 to %Qubit addrspace(2)*
    call void @majority(%Qubit addrspace(2)* %cin, %Qubit addrspace(2)* %b0, %Qubit addrspace(2)* %a0)
    %a1 = inttoptr i32 2 to %Qubit addrspace(2)*
    call void @majority(%Qubit addrspace(2)* %a0, %Qubit addrspace(2)* %b1, %Qubit addrspace(2)* %a1)
    %a2 = inttoptr i32 3 to %Qubit addrspace(2)*
    call void @majority(%Qubit addrspace(2)* %a1, %Qubit addrspace(2)* %b2, %Qubit addrspace(2)* %a2)
    %a3 = inttoptr i32 4 to %Qubit addrspace(2)*
    call void @majority(%Qubit addrspace(2)* %a2, %Qubit addrspace(2)* %b3, %Qubit addrspace(2)* %a3)
    %cout = inttoptr i32 9 to %Qubit addrspace(2)*
    call void @quantum_qis_cnot(%Qubit addrspace(2)* %a3, %Qubit addrspace(2)* %cout)
    call void @unmaj(%Qubit addrspace(2)* %a2, %Qubit addrspace(2)* %b3, %Qubit addrspace(2)* %a3)
    call void @unmaj(%Qubit addrspace(2)* %a1, %Qubit addrspace(2)* %b2, %Qubit addrspace(2)* %a2)
    call void @unmaj(%Qubit addrspace(2)* %a0, %Qubit addrspace(2)* %b1, %Qubit addrspace(2)* %a1)
    call void @unmaj(%Qubit addrspace(2)* %cin, %Qubit addrspace(2)* %b0, %Qubit addrspace(2)* %a0)

    call void quantum_qis_mz(%Qubit addrspace(2)* %b0, 0)
    call void quantum_qis_mz(%Qubit addrspace(2)* %b1, 1)
    call void quantum_qis_mz(%Qubit addrspace(2)* %b2, 2)
    call void quantum_qis_mz(%Qubit addrspace(2)* %b3, 3)
    call void quantum_qis_mz(%Qubit addrspace(2)* %cout, 4)
}
```

### Current Format (to be removed)

```
OPENQASM 2.0;  
include "qelib1.inc";  

qreg q[3];  
creg c0[2];  
creg c1[5];  

h q[2];  
h q[0];
h q[1];
t q[0];
cx q[1], q[0];
tdg q[0];
h q[0];
measure q[0] -> c1[0];  
reset q[0];  
c0[0] = c1[0];  
if (c0==1) x q[0];  
c0[0] = 0;  
h q[0];  
c0[0] = c1[0];
if (c0==0) t q[2];
if (c0==0) z q[2];  
if (c0==0) cx q[2], q[1];  
if (c0==0) t q[1];  
if (c0==0) h q[1];  
if (c0==0) measure q[1] -> c1[1];  
if (c0==0) reset q[1];  
c0[1] = c1[1];  
if (c0==2) x q[1];
c0[1] = 0;  
if (c0==0) h q[1];  
c0[0] = 0;
rz(2.214297435588181) q[2];  
h q[1];
h q[0];  
measure q[0] -> c1[2];  
measure q[1] -> c1[3];  
h q[2];  
measure q[2] -> c1[4];  
```
