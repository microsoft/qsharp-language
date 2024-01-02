# Operations and functions


As elaborated in more detail in the description of the [qubit data type](xref:microsoft.quantum.qsharp.quantumdatatypes#qubits), quantum computations are executed in the form of side effects of operations that are natively supported on the targeted quantum processor. These are, in fact, the only side effects in Q#. Since all types are [immutable](xref:microsoft.quantum.qsharp.immutability#immutability), there are no side effects that impact a value that is explicitly represented in Q#. Hence, as long as an implementation of a certain callable does not directly or indirectly call any of these natively implemented operations, its execution always produces the same output, given the same input. 

Q# allows you to explicitly split out such purely deterministic computations into *functions*. Since the set of natively supported instructions is not fixed and built into the language itself, but rather fully configurable and expressed as a Q# library, determinism is guaranteed by requiring that functions can only call other functions and cannot call any operations. Additionally, native instructions that are not deterministic, that is, because they impact the quantum state, are represented as operations. With these two restrictions, functions can be evaluated as soon as their input value is known, and, in principle, never need to be evaluated more than once for the same input. 


Q# therefore distinguishes between two types of [callables](xref:microsoft.quantum.qsharp.callabledeclarations): operations and functions. All callables take a single argument (potentially tuple-valued) as input and produce a single value (tuple) as output. Syntactically, the operation type is expressed as `<TIn> => <TOut> is <Char>`, where `<TIn>` is to be replaced by the argument type, `<TOut>` is to be replaced by the return type, and `<Char>` is to be replaced by the [operation characteristics](#operation-characteristics). If no characteristics need to be specified, the syntax simplifies to `<TIn> => <TOut>`. Similarly, function types are expressed as `<TIn> -> <TOut>`. 

Aside from this determinism guarantee, there is little difference between operations and functions. Both are first-class values that can be passed around freely; they can be used as return values or arguments to other callables, as shown in the following example:

```qsharp
function Pow<'T>(op : 'T => Unit, pow : Int) : 'T => Unit {
    return PowImpl(op, pow, _);
}
```


Both can be instantiated based on a type-parametrized definition, for example, the [type parametrized](xref:microsoft.quantum.qsharp.typeparameterizations#type-parameterizations) function `Pow` above, and they can be [partially applied](xref:microsoft.quantum.qsharp.closures#partial-application) as done in the `return` statement in the example. 



## Operation characteristics

In addition to the information about input and output type, the operation type contains information about the characteristics of an operation. This information, for example, describes what functors are supported by the operation. Additionally, the internal representation also contains optimization-relevant information that is inferred by the compiler. 

The characteristics of an operation are a set of predefined and built-in labels. 
They are expressed in the form of a special expression that is part of the type signature. The expression consists either of one of the predefined sets of labels, or of a combination of characteristics expressions via a supported binary operator. 

There are two predefined sets, `Adj` and `Ctl`. 

- `Adj` is the set that contains a single label indicating that an operation is adjointable, meaning it supports the [`Adjoint` functor](xref:microsoft.quantum.qsharp.functorapplication#functor-application) and the applied quantum transformation can be "undone", that is, it can be inverted.
- `Ctl` is the set that contains a single label indicating that an operation is controllable, meaning it supports the [`Controlled` functor](xref:microsoft.quantum.qsharp.functorapplication#functor-application) and
its execution can be conditioned on the state of other qubits. 

The two operators that are supported as part of characteristics expressions are the set union `+` and the set intersection `*`. 
In EBNF, 

```
    predefined = "Adj" | "Ctl";
    characteristics = predefined 
        | "(", characteristics, ")" 
        | characteristics ("+"|"*") characteristics;
```

As one would expect, `*` has higher precedence than `+` and both are left-associative. The type of a unitary operation, for example, is expressed as `<TIn> => <TOut> is Adj + Ctl`, where `<TIn>` should be replaced with the type of the operation argument, and `<TOut>` replaced with the type of the returned value. 

>[!NOTE]
>Indicating the characteristics of an operation in this form has two major advantages; for one, new labels can be introduced without having exponentially many language keywords for all combinations of labels. Perhaps more importantly, using expressions to indicate the characteristics of an operation also supports parameterizations over operation characteristics in the future. 

