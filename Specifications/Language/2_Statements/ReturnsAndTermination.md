# Returns and Termination

There are two statements available that conclude the execution of the current subroutine or the program; the `return`- and the `fail`-statement.
For callables that return any other type than `Unit` each execution path needs to terminate either in a `return`- or a `fail`-statement

## Return-Statement

The `return`-statement exits from the current callable and returns control to the callee. It changes the context of the execution by popping a stack frame. 

The statement always returns a value back to the context of the callee; it consists of the keyword `return`, followed by an expression of the appropriate type, and a terminating semicolon. The return value is evaluated before any terminating actions are performed and control is returned. Such terminating actions include, e.g., cleaning up and releasing qubits that have been allocated within the context of the callable. When executing on a simulator or validator, terminating actions often also include checks related to the state of those qubits, like, e.g., whether they are properly disentangled from all qubits that remain live. 

The `return`-statement at the end of a callable that returns a `Unit` value may be omitted. In that case, control is returned automatically when all statements have been executed and all terminating actions were performed. Callables may contain multiple `return`-statements, one for each possible execution path, albeit the adjoint implementation for operations containing multiple `return`-statements cannot be automatically generated. 

For example,
```qsharp
return 1;
```
or 
```qsharp
return ();
```

## Fail-Statement

The `fail`-statement on the other hand aborts the computation entirely. It corresponds to a fatal error that was not expected to happen as part of normal execution. 

It consists of the keyword `fail`, followed by an expression of type `String` and a terminating semicolon.
The `String` value should be used to give information about the encountered failure.

For example,
```qsharp
fail "Impossible state reached";
```
or, using an [interpolated string](xref:microsoft.quantum.qsharp.valueliterals#string-literals),
```qsharp
fail $"Syndrome {syn} is incorrect";
```

In addition to the given `String`, ideally a `fail`- statement collects and permit to retrieve information about the program state that facilitate diagnosing and remedying the source of the error. This requires support from the executing runtime and firmware which may vary across different targets. 


