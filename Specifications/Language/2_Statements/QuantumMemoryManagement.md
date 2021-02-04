# Quantum Memory Management

A program always starts with no qubits, meaning values of type `Qubit` cannot be passed as entry point arguments. This restriction is intentional, since a purpose of Q# is to express and reason about a program in its entirety.
Instead, a program allocates and releases quantum memory as it goes.
In this regard, Q# models the quantum computer as a qubit heap.

Rather than supporting separate allocate and release statements for quantum memory, 
Q# supports quantum memory allocation in the form of block statements, where the memory is accessible only within the scope of that statement. An attempt to access that memory after the statement terminates will result in a runtime exception.

### *Discussion* 
>Forcing that qubits cannot escape their scope greatly facilitates reasoning about quantum dependencies and how the quantum parts of the computation can impact the continuation of the program. 
>An additional benefit of this setup is that qubits cannot get allocated and never freed, which avoids a class of common bugs in manual memory management languages without the overhead of qubit garbage collection.

Q# has two statements to instantiate qubit values, arrays of qubits, or any combination thereof. Both of these statements can only be used within operations. They gather the instantiated qubit values, bind them to the variable(s) specified in the statement, and then execute a block of statements.
At the end of the block, the bound variables go out of scope and are no longer defined.

Q# distinguishes between the allocation of "clean" qubits, meaning qubits that are unentangled and are not used by another part of the computation, and what is often referred to as "dirty" qubits, meaning qubits whose state is unknown and can even be entangled with other parts of the quantum processor's memory.

## Use-Statement

Clean qubits are allocated by the `use`-statement.
The statement consists of the keyword `use` followed by a binding and an optional statement block.
If a statement block is present, the qubits are only available within that block.
Otherwise, the qubits are available until the end of the current scope.
The binding follows the same pattern as `let` statements: either a single symbol or a tuple of symbols, followed by an equals sign `=`, and either a single tuple or a matching tuple of *initializers*.

Initializers are available either for a single qubit, indicated as `Qubit()`, or an array of qubits, `Qubit[n]`, where `n` is an `Int` expression.
For example,

```qsharp
use qubit = Qubit();
// ...

use (aux, register) = (Qubit(), Qubit[5]);
// ...

use qubit = Qubit() {
    // ...
}

use (aux, register) = (Qubit(), Qubit[5]) {
    // ...
}
```

The qubits are guaranteed to be in a |0⟩ state upon allocation. They are released at the end of the scope and are required to either be in a |0⟩ state upon release, or to have been measured right beforehand. This requirement is not compiler-enforced, since this would require a symbolic evaluation that quickly gets prohibitively expensive. When executing on simulators, the requirement can be runtime enforced. On quantum processors, the requirement cannot be runtime enforced; an unmeasured qubit may be reset to |0⟩ via unitary transformation. Failing to do so will result in incorrect behavior. 

The `use`-statement allocates the qubits from the quantum processor's free qubit heap, and returns them to the heap no later than the end of the scope in which the qubits are bound.

## Borrow-Statement

The `borrow`-statement is used to make qubits available for temporary use, which do not need to be in a specific state:
Some quantum algorithms are capable of using qubits without relying on their exact state - or even that they are unentangled with the rest of the system. That is, they require extra qubits temporarily, but they can ensure that those qubits are returned exactly to their original state independent of which state that was. 

If there are qubits that are in use but not touched during the execution of a subroutine, those qubits can be borrowed for use by such an algorithm instead of having to allocate additional quantum memory. 
Borrowing instead of allocating can significantly reduce the overall quantum memory requirements of an algorithm, and is a quantum example of a typical space-time tradeoff. 

A `borrow`-statement follows the same pattern as described [above](#use-statement) for a `use`-statement, with the same initializers being available.
For example,
```qsharp
borrow qubit = Qubit();
// ...

borrow (aux, register) = (Qubit(), Qubit[5]);
// ...

borrow qubit = Qubit() {
    // ...
}

borrow (aux, register) = (Qubit(), Qubit[5]) {
    // ...
}
```
The borrowed qubits are in an unknown state and go out of scope at the end of the statement block.
The borrower commits to leaving the qubits in the same state they were in when they were borrowed,  i.e. their state at the beginning and at the end of the statement block is expected to be the same.

The `borrow`-statement retrieves in-use qubits that are guaranteed not to be used from the time the qubit is bound until the last usage of that qubit.
If there aren't enough qubits available to borrow, then qubits will be allocated from and returned to the heap like a `use` statement.

### *Discussion*
>Among the known use cases of dirty qubits are implementations of multi-controlled CNOT gates that require only very few qubits and implementations of incrementers.
>This [paper](https://arxiv.org/abs/1611.07995) gives an example of an algorithm that utilizes borrowed qubits.



