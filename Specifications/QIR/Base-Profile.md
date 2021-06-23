# Basic QIR Profile

## Introduction

// This profile is for OpenQASM 2.0 and such like
// no assignments, no variables
// need to represent: classical bitregister, device qubits

## Description

### Data Types

// Int and double, but only literals and passing to subroutines, no arithmetic or the like
// Qubits are normal, see below
// Booleans are literals only

### Program Structure

The QIR representing a quantum program consists of a single file containing the LLVM bitcode. The human readable equivalent of that bitcode can be obtained using standard LLVM tools, and consists of a header

The LLVM IR file contains the following:

- Declarations of the functions that make up the quantum instruction set. All of these functions start with a `quantum_qis_` prefix.
- Declarations of the functions that make up the QIR runtime. All of these functions start with a `quantum_qir_` prefix.
- Declarations of the `%Qubit`, `%Result`, and ... types.
- Declarations of the `%ResultZero` and `%ResultOne` constants. The values of these constants are not actually meaningful, although the names are.
- Definition of the [entry point function](#entry-point).
- Definitions of custom functions (subroutines), if any.

### Entry Point

The entry point will be a void LLVM function named `qmain`.

In LLVM, this looks like:

```llvm
define void qmain() {
entry:
    ; Function implementation goes here
}
```

### Classical Register

All classical bits get mapped to a single global variable named `qresults`.
The QIR generator should compute the total required number of classical bits,
round that up to a full byte, and define `qresults` as a global byte array of the
required size (or larger).

For example, if between 17 and 24 bits are required, the following LLVM code would appear:

```llvm
@qresults = global [3 x i8]
```

The classical bits for all classical registers are stored together in the
`qresults` global.
The QIR generator is responsible for mapping bits in specific classical registers
to bits within the `qresults` global.

All classical bits are accessed using the `quantum_qir_read_qresult` and 
`quantum_qir_write_qresult` functions, which will be defined in the QIR file as:

```llvm
define i1 quantum_qir_read_qresult(i32 bitNumber) {
    ; code to go here
}

define void quantum_qir_write_qresult(i32 bitNumber, i1 value) {
    ; code to go here
}
```

### Device Qubits

Qubits are represented as pointers to the opaque `%Qubit` type.
In this protocol, device qubits are not allocated and released;
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

### Custom Functions (Subroutines)

Custom functions can take integer, double, or qubit parameters.
All custom functions are void; results are communicated through the
global classical register.

Custom functions may not be directly or indirectly recursive.

### Control Flow

The only forms of control flow allowed in the basic profile are:

- Branching based on the contents of a classical bit; and
- Calling a subroutine.

Branching based on Boolean combinations of classical bits should be
expressed by multiple branches; for example,

// example of branching on a[0] && a[1]

### Quantum Instruction Set

These are LLVM function declarations without an implementation.

### Dealing with Measurements

Measurements take the qubit to measure and the global creg offset and are responsible
for putting the measurement result as a bit into the creg properly.

## Sample Programs

// In OpenQASM and in QIR

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

## Profile Specification

// More precise specification; e.g.:

- ...
