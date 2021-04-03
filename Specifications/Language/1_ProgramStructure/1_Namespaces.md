# Namespaces

At its top-level, a Q# program consists of a set of namespaces. Aside from [comments](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/7_Comments.md#comments), namespaces are the only top-level elements in a Q# program, and any other elements must reside within a namespace. 
Each file may contain zero or more namespaces, and each namespace may span multiple files. Q# does not support nested namespaces.

A namespace block consists of the keyword `namespace`, followed by the namespace name, and the content of the block inside braces `{ }`. 
Namespace names consist of a sequence of one or more [legal symbols](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Identifiers.md#identifiers) separated by a dot (`.`).
Double underscores (`__`), double dots (`..`), or an underscore followed by a dot (`_.`) are not permitted since these character sequences are reserved. More precisely, a fully qualified name may not contain such a sequence, and namespace names correspondingly cannot end with an underscore.
While namespace names may contain dots for better readability, Q# does not support relative references to namespaces. For example, two namespaces `Foo` and `Foo.Bar` are unrelated, and there is no notion of a hierarchy. In particular, for a function `Baz` defined in `Foo.Bar`, it is *not* possible to open `Foo` and then access that function via `Bar.Baz`. 

Within a namespace block, [open directives](#open-directives) precede any other namespace elements. 
Aside from `open` directives, namespace blocks may contain [operation](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md#callable-declarations), [function](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md#callable-declarations), and [type](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md#type-declarations) declarations. These may occur in any order and are recursive by default, meaning they can be declared and used in any order and can call themselves; there is no need for the declaration of a type or callable to precede its use.

## Open Directives

By default, everything declared within the same namespace can be accessed without further qualification. However, declarations in a different namespace can only be used by qualifying their name with the name of the namespace they belong to or by opening that namespace before it is used, as shown in the following example.  

```qsharp
namespace Microsoft.Quantum.Samples {
    
    open Microsoft.Quantum.Arithmetic; 
    open Microsoft.Quantum.Arrays as Array; 

    // ...
}
```

The example also uses two `open` directives, which import all types and callables declared in the opened namespace. They can then be referred to by their unqualified name unless that name conflicts with a declaration in the namespace block or another opened namespace. 

To avoid typing out the full name while still distinguishing where certain elements come from, you can define an alternative name, or *alias*, which is usually shorter, for a particular namespace. In this case, all types and callables declared in that namespace can be qualified by the defined short name instead. 
In the previous example, this is the case for the `Microsoft.Quantum.Arrays` namespace. A function `IndexRange` declared in `Microsoft.Quantum.Arrays`, for example, can then be used via `Array.IndexRange` within that namespace block.

Defining namespace aliases is particularly helpful when combined with the code completion functionality provided by the Q# extensions available for Visual Studio Code and Visual Studio. With the extension installed, typing the namespace alias followed by a dot will show a list of all the available elements in that namespace that are valid at the current location.  

Whether you are opening a namespace or defining an alias, `open` directives need to precede any other namespace elements and are valid throughout the namespace piece in that file only.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
