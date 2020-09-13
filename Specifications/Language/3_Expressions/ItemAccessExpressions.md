# Item Access for User Defined Types

[This section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md) describes how to define custom types, containing one or more named or anonymous items. The contained items can be accessed via their name or by deconstruction, illustrated by the following statements that may be used as part of a operation or function implementation:

```qsharp
    let complex = Complex(1.,0.); // create a value of type Complex
    let (re, _) = complex!;       // item access via deconstruction
    let im = complex::Imaginary;  // item access via name
```

The item access operator (`::`) retrieves named items.
While named items can be accessed by their name or via deconstruction, anonymous items can only be accessed by the latter. Since deconstruction relies on all of the contained items, the usage anonymous items is discourage when these items need to be accessed outside the compilation unit in which the type is defined. 
Access via deconstruction makes use of the unwrap operator (`!`). That operator will return a tuple of all contained items, where a single item tuple is equivalent to the item itself (see [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md)).  
