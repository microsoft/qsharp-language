# Visibility of Local Variables

In general, symbol bindings become inoperative at the end of the statement block they occur in. The exceptions to this rule are:

- Bindings of the loop variables in a [`for` loop](xref:microsoft.quantum.qsharp.iterations#iterations) are defined for the body of the loop, but not after the end of the loop.
- Bindings of allocated qubits in [`use`](xref:microsoft.quantum.qsharp.quantummemorymanagement#quantum-memory-management)- and [`borrow`-statements](xref:microsoft.quantum.qsharp.quantummemorymanagement#quantum-memory-management) are defined for the body of the allocation, but not after the statement terminates.
  This only applies to `use` and `borrow`-statements that have an associated statement block.
- For [`repeat`-statements](xref:microsoft.quantum.qsharp.conditionalloops#conditional-loops), both blocks as well as the condition are treated as a single scope; i.e. symbols that are bound in the body are accessible in the condition and in the `fixup`-block.

For loops, each iteration executes in its own scope, and all defined variables are bound anew for each iteration.

Bindings in outer blocks are visible and defined in inner blocks.
A symbol may only be bound once per block; it is illegal to define a symbol with the same name as another symbol that is accessible (no "shadowing").

The following sequences would be legal:

```qsharp
if (a == b) {
    ...
    let n = 5;
    ...             // n is 5
}
let n = 8;
...                 // n is 8
```

and

```qsharp
if (a == b) {
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

The following sequences would be illegal:

```qsharp
let n = 5;
...                 // n is 5
let n = 8;          // Error
...
```

and

```qsharp
let n = 8;
if (a == b) {
    ...             // n is 8
    let n = 5;      // Error
    ...
}
...
```

[This section](xref:microsoft.quantum.qsharp.variabledeclarationsandreassignments#variable-declarations-and-reassignments) gives further details on variable declarations and reassignments. 

