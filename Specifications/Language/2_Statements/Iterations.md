# Iterations

Loops that iterate over a sequence of values are expressed as `for`-loops in Q#. A `for`-loop in Q# does not break based on a condition, but instead corresponds to what is often expressed as `foreach` or `iter` in other languages. There are furthermore no `break`- or `continue`-primitives in Q#, such that the length of the loop is perfectly predictable as soon as the value to iterate over is known. Such `for`-loops can hence be executed on all quantum hardware.

There are currently two data types in Q# that support iteration: arrays and ranges. 
The same deconstruction rules apply to the defined loop variable(s) as to any other variable assignment, such as bindings in `let`-, `mutable`-, `set`-, `using`- and `borrowing`-statements. The loop variables themselves are immutably bound, cannot be reassigned within the body of the loop, and go out of scope when the loop terminates. 
