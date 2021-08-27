# Singleton tuple equivalence

To avoid any ambiguity between tuples and parentheses that group sub-expressions, a tuple with a single element is considered to be equivalent to the contained item, including its type. For Example, the types `Int`, `(Int)`, and `((Int))` are treated as being identical. The same holds true for the values `5`, `(5)` and `(((5)))`, or for `(5, (6))` and `(5, 6)`. This equivalence applies for all purposes, including assignment. Since there is no dynamic dispatch or reflection in Q# and all types in Q# are resolvable at compile-time, singleton tuple equivalence can be readily implemented during compilation.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)