# QIR Base Profile Sample Programs

In all of the samples, we have dropped the QIR declarations that are not used in the base profile.
We have inserted some explanatory comments in the QIR LLVM code.
We have followed a style of inserting the qubit assignments as late as possible, but they could instead
all appear at the start of `qmain`.

## [OpenQASM 2.0 QFT](https://github.com/Qiskit/openqasm/blob/OpenQASM2.x/examples/qft.qasm)

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
define void @cu1_body(double %theta, %Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b) {
entry:
    %theta_2 = fdiv double %theta, 2.0
    call void quantum_qis_rz_body(double %theta_2, %Qubit addrspace(2)* %a)
    call void quantum_qis_cnot_body(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b);
    %neg_theta_2 = fsub double 0.0, %theta_2
    call void quantum_qis_rz_body(double %neg_theta_2, %Qubit addrspace(2)* %a)
    call void quantum_qis_cnot_body(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b);
    call void quantum_qis_rz_body(double %theta_2, %Qubit addrspace(2)* %b)
}

; The main OpenQASM program
define void @quantum_main() {
entry:
    ; The "q" qubit array is mapped to device qubits 0-3
    %q0 = inttoptr i32 0 to %Qubit addrspace(2)*
    call void @quantum_qis_x_body(%Qubit addrspace(2)* %q0)
    %q2 = inttoptr i32 0 to %Qubit addrspace(2)*
    call void @quantum_qis_x_body(%Qubit addrspace(2)* %q2)
    ; We assume barrier is a quantum instruction, rather than using the LLVM fence instruction
    call void @quantum_qis_barrier()
    call void @quantum_qis_h_body(%Qubit addrspace(2)* %q0)

    %q1 = inttoptr i32 1 to %Qubit addrspace(2)*
    call void @cu1(double 1.5707963267948966192313216916398, %q1, %q0)
    call void @quantum_qis_h_body(%Qubit addrspace(2)* %q1)

    call void @cu1(double 0.78539816339744830961566084581988, %q2, %q0)
    call void @cu1(double 1.5707963267948966192313216916398, %q2, %q1)
    call void @quantum_qis_h_body(%Qubit addrspace(2)* %q2)

    %q3 = inttoptr i32 3 to %Qubit addrspace(2)*
    call void @cu1_body(double 0.39269908169872415480783042290994, %q3, %q0)
    call void @cu1_body(double 0.78539816339744830961566084581988, %q3, %q1)
    call void @cu1_body(double 1.5707963267948966192313216916398, %q3, %q2)
    call void @quantum_qis_h_body(%Qubit addrspace(2)* %q3)

    call void quantum_qis_mz_body(%Qubit addrspace(2)* %q0, 0)
    call void quantum_qis_mz_body(%Qubit addrspace(2)* %q1, 1)
    call void quantum_qis_mz_body(%Qubit addrspace(2)* %q2, 2)
    call void quantum_qis_mz_body(%Qubit addrspace(2)* %q3, 3)
}
```

## [OpenQASM 2.0 Adder](https://github.com/Qiskit/openqasm/blob/OpenQASM2.x/examples/adder.qasm)

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
define void @majority_body(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b, %Qubit addrspace(2)* %c) {
    call void quantum_qis_cnot(%Qubit addrspace(2)* %c, %Qubit addrspace(2)* %b);
    call void quantum_qis_cnot(%Qubit addrspace(2)* %c, %Qubit addrspace(2)* %a);
    call void quantum_qis_toffoli(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b, %Qubit addrspace(2)* %c);
}

; The "unmaj" custom gate
define void @unmaj_body(%Qubit addrspace(2)* %a, %Qubit addrspace(2)* %b, %Qubit addrspace(2)* %c) {
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
    call void @quantum_qis_x_body(%Qubit addrspace(2)* %a0)

    %b0 = inttoptr i32 5 to %Qubit addrspace(2)*
    call void @quantum_qis_x_body(%Qubit addrspace(2)* %b0)
    %b1 = inttoptr i32 6 to %Qubit addrspace(2)*
    call void @quantum_qis_x_body(%Qubit addrspace(2)* %b1)
    %b2 = inttoptr i32 7 to %Qubit addrspace(2)*
    call void @quantum_qis_x_body(%Qubit addrspace(2)* %b2)
    %b3 = inttoptr i32 8 to %Qubit addrspace(2)*
    call void @quantum_qis_x_body(%Qubit addrspace(2)* %b3)

    %cin = inttoptr i32 0 to %Qubit addrspace(2)*
    call void @majority_body(%Qubit addrspace(2)* %cin, %Qubit addrspace(2)* %b0, %Qubit addrspace(2)* %a0)
    %a1 = inttoptr i32 2 to %Qubit addrspace(2)*
    call void @majority_body(%Qubit addrspace(2)* %a0, %Qubit addrspace(2)* %b1, %Qubit addrspace(2)* %a1)
    %a2 = inttoptr i32 3 to %Qubit addrspace(2)*
    call void @majority_body(%Qubit addrspace(2)* %a1, %Qubit addrspace(2)* %b2, %Qubit addrspace(2)* %a2)
    %a3 = inttoptr i32 4 to %Qubit addrspace(2)*
    call void @majority_body(%Qubit addrspace(2)* %a2, %Qubit addrspace(2)* %b3, %Qubit addrspace(2)* %a3)
    %cout = inttoptr i32 9 to %Qubit addrspace(2)*
    call void @quantum_qis_cnot_body(%Qubit addrspace(2)* %a3, %Qubit addrspace(2)* %cout)
    call void @unmaj_body(%Qubit addrspace(2)* %a2, %Qubit addrspace(2)* %b3, %Qubit addrspace(2)* %a3)
    call void @unmaj_body(%Qubit addrspace(2)* %a1, %Qubit addrspace(2)* %b2, %Qubit addrspace(2)* %a2)
    call void @unmaj_body(%Qubit addrspace(2)* %a0, %Qubit addrspace(2)* %b1, %Qubit addrspace(2)* %a1)
    call void @unmaj_body(%Qubit addrspace(2)* %cin, %Qubit addrspace(2)* %b0, %Qubit addrspace(2)* %a0)

    call void quantum_qis_mz_body(%Qubit addrspace(2)* %b0, 0)
    call void quantum_qis_mz_body(%Qubit addrspace(2)* %b1, 1)
    call void quantum_qis_mz_body(%Qubit addrspace(2)* %b2, 2)
    call void quantum_qis_mz_body(%Qubit addrspace(2)* %b3, 3)
    call void quantum_qis_mz_body(%Qubit addrspace(2)* %cout, 4)
}
```
