# Callable Declarations

Q# supports two kinds of callables: operations and functions. [This section](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language) elaborates on the distinction between the two. Even more, Q# in fact supports defining *templates*, i.e. type parametrized implementations for a certain callable. Type parameterizations are described in more detail in [this section](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language). 

Naturally, such type parametrized implementations may not use any language constructs that rely on particular properties of the type arguments; there is currently no way to express type constraints in Q#. However, it is conceivable to introduce a suitable mechanism, similar to, e.g., type classes in Haskell, to allow for more expressiveness in the future.

Such a mechanism could also be combined with permitting to define specialized implementations for particular type arguments, similar to how, e.g., C++ does, or for type arguments that belong to certain type classes. While this is not yet supported either, Q# does already have the notion of specializing implementations for certain purposes; operations in Q# can implicitly or explicitly define support for certain *functors*, and along with it the specialized implementations that are to be invoked when a certain functor is applied to that callable. 

A functor in a sense is a factory that define a new callable implementation 
that has a certain relation to the callable it was applied to. 
Functors are more than traditional higher-level functions since they require access to the implementation details of the callable they have been applied to. In that sense, they are similar to other factories, such as templates. Correspondingly, they can be applied not just to callable, but in fact to templates as well. 

The [example program](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/ProgramStructure#program-execution) for instance defines the two operations `ApproximateQFT` and `Main`, which is used as entry point. `ApproximateQFT` takes an tuple-valued argument containing an integer and a value of type `LittleEndian`, and returns a value of type `Unit`. The annotation `is Adj + Ctl` in the declaration of `ApproximateQFT` indicates that the operation supports both the `Adjoint` and the `Controlled` functor, see also the section on [operation characteristics](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language). If `Unitary` is an operation that has an adjoint and a controlled specialization, the expression `Adjoint Unitary` accesses the specialization that implements the adjoint of `Unitary`, and `Controlled Unitary` the one that implements the controlled version of `Unitary`.
The controlled version of an operation takes an array of control qubits in addition to the argument of the original operation, and applies the original operation conditional on all of these control qubits being in a |1⟩ state. 

While in theory, an operation for which an adjoint version can be defined should also have a controlled version and vice versa, in practice it may be hard to come up with an implementation for one or the other, especially for probabilistic implementations following a repeat-until-success pattern. 
For that reason, Q# allows to declare support for each functor individually. However, since the two functors commute, an operation that defines support for both necessarily also has to have a usually implicitly defined -- meaning compiler-generated -- implementation for when both functors are applied to the operation. 

There are no functors that can be applied to functions, such that functions currently have exactly one body implementation and no further specializations. The declaration
```qsharp
    function Hello (name : String) : String {
        return $"Hello, {name}!";
    }
```
is equivalent to
```qsharp
    function Hello (name : String) : String {
        body (...) {
            return $"Hello, {name}!";
        }
    }
```
Here, `body` specifies that the given implementation applies to the default body of the function `Hello`, meaning the implementation that is invoked when no functors or other factory mechanisms have been applied prior to invocation. The three dots in `body (...)` correspond to a compiler directive indicating that the argument items in the function declaration should be copy-pasted into this spot.  
The reasoning behind explicitly indicating where the arguments of the parent callable declaration are to be copy-pasted is that for one, it is unnecessary to repeat the argument declaration, but more importantly it ensures that functors that require additional arguments, like the `Controlled` functor, can be introduced in a consistent manner. 

The same applies to operations; when there is exactly one specialization defining the implementation of the default body, the additional wrapping of the form `body (...){ <implementation> }` may be omitted.
