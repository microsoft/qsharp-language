# Functor Application

Functors are factories that allow to access particular specialization implementations of a callable. Q# currently supports two functors; the `Adjoint` and the `Controlled` function, both of which can be applied to operations that provide the necessary specialization(s). 

The `Controlled` and `Adjoint` functors commute; if `ApplyUnitary` is an operation that supports both functors, then there is no difference between `Controlled Adjoint ApplyUnitary` and `Adjoint Controlled ApplyUnitary`.
Both have the same type and upon invocation execute the implementation defined for the `controlled adjoint` [specialization](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md#specialization-declarations).

## Adjoint functor

If the operation `ApplyUnitary` defines a unitary transformation *U* of the quantum state, `Adjoint ApplyUnitary` accesses the implementation of *U†*. The `Adjoint` functor is its own inverse, since *(U†)† = U* by definition; i.e. `Adjoint Adjoint ApplyUnitary` is the same as `ApplyUnitary`.

The expression `Adjoint ApplyUnitary` is an operation of the same type as `ApplyUnitary`; it has the same argument and return type and supports the same functors. Like any operation, it can be invoked with an argument of suitable type. The following expression will apply the [adjoint specialization](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md#specialization-declarations) of `ApplyUnitary` to an argument `arg`:
```qsharp
Adjoint ApplyUnitary(arg) 
```

## Controlled functor

For an operation `ApplyUnitary` that defines a unitary transformation *U* of the quantum state, `Controlled ApplyUnitary` accesses the implementation that applies *U* conditional on all qubits in an array of control qubits being in the |1⟩ state. 

The expression `Controlled ApplyUnitary` is an operation with the same return type and [operation characteristics](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/OperationsAndFunctions.md#operation-characteristics) as `ApplyUnitary`, meaning it supports the same functors.
It takes an argument of type `(Qubit[], <TIn>)`, where `<TIn>` should be replaced with the argument type of `ApplyUnitary`, taking [singleton tuple equivalence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md#singleton-tuple-equivalence) into account. 

| Operation | Argument Type | Controlled Argument Type |
| --- | --- | --- |
| X | `Qubit` | `(Qubit[], Qubit)` | 
| SWAP | `(Qubit, Qubit)` | `(Qubit[], (Qubit, Qubit))` |

Concretely, if `cs` contains an array of qubits, `q1` and `q2` are two qubits, and the operation `SWAP` is as defined [here](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md#specialization-declarations), then the following expression exchanges the state of `q1` and `q2` if all qubits in `cs` are in the |1⟩ state:
```qsharp
Controlled SWAP(cs, (q1, q2))
```

### Discussion
> Conditionally applying an operation based on the control qubits being in another state than a zero-state may be achieved by applying the appropriate adjointable transformation to the control qubits before invocation, and applying is inverses after. Conditioning the transformation on all control qubits being in the |0⟩ state, for example, can be achieved by applying the `X` operation before and after. This can be conveniently expressed using a [conjugation](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Conjugations.md#conjugations). Nonetheless, the verbosity of such a construct may merit additional support for a more compact syntax in the future.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
