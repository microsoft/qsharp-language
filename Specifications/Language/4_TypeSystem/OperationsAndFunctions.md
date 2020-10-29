# Operations and Functions

As elaborated in more detail in the description of the [qubits](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md#qubits), quantum computations are executed in the form of side effects of operations that are natively supported on the targeted quantum processor. These are in fact the only side effects in Q#; since all types are [immutable](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md#immutability), there are no side effect that impact a value that is explicitly represented in Q#. Hence, as long as an implementation of a certain callable does not directly or indirectly call any of these natively implemented operations, its execution will always produce the same output given the same input. 

Q# allows to explicitly split out such purely deterministic computations into *functions*. Since the set of natively supported instructions is not fixed and built into the language itself, but rather fully configurable and expressed as a Q# library, determinism is guaranteed by requiring that functions can only call other functions, but cannot call any operations. Additionally, native instructions that are not deterministic, e.g., because they impact the quantum state are represented as operations. With these two restrictions, function can be evaluated as soon as their input value is known, and in principle never need to be evaluated more than once for the same input. 

Q# therefore distinguishes between two types of callables: operations and functions. All callables take a single (potentially tuple-valued) argument as input and produce a single value (tuple) as output. Syntactically, the operation type is expressed as `(<TIn> => <TOut> is <Char>)`, where `<TIn>` is to be replaced by the argument type, `<TOut>` is to be replaced by the return type, and `<Char>` is to be replaced by the [operation characteristics](#operation-characteristics). If no characteristics need to be specified, the syntax simplifies to `(<TIn> => <TOut>)`. Similarly, function types are expressed as `(<TIn> -> <TOut>)`. 

There is little difference between operations and functions beside this determinism guarantee. Both are first-class values that can be passed around freely; they can be used as return values or arguments to other callables, as illustrated by the example below.
```qsharp
    function Pow<`T>(op:(`T => Unit, pow : Int) : (`T => Unit){
        return PowImpl(op, pow, _); 
    }
```

They can be instantiated based on a type parametrized definition such as, e.g., the [type parametrized](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/TypeParameterizations.md#type-parameterizations) function `Pow` above, and they can be [partially applied](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PartialApplication.md#partial-application) as done in Line 2 in the example. 


## Operation Characteristics

In addition to the information about in- and output type, the operation type contains information about the characteristics of an operation. This information for example describes what functors are supported by the operation. Additionally, the internal representation also contains optimization relevant information that is inferred by the compiler. 

The characteristics of an operation are a set of predefined and built-in labels. 
They are expressed in the form of a special expression that is part of the type signature. The expression consists either of one of the predefined sets of labels, or of a combination of characteristics expressions via a supported binary operator. 

There are two predefined sets, `Adj` and `Ctl`. 
- `Adj` is the set that contains a single label indicating that an operation is adjointable - meaning it supports the [`Adjoint` functor](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/FunctorApplication.md#functor-application) and the applied quantum transformation can be "undone" (i.e. it can be inverted).   
- `Ctl` is the set that contains a single label indicating that an operation is controllable - meaning it supports the [`Controlled` functor](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/FunctorApplication.md#functor-application) and
its execution can be conditioned on the state of other qubits. 

The two operators that are supported as part of characteristics expressions are the set union `+` and the set intersection `*`. 
In EBNF, 
```
    predefined = "Adj" | "Ctl";
    characteristics = predefined 
        | "(", characteristics, ")" 
        | characteristics ("+"|"*") characteristics;
```
As one would expect, `*` has higher precedence than `+` and both are left-associative. The type of a unitary operation for example is expressed as `(<TIn> => <TOut> is Adj + Ctl)` where `<TIn>` should be replace with the type of the operation argument, and `<TOut>` with the type of the returned value. 

### *Discussion*
>Indicating the characteristics of an operation in this form has two major advantages; for one, new labels can be introduced without having exponentially many language keywords for all combinations of labels. Perhaps more importantly, using expressions to indicate the characteristics of an operation also permits to support parameterizations over operation characteristics in the future. 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)