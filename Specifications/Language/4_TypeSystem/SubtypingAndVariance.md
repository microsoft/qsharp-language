# Subtyping and Variance

Q# supports only very few conversion mechanisms. Implicit conversions can happen only when applying binary operators, when evaluating conditional expressions, and when constructing an array literal. In these cases, a common supertype is determined and the necessary conversions are performed automatically. Aside from such implicit conversions, explicit conversation via function calls are possible and often necessary. 

At present time, the only subtyping relation that exists applies to operations. Intuitively it makes sense that one should be allowed to substitute an operation that supports more than the required set of functors. Concretely, for any two concrete types `TIn` and `TOut`, the subtyping relation is 
```
    (TIn => TOut) :>
    (TIn => TOut is Adj), (TIn => TOut is Ctl) :>
    (TIn => TOut is Adj + Ctl)
```
where `A :> B` indicates that `B` is a subtype of `A`. Phrased differently, `B` is more restrictive than `A` such that a value of type `B` can be used wherever a value of type `A` is required. If a callable relies on an argument (item) of being of type `A`, then an argument of type `B` can safely be substituted since if provides all the necessary capabilities. 

This kind of polymorphism extends to tuples in that a tuple type `B` is a subtype of a tuple type `A` if it contains the same number of items and the type of each item is a subtype of the corresponding item type in `A`. This is known as *depth subtyping*. 
It is worth pointing out that currently, there is no support for *width subtyping* whatsoever; there is no subtype relation between any two user defined types or a user defined type and any built-in type. The existence of the unwrap operator that allows to extract a tuple containing all named and anonymous items prevents this.  

Looking at callables, we have established that if a callable processes an argument of type `A`, then it is also capable of processing an argument of type `B`. If a callable is passed as an argument to another callable, then it has to be capable of processing anything that the type signature requires. This means that if the callable needs to be able to process an argument of type `B`, any callable that is capable of processing a more general argument of type `A` can safely be passed. We say that the operation or function type is *contravariant* in its argument type. Conversely, we expect that if we require that the passed callable returns an a value of type `A`, then the promise to return a value of type `B` is sufficient since that value will provide all necessary capabilities. We say that the operation or function type is *covariant* in its return type. `A :> B` hence implies that for any concrete type `T1`,
```
    (B → T1) :> (A → T1), and
    (T1 → A) :> (T1 → B) 
```
where `→` here can mean either a function or operation, and we omit any annotations for characteristics.
Substituting `A` with `(B → T2)` and `(T2 → A)` respectively, 
and substituting `B` with `(A → T2)` and `(T2 → B)` respectively leads to the conclusion that for any concrete type `T2`,
```
    ((A → T2) → T1) :> ((B → T2) → T1), and
    ((T2 → B) → T1) :> ((T2 → A) → T1), and
    (T1 → (B → T2)) :> (T1 → (A → T2)), and
    (T1 → (T2 → A)) :> (T1 → (T2 → B)) 
```
By induction, it follows that every additional indirection reverses the variance of the argument type, and leaves the variance of the return type unchanged. 

This also makes it clear what the variance behavior of arrays needs to be; retrieving items via an item access operator corresponds to invoking a function of type `(Int -> TItem)`, where `TItem` is the type of the elements in the array. Since this function is implicitly passed when passing an array, it follows that arrays need to be covariant in their item type. The same considerations also hold for tuples, which are immutable and thus covariant with respect to each item type.
If arrays weren't immutable, the existence of an construct that would allow to set items in an array and thus takes an argument of type `TItem` would imply that arrays also need to be contravariant. The only option for data types that support getting and setting items is hence to be *invariant*, meaning there is no subtyping relation whatsoever; `B[]` is *not* a subtype of `A[]` even if `B` is a subtype of `A`.

Despite that arrays in Q# are [immutable](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md#immutability), they are invariant rather than covariant. This is allows for more flexibility related to how arrays are handled and optimized in the runtime, but it may be possible to revise that in the future. 
