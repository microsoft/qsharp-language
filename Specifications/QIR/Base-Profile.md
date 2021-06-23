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

- Declarations of the functions that make up the quantum instruction set. All of these functions start with a `__quantum__qis` prefix.
- Declarations of the functions that make up the QIR runtime. All of these functions start with a `__quantum__qir` prefix.
- Declarations of the `%Qubit`, `%Result`, and ... types.
- Declarations of the `%ResultZero` and `%ResultOne` constants. The values of these constants are not actually meaningful, although the names are.
- Definition of the [entry point function](#entry-point).
- Definitions of custom functions (subroutines), if any.

### Entry Point

The entry point will be a void LLVM function named `main`.


In LLVM, this looks like:

```llvm
define void main() {
entry:
    ; Function implementation goes here
}
```

### Classical Registers

All classical bits get mapped to a single global variable named `results`.
Each classical register becomes a global variable.
 to a fixed-size
array of bytes (LLVM type `[n x i8]`, for some fixed integer `n`)

// define write_bit and read_bit functions that take a bit position

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

### Custom Functions (Subroutines)

//

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

- Only built-in functions can take qubit parameters.
- ...
