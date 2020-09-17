# Type System

With the focus for quantum algorithm being more towards what should be achieved rather than on a problem representation in terms of data structures, taking a more functional perspective on language design is a natural choice. At the same time, the type system is a powerful mechanism that can be leveraged for program analysis and other compile-time checks that facilitate formulating robust code. 

All in all, the Q# type system is fairly minimalist, in the sense that there isn't an explicit notion of classes or interfaces as one might be used to from classical languages like C# or Java. We also take a somewhat pragmatic approach making incremental progress, such that certain construct are not yet fully integrated into the type system. An example are functors, which can be used within expressions but don't yet have a representation in the type system. Correspondingly, they cannot currently be assigned or passed as arguments, similar as it is the case for type parametrized callables.
We expect to make incremental progress in extending the type system to be more complete, and balance immediate needs with longer-term plans. 

