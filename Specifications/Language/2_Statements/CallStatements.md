# Call Statements

Call statements are a very important part of any programming language. While operation and function calls, much like [partial applications](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PartialApplication.md), can be used as an expression anywhere as long as the returned value is of a suitable type, they can also be used as statements if they return `Unit`. 
The usefulness of calling functions in this form primarily lays in debugging, whereas such operation calls are one of the most common constructs in any Q# program. At the same time, operations can only be called from within other operations and not from within functions (for context, see also [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md#qubits)). 

With callables being first-class values, 
call statements in a sense are the generic way of supporting patterns that aren't common enough to merit their own dedicated language construct or dedicated syntax has not (yet) been introduced for other reasons. Examples for library methods that serve exactly that purpose are `ApplyIf`, that invokes an operation conditional on a classical bit being set, `ApplyToEach`, that applies a given operation to each element in an array, and `ApplyWithInputTransformation` shown below to give to just a few. 

```qsharp
    operation ApplyWithInputTransformation<'TArg, 'TIn>(
        fn : ('TIn -> 'TArg), 
        op : ('TArg => Unit), 
        input : 'TIn
    ) : Unit {

        op(fn(input)); 
    }
```

`ApplyWithInputTransformation` takes a function `fn`, an operation `op`, and an `input` value as argument, applies the give function to the input, before invoking the given operation with the value returned form the function.

We have also already mentioned functors; factories that allow to access particular specialization implementations of a callable. 
For an operation `ApplyUnitary` that defines a unitary transformation *U* of the quantum state, `Adjoint ApplyUnitary` accesses the implementation of *U†* and `Controlled ApplyUnitary` accesses the implementation that applies *U* conditional on all qubits in an array of control qubits being in a state |1⟩. 
Concretely, if `cs` contains an array of qubits, and `q1` and `q2` are two qubits, then the operation call `Controlled SWAP(cs, (q1, q2))`, with `SWAP` as defined [here](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md), exchanges the state of `q1` and `q2` if all qubits in `cs` are in a |1⟩ state. 

For the compiler to be able to auto-generate the specializations to support particular functors usually requires that the called operations support those functors as well. The exception are calls in outer blocks of [conjugations](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language), which always need to support the `Adjoint` functor but never need to support the `Controlled` functor, and self-adjoint operations, which support the `Adjoint` functor without imposing any additional requirements on the individual calls. More sophisticated generation directives should allow to relax that requirement in further contexts. 
