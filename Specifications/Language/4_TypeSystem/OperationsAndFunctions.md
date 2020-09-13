# Operations and Functions

As elaborated in more detail in the description of the [qubits](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md#qubits), quantum computations are executed in the form of side effects of operations that are natively supported on the targeted quantum processor. These are in fact the only side effects in Q#; since all types are immutable, there are no side effect that impact a value that is explicitly represented in Q#. Hence, as long as the implementation of a certain routine does not directly or indirectly call any of these natively implemented operations, its execution will always produce the same output given the same input. 

Q# allows to explicitly split out such purely deterministic computations into *functions*. Since the set of natively supported instructions is not fixed and built into the language itself, but rather fully configurable and expressed as a Q# library, determinism is guaranteed by requiring that functions can only call other functions, but cannot call any operations. Additionally, native instructions that are not deterministic, e.g., because they impact the quantum state are represented as operations. With these two restrictions, function can be evaluated as soon as their input value is known, and in principle never need to be evaluated more than once for the same input. 

Q# therefore distinguishes between two types of callables: operations and functions. All callables take a single (potentially tuple-valued) argument as input and produce a single value (tuple) as output. 

There is little difference between operations and functions beside this determinism guarantee. Both are first-class values that can be passed around freely; they can be used as return values or arguments to other callables, as illustrated by the example below.
```qsharp
    function Pow<`T>(op:(`T => Unit, pow : Int) : (`T => Unit){
        return PowImpl(op, pow, _); 
    }
```

They can be instantiated based on a type parametrized definition such as, e.g., the [type parametrized](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/TypeParameterizations.md) function `Pow` above, and they can be [partially applied](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language) as done in Line 2 in the example. However, splitting out computations that cannot possibly impact the quantum state allows to build out more powerful and expressive language constructs in the future; constructs that are commonly used in conventional programming languages but would be hard to support on quantum hardware. 

## Operation Characteristics

In addition to the information about in- and output type, the operation type contains information about the characteristics of an operation. This information for example describes what functors are supported by the operation. Additionally, the internal representation also contains information that is inferred by the compiler but not exposed to the user. An example for this is whether or not an operation is self-adjoint. The type system is leveraged to propagate this information, such that it proliferates, e.g., when a local alias is defined or an array of self-adjoint operations is constructed. It could in principle be exposed to the user in the same way as the information whether an operation is adjointable or controllable is explicitly expressed in source code. 

The choice of when to allow to explicitly express certain information in source code and when to merely infer them if possible depends on how this would impact the ecosystem of Q# libraries; allowing the user to explicitly require, e.g., operation valued arguments to have certain properties can significantly impact how effectively the defined operations can be composed. Exposing properties that could be inferred promotes defining several implementations for the same functionality. If the implementations have the same name, then this can lead to a tricky dispatching problem upon optimization, where the compiler needs to make a decision regarding which concrete implementation is the most favorable to invoke for any given call. If on the other hand different implementations for the same functionality have different names, then this on one hand complicates things for a user of said libraries, and on the other hand also promotes hand-coding 
specialized solutions for each problem instance rather than composing general solutions for classes of problem based on existing libraries. 
In the case of an operation being self-adjoint, the fact that a self-adjoint operation also necessarily is adjointable could potentially be handled well via dispatching to different hand-optimized implementations with the same name, since the choice of when to use which implementation should allows follow the strict hierarchy of preferring and implementation requiring a self-adjoint operation over simply an adjointable one in all cases. However, currently Q# doesn't yet support type specializations such that for now, that information is merely included in the inferred characteristics of a callable. 

The characteristics of an operation are a set of predefined and built-in labels. 
They are expressed in the form of a special expression that is part of the type signature. The expression consists either of one of the predefined sets of labels, or of a combination of characteristics expressions via a supported binary operator. There are two predefined sets, `Adj` and `Ctl`. `Adj` is the set that contains a single label indicating that an operation is adjointable, and `Ctl` is the set that contains a single label indicating that an operation is controllable. 
The two operators that are supported as part of characteristics expressions are the set union `+` and the set intersection `*`. 
In EBNF, 
```
    predefined = "Adj" | "Ctl";
    characteristics = predefined 
        | "(", characteristics, ")" 
        | characteristics ("+"|"*") characteristics;
```
As one would expect, `*` has higher precedence than `+` and both are left-associative. The type of a unitary operation for example is expressed as `(<TIn> => <TOut> is Adj + Ctl)` where `<TIn>` should be replace with the type of the operation argument, and `<TOut>` with the type of the returned value. 

Indicating the characteristics of an operation in this form has two major advantages; for one, new labels can be introduced without having exponentially many language keywords for all combinations of labels. Perhaps more importantly, using expressions to indicate the characteristics of an operation also permits to support parameterizations over operation characteristics in the future. While this is still under active development, the basic idea is to have a placeholder indicating the set of labels. The set intersection then basically allows to impose requirements. Consider for example the following operation:
```qsharp
    operation ApplyWith<'TIn>(
        outerOperation : ('TIn => Unit is Adj), 
        innerOperation : ('TIn => Unit), 
        target : 'TIn
    ) : Unit {
        
        outerOperation(target); 
        innerOperation(target); 
        Adjoint outerOperation(target);
    }    
```
We could have used a [conjugation](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language) to express the body of the operation, but instead chose to make it more apparent that applying such an operation conditionally on the state of one or more control qubits merely requires applying the inner operation conditionally on their state, since the outer operation will cancel out with its adjoint if the inner operation is not applied. The same holds for constructing the adjoint version. Hence we see that which functors `ApplyWith` can support entirely depends on which functors the inner operation supports. Currently, there is not concise way of expressing that, such that the standard libraries in fact contain four different operation called `ApplyWith`, `ApplyWith`, `ApplyWithC`, and `ApplyWithAC` - one for each combination of labels for the inner operation. We could, however, conceive expressing that as a single operation parametrized over operation characteristics `#C`, e.g., with the suggested syntax
```qsharp
    operation ApplyWith<'TIn, #C>(
        outerOperation : ('TIn => Unit is Adj), 
        innerOperation : ('TIn => Unit is #C), 
        target : 'TIn
    ) : Unit is #C {
        
        outerOperation(target); 
        innerOperation(target); 
        Adjoint outerOperation(target);
    }    
```
where `#C` is a placeholder for a characteristics expression that evaluates to a set of labels. Technically, there is currently no notion of an empty set of labels in Q#, but introducing a way to represent such an empty set for the sake of supporting parametrizing over operation characteristics seems reasonable. 

The example above doesn't make it immediately clear why indicating operation characteristics as expressions is important to support this. However, consider the case of an operation `ApplyMultiControlled`. 
The operation `ApplyMultiControlled` takes an operation `cOp` as argument, as well as an array of control qubits and a target qubit. The passed operation `cOp` takes two qubits as arguments and transforms the second qubit conditional on the state of the first qubit. `ApplyMultiControlled` then transforms the given `target` qubit conditional on all control qubits `cs` being in a |0⟩ state. Whether or not `ApplyMultiControlled` is adjointable correspondingly depends on whether the given operation `cOp` is adjointable. However, by definition, the operation `ApplyMultiControlled` is always controllable. This could in the future be expressed in the following form:

```qsharp
    operation ApplyMultiControlled<#C> (
        cOp : ((Qubit, Qubit) => Unit is #C), 
        cs : Qubit[], 
        target : Qubit
    ) : Unit is Ctl + #C {

        body (...) {

            if (Length(cs) == 0) {
                fail "need at least one control qubit";
            }
            elif (Length(cs) == 1) {
                cOp(cs[0], target);
            }
            else {
                using (anc = Qubit[Length(cs)-1]) {

                    within {
                        for (k in 1 .. Length(anc)-1) {
                            CCNOT(cs[k+1], anc[k-1], anc[k]);
                        }
                    } apply {                    
                        cOp(Tail(anc), target);
                    }
                }
            }
        }

        controlled (moreCs, ...) {
            ApplyMultiControlled(cOp, cs+moreCs, target);
        }
    }   
```
