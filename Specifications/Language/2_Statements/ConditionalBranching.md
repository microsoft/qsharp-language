# Conditional Branching

In contrast to embedded languages that predominately leverage a classical host language to provide expressiveness for control flow constructs, Q# integrates these constructs seamlessly with quantum computations. 
As of the time of writing, conditional branching is expressed in the form of `if`-statements, that may optionally contain zero or more `elif`-clauses and an `else`-block that is executed if none of the conditions evaluate to true. From an execution perspective, the same constructs that represent such and `if`-statement could equally well be leveraged to express `match`-statements as they existing, e.g., in F# in the future. Especially in combination with additional types like discriminated unions, this could significantly enhance expressiveness and ease of use. 
Additionally, Q# even allows to express simple branching in the form of a [conditional expression](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language).

A tight integration between control-flow constructs and quantum computations of course poses a challenge for current hardware. Here is where the Q#'s rigorous type system has its benefits; it allows for fine-grained control over how information that depends on measurement outcomes on the quantum device may propagate and impact the program continuation. 

Measurement results are represented by their own dedicated `Result` type within Q#.
Since there are no automatic casts or even explicit casts between values of type `Result` and any other data types, the only way how the program continuation can depend on quantum computations is when a `Result` value is compared for equality or inequality against another `Result`. Restricting when and where such comparisons may happen thus gives the means to impose exactly the adequate restrictions to precisely match current hardware capabilities. 

Certain quantum processors do not support branching based on measurement outcomes. Comparison for values of type `Result` will hence always result in a compilation error for Q# programs that are targeted to execute on that hardware. 
Other quantum processors support specific kinds of branching based on measurement outcomes. Concretely, they support the kind of branching that could also be expressed in OpenQASM. Q# allows to express more general constructs. However, they can largely be translated into suitable calls of nested primitives. The imposed restrictions are that values of type `Result` may only be compared as part of the condition within if-statements in operations. The conditionally executed blocks furthermore cannot contain any return statements or update mutable variables that are declared outside that block. 

Such restrictions can even be enforced at design-time, meaning whether or not a certain comparison or call is supported by the targeted hardware platform can be determined and displayed live while editing source code in an IDE. 

Let's look at an example for how `if`-statements are translated when targeting devices with limited control flow capabilities. 
For example, if `res` is the result of a measurement and `q` is a qubit, a conditional statement of the form
```qsharp
    if (M(q) == res or res == Zero){
        H(q);                
    }    
```
would be translated into a call-statement
```qsharp
    ApplyConditionally(
        [M(q)], [res], 
        (H, q), 
        (ApplyIfZeroCA(_, (H, _)), (res, q))
    );
```
Upon execution, the first two arguments in the call to `ApplyConditionally` will be compared for equality. If they are equal, then the first item in the third argument `H` is invoked with the second time in the third argument (the qubit `q`). If they are unequal, then the first item in the forth argument `ApplyIfZeroCA(_, (H, _))` is invoked with the second item in the forth argument. That invocation applies `H` to `q` if `res` is `Zero`.

If the conditional block contains more than a single operation (`H` in the given example), then the content of that block is lifted upon compilation; a new operation is generated that contains the statements in that block and takes the captured values as arguments. The characteristics of the lifted code block are correctly inferred and preserved.
Similar code transformations are done for more involved examples in order to generate suitable instructions that are easier to process for the targeted quantum hardware. These compiler capabilities allow to execute even repeat-until-success-based algorithms on current quantum processors. 
