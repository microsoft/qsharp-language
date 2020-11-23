# Namespaces

At the top-level, a Q# program consists of a set of namespaces; namespaces are the only top-level elements (aside from [comments](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/7_Comments.md#comments)), and anything else needs to be contained in a namespace. 
Q# does not support nested namespaces. Each file may contain zero or more namespaces, and each namespace may span multiple files.

A namespace block consists of the keyword `namespace`, followed by the name of the namespace, and the content of that block inside curly brackets `{` and `}`. 
Namespace names consist of a sequence of one or more [legal symbols](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Identifiers.md#identifiers) separated by a dot (`.`).
Double underscores (`__`), double dots (`..`), or an underscore followed by a dot (`_.`) are not permitted, since these character sequences are reserved. More precisely, a fully qualified name may not contain such a sequence, and namespace names correspondingly cannot end with an underscore.   
While namespace names may contain dots for better readability, Q# does not support relative references to namespaces; two namespaces `Foo` and `Foo.Bar` are entirely unrelated and there is no notion of a hierarchy. In particular, for a function `Baz` defined in `Foo.Bar`, it is *not* possible to open `Foo` and then access that function via `Bar.Baz`. 

Within a namespace block, [open directives](#open-directives) precede any other namespace elements. 
Aside from `open` directives, namespace blocks may contain [operation](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md#callable-declarations), [function](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md#callable-declarations) and [type](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md#type-declarations) declarations. These may occur in any order, and are recursive by default, meaning they can be declared and used in any order and can call themselves; there is no need for the declaration of a type or callable to precede its use.

## Open Directives

By default, everything declared within the same namespace can be accessed without further qualification, whereas declarations in a different namespace can only be used either by qualifying their name with the name of the namespace they belong to, or by opening that namespace before use as it is done for `Microsoft.Quantum.Arithmetic` below.  

```qsharp
namespace Microsoft.Quantum.Samples {
    
    open Microsoft.Quantum.Arithmetic; 
    open Microsoft.Quantum.Arrays as Array; 

    // ...
}
```

An `open` directive such as the one in Line 3 above imports all types and callables declared in the opened namespace such that they can be refer to by their unqualified name, unless that name conflicts with a declaration in the namespace block or another opened namespace. 

It is possible to define an alternative, usually shorter, name for a particular namespace to avoid having to type out the full name but still distinguish where certain elements came from. In that case, all types and callables declared in that namespace can be qualified by the defined short name instead.
This is done for the `Microsoft.Quantum.Arrays` namespace in the example above. A function `IndexRange` declared in `Microsoft.Quantum.Arrays`, for instance, can then be used via `Array.IndexRange` within that namespace block.

Defining namespace aliases is particularly helpful in combination with the code completion functionality provided by the Q# extensions available for Visual Studio Code and Visual Studio; If the extension is installed, typing the namespace alias followed by a dot will show a list of all available elements in that namespace that can be used at the current location.  

Whether a namespace is opened or an alias is defined, `open` directives need to precede any other namespace elements and are valid throughout the namespace piece in that file only. 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
