# Quantum Memory Management

A program always starts with no qubits, meaning passing values of type `Qubit` cannot be passed as entry point arguments. This restriction is intentional, since a purpose of Q# is to express and reason about a program in its entirety.
Instead, a program allocates and releases quantum memory as it goes.
In this regard, Q# models the quantum computer as a qubit heap.

Rather than supporting separate allocate and release statements or functions, Q# has two statements to instantiate qubit values, arrays of qubits, or any combination thereof.
Both of these statements gather the instantiated qubit values, bind them to the variable(s) specified in the statement, and then execute a block of statements.
At the end of the block, the bound variables go out of scope and are no longer defined.
These statements are thus block statements - meaning their body contains a block of statements -, and the instantiated qubit values can only be accessed within their body. Forcing that qubits cannot escape their scope greatly facilitates reasoning about quantum dependencies and how the quantum parts of the computation can impact the continuation of the program. 
An additional benefit of this setup is that qubits cannot get allocated and never freed, which avoids a class of common bugs in manual memory management languages without the overhead of qubit garbage collection.

Q# distinguishes between the allocation of "clean" qubits, meaning qubits that are unentangled and are not used by another part of the computation, and "dirty" qubits, described in more detail below. 
Clean qubits are allocated by the `using`-statement, and are guaranteed to be in a |0⟩ state upon allocation. They are released at the end of the scope and are required to either be in a |0⟩ state upon release, or to have been measured right beforehand. Of course, this requirement cannot be compiler-enforced in general, since this would require a symbolic evaluation that quickly gets prohibitively expensive. Execution on a special simulator for validation purposes, however, allows to do some decent checks whether that requirement is satisfied. 

Some quantum algorithms are capable of using qubits without relying on their exact state - or even that they are unentangled with the rest of the system. That is, they require extra qubits temporarily, but they can ensure that those qubits are returned exactly to their original state independent on which state that was. 
This means that if there are qubits that are in use but not touched during the execution of a subroutine, those qubits can be borrowed for use by such an algorithm instead of having to allocate additional quantum memory. 
Borrowing instead of allocating can significantly reduce the overall quantum memory requirements of an algorithm, and is a quantum example of a typical space-time tradeoff. 
Q# has a dedicated `borrowing`-statement for such a qubit use, where the qubits are returned at the end of the allocation scope so that they can no longer be accessed. 

For the `using`-statement, the qubits are allocated from the quantum computer's free qubit heap, and then returned to the heap.
For the `borrowing`-statement, the qubits are allocated from in-use qubits that are guaranteed not to be used during the body of the statement, and left in their original state at the end.
If there aren't enough qubits available to borrow, then qubits will be allocated from and returned to the heap.

Currently, Q# requires all allocations of quantum memory to be explicit. One might wonder whether allowing for implicit qubit allocations and deallocations would make sense in the future, in cases where additional scratch space is temporarily needed and readily cleaned up again. An example where this is the case is the construction of quantum oracles based on reversible classical functions. Introducing the concept of implicit quantum memory management requires further thorough considerations to ensure that there are no adverse effects for optimizing the quantum execution, and that the integration into the language is done in a consistent and holistic manner rather than in an ad-hoc way for selective cases only. 
