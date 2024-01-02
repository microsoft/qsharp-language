# Call expressions

Call expressions are an important part of any programming language. Operation and function calls, much like [partial applications](xref:microsoft.quantum.qsharp.closures#partial-application), can be used as an expression anywhere as long as the returned value is of a suitable type.

The usefulness of calling operations in this form primarily lies in debugging, and such operation calls are one of the most common constructs in any Q# program. At the same time, operations can only be called from within other operations and not from within functions. For more information, see also [Qubits](xref:microsoft.quantum.qsharp.quantumdatatypes#qubits).

With callables being first-class values, call expressions are a generic way of supporting patterns that aren't common enough to merit their own dedicated language construct, or dedicated syntax has not (yet) been introduced for other reasons. Some examples of library methods that serve that purpose are `ApplyIf`, which invokes an operation conditional on a classical bit being set; `ApplyToEach`, which applies a given operation to each element in an array; and `ApplyWithInputTransformation`, as shown in the following sample.

```qsharp
    operation ApplyWithInputTransformation<'TArg, 'TIn>(
        fn : 'TIn -> 'TArg,
        op : 'TArg => Unit,
        input : 'TIn
    ) : Unit {

        op(fn(input));
    }
```

`ApplyWithInputTransformation` takes a function `fn`, an operation `op`, and an `input` value as arguments and then applies the given function to the input before invoking the given operation with the value returned from the function.

For the compiler to auto-generate the specializations to support particular [functors](xref:microsoft.quantum.qsharp.functorapplication#functor-application), it usually requires that the called operations support those functors as well. The two exceptions are calls in outer blocks of [conjugations](xref:microsoft.quantum.qsharp.conjugations#conjugations), which always need to support the `Adjoint` functor but never need to support the `Controlled` functor, and self-adjoint operations, which support the `Adjoint` functor without imposing any additional requirements on the individual calls.


