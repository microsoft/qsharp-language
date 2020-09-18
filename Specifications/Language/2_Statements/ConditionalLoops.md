# Conditional Loops

In terms of execution, loops that break based on a condition can be a huge challenge to process on quantum hardware if the condition depends on measurement outcomes; this poses an extra challenge since the length of the instruction sequence to execute is not known ahead of time. Despite that, Q# supports such constructs. 

The repeat-until-success pattern is a vital ingredient to a lot of quantum algorithms. Q# hence has its own dedicated statement for these: the `repeat`-statement. The statement consists of a first block to execute, after which a condition is evaluated. If the condition evaluates to true, the loop exists. If the condition evaluates to false, an addition block of statements defined as part of an optional `fixup`-block is executed prior to entering the next loop iteration. 

Despite their common presence in particular classes of quantum algorithms, current hardware does not yet provide native support for these kind of control flow constructs. Execution on quantum hardware can potentially be supported in the future by imposing a maximum number of iterations.

In an effort to provide a more familiar looking statement for classical computations, a traditional `while`-loop is also supported, albeit only within functions to discourage the use of loops that break based on a condition when dealing with quantum computation, unless they are needed. With more sophisticated tracking regarding when a value depends on the quantum parts of a computation, it will be possible to allow the use of `while`-loops within operations as well, as long as the condition does not depend on quantum instructions within the body of the loop. 
There is also no reason not to support other kinds of commonly available loop constructs within functions in the future. 
