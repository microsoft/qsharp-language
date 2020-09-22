# Conjugations

Conjugations are fairly omnipresent in quantum computations. Expressed in mathematical terms, they are patterns of the form *U†VU* for unitary transformations *U* and *V*. That pattern is especially relevant due to the particularities of quantum memory: To leverage the unique assets of quantum, computations build up quantum correlations, i.e. entanglement. However, that also means that once qubits are no longer needed for a particular subroutine, they cannot easily be reset and released, since observing their state would impact the rest of the system. For that reason, the effects of a previous computation commonly need to be reversed prior to being able to release and reuse quantum memory. 

Q# hence has a dedicated statement for expressing computation that require such a subsequent clean-up. The statement consists of two code blocks, one containing the implementation of *U* and one containing the implementation of *V*. The uncomputation (i.e. the application of *U†*) is done automatically as part of the statement. 

The statement takes the form
```qsharp
within {
    <statements>
}
apply {
    <statements>
}
```
where `<statements>` is to be replaced with any number of statements defining the implementation of *U* and *V* respectively.
Both blocks may contain arbitrary classical computations, aside from the usual restrictions for automatically generating adjoint versions that apply to the `within`-block. Mutably bound variables that are used as part of the `within`-block may not be reassigned as part of the `apply`-block.  

The example of the `ApplyXOrIfGreater` operation defined in the arithmetic library illustrates the usage of such a conjugation:
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

A temporarily used storage qubit `anc` is automatically cleaned up before it is released at the end of the `using`-block; the statements in the `within`-block are applied first, followed by the statements in the `apply`-block, and finally the automatically generated adjoint of the `within`-block is applied to clean up the temporarily used helper qubit `anc`. 

### *Discussion*
>Returning control from within the `apply`-block is not yet supported. It should be possible to support this in the future. The expected behavior in this case is to evaluate the returned value before the adjoint of the `within`-block is executed, any qubits going out of scope are released (`anc` in this case), and the control is returned to the callee. In short, the statement should behave similarly to a `try-finally` pattern in C#. However, the necessary functionality is not yet implemented. 
