# Type System

With the focus for quantum algorithm being more towards what should be achieved rather than on a problem representation in terms of data structures, taking a more functional perspective on language design is a natural choice. At the same time, the type system is a powerful mechanism that can be leveraged for program analysis and other compile-time checks that facilitate formulating robust code. 

All in all, the Q# type system is fairly minimalist, in the sense that there isn't an explicit notion of classes or interfaces as one might be used to from classical languages like C# or Java. We also take a somewhat pragmatic approach making incremental progress, such that certain construct are not yet fully integrated into the type system. An example are functors, which can be used within expressions but don't yet have a representation in the type system. Correspondingly, they cannot currently be assigned or passed as arguments, similar as it is the case for type parametrized callables.
We expect to make incremental progress in extending the type system to be more complete, and balance immediate needs with longer-term plans. 

## Available Types

All types in Q# are [immutable](xref:microsoft.quantum.qsharp.immutability#immutability). 

Type | Description
---------|----------
 `Unit` | Represents a singleton type whose only value is `()`.
 `Int` | Represents a 64-bit signed integer. [Values](xref:microsoft.quantum.qsharp.valueliterals#int-literals) range from -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807.
 `BigInt` | Represents signed integer [values](xref:microsoft.quantum.qsharp.valueliterals#bigint-literals) of any size.
 `Double` | Represents a double-precision 64-bit floating-point number. [Values](xref:microsoft.quantum.qsharp.valueliterals#double-literals) range from -1.79769313486232e308 to 1.79769313486232e308 as well as NaN (not a number).
 `Bool` | Represents Boolean [values](xref:microsoft.quantum.qsharp.valueliterals#bool-literals). Possible values are `true` or `false`.
 `String` | Represents text as [values](xref:microsoft.quantum.qsharp.valueliterals#string-literals) that consist of a sequence of UTF-16 code units. 
 `Qubit` | Represents an opaque identifier by which virtual quantum memory can be addressed. [Values](xref:microsoft.quantum.qsharp.valueliterals#qubit-literals) of type `Qubit` are instantiated via allocation.
 `Result` | Represents the result of a projective measurement onto the eigenspaces of a quantum operator with eigenvalues ±1. Possible [values](xref:microsoft.quantum.qsharp.valueliterals#result-literals) are `Zero` or `One`. 
 `Pauli` | Represents a single-qubit Pauli matrix. Possible [values](xref:microsoft.quantum.qsharp.valueliterals#pauli-literals) are `PauliI`, `PauliX`, `PauliY`, or `PauliZ`.
 `Range` | Represents an ordered sequence of equally spaced `Int` values. [Values](xref:microsoft.quantum.qsharp.valueliterals#range-literals) may represent sequences in ascending or descending order.
 Array | Represents [values](xref:microsoft.quantum.qsharp.valueliterals#array-literals) that each contain a sequence of values of the same type.
 Tuple | Represents [values](xref:microsoft.quantum.qsharp.valueliterals#tuple-literals) that each contain a fixed number of items of different types. Tuples containing a single element are equivalent to the element they contain.
 User defined type | Represents a [user defined type](xref:microsoft.quantum.qsharp.typedeclarations#type-declarations) consisting of named and anonymous items of different types. [Values](xref:microsoft.quantum.qsharp.valueliterals#literals-for-user-defined-types) are instantiated by invoking the constructor. 
 Operation | Represents a non-deterministic [callable](xref:microsoft.quantum.qsharp.operationsandfunctions#operations-and-functions) that takes one (possibly tuple-valued) input argument returns one (possibly tuple-valued) output. Calls to operation [values](xref:microsoft.quantum.qsharp.valueliterals#operation-literals) may have side effects and the output may vary for each call even when invoked with the same argument.
 Function | Represents a deterministic [callable](xref:microsoft.quantum.qsharp.operationsandfunctions#operations-and-functions) that takes one (possibly tuple-valued) input argument returns one (possibly tuple-valued) output. Calls to function [values](xref:microsoft.quantum.qsharp.valueliterals#function-literals) do not have side effects and the output is will always be the same given the same input. 


