# Copy-and-Update Expressions

To reduce the need for mutable bindings, Q# supports copy-and-update expressions for value types with item access. User defined types and arrays both are immutable and fall into this category. 
User defined types allow to access items via name, whereas arrays allow to access items via an index or range of indices. 

Copy-and-update expressions instantiate a new value of with all items set to the corresponding value in  the original expression, except certain specified items(s), which are set to the one(s) defined on the right hand side of the expression. 
They are constructed using a ternary operator `w/` `<-`; the syntax `w/` should be read as the commonly used short notation for "with":
```qsharp
    original w/ itemAccess <- modification
```
where `original` is either an expression of user defined type or an array expression. The corresponding requirements for `itemAccess` and `modification` are specified in the corresponding subsection below. 

In terms of precedence, the copy-and-update operator is left-associative and has lowest precedence, 
and in particular lower precedence than the range operator (`..`) or the ternary conditional operator (`?` `|`). 
The chosen left associativity allows easy chaining of copy-and-update expressions:

```qsharp
    let model = Default<SequentialModel>()
                    w/ Structure <- ClassifierStructure()
                    w/ Parameters <- parameters
                    w/ Bias <- bias;
```

Like for any operator that constructs an expression that is of the same type as the left-most expression involved, the corresponding [evaluate-and-reassign statement](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#evaluate-and-reassign-statements) is available. 
The two statements below for example achieve the following: The first statement declares a mutable variable `arr` and binds it to the default value of an integer array. The second statement then builds a new array with the first item (with index 0) set to 3, and reassigns it to `arr`. 
```qsharp
    mutable arr = new Int[3]; // arr contains [0,0,0]
    set arr w/= 0 <- 10;      // arr contains [3,0,0] 
```
The second statement is nothing but a short-hand for the more verbose syntax `set arr = arr w/ 0 <- 10;`.

## Copy-and-Update of User Defined Types

If the value `original` is of user defined type, then `itemAccess` denotes the name of the item that diverges from the original value. The reason that this is not simply another expression, like `original` and `modification`, is that the ability to simply use the item name without any further qualification is limited to this context; it is one of two [contextual expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions) in Q#. 

The type of the `modification` expression needs to match the type of the named item that diverges. 
For instance, for a type `Complex` defined as 
```qsharp
newtype Complex = (Re : Double, Im : Double);
```
if `complex` contains the value `Complex(0.,0.)`, then 
```qsharp
complex w/ Re <- 1. 
```
is an expression of type `Complex` that evaluates to `Complex(1.,0.)`.

## Copy-and-Update of Arrays

For arrays, `itemAccess` can be an arbitrary expression of a suitable type;
the same types that are valid for array slicing are valid in this context. Concretely, the `itemAccess` expression can be of type `Int` or `Range`. If `itemAccess` is a value of type `Int`, then the type of `modification` has to match the item type of the array. If `itemAccess` is a value of type `Range` then the type of `modification` has to be the same as the array type. 

For example, if `arr` contains an array `[0,1,2,3]`, then 
- `arr w/ 0 <- 10` is the array `[10,1,2,3]`.
- `arr w/ 2 <- 10` is the array `[0,1,10,3]`.
- `arr w/ 0..2..3 <- [10,12]` is the array `[10,1,12,3]`.

Copy-and-update expressions allow efficient creation of new arrays based on existing ones. 
The implementation for copy-and-update expressions avoids copying the entire array 
but merely duplicates the necessary parts to achieve the desired behavior, and performs an in-place modification if possible. 
Suitable ways to initialize an array via, e.g., an initialization function or similar means are provided by the standard libraries. Array initialization via a call to such a core function does not incur additional overhead due to immutability. 


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)