---
title: Implicitly-scoped qubit allocation
description: Provides more convenient syntax for allocating qubits.
author: Sarah Marshall
date: TBD
---

# Proposal

1. Deprecate `using` and `borrowing` keywords and replace with `use` and `borrow`.
2. Allow `use` and `borrow` statements to be followed by either a block `{ ... }` or a semicolon `;`.
3. Deprecate and remove parentheses around block statement headers.

We expect to permanently support the new non-block `use` and `borrow` statements, but we may reconsider how or if the block forms are supported at a later date, after we learn more about how both forms are used in practice.

The parentheses that are currently required by the `for`, `using` or `use`, and `borrowing` or `borrow` statements will be deprecated and removed.
Using parentheses for these statements will become a syntax error.
The parentheses for the `if`, `elif`, `while`, and `until` statements will no longer be required, but will still be supported because an expression may always be wrapped in parentheses.

# Justification

Qubit allocation is currently awkward in Q# for two reasons:

1. It requires creating a new block to define the lifetime of the qubit, even when the intended lifetime is the same as the current block.
2. Allocating multiple qubits at the same time requires either tuple destructuring or nested blocks, both of which can be hard to read.

As a quantum programming language, qubit allocation is at the core of Q#.
Both the simple case of allocating a single qubit for the remainder of the current block, and more complicated scenarios involving multiple qubit variables that are both clean and borrowed and have varying lifetimes, should have clear, intuitive syntax that doesn't require boilerplate.

# Description

Qubits are a managed resource in Q#: when qubits are allocated, they are valid only within the new block declared at allocation, after which they are released and can no longer be used.
This proposal adds the option to allocate qubits that are scoped to the current block, instead of a new block.
Its aim is to be syntactically concise and consistent with other binding statements like `let`.
As a consequence, it also modifies the existing block qubit allocation syntax slightly in order to increase consistency with the new non-block form.

## Current Status

Currently, the only mechanism to allocate qubits in Q# is with `using` and `borrowing` block statements.
No new functionality is provided by this proposal.
Every example with the existing syntax has a corresponding equivalent example with the proposed syntax, and vice versa.
However, the proposed syntax addresses several problems with the existing syntax.

### Examples

**Example 1a:** A single qubit allocated and released at the same time as the end of the outer block.

```qsharp
operation FlipCoin() : Result {
    using (q = Qubit()) {
        H(q);
        return M(q);
    }
}
```

The lifetime of the qubit `q` is the same as the lifetime of the surrounding block.
A new block is syntactically required, but does not serve any purpose other than increasing the indentation level.

**Example 2a:** Many qubits allocated in a single `using` statement with tuple destructuring.

```qsharp
operation QubitTuple(n : Int) : Result {
    using ((a, b, c) = (Qubit[2 * n + 1], Qubit[n], Qubit())) {
        // ...
        return M(c);
    }
}
```

Allocating multiple qubits requires either a single `using` statement with tuple destructuring, or multiple nested `using` statements.
Tuple destructuring is hard to read when many variables are declared or when the qubit initializer expression is long.
It is hard to tell which tuple item corresponds to which variable name.

**Example 3a:** Many qubits allocated with a separate `using` block for each variable.

```qsharp
operation NestedBlocks(n : Int) : Result {
    using (a = Qubit[n]) {
        using (b = Qubit[2 * n + 1]) {
            using (c = Qubit()) {
                // ...
                return M(c);
            }
        }
    }
}
```

Allocating multiple qubits with nested `using` statements makes it clear which qubit initializer expression corresponds to which variable name, but at the cost of many levels of unnecessary indentation.

**Example 4a:** A clean qubit and a borrowed qubit.
When `using` and `borrowing` statements are mixed, nested blocks are required; tuple destructuring is not possible.

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

**Example 5a:** A qubit allocated in a `using` block but released before the end of the outer block.

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

This example shows the main benefit of the current syntax: it allows the lifetime of a qubit to be shorter than the parent block.
This syntax is preserved by this proposal with only minor changes.

## Proposed Modification

The new `use` and `borrow` statements behave like the existing `using` and `borrowing` statements with two differences:

1. The block is optional.
   If no block is provided, the scope of the qubit is implicitly defined to be from the `use` or `borrow` statement until the end of the current block.
2. Parentheses around the header are not required.
   For consistency, parentheses are no longer required around any block statement header.

Each example below is equivalent to the corresponding example in the [Current Status](#current-status) section with the same number.

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
    use (a, b, c) = (Qubit[2 * n + 1], Qubit[n], Qubit());
    // ...
    return M(c); // a, b, and c are released here.
}
```

Example 3b: Many qubits allocated with a separate `use` statement for each variable.

```qsharp
operation NestedBlocks(n : Int) : Result {
    use a = Qubit[2 * n + 1];
    use b = Qubit[n];
    use c = Qubit();
    // ...
    return M(c); // a, b, and c are released here.
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

Example 5b: A qubit allocated within a new block and released before the end of the outer block.

```qsharp
operation DifferentLifetime() : Result {
    mutable r = Zero;
    use q = Qubit() {
        // Apply operations...
        set r = M(q);
        // q is released here.
    }
    // Classical post-processing...
    return r;
}
```

# Implementation

The `use` and `borrow` keywords can be added, and the `using` and `borrowing` keywords can be deprecated.
Until `using` and `borrowing` are removed, they can be used in place of `use` and `borrow` for both the block and non-block statements.

The block for the existing `using` and `borrowing` syntax nodes can be made optional.
Either the block remains optional throughout all stages of the syntax tree, or the non-block form is transformed into the block form by automatically moving all statements below it into a new block.
In the former case, all syntax tree consumers need to be aware of both forms, while in the latter case consumers would notice no change from the current syntax tree node.

## Timeline

There are no dependencies on other proposals or libraries.
The work needed for either option appears to be minimal, since it is similar to the existing implementation.

# Further Considerations

Development tools should consider adding support for transitioning from the current syntax to the proposed syntax, such as a code action in IDEs.

## Related Mechanisms

This proposal relies on the existing qubit management functionality that is already a core feature of Q#.
It does not change the behavior of qubit management; it only provides new syntax for existing functionality.

## Impact on Existing Mechanisms

The new keywords `use` and `borrow` were previously valid Q# identifiers.
Adding them is a breaking change, unless an opt-in mechanism for new keywords is added to the language.

For consistency, parentheses are no longer required for all block statement headers.
That means that the following code is now valid:

```qsharp
if M(q) == One {
    X(q);
}

for x in xs {
    Message(x);
}
```

## Anticipated Interactions with Future Modifications

There will likely be changes to qubit initializers soon.
See [Issue #40: Allocatable types and generalization of initializers](https://github.com/microsoft/qsharp-language/issues/40).
We expect the changes to initializers to integrate well with this proposal, because this proposal only changes the syntax *around* qubit initializers, not the initializers themselves.

Removing parentheses around block statement headers may affect future syntax development.
For example, it will no longer be feasible to remove the braces without also re-introducing parentheses or another token, such as `then`:

```qsharp
if M(q) == One then
    X(q);
```

## Alternatives

### Alternative 1: Remove `use` and `borrow` block statements and add scope statement

Instead of allowing both block and non-block `use` and `borrow` statements, only the non-block form could be allowed.
A scope statement could be added to limit the lifetime of qubits.

```qsharp
{
    use q = Qubit();
    X(q);
}
```

This would be equivalent to:

```qsharp
use q = Qubit() {
    X(q);
}
```

This alternative has simpler `use` and `borrow` statements, because they only have one form (no block) rather than two (block and no block).
However, it is less readable than the proposed syntax because it is less clear what the intended purpose of the new scope is, since the qubit allocation occurs after the scope starts instead of before.

### Alternative 2: Add compound `using` and `borrowing` block statements

The existing block statement syntax could be extended to allow multiple `using` and `borrowing` statements in a row that have only one block attached:

```qsharp
using (a = Qubit())
borrowing (b = Qubit())
using (c = Qubit()) {
    // ...
}
```

This alternative has syntax that is somewhat unusual and inconsistent with other statements in Q#.
While it reduces block nesting when multiple variables are needed, it does not address the problem that at least one new block is always needed even if the lifetime of the qubits is the same as the parent block.

### Alternative 3: Replace `using` and `borrowing` statements with `use` and `borrow` expressions

`use` and `borrow` expressions could be used in conjunction with the `let` statement:

```qsharp
let q1 = use Qubit();
let q2 = borrow Qubit();
```

This syntax makes the variable binding look identical for both classical values and qubits.
But the lifetime of a qubit is bound to the variable: the qubit is deallocated when the *variable* goes out of scope, not when the *value* created by a `use` expression becomes inaccessible.
This syntax, unless it's constrained further, also opens up possibilities such as:

```qsharp
mutable q = use Qubit();
set q = use Qubit();
Foo(use Qubit());
```

which we do not want to support.
It is clearer to have a dedicated variable binding for qubits.

# Raised Concerns

## The renaming of the `using` and `borrowing` keywords to `use` and `borrow` is not necessary and will break existing code.

We believe that the new keywords come with enough benefits to make the breaking change worth it.
The `use` and `borrow` keywords are more concise, and more consistent with the rest of the language because there are no other keywords in Q# that end in -ing.
The old keywords will continue to be supported in a deprecated state until Q# 1.0, and can be easily updated with code actions in IDEs.
