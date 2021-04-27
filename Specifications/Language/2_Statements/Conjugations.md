# Conjugations

Conjugations are common in quantum computations. They are expressed in mathematical terms and are patterns of the form *U†VU* for the unitary transformations *U* and *V*. That pattern is relevant due to the particularities of quantum memory: computations build up quantum correlations, or *entanglement*, to leverage the unique assets of quantum. However, that also means that once a subroutine no longer needs its qubits, those qubits cannot easily be reset and released since observing their state would impact the rest of the system. For that reason, the effect of a previous computation usually needs to be reversed before releasing and reusing quantum memory.

Q# hence has a dedicated statement for expressing computations that require such a cleanup. The statement consists of two code blocks, one containing the implementation of *U* and one containing the implementation of *V*. The *uncomputation* (that is, the application of *U†*) is done automatically as part of the statement. 

The statement takes the form

```qsharp
within {
    <statements>
}
apply {
    <statements>
}
```

where `<statements>` is replaced with any number of statements defining the implementation of *U* and *V* respectively.
Both blocks may contain arbitrary classical computations, aside from the usual restrictions for automatically generating adjoint versions that apply to the `within` block. Mutably bound variables used as part of the `within` block may not be reassigned as part of the `apply` block.  

The example of the `ApplyXOrIfGreater` operation defined in the arithmetic library illustrates the usage of such a conjugation:
The operation maps |lhs⟩|rhs⟩|res⟩ → |lhs⟩|rhs⟩|res ⊕ (lhs>rhs)⟩, that is, it coherently applies an XOR to a given qubit `res` if the quantum integer represented by `lhs` is greater than the one in `rhs`. The two integers are represented in little-endian encoding, as indicated by the usage of the corresponding data type.

```qsharp
    operation ApplyXOrIfGreater(
        lhs : LittleEndian, 
        rhs : LittleEndian, 
        res : Qubit
    ) : Unit is Adj + Ctl {
  
        let (x, y) = (lhs!, rhs!);
        let shuffled = Zip3(Most(x), Rest(y), Rest(x));

        use anc = Qubit();
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
```

The temporary storage qubit `anc` is automatically cleaned up before it is released at the end of the operation. The statements in the `within` block are applied first, followed by the statements in the `apply` block, and finally, the automatically generated adjoint of the `within` block is applied to clean up the temporary qubit `anc`. 

> [!NOTE]Returning control from within the `apply` block is not yet supported. However, it may be supported in the future. The expected behavior, in this case, is to evaluate the returned value before the adjoint of the `within` block is run, then release any qubits going out of scope (`anc` in this case), and finally, return control to the callee. In short, the statement should behave similarly to a `try-finally` pattern in C#. 

← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)