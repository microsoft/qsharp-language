# Quantum memory management

A program always starts without qubits, meaning you cannot pass values of type `Qubit` as entry point arguments. This restriction is intentional since the purpose of Q# is to express and reason about a program in its entirety.
Instead, a program allocates and releases qubits, or quantum memory, as it goes.
In this regard, Q# models the quantum computer as a qubit heap.

Rather than supporting separate *allocate* and *release* statements for quantum memory, 
Q# supports quantum memory allocation in the form of *block statements*, where the memory is accessible only within the scope of that block statement. The statement block can be implicitly defined when allocating qubits for the duration of the current scope, as described in more detail in the sections about the `use` and `borrow` statements. Attempting to access the allocated qubits after the statement terminates results in a runtime exception.


Q# has two statements, `use` and `borrow`, that instantiate qubit values, arrays of qubits, or any combination thereof. You can only use these statements within operations. They gather the instantiated qubit values, bind them to the variables specified in the statement, and then run a block of statements.
At the end of the block, the bound variables go out of scope and are no longer defined.

Q# distinguishes between the allocation of *clean* and *dirty* qubits. Clean qubits are unentangled and are not used by another part of the computation. Dirty qubits are qubits whose state is unknown and can even be entangled with other parts of the quantum processor's memory.

## Use statement

Clean qubits are allocated by the `use` statement.

- The statement consists of the keyword `use` followed by a binding and an optional statement block.
- If a statement block is present, the qubits are only available within that block.
Otherwise, the qubits are available until the end of the current scope.
- The binding follows the same pattern as `let` statements: either a single symbol or a tuple of symbols, followed by an equals sign `=`, and either a single tuple or a matching tuple of *initializers*.

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

The qubits are guaranteed to be in a |0⟩ state upon allocation. They are released at the end of the scope and are required to either be in a |0⟩ state upon release, or measured right beforehand. This requirement is not compiler-enforced since this would require a symbolic evaluation that quickly gets prohibitively expensive. When running on simulators, the requirement can be runtime enforced. On quantum processors, the requirement cannot be runtime enforced; an unmeasured qubit may be reset to |0⟩ via unitary transformation. Failing to do so results in incorrect behavior. 

The `use` statement allocates the qubits from the quantum processor's free qubit heap and returns them to the heap no later than the end of the scope in which the qubits are bound.

## Borrow statement

The `borrow` statement grants access to qubits that are already allocated but not currently in use. These qubits can be in an arbitrary state and need to be in the same state again when the borrow statement terminates.
Some quantum algorithms can use qubits without relying on their exact state, and without requiring that they are unentangled with the rest of the system. That is, they require extra qubits temporarily, but they can ensure that those qubits are returned exactly to their original state, independent of which state that was. 

If there are qubits that are in use but not touched during parts of a subroutine, those qubits can be borrowed for use by such an algorithm instead of allocating additional quantum memory. 
Borrowing instead of allocating can significantly reduce the overall quantum memory requirements of an algorithm and is a quantum example of a typical space-time tradeoff. 

A `borrow` statement follows the same pattern described previously for the [`use` statement](#use-statement), with the same initializers being available.
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
The borrower commits to leaving the qubits in the same state as when they were borrowed; that is, their state at the beginning and the end of the statement block is expected to be the same.

The `borrow` statement retrieves in-use qubits that are guaranteed not to be used by the program from the time the qubit is bound until the last use of that qubit.
If there aren't enough qubits available to borrow, then qubits are allocated from and returned to the heap like a `use` statement.

> [!NOTE]
> Among the known use-cases of dirty qubits are implementations of multi-controlled CNOT gates that require very few qubits, and implementations of incrementers. This [paper on factoring with qubits](https://arxiv.org/abs/1611.07995) provides an example of an algorithm that utilizes borrowed qubits.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
