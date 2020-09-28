---
title: Implicitly-scoped qubit allocation
description: Provides more convenient syntax for allocating qubits.
author: Sarah Marshall
date: September 28, 2020
---

# Proposal

1. Add new `use` and `borrow` statements to allocate qubits that are valid until the end of the current block.
2. Add new unconditional block statement that does not require a preceding keyword, and is executed exactly once; equivalent to `if (true) { }`.
3. Deprecate and remove existing `using` and `borrowing` block statements.

# Justification

Qubit allocation is curently awkward in Q# for two reasons:

1. It requires creating a new block to define the lifetime of the qubit, even when the intended lifetime is the same as the current block.
2. Allocating multiple qubits at the same time requires either tuple destructuring or nested blocks, both of which can be hard to read.

As a quantum programming language, qubit allocation is at the core of Q#.
Both the simple case of allocating a single qubit for the remainder of the current block, and more complicated scenarios involving multiple qubit variables that are both clean and borrowed and have varying lifetimes, should have clear, intuitive syntax that doesn't require boilerplate.

# Description

Qubits are a managed resource in Q#: when qubits are allocated, they are valid only within the new block declared at allocation, after which they are released and can no longer be used.
This proposal makes qubit allocation in Q# always scoped to the current block.
Instead of being released at the end of a newly-declared block, qubits are released at the end of the current block.
It also extends block statement syntax to allow precise control of qubit lifetime when needed in more complicated scenarios.
Finally, this proposal aims to be syntactically minimal and consistent with other binding statements like `let`, in contrast to alternatives that have more complicated syntax.

## Current Status

The only mechanism to allow qubits in Q# currently is with `using` and `borrowing` block statements.
These statements will be deprecated and removed, replaced with new `use` and `borrow` statements that do not require a block, as well as a new unconditional block statement that can be used when a new block is desired.

No new functionality is provided by this proposal.
Every example with the existing syntax has a corresponding equivalent example with the proposed syntax, and vice versa.
However, the proposed syntax addresses several problems with the existing syntax:

1. Example 1a: The lifetime of the qubit `q` is the same as the lifetime of the surrounding block.
   A new block is syntactically required, but does not serve any purpose other than increasing the indentation level.
2. Example 2a: Allocating multiple qubits requires either a single `using` statement with tuple destructuring, or multiple nested `using` statements.
   Tuple destructuring is hard to read when many variables are declared or when the qubit initializer expression is long.
   It is hard to tell which tuple item corresponds to which variable name.
3. Example 3a: Allocating multiple qubits with nested `using` statements makes it clear which qubit initializer expression corresponds to which variable name, but at the cost of many levels of unnecessary indentation.
4. Example 4a: When `using` and `borrowing` statements are mixed, nested blocks are required; tuple destructuring is not possible.

Example 5a shows the main benefit of the current syntax: it allows the lifetime of a qubit to be shorter than the parent block.
While this exact syntax will be removed, the proposed syntax can also express this in a simple way.

### Examples

Example 1a: A single qubit allocated and released at the same time as the end of the outer block.

```qsharp
operation FlipCoin() : Result {
    using (q = Qubit()) {
        H(q);
        return M(q);
    }
}
```

Example 2a: Many qubits allocated in a single `using` statement with tuple destructuring.

```qsharp
operation QubitTuple(n : Int) : Result {
    using ((a, b, c) = (Qubit(), Qubit[2 * n + 1], Qubit[n])) {
        // ...
        return M(q);
    }
}
```

Example 3a: Many qubits allocated with a separate `using` block for each variable.

```qsharp
operation NestedBlocks(n : Int) : Result {
    using (a = Qubit()) {
        using (b = Qubit[2 * n + 1]) {
            using (c = Qubit[n]) {
                // ...
                return M(q);
            }
        }
    }
}
```

Example 4a: A clean qubit and a borrowed qubit. This can only be expressed with nested blocks, not with tuple destructuring.

```qsharp
operation UsingAndBorrowing() : Result {
    using (a = Qubit()) {
        borrowing (b = Qubit()) {
            // ...
            return M(a);
        }
    }
}
```

Example 5a: A qubit allocated in a `using` block but released before the end of the outer block.

```qsharp
operation DifferentLifetime() : Result {
    mutable r = Zero;
    using (q = Qubit()) {
        // Apply operations...
        set r = M(q);
    }
    // Classical post-processing...
    return r;
}
```

## Proposed Modification

The new `use` and `borrow` statements behave identically to `using` and `borrowing`, but the new block is implicitly defined to start at the statement and end at the end of the current block:

```qsharp
operation FlipCoin() : Result {
    let x = 10;
    use q = Qubit();
    H(q);
    return M(q);
}
```

is equivalent to

```qsharp
operation FlipCoin() : Unit {
    let x = 10;
    using (q = Qubit()) {
        H(q);
        return M(q);
    }
}
```

In combination with the new unconditional block statement, the lifetime control provided by `using` can be obtained:

```qsharp
operation FlipCoin() : Result {
    mutable r = Zero;
    {
        use q = Qubit();
        H(q);
        set r = M(q);
    }
    return r;
}
```

is equivalent to

```qsharp
operation FlipCoin() : Result {
    mutable r = Zero;
    if (true) {
        using (q = Qubit()) {
            H(q);
            set r = M(q);
        }
    }
    return r;
}
```

or more simply

```qsharp
operation FlipCoin() : Result {
    mutable r = Zero;
    using (q = Qubit()) {
        H(q);
        set r = M(q);
    }
    return r;
}
```

Each example below is equivalent to the corresponding example in the Current Status section with the same number.

### Examples

Example 1b: A single qubit allocated and released at the same time as the end of the outer block.

```qsharp
operation FlipCoin() : Result {
    use q = Qubit();
    H(q);
    return M(q); // q is released here.
}
```

Example 2b: Many qubits allocated in a single `use` statement with tuple destructuring.

```qsharp
operation QubitTuple(n : Int) : Result {
    use (a, b, c) = (Qubit(), Qubit[2 * n + 1], Qubit[n]);
    // ...
    return M(a); // a, b, and c are released here.
}
```

Example 3b: Many qubits allocated with a separate `use` statement for each variable.

```qsharp
operation NestedBlocks(n : Int) : Result {
    use a = Qubit();
    use b = Qubit[2 * n + 1];
    use c = Qubit[n];
    // ...
    return M(q); // a, b, and c are released here.
}
```

Example 5b: A clean qubit and a borrowed qubit. This can only be expressed with multiple statements, not with tuple destructuring.

```qsharp
operation UsingAndBorrowing() : Result {
    use a = Qubit();
    borrow b = Qubit();
    // ...
    return M(a); // a and b are released here.
}
```

Example 5b: A qubit allocated in new block and released before the end of the outer block.

```qsharp
operation DifferentLifetime() : Result {
    mutable r = Zero;
    {
        use q = Qubit();
        // Apply operations...
        set r = M(q);
        // q is released here.
    }
    // Classical post-processing...
    return r;
}
```

# Implementation

TODO:    
Describe how the made proposal could be implemented and why it should be implemented in this way.    
Be specific regarding the efficiency, and potential caveats of such an implementation.    
Based on that description a user should be able to determine when to use or not to use the proposed modification and how.

## Timeline

TODO:    
List any dependencies that the proposed implementation relies on.    
Estimate the resources required to accomplish each step of the proposed implementation. 

# Further Considerations

TODO:    
Provide any context and background information that is needed to discuss the concepts in detail that are related to or impacted by your proposal.

## Related Mechanisms

TODO:    
Provide detailed information about the mechanisms and concepts that are relevant for or related to your proposal,
as well as their role, realization and purpose within Q#. 

## Impact on Existing Mechanisms

TODO:    
Describe in detail the impact of your proposal on existing mechanisms and concepts within Q#. 

## Anticipated Interactions with Future Modifications

TODO:    
Describe how the proposed modification ties in with possible future developments of Q#.
Describe what developments it can facilitate and/or what functionalities depend on the proposed modification.

## Alternatives

TODO:    
Explain alternative mechanisms that would serve a similar purpose as the proposed modification.    
For each one, discuss what the implications are for the future development of Q#.

## Comparison to Alternatives

TODO:    
Compare your proposal to the possible alternatives and compare the advantages and disadvantages of each approach. 
Compare in particular their impact on the future development of Q#. 

# Raised Concerns

Any concerns about the proposed modification will be listed here and can be addressed in the [Response](#response) section below. 

## Response 

N/A
