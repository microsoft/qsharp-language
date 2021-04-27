# Returns and termination

There are two statements available that conclude the execution of the current subroutine or the program; the `return` and the `fail` statements.
For callables that return any type other than `Unit`, each run path needs to terminate in a `return` or a `fail` statement

## Return statement

The `return` statement exits from the current callable and returns control to the callee. It changes the context of the execution by popping a stack frame. 

The statement always returns a value to the context of the callee; it consists of the keyword `return`, followed by an expression of the appropriate type and a terminating semicolon. The return value is evaluated before any terminating actions are performed and control is returned. Terminating actions include, for example, cleaning up and releasing qubits that are allocated within the context of the callable. When running on a simulator or validator, terminating actions often also include checks related to the state of those qubits, for example, whether they are properly disentangled from all qubits that remain live.

The `return` statement at the end of a callable that returns a `Unit` value may be omitted. In that case, control is returned automatically when all statements have run and all terminating actions have been performed. Callables may contain multiple `return` statements, one for each possible execution path, albeit the adjoint implementation for operations containing multiple `return` statements cannot be automatically generated. 

For example,

```qsharp
return 1;
```

or 

```qsharp
return ();
```

## Fail statement

The `fail` statement, on the other hand, ends the computation entirely. It corresponds to an unexpected fatal error that happens as part of the normal run process. 

It consists of the keyword `fail`, followed by an expression of type `String` and a terminating semicolon.
The `String` value provides information about the encountered failure.

For example,

```qsharp
fail "Impossible state reached";
```

or, using an [interpolated string](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ValueLiterals.md#string-literals),

```qsharp
fail $"Syndrome {syn} is incorrect";
```

In addition to the given `String`,  a `fail` statement ideally collects and permits the retrieval of information about the program state. This facilitates diagnosing and remedying the source of the error, and requires support from the executing runtime and firmware, which may vary across different targets. 

← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)