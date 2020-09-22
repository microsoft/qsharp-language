# Type Parameterizations

Q# supports type-parameterized operations and functions. The Q# standard libraries make heavy use of type parametrized callables to provide a host of useful abstractions, including functions like `Mapped` and `Fold` that are familiar from functional languages.

Any operation or function declaration may specify one or more type parameters that can be used as the types or part of the types of the callable's input and/or output. The exception are entry points, which must be concrete and cannot be type parametrized. Type parameter names start with a tick (') and may appear multiple times in the input and output types. 
All arguments that correspond to the same type parameter in the callable signature must be of the same type.

A type parametrized callable needs to be concretized before it can be assigned or passed as argument, meaning all type parameters need to be resolved to concrete types. A type is considered to be concrete if it is either one of the built-in types, a user defined type, or if it is concrete within the current scope. The following example illustrates what it means for a type to be concrete within the current scope, and is explained in more detail below:

```qsharp
    function Mapped<'T1, 'T2> (
        mapper : ('T1 -> 'T2), 
        array : 'T1[]
    ) : 'T2[] {

        mutable mapped = new 'T2[Length(array)];
        for (i in IndexRange(array)) {
            set mapped w/= i <- mapper(array[i]);
        }
        return mapped;
    }

    function AllCControlled<'T3> (
        ops : ('T3 => Unit)[]
    ) : ((Bool,'T3) => Unit)[] {

        return Mapped(CControlled<'T3>, ops); 
    }
```

The function `CControlled` is defined in the Microsoft.Quantum.Canon namespace. It takes an operation `op` of type `('TIn => Unit)` as argument and returns a new operation of type `((Bool, 'TIn) => Unit)` that applies the original operation provided a classical bit (of type `Bool`) is set to true; this is often referred to as the classically controlled version of `op`. 

The function `Mapped` takes an array of an arbitrary item type `'T1` as argument, applies the given `mapper` function to each item and returns a new array of type `'T2[]` containing the mapped items. It is defined in the `Microsoft.Quantum.Array` namespace. For the purpose of the example, the type parameters are numbered to avoid making the discussion more confusing by giving the type parameters in both functions the same name. This is not necessary; type parameters for different callables may have the same name, and the chosen name is only visible and relevant within the definition of that callable. 

The function `AllCControlled` takes an array of operations and returns a new array containing the classically controlled versions of these operations. The call of `Mapped` resolves its type parameter `'T1` to `('T3 => Unit)`, and its type parameter `'T2` to `((Bool,'T3) => Unit)`. The resolving type arguments are inferred by the compiler based on the type of the given argument. We say that they are *implicitly* defined by the argument of the call expression. Type arguments can also be specified explicitly as it is done for `CControlled` in the same line. The explicit concretization `CControlled<'T3>` is necessary when the type arguments cannot be inferred. 

The type `'T3` is concrete within the context of `AllCControlled`, since it is known for each *invocation* of `AllCControlled`. That means that as soon as the entry point of the program - which cannot be type parametrized - is know, so is the concrete type `'T3` for each call to `AllCControlled`, such that a suitable implementation for that particular type resolution can be generated; once the entry point to a program is known, all usages of type parameters can be eliminated at compile-time. We refer to this process as *monomorphization*. 

A couple of restrictions are needed to ensure that this can indeed be done at compile-time opposed to only at run time. 

### *Discussion*
>Consider the following example: 
>
>```qsharp
>    operation Foo<'TArg> (
>        op : ('TArg => Unit), 
>        arg : 'TArg
>    ) : Unit {
>
>        let cbit = RandomInt(2) == 0;
>        Foo(CControlled(op), (cbit, arg));        
>    } 
>```
>Ignoring that an invocation of `Foo` will result in an infinite loop, it serves the purpose of illustration. `Foo` invokes itself with the classically controlled version of the original operation `op` that has been passed in as well as a tuple containing a random classical bit in addition to the original argument. 
>
>For each iteration in the recursion, the type parameter `'TArg` of the next call is resolved to `(Bool, 'TArg)`, where `'TArg` is the type parameter of the current call. Concretely, suppose `Foo` is invoked with the operation `H` and an argument `arg` of type `Qubit`. `Foo` will then invoke itself with a type argument `(Bool, Qubit)`, which will then invoke `Foo` with a type argument `(Bool, (Bool, Qubit))`, and so on. Clearly, in this case `Foo` cannot be monomorphized at compile-time. 

Additional restrictions apply to cycles in the call graph that involve only type parametrized callables. Each callable needs to be invoked with the same set of type arguments after traversing the cycle. 

### *Discussion*
>It would be possible to be less restrictive and require that for each callable in the cycle, there is a finite number of cycles after which it is invoked with the original set of type arguments, such as it is the case for the following function: 
>```qsharp
>    function Bar<'T1,'T2,'T3>(a1:'T1, a2:'T2, a3:'T3) : Unit{
>        Bar<'T2,'T3,'T1>(a2, a3, a1);
>    }
>```
>For simplicity, the more restrictive requirement is enforced. Note that for cycles that involve at least one concrete callable without any type parameter, such a callable will ensure that the type parametrized callables within that cycle are always called with a fixed set of type arguments.

