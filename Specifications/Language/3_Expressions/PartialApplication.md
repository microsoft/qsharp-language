# Partial Application

Currently, callables can only be declared at a global scope. By default, they are publicly visible, i.e. they can be used anywhere in the same project and in a project that references the assembly in which they are declared. Access modifiers allow to restrict their visibility to the current assembly only, such that implementation details can be changed later on without breaking code that relies on a certain library. However, often there is a need to construct a callable for one-time use only, meaning no other piece of code will make use of it. Having to declare it on a global scope is hence inconvenient and limits the flexibility in how to structure and organize code. 

Q# currently provides one rather powerful mechanism to construct new callables on the fly: partial applications. Partial application refers to that some of the argument items to a callable are provided while others are still missing as indicated by an underscore. The result is a new callable value that takes the remaining argument items, combines them with the already given ones, and invokes the original callable. Naturally, partial application preserves the characteristics of a callable, i.e. a callable constructed by partial application supports the same functors as the original callable. 

In contrast to other functional languages, Q# allows any subset of the parameters to be left unspecified, not just a final sequence, which ties in more naturally with the design to have each callable take and return exactly one value. 
For a function `Foo` whose argument type is `(Int, (Double, Bool), Int)` for instance, `Foo(_, (1.0, _), 1)` is a function that takes an argument of type `(Int, (Bool))`, which is the same as an argument of type `(Int, Bool)`, see [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md).

Because partial application of an operation does not actually evaluate the operation, it has
no impact on the quantum state. This means that building a new operation from existing operations and computed data may be done in a function; this is useful in many adaptive quantum algorithms and in defining new control flow constructs.

Implementations such as the one below are at present time quite common in the Q# libraries. It shows both the usefulness and limitations of partial applications. The operation `ApplyBound` defined in the Q# standard library takes an array of operations and one after another applies them to the given argument. Access to `ApplyBound` is limited to the compilation unit. Projects that have a reference to standard library cannot access it, but instead access the operation `Bound`, which given an array of operations returns an new operation that implements their sequential application. 

```qsharp
    internal operation ApplyBoundCA<'T> (
        ops : ('T => Unit is Adj + Ctl)[], 
        arg : 'T) 
    : Unit is Adj + Ctl {

        for (op in ops) {
            op(arg);
        }
    }

    function BoundCA<'T> (
        ops : ('T => Unit is Adj + Ctl)[]
    ) : ('T => Unit is Adj + Ctl) {

        return ApplyBoundCA(ops, _);
    }    
```

We see that there is no reason to define `ApplyBound` on the global scope, and a local declaration within `Bound` would do fine. Some of the most anticipated future features are hence local declarations and lambda expressions. Local declarations, in contrast to globally defined callables, would have to be declared in order and wouldn't be recursive by default. There is no need for locally declared callables to explicitly specify their return type, though the type(s) of the argument (items) would still need to be annotated, and their [characteristics](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/OperationsAndFunctions.md#operation-characteristics) could also be inferred. Lambda expressions are even more convenient in a sense; for one, being expressions they can be used in almost any context, and furthermore, that context in certain cases additionally allows to infer the type(s) of the argument (items). 

In the meantime, partial applications allow to express the same functionality and provide a neat and compact way to cover some of the most common use cases. 
