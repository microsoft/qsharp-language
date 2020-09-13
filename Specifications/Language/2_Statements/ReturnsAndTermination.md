# Returns and Termination

There are two statements available that conclude the execution of the current subroutine or the program; the `return`- and the `fail`-statement.  

The `return`-statement exits from the current callable and returns control to the callee. It changes the context of the execution by popping a stack frame. The statement always returns a value back to the context of the callee. The return value is evaluated before any terminating actions are performed and control is returned. Such terminating actions include, e.g., cleaning up and releasing qubits that have been allocated within the context of the callable. When executing on a simulator or validator, terminating actions often also include checks related to the state of those qubits, like, e.g., whether they are properly disentangled from all qubits that remain live. 

The `return`-statement at the end of a callable that returns a `Unit` value may be omitted. In that case, control is returned automatically when all statements have been executed and all terminating actions were performed. Callables may contain multiple `return`-statements, one for each possible execution path, albeit operations containing multiple `return`-statements cannot be automatically inverted. 

The `fail`-statement on the other hand aborts the computation entirely. It corresponds to a fatal error that was not expected to happen as part of normal execution. Ideally, a `fail`- statement should collect and permit to retrieve information about the program state that facilitate diagnosing and remedying the source of the error. Of course, this requires support from the executing runtime and firmware. 
