# Quantum Intermediate Representation Specification

Version 0.2 (May 15 2020)

Copyright (c) Microsoft Corporation. All rights reserved.

## Introduction

This specification defines an intermediate representation for compiled
quantum computations.
The intent is that a quantum computation written in any language can be
compiled into this representation as a common intermediate _lingua franca_.
The intermediate representation would then be an input to a code generation
step that is specific to the target execution platform, whether simulator
or quantum hardware.

We see compilation as having three high-level phases:

1. A language-specific phase that takes code written in some quantum language,
   performs language-specific transformations and optimizations, and compiles
   the result into this intermediate format.
2. A generic phase that performs transformations and analysis of the code
   in the intermediate format.
3. A target-specific phase that performs additional transformations and
   ultimately generates the instructions required by the execution platform
   in a target-specific format.

By defining our representation within the popular open-source LLVM framework,
we enable users to easily write code analyzers and code transformers that
operate at this level, before the final target-specific code generation.

## Role of This Specification

The representation defined in this specification is intended to be the target
representation for language-specific compilers.
In particular, a language-specific compiler may rely on the existence of the
various utility and quantum functions defined in this specification.

It is neither required nor expected that any particular execution target actually
implement every runtime function specified here.
Rather, it is expected that the target-specific compiler will translate the
functions defined here into the appropriate representation for the target, whether
that be code, calls into target-specific libraries, metadata, or something else.

This applies to quantum functions as well as classical functions.
We do not intend to specify a gate set that all targets must support, nor even
that all targets use the gate model of computation.
Rather, the quantum functions in this document specify the interface that
language-specific compilers should meet.
It is the role of the target-specific compiler to translate the quantum functions
into an appropriate computation that meets the computing model and capabilities
of the target platform.

## Profiles

We know that many current targets will not support the full breadth of possible
quantum programs that can be expressed in this representation.
It is our intent to define a sequence of specification _profiles_ that define
coherent subsets of functionality that a specific target can support.
We describe here two initial draft profiles.

### Profile A: Basic Quantum Functionality

The *Basic Quantum Functionality* profile defines a minimal subset of the QIR that includes
quantum operations but explicitly rules out any decision making or "fast feedback" based on
measurement results.

In terms of the intermediate representation, this translates into the following restrictions:

- Values of type `%Result` may be stored in memory, stored as part of a tuple or as an element
  of an array, or returned from an operation or function. No other actions may be performed with
  them. In particular, they may not be compared against other `%Result` values or converted into
  values of any other type. Note that this implies that control flow cannot be based on the result
  of a measurement.
- Once a qubit is measured, nothing further will be done with it other than releasing it.
- No arithmetic or other calculations may be performed with classical values. Any such computations
  in the original source code are performed in the service before passing the QIR to the target
  and the results folded in as constants in the QIR.
- The only LLVM primitives allowed are: `call`, `bitcast`, `getelementptr`, `load`, `store`, `ret`,
  and `extractvalue`.
- The only QIR runtime functions allowed are: **TBD**.
- LLVM functions will always be passed null pointers for the capture tuple.
- The only classical value types allowed are `%Int`, `%Double`, `%Result`, `%Pauli`, and tuples of these
  values.
- The argument tuple passed to an operation will be a tuple of the above types.
- Outside of the argument tuple, values of types other than `%Result` will only appear as literals.

### Profile B: Basic Measurement Feedback

The *Basic Measurement Feedback* profile expands on the Basic Quantum Functionality profile
to allow limited capabilities to control the execution of quantum operations based on prior
measurement results.
These capabilities correspond roughly to what are commonly known as "binary controlled gates".

In terms of the intermediate representation, this translates into the following restrictions:

- Comparison of `%Result` values is allowed, but only to compute the input to a conditional branch.
- Boolean computations are not allowed. Boolean expressions on `%Result` comparisons must be represented
  by a sequence of simple comparisons and branches. Effectively, complex "if" clauses must be translated
  into embedded simple "if"s.
- Any basic blocks whose execution depends on the result of a `%Result` comparison may only include
  calls to quantum operations, comparisons of `%Result`s, and branches. In particular, classical
  arithmetic and other purely classical operations may not be performed inside of such a basic block.
- Basic blocks that depend on the result of a `%Result` comparison may not form a cycle (loop).
- No arithmetic or other calculations may be performed with classical values. Any such computations
  in the original source code are performed in the service before passing the QIR to the target
  and the results folded in as constants in the QIR.
- The only LLVM primitives allowed are: `call`, `bitcast`, `getelementptr`, `load`, `store`, `ret`,
  `extractvalue`, `icmp`, `alloca`, and `br`.
- The only QIR runtime functions allowed are: **TBD**.
- LLVM functions will always be passed a null pointer for the capture tuple.
- LLVM functions may fill in the result tuple. If they do, the result tuple may only contain `%Result`
  values or tuples of `%Result` values.
- The only classical value types allowed are `%Int`, `%Double`, `%Result`, `%Pauli`, `%Unit`, and tuples
  of these values.
- The argument tuple passed to an operation will be a tuple of the above types.
- Outside of the argument tuple, values of types other than `%Result` will only appear as literals.

## Executable Code Generation Considerations

There are several areas where a code generator may want to significantly deviate
from a simple rewrite of basic intrinsics to target machine code:

- The intermediate representation assumes that the runtime does not perform
  garbage collection, and thus carefully tracks stack versus heap allocation
  and reference counting for heap-allocated structures. A runtime that provides
  full garbage collection may wish to remove the reference count field from several
  intermediate representation structures and elide calls to `quantum.rt.free`
  and the various `unreference` functions.
- Many types are defined as pointers to opaque structures. The code generator
  will need to either provide a concrete realization of the structure or replace
  the pointer type with some other representation entirely.
- Depending on the characteristics of the target architecture, the code generator
  may prefer to use different representations for the various types given concrete
  types here. For instance, on some architectures it will make more sense to represent
  small types as bytes rather than as single or double bits.
- The primitive quantum operations provided by a particular target architecture
  may differ significantly from the intrinsics defined in this specification.
  It is expected that code generators will significantly rewrite sequences of
  quantum intrinsics into sequences that are optimal for the specific target.

## Identifiers

Identifiers in LLVM begin with a prefix, '@' for global symbols and '%' for
local symbols, followed by the identifier name.
Names must be in 8-bit ASCII, and must start with a letter or one of the special
characters '\$', '_', '-', and '.'; the rest of the characters in the name must
be either one of those characters or a digit.
It is possible to include other ASCII characters in names by surrounding the name
in quotes and using '\\xx' to represent the hex encoding of the character.
LLVM has no analog to namespaces or similar named scopes that are present in
many modern languages.

To the extent possible, symbols in the QIR should have identifiers that match
the identifier used in the source language.
The identifiers of local symbols should be converted to LLVM by merely adding the
'%' prefix.
If necessary, a suffix of ".." followed by an integer may be used to avoid name
clashes.
Anonymous local variables generated by the compiler can be represented
as %0, %1, etc., as is usual in LLVM.

Similarly, global symbols should have their identifiers converted by adding the
'@' prefix.
If the source language provides a named scoping mechanism, such as Python modules
or Q# namespaces, then the fully-qualified name of the global symbol should be used.

:[DataTypes](./Data-Types.md)

## Metadata

### Representing Source-Language Attributes

Many languages allow attributes to be placed on callable and type definitions.
For instance, in Q# attributes are compile-time constant values of specific
user-defined types that themselves have the `Microsoft.Quantum.Core.Attribute`
attribute.

The language compiler should represent these attributes as LLVM metadata associated
with the callable or type.
For callables, the metadata representing the attribute should be attached
to the LLVM global symbol that defines the implementation table for the callable.
The identifier of the metadata node should be "!quantum.", where "!" is the LLVM
standard prefix for a metadata value, followed by the namespace-qualified name of
the attribute.
For example, a callable `Your.Op`with two attributes, `My.Attribute(6, "hello")`
and `Their.Attribute(2.1)`, applied to it would be represented in LLVM as follows:

```LLVM
@Your.Op = constant
  [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]
  [
    void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*
        @Your.Op-body,
    void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*
        @Your.Op-adj,
    void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* 
        @Your.Op-ctl,
    void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* 
        @Your.Op-ctladj
  ], !quantum.My.Attribute {i64 6, !"hello\00"},
     !quantum.Their.Attribute {double 2.1}
```

LLVM does not allow metadata to be associated with structure definitions,
so there is no direct way to represent attributes attached to user-defined types.
Thus, attributes on types are represented as named (module-level)
metadata, where the metadata node's name is "quantum." followed by the
namespace-qualified name of the type.
The metadata itself is the same as for callables, but wrapped in one more
level of LLVM structure in order to handle multiple attributes on the
same structure.
For example, a type `Your.Type`with two attributes, `My.Attribute(6, "hello")`
and `Their.Attribute(2.1)`, applied to it would be represented in LLVM as follows:

```LLVM
!quantum.Your.Type = !{ !{!"quantum.My.Attribute\00", i64 6, !"hello\00"},
                        !{ !"quantum.Their.Attribute\00", double 2.1} }
```

### Standard LLVM Metadata

#### Debugging Information

Compilers are strongly urged to follow the recommendations in
[Source Level Debugging with LLVM](http://llvm.org/docs/SourceLevelDebugging.html).

#### Branch Prediction

Compilers are strongly urged to follow the recommendations in
[LLVM Branch Weight Metadata](http://llvm.org/docs/BranchWeightMetadata.html).

### Other Compiler-Generated Metadata

> **TODO**: what quantum-specific "well-known" metadata do we want to specify?

## Quantum Instruction Set and Runtime

### Standard Operations

As recommended by the [LLVM documentation](https://llvm.org/docs/ExtendingLLVM.html),
we do not define new LLVM instructions for standard quantum operations.
Instead, we expect each target to define a set of quantum operations as callables that may be used by
language-specific compilers.

### Qubit Management Functions

We define the following functions for managing qubits:

| Function                        | Signature       | Description |
|---------------------------------|-----------------|-------------|
| quantum.rt.qubit_allocate       | `%Qubit*()`     | Allocates a single qubit. |
| quantum.rt.qubit_allocate_array | `%Array*(i64)`  | Allocates an array of qubits. |
| quantum.rt.qubit_release        | `void(%Qubit*)` | Release a single qubit. |
| quantum.rt.qubit_release_array  | `void(%Array*)` | Release an array of qubits. |

Allocated qubits are not guaranteed to be in any particular state.
If a language guarantees that allocated qubits will be in a specific state, the compiler
should insert the code required to set the state of the qubits returned from `alloc`.
Qubits should be unentangled -- measured out -- before they are released.

If borrowing qubits is supported, then the following runtime functions should also be provided:

| Function                        | Signature       | Description |
|---------------------------------|-----------------|-------------|
| quantum.rt.qubit_borrow         | `%Qubit*()`     | Borrow a single qubit. |
| quantum.rt.qubit_borrow_array   | `%Array*(i64)`  | Borrow an array of qubits. |
| quantum.rt.qubit_return         | `void(%Qubit*)` | Return a borrowed qubit. |
| quantum.rt.qubit_return_array   | `void(%Array*)` | Return an array of borrowed qubits. |

Borrowing qubits means supplying qubits that are guaranteed not to be otherwise
accessed while they are borrowed.
The code that borrows the qubits guarantees that the state of the qubits when
returned is identical, including entanglement, to their state when borrowed.
It is always acceptable to satisfy `borrow` by allocating new qubits.

It will likely be useful to provide usage hints to `alloc` and `borrow`.
Since we don't know yet what form these hints may take, we leave them out for now.

## Classical Runtime

### Memory Management

The quantum runtime is not required to provide garbage collection.
Rather, the compiler should generate code that generates proper allocation
for values on the stack or heap, and ensure that values are properly unreferenced
when they go out of scope.

#### Stack versus Heap Allocation

We assume that the source language does not provide any mechanism for mutable values
that persist across call values.
That is, this discussion assumes that the source language provides no feature
analogous to C `static` variables or to class static members as in C++, Java, or C#.

Any value that the compiler can prove will not be part of the return value can thus
always be allocated on the stack using the LLVM `alloca` intrinsic.
Values that might be part of the return value must be allocated on the heap; if such
a value is determined at run time to no longer be a possible part of the return value,
it may be explicitly released before the return.
Similarly, values that require too much memory space to put on the stack can be
allocated on the heap and explicitly released after their last use.

Values passed as arguments to a callable should not be released by the callable.

Values that are returned from a callable must not be allocated on the callee's stack.
The calling code can rely on this, and can apply the same logic as above to either pass
the value to the next caller or release the value after its last use.

We define the following functions for allocating and releasing heap memory,
They should provide the same behavior as the standard C library functions malloc and free.

| Function              | Signature   | Description |
|-----------------------|-------------|-------------|
| quantum.rt.heap_alloc | `i8*(i32)`  | Allocate a block of memory on the heap. |
| quantum.rt.heap_free  | `void(i8*)` | Release a block of allocated heap memory. |

#### Reference Counting

The reference count of a heap-allocated structure should be incremented whenever a new
long-lived reference to the structure is created and decremented whenever such a
reference is overwritten or goes out of scope.
A reference is long-lived if it is potentially part or all of the return value of the
current callable.

In some cases, it may be possible to avoid incrementing the reference count of a
structure when a new alias of the structure is created, as long as that alias is local
and not part of the return value.
For instance, in the following somewhat artificial Q# snippet:

```qsharp
function First<'T>(tuple: ('T1, 'T2)) : 'T1
{
  let x = tuple;
  let (first, second) = x;
  return first;
}
```

There is no need to increment the reference count for `tuple` when `x` is initialized,
nor to decrement it at the function exit when `x` goes out of scope.

### Other Functions

| Function              | Signature         | Description |
|-----------------------|-------------------|-------------|
| quantum.rt.fail       | `void(%String*)`  | Fail the computation with the given error message. |
| quantum.rt.message    | `void(%String*)`  | Log the given string as part of the output of the current computation. |
