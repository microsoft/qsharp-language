# Binding scopes

In general, symbol bindings in Q# become inoperative at the end of the statement block they occur in. However, there are some exceptions to this rule.

## Visibility of local variables


| Scope | Visibility |
|------|-----|
| Loop variables |Bindings of loop variables in a [`for`](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Iterations.md#iterations) loop are defined only for the body of the loop. They are inoperative outside of the loop. |
| [`use`](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md#quantum-memory-management) and [`borrow`](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md#quantum-memory-management) statements |Bindings of allocated qubits in `use` and `borrow` statements are defined for the body of the allocation, and are inoperative after the statement terminates. This only applies to `use` and `borrow` statements that have an associated statement block.|
| [`repeat`](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalLoops.md#conditional-loops) statements |For `repeat` statements, both blocks, as well as the condition, are treated as a single scope, that is, symbols that are bound in the body are accessible in both the condition and in the `fixup` block. |
| Loops |Each iteration of a loop runs in its own scope, and all defined variables are bound anew for each iteration. |

Bindings in outer blocks are visible and defined in inner blocks.
A symbol may only be bound once per block; it is not valid to define a symbol with the same name as another symbol that is accessible (no "shadowing").

The following sequences are valid:

```qsharp
if a == b {
    ...
    let n = 5;
    ...             // n is 5
}
let n = 8;
...                 // n is 8
```

and

```qsharp
if a == b {
    ...
    let n = 5;
    ...             // n is 5
} else {
    ...
    let n = 8;
    ...             // n is 8
}
...                 // n is not bound to a value
```

The following sequences are invalid:

```qsharp
let n = 5;
...                 // n is 5
let n = 8;          // Error
...
```

and

```qsharp
let n = 8;
if a == b {
    ...             // n is 8
    let n = 5;      // Error
    ...
}
...
```

For more details, see [Variable Declarations and Reassignments](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#variable-declarations-and-reassignments). 

← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
