# Binding scopes

In general, symbol bindings in Q# become inoperative at the end of the statement block they occur in. However, there are some exceptions to this rule.

## Visibility of local variables

| Scope | Visibility |
|------|-----|
| Loop variables |Bindings of loop variables in a [`for`](xref:microsoft.quantum.qsharp.iterations#iterations) loop are defined only for the body of the loop. They are inoperative outside of the loop. |
| [`use`](xref:microsoft.quantum.qsharp.quantummemorymanagement#quantum-memory-management) and [`borrow`](xref:microsoft.quantum.qsharp.quantummemorymanagement#quantum-memory-management) statements |Bindings of allocated qubits in `use` and `borrow` statements are defined for the body of the allocation, and are inoperative after the statement terminates. This only applies to `use` and `borrow` statements that have an associated statement block.|
| [`repeat`](xref:microsoft.quantum.qsharp.conditionalloops#conditional-loops) expressions |For `repeat` expressions, both blocks, as well as the condition, are treated as a single scope, that is, symbols that are bound in the body are accessible in both the condition and in the `fixup` block. |
| Loops |Each iteration of a loop runs in its own scope, and all defined variables are bound anew for each iteration. |

Bindings in outer blocks are visible and defined in inner blocks.
A symbol may only be bound multiple times per block in which case the last binding in scope is the one used for logic. This is known as "shadowing".

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

```qsharp
let n = 5;
...                 // n is 5
let n = 8;
...                 // n is 8
```

and

```qsharp
let n = 8;
if a == b {
    ...             // n is 8
    let n = 5;
    ...             // n is 5
}
...                 // n is 8 again
```

For more details, see [Variable Declarations and Reassignments](xref:microsoft.quantum.qsharp.variabledeclarationsandreassignments#variable-declarations-and-reassignments).


