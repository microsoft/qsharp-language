# Immutability

All types in Q# are *value types*. Q# does not have a concept of a reference or pointer. Instead, it allows you to reassign a new value to a previously declared variable via a `set` statement. For example, there is no distinction in behavior between reassignments for variables of type `Int` or variables of type `Int[]`. Consider the following sequence of statements:

```qsharp
    mutable arr1 = new Int[3];
    let arr2 = arr1; 
    set arr1 w/= 0 <- 3; 
```

The first statement instantiates a new array of integers `[0,0,0]` and assigns it to `arr1`. 
The next statement assigns that value to a variable with name `arr2`. The last statement creates a new array instance based on `arr1` with the same values except for the value at index 0 which is set to 3. The newly created array is then assigned to the variable `arr1`. The last line makes use of the abbreviated syntax for [evaluate-and-reassign statements](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#evaluate-and-reassign-statements), and could equivalently have been written as `set arr1 = arr1 w/ 0 <- 1;`.  
After running the three statements, `arr1` will contain the value `[3,0,0]` while `arr2` remains unchanged and contains the value `[0,0,0]`. 

Q# clearly thus distinguishes the mutability of a handle and the behavior of a type. 
Mutability within Q# is a concept that applies to a *symbol* rather than a type or value; 
it applies to the handle that allows you to access a value rather than to the value itself. It is *not* represented in the type system, implicitly or explicitly.

Of course, this is merely a description of the formally defined behavior; under the hood, the actual implementation uses a reference counting scheme to avoid copying memory as much as possible. 
The modification is specifically done in place as long as there is only one currently valid handle that accesses a certain value.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)