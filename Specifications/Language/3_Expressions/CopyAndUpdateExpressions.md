# Copy-and-Update Expressions

To reduce the need for mutable bindings, Q# supports copy-and-update expressions for value types with item access. Such expressions eliminate the need for one or several dedicated set-statements in certain cases.
There are currently two such types available; user defined types, which allow to access items via name, and arrays, which allow to access items via index. 
Such copy-and-update expressions consist of a ternary operator and are of the form 
```qsharp
    expression w/ itemAccess <- expression
```
with suitable restrictions regarding the type of the inner expressions. The use of the syntax `w/` is rooted in the short notation commonly used for "with".

For user defined types, `itemAccess` denotes the name of the item that diverges from the original value. The reason that this is not simply another expression of suitable type is that the ability to simply use the item name without any further qualification is limited to this context; it is one of two *contextual expressions* in Q#, see also \autoref{sec:contextual_expressions}. 

For arrays, `itemAccess` indeed is just any expression of a suitable type. 
In the interest of consistency, the same types that are valid for array slicing are valid in this context; more concretely, the `itemAccess` expression currently can be of type `Int`, `Range`, and in the future possibly also of type `Int[]`, which is not yet supported neither in this context nor in array slicing expressions. 

Copy-and-update expressions allow efficient creation of new arrays based on existing ones. 
The implementation for copy-and-update expressions avoids copying the entire array 
but merely duplicates the necessary parts to achieve the desired behavior, and performs an in-place modification if possible. 
Suitable means to initialize an array via, e.g., an initialization function or similar means are provided by the standard libraries. Array initialization via a call to such a core function does not incur additional overhead due to immutability. 

In terms of precedence, the copy-and-update operator is left-associative and has lowest precedence, 
and in particular lower precedence than the range operator (`..`) or the ternary conditional operator (`?|`). 
The chosen left associativity allows easy chaining of copy-and-update expressions:

```qsharp
    let model = Default<SequentialModel>()
                    w/ Structure <- ClassifierStructure()
                    w/ Parameters <- parameters
                    w/ Bias <- bias;
```

Like for any operator that constructs an expression that is of the same type as the left-most expression involved, the corresponding [evaluate-and-reassign statement](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndUpdates.md#evaluate-and-reassign-statements) is available. 
The two statements below for example achieve the following: The first statement declares a mutable variable `arr` and binds it to the default value of an integer array. The second statement then builds a new array with the first item (with index 0) set to 3, and reassigns it to `arr`. 
```qsharp
    mutable arr = new Int[3]; // arr contains [0,0,0]
    set arr w/= 0 <- 10;      // arr contains [3,0,0] 
```
The second statement is nothing but a short-hand for the more verbose syntax `set arr = arr w/ 0 <- 10;`.
