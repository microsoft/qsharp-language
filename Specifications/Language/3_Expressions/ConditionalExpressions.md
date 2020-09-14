# Conditional Expressions

Conditional expressions consist of three sub-expressions, where the left-most one is of type `Bool` and determines which one of the two other sub-expressions is evaluated. They are of the form `cond ? ifTrue | ifFalse`.
The types of the `ifTrue` and the `ifFalse` expression have to have a common base type. Independent of which one of the two ultimately yields the value to which the expression evaluates, its type will always match the determined base type. 

While such expressions are rather convenient to use, they also require a rather non-trivial translation upon compilation, since there is no corresponding construct in the planned intermediate representation that a Q# program is intended to compile into. Conditional expressions hence need to be converted to full-fledged `if`-statements during compilation. 
Naively, the use of a conditional expression could be expressed as an assignment to a mutable variable that is then substituted where the conditional expression was used. With `__CBT__` standing for the determined common base type, the native translation would look like
```qsharp
    mutable __tempVar1__ = Default<__CBT__>();
    if (cond) { set __tempVar1__ = ifTrue; }
    else      { set __tempVar1__ = ifFalse; }
```
followed by the original code with the conditional expression replaced by `__tempVar1__`. 
Considering the restrictions that apply to [if-statements](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalBranching.md) when targeting a program for execution on current quantum hardware, this translation is clearly suboptimal; It violates these restrictions if the condition contains a comparison of a `Result` value even if the targeted hardware fundamentally is capable of processing the necessary branching based on measurement results. 

Let's look at whether, when and how we can do better by considering how conditional expressions can be used.
We will start by looking at how they can be used within expressions. [This section](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language) gives an overview over all possible expressions in Q#. Considering any unary prefix operator or modifier 〈#〉, it is easy to see that 
```
    〈#〉 (cond ? ifTrue | ifFalse)
```
is the same as 
```
    cond ? (〈#〉 ifTrue) | (〈#〉 ifFalse). 
```
Clearly, also any unary postfix operator or modifier can be pulled into the conditional expression in a similar fashion. Thanks to the fact that only ever one "side" of the conditional expression is evaluated, the same also holds for all binary operators that do not [short-circuit](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language), as well as for [copy-and-update expressions](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language) (which are built using the only other ternary operator) and all [combinators](https://github.com/microsoft/qsharp-language/tree/beheim/specs/Specifications/Language). 
More care needs to be taken for binary operators that short-circuit, i.e. for the logical *AND* and *OR*. In the case where the conditional expression is used on the left-hand-side, they can be pulled in as well. In the case where the conditional is on the right-hand-side, however, we need to preserve the original expression. 
Nested conditionals need to be translated into nested `if`-statement (unless the nesting merely occurs as part of the condition), with the corresponding options regarding flattening them into an `if`-statement with several `elif`-clauses.

To summarize these considerations in EBNF notation, any expression can be brought into the following form:
```
    conditional = "(", expr, "?", expr, "|", expr, ")"
    expr = "branchFree"
        | [expr ("and"|"or")], conditional
```
where "branchFree" is an expression that does not contain any conditionals. Nested conditionals translate into nested `if`-statements in a straightforward manner. For the rest of this section we will hence limit the discussion to considering expressions of the form `cond ? ifTrue | ifFalse` which we will abbreviate with `condEx`, leaving it up to the reader to generalize the translation to include arbitrary expressions containing one or more conditionals. 

We proceed to look at each statement to determine whether we can translate any contained conditional expressions in a way that would permit to execute it on quantum hardware with limited support for branching based on measurement results. It should be stated explicitly that the naive translation given at the beginning of this section will do perfectly fine as long as the condition does not contain any `Result` values. 

Expression statements don't require further considerations beyond what has already been discussed regarding conditionals within expressions, and neither do conjugations as they only contain statement blocks and no additional expressions.

In the case of a `return`-statement, there is not much we can do without the firmware/hardware support that would allow to evaluate all expressions that make use of the returned value. 
Of course, we could attempt to propagate the condition into the caller by adding the corresponding branching to the program continuation, but this quickly becomes infeasible. 
A `fail`-statement on the other hand aborts all further computation and we can pull the `fail`-statement into the generated `if`-statement. The statement `fail condEx;` then simply becomes
```qsharp
    if (cond) { fail ifTrue; }
    else      { fail ifFalse; }
```

If a value assigned as part of a `let`-, `mutable`-, or `set`-statement depends on a conditional expression, we potentially face the same challenges as for a `return`-statement. As long as no `return`- or `set`-statements depend on the bound variable(s) and the assignment is not part of a `repeat`-loop, we can enclose all subsequent computations that make use of the bound variable(s) into a suitable `if`-statement. If this is not possible or impractical, supporting such occurrences then requires that all subsequent computations that depend on the bound variable(s) and impact the executed quantum transformations can be evaluated while qubits remain live.
The same holds for the loop variable(s) of a `for`-loop iterating through a sequence that depends on the evaluation of a conditional expression. 

Conditionals in all other statements on the other hand can be supported as long as the statement itself is executable; any value resulting from evaluating a conditional expression is never assigned such that it is only ever used within the statement itself and not as part of the statement body or subsequent statements. The idea here is to convert the expression to a suitable `if`-statement and pull the assignment of each sub-expression into the corresponding branch - if such an assignment is even necessary. 
In the case of a conditional expression within an existing `if`-statement, or a `using`- or `borrowing`-statement, this translation is straightforward. A `using`-statement of the form `using (qs = Qubit[condEx]){ ... }` for example is translated into
```qsharp
    if (cond) {
        using (qs = Qubit[ifTrue]) {
            // some code
        }
    }
    else {
        using (qs = Qubit[ifFalse]) {
            // some code
        }
    }
```
A mutable assignment is required to deal with loops that break based on a condition. 
Nonetheless, in contrast to `for`-loops, as well as `let`-, `mutable`-, `set`-, and `return`-statements, we can be sure that the bound variable cannot impact the program flow beyond determining whether to enter the next iteration. Currently, such loops need to be unrolled in order to be executable, which requires imposing a (fairly small) limit on the maximal number of iterations (see also \autoref{sec:loops}).
