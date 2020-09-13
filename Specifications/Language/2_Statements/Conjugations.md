# Conjugations

Conjugations are fairly omnipresent in quantum computations. Expressed in mathematical terms, they are patterns of the form *U†VU* for unitary transformations *U* and *V*. That pattern is especially relevant due to the particularities of quantum memory: To leverage the unique assets of quantum, computations build up quantum correlations -- i.e. entanglement. However, that also means that once qubits are no longer needed for a particular subroutine, they cannot easily be reset and released, since observing their state would impact the rest of the system. For that reason, the effects of a previous computation commonly need to be reversed prior to being able to release and reuse quantum memory. 

What's more is that there is a certain flexibility to when exactly to perform such cleanup, giving room for optimizations, similar to pebbling games. 
Additionally, it is useful to recognize the pattern when auto-generating a controlled version of an operation, since rather than having to control all three transformations it is sufficient to merely condition the execution of *V* on the state of the control qubits. This can easily be seen by remembering that if *V* is not applied, then *U†U* evaluates to the identity and no transformation is applied.
 
Having a dedicated representation for expressing conjugations makes sense not just from an optimization perspective but certainly also for user convenience, saving the trouble of having the explicitly express the cleanup in source code and making code more concise. 

The example of the `ApplyXOrIfGreater` operation defined in the arithmetic library demonstrates the usage of such a conjugation in practice.
The operation maps |lhs⟩|rhs⟩|res⟩ → |lhs⟩|rhs⟩|res ⊕ (lhs>rhs)⟩, i.e. it coherently applies an XOR to a given qubit `res` if the quantum integer represented by `lhs` is greater than the one in `rhs`. The two integers are expected to be represented in little endian encoding, as indicated by the usage of the corresponding data type.

```qsharp
    operation ApplyXOrIfGreater(
        lhs : LittleEndian, 
        rhs : LittleEndian, 
        res : Qubit
    ) : Unit is Adj + Ctl {
  
        let (x, y) = (lhs!, rhs!);
        let shuffled = Zip3(Most(x), Rest(y), Rest(x));

        using (anc = Qubit()) {
            within { 
                ApplyToEachCA(X, x + [anc]);
                ApplyMajorityInPlace(x[0], [y[0], anc]);
                ApplyToEachCA(MAJ, shuffled);
            } 
            apply { 
                X(res);
                CNOT(Tail(x), res);
            }
        }
    }

```

A temporarily used storage qubit `anc` is automatically cleaned up before it is released at the end of the `using`-block; the statements in the `within`-block are applied first, followed by the statements in the `apply`-block, and finally the automatically generated adjoint of the `within`-block is applied to clean up the temporarily used helper qubit `anc`. The example doesn't illustrate that both blocks may contain arbitrary classical computations as well. The only exception is
that mutably bound variables that are used as part of the `within`-block may not be reassigned as part of the `apply`-block. The reason for this restriction is less a technical one, but more to prevent confusion regarding the expected behavior in this case. 

What is not yet supported for technical reasons is to permit to return from within the `apply`-block. It should be possible to support this in the future. The expected behavior in this case is to evaluate the returned value before the adjoint of the `within`-block is executed, any qubits going out of scope are released (`anc` in this case), and the control is returned to the callee. In short, the statement should behave similarly to a `try-finally` pattern in C#. However, the necessary functionality is not yet implemented. 
