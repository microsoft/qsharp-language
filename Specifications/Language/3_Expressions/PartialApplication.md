# Partial Application

Callables are declared at a global scope and by default can be used anywhere in the same project and in a project that references the assembly in which they are declared. However, often there is a need to construct a callable for use in a local context only. Q# currently provides one rather powerful mechanism to construct new callables on the fly: partial applications. 

Partial application refers to that some of the argument items to a callable are provided while others are still missing as indicated by an underscore. The result is a new callable value that takes the remaining argument items, combines them with the already given ones, and invokes the original callable. Naturally, partial application preserves the characteristics of a callable, i.e. a callable constructed by partial application supports the same functors as the original callable. 

Q# allows any subset of the parameters to be left unspecified, not just a final sequence, which ties in more naturally with the design to have each callable take and return exactly one value. 
For a function `Foo` whose argument type is `(Int, (Double, Bool), Int)` for instance, `Foo(_, (1.0, _), 1)` is a function that takes an argument of type `(Int, (Bool))`, which is the same as an argument of type `(Int, Bool)`, see [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md#singleton-tuple-equivalence).

Because partial application of an operation does not actually evaluate the operation, it has
no impact on the quantum state. This means that building a new operation from existing operations and computed data may be done in a function; this is useful in many adaptive quantum algorithms and in defining new control flow constructs.
