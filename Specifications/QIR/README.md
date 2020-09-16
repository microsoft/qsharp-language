# Quantum Intermediate Representation

This [specification](https://github.com/microsoft/qsharp-language/blob/main/Specifications/QIR/Specification.md) 
defines an intermediate representation for compiled quantum computations.
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

## Profiles

We know that many current targets will not support the full breadth of possible
quantum programs that can be expressed in this representation.
It is our intent to define a sequence of specification _profiles_ that define
coherent subsets of functionality that a specific target can support. 
Please take a look at [this document](https://github.com/microsoft/qsharp-language/blob/main/Specifications/QIR/Profiles.md) for more details. 
