## Metadata

Here we use "metadata" to signify both LLVM metadata and attributes.
While metadata is more flexible, in some cases attributes may be preferred
either because passes are required to keep them or because there are
existing LLVM attributes with the required semantics.

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

If the QIR includes a function that is the quantum entry point, it should
be marked with an LLVM "EntryPoint" attribute.

*__Discussion__*
>It is likely that there is other useful information that could be represented
>as LLVM metadata in QIR. We anticipate that this will become clearer through use.

---
_[Back to index](README.md)_
