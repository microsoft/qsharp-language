# Q# Style Guide
## General Conventions

The conventions listed here are suggestions only, and should likely be disregarded when they would result in less readable or useful code.

# [Guidance](#tab/guidance)

We suggest:

- Never disregard a convention unless you’re doing so intentionally in order to provide more readable and understandable code for your users.

# [Examples](#tab/examples)

***

## Naming Conventions

In offering the Quantum Development Kit, we strive for function and operation names that help quantum developers write programs that are easy to read and that minimize surprise.
An important part of that is that when we choose names for functions, operations, and types, we are establishing the *vocabulary* that programmers use to express quantum concepts; with our choices, we either help or hinder them in their effort to clearly communicate.
This places a responsibility on us to make sure that the names we introduce lend themselves to clarity rather than obscurity.
In this section, we detail how we meet this obligation in terms of explicit guidance that helps us do the best by the Q# development community.

### Operations and Functions

The first thing that a name should establish is whether a given symbol represents a function or an operation.
The difference between functions and operations is critical to understanding how a block of code behaves.
To communicate this distinction to programmers, we refer back to that in Q#, quantum computation proceeds through the effects of operations.
That is, an operation *does* something.

By contrast, functions describe the mathematical relationships between data.
The expression `Sin(PI() / 2.0)` *is* `1.0`, and implies nothing about the state of a program or its qubits.

Summarizing, operations do things while functions are things.
This distinction suggests that we name operations as verbs and functions as nouns.

> [!NOTE]
> In many ways, user-defined types can be thought of as functions which construct instances of a UDT.
> From that perspective, UDTs should be named as functions rather than as operations.

Where reasonable, ensure that operation names begin with verbs that clearly indicate the effect taken by the operation.
For example:

- `MeasureInteger`
- `EstimateEnergy`
- `SampleInt`

One case that deserves special mention is when an operation takes another operation as input and calls it.
In such cases, the action taken by the input operation is not clear when the outer operation is defined, such that the right verb is not immediately clear.
We recommend the verb `Apply`, as in `ApplyIf`, `ApplyToEach`, and `ApplyToFirst`.
Other verbs may be useful in this case as well, as in `IterateThroughCartesianPower`.

| Verb | Expected Effect |
| ---- | ------ |
| Apply | An operation provided as input is called |
| Assert | A hypothesis about the outcome of a possible quantum measurement is checked by a simulator |
| Estimate | A classical value is returned, representing an estimate drawn from one or more measurements |
| Measure | A quantum measurement is performed, and its result is returned to the user |
| Prepare | A given register of qubits is initialized into a particular state |
| Sample | A classical value is returned at random from some distribution |

For functions, we suggest avoiding the use of verbs in favor of common nouns (see guidance on proper nouns below) or adjectives:

- `ConstantArray`
- `Head`
- `LookupFunction`

In particular, in almost all cases, we suggest using past participles where appropriate to indicate that a function name is strongly connected to an action or side effect elsewhere in a quantum program.
For example,  `ControlledOnInt` uses the part participle form of the verb "control" to indicate that the function acts as an adjective to modify its argument.
This name has the additional benefit of matching the semantics of the built-in `Controlled` functor, as discussed further below.
Similarly, _agent nouns_ can be used to construct function and UDT names from operation names, as in the case of the name `Encoder` for a UDT that is strongly associated with `Encode`.

In common cases, we suggest using particular nouns and adjectives:

| Noun/Adjective | Expected Result |
|----|----|
| Claim | Unit, but fails if a condition is not true. (Contrast with `Assert`, which should be used for operations.)
| Controlled | An operation that is a controlled version of an input operation. |
| Identity | A UDT or operation that represents identity / no-op on some data type. |
| Operation | An operation that is computed from another operation in some way. Use when no more specific case applies. |

# [Guidance](#tab/guidance)

We suggest:

- Use verbs for operation names.
- Use nouns or adjectives for function names.
- Use nouns for user-defined types.
- For all callable names, use `CamelCase` in strong preference to `pascalCase`, `snake_case`, or `ANGRY_CASE`.
- Avoid the use of underscores `_` in function and operation names.

# [Examples](#tab/examples)

|   | Name | Description |
|---|------|-------------|
| ☑ | `operation ReflectAboutStart` | Clear use of a verb ("reflect") to indicate the effect of the operation. |
| ☒ | <s>`operation XRotation`</s> | Use of noun phrase suggests function, rather than operation. |
| ☒ | <s>`operation search_oracle`</s> | Use of `snake_case` contravenes Q# notation. |
| ☑ | `function StatePreparationOracle` | Use of noun phrase suggests that the function returns an operation. |
| ☑ | `function ClaimEqual` | Clear use of noun ("claim") to indicate that this is a function. |
| ☒ | <s>`function GetRotationAngles`</s> | Use of verb ("get") suggests that this is an operation. |
| ☑ | `newtype GeneratorTerm` | Use of noun phrase clearly refers to the result of calling the UDT constructor. |

***

### Shorthand and Abbreviations

The above advice notwithstanding, there are many forms of shorthand that see common and pervasive use in quantum computing.
We suggest using existing and common shorthand where it exists, especially for operations that are intrinsic to the operation of a target machine.
For example, we choose the name `X` instead of `ApplyX`, and `Rz` instead of `RotateAboutZ`.
When using such shorthand, operation names should be uppercase.

Some care is required when applying this convention in the case of commonly used acronyms and initialisms such as "QFT" for "quantum Fourier transform."
We suggest following general .NET conventions for the use of acronyms and initialisms in full names, which prescribe that:

- two-letter acronyms and initialisms are named in upper case (e.g.: `BE` for "big-endian"),
- all longer acronyms and initialisms are named in `CamelCase` (e.g.: `Qft` for "quantum Fourier transform")

Thus, an operation implementing the QFT could either be called `QFT` as shorthand, or written out as `ApplyQft`.

For particularly commonly used operations and functions, it may be desirable to provide a shorthand name as an _alias_ for a longer form:

```qsharp
operation CCNOT(control0 : Qubit, control1 : Qubit, target : Qubit) {
    body (...) {
        Controlled X([control0, control1], target);
    }
    adjoint auto;
    controlled auto;
    controlled adjoint auto;
}
```

# [Guidance](#tab/guidance)

We suggest:

- Consider commonly accepted and widely used shorthand names when appropriate.
- Use uppercase for shorthand.
- Use uppercase for short (two-letter) acronyms and initialisms.
- Use `CamelCase` for longer (three or more letter) acronyms and initialisms.

# [Examples](#tab/examples)

|   | Name | Description |
|---|------|-------------|
| ☑ | `X` | Well-understood shorthand for "apply an $X$ transformation" |
| ☑ | `CNOT` | Well-understood shorthand for "controlled-NOT" |
| ☒ | <s>`Cnot`</s> | Shorthand should not be in `CamelCase`. |
| ☑ | `ApplyQft` | Common initialism "QFT" appears as a part of a long-form name. |
| ☑ | `QFT` | Common initialism "QFT" appears as a part of a shorthand name. |

***

### Proper Nouns in Names

While in physics it is common to name things after the first person to publish about them, most non-physicists aren’t familiar with everyone’s names and all of the history.
Relying too heavily on naming conventions from physics can thus put up a substantial barrier to entry, as users from other backgrounds must learn a large number of seemingly opaque names in order to use common operations and concepts.
<!-- An important part of the task of reducing confusion is to make code more accessible.
Especially in a field such as quantum computing that is rich with domain expertise, we must at all times be cognizant of the demands we place on that expertise as we design quantum software.
In naming code symbols, one way that this cognizance expresses itself is as an awareness of the convention from physics of adopting as the names of algorithms and operations the names of their original publishers.
While we must maintain the history and intellectual provenance of concepts in quantum computing, demanding that all users be versed in this history to use even the most basic of functions and operations places a barrier to entry that is in most cases severe enough to even present an ethical compromise. -->
Thus, we recommend that wherever reasonable, common nouns that describe a concept be adopted in strong preference to proper nouns that describe the publication history of a concept.
As a particular example, the singly controlled SWAP and doubly controlled NOT operations are often called the "Fredkin" and "Toffoli" operations in academic literature, but are identified in Q# primarily as `CSWAP` and `CCNOT`.
In both cases, the API documentation comments provide synonymous names based on proper nouns, along with all appropriate citations.

This preference is especially important given that some usage of proper nouns will always be necessary — Q# follows the tradition set by many classical languages, for instance, and refers to `Bool` types in reference to Boolean logic, which is in turn named in honor of George Boole.
A few quantum concepts similarly are named in a similar fashion, including the `Pauli` type built-in to the Q# language.
By minimizing the usage of proper nouns where such usage is not essential, we reduce the impact where proper nouns cannot be reasonably avoided.

# [Guidance](#tab/guidance)

We suggest:

- Avoid the use of proper nouns in names.

# [Examples](#tab/examples)

***

### Type Conversions

Since Q# is a strongly and staticly typed language, a value of one type can only be used as a value of another type by using an explicit call to a type conversion function.
This is in contrast to languages which allow for values to change types implicitly (e.g.: type promotion), or through casting.
As a result, type conversion functions play an important role in Q# library development, and comprise one of the more commonly encountered decisions about naming.
We note, however, that since type conversions are always _deterministic_, they can be written as functions and thus fall under the advice above.
In particular, we suggest that type conversion functions should never be named as verbs (e.g.: `ConvertToX`) or adverb prepositional phrases (`ToX`), but should be named as adjective prepositional phrases that indicate the source and destination types (`XAsY`).
When listing array types in type conversion function names, we recommend the shorthand `Arr`.
Barring exceptional circumstances, we recommend that all type conversion functions be named using `As` so that they can be quickly identified.

# [Guidance](#tab/guidance)

We suggest:

- If a function converts a value of type `X` to a value of type `Y`, use either the name `AsY` or `XAsY`.

# [Examples](#tab/examples)

|   | Name | Description |
|---|------|-------------|
| ☒ | <s>`ToDouble`</s> | The preposition "to" results in a verb phrase, indicating an operation and not a function. |
| ☒ | <s>`AsDouble`</s> | The input type is not clear from the function name. |
| ☒ | <s>`PauliArrFromBoolArr`</s> | The input and output types appear in the wrong order. |
| ☑ | `ResultArrAsBoolArr` | Both the input types and output types are clear. |

***

### Private or Internal Names

> [!NOTE]
> It is expected that the guidance in this section will change with Q# 1.0.

In many cases, a name is intended strictly for use internal to a library or project, and is not a guaranteed part of the API offered by a library.
It is helpful to clearly indicate that this is the case when naming functions and operations so that accidental dependencies on internal-only code are made obvious.
If an operation or function is not intended for direct use, but rather should be used by a matching callable which acts by partial application, consider using a name ending with `Impl` for the callable that is partially applied.

# [Guidance](#tab/guidance)

We suggest:

- When a function, operation, or user-defined type is not a part of the public API for a Q# library or program, ensure that its name begins with a leading underscore (`_`).
- When a function or operation is used only in when partially applied, ensure that its name ends with `Impl`.
  Alternatively, refactor to make the `Impl` callable useful in its own right.

# [Examples](#tab/examples)

|   | Name | Description |
|---|------|-------------|
| ☒ | <s>`ApplyDecomposedOperation_`</s> | The underscore `_` should not appear at the end of the name. |
| ☑ | `_ApplyDecomposedOperation` | The underscore `_` at the beginning clearly indicates that this operation is for internal use only. |
| ☑ | `ComposeImpl` | The suffix `Impl` clearly indicates that this callable is meant to support the `Compose` callable. |

***

### Variants

Though this limitation may not persist in future versions of Q#, it is presently the case that there will often be groups of related operations or functions that are distinguished by which functors their inputs support, or by the concrete types of their arguments.
These groups can be distinguished by using the same root name, followed by one or two letters that indicate its variant.

| Suffix | Meaning |
|--------|---------|
| `A` | Input expected to support `Adjoint` |
| `C` | Input expected to support `Controlled` |
| `CA` | Input expected to support `Controlled` and `Adjoint` |
| `I` | Input or inputs are of type `Int` |
| `D` | Input or inputs are of type `Double` |
| `L` | Input or inputs are of type `BigInt` |
| `BE` | Input or inputs are of type `BigEndian` |
| `LE` | Input or inputs are of type `LittleEndian` |

# [Guidance](#tab/guidance)

We suggest:

- If a function or operation is not related to any similar functions or operations by the types and functor support of their inputs, do not use a suffix.
- If a function or operation is related to any similar functions or operations by the types and functor support of their inputs, use suffixes as in the table above to distinguish variants.

# [Examples](#tab/examples)

***

### Arguments and Variables

A key goal of the Q# code for a function or operation is for it to be easily read and understood.
Similarly, the names of inputs and type arguments should communicate how a function or argument will be used once provided.

# [Guidance](#tab/guidance)

We suggest:

- For all variable and input names, use `pascalCase` in strong preference to `CamelCase`, `snake_case`, or `ANGRY_CASE`.
- Input names should be descriptive; avoid one or two letter names where possible.
- Operations and functions accepting exactly one type argument should denote that type argument by `T` when its role is obvious.
- If a function or operation takes multiple type arguments, or if the role of a single type argument is not obvious, consider using a short capitalized word prefaced by `T` (e.g.: `TOutput`) for each type.
- Do not include type names in argument and variable names unless absolutely necessary; this information can and should be provided by your development environment.
- Denote scalar types by their literal names (`flagQubit`), and array types by a plural (`measResults`).
  For arrays of qubits in particular, consider denoting such types by `Register` where the name refers to a sequence of qubits that are closely related in some way.
- Variables used as indices into arrays should begin with `idx` and should be singular (e.g.: `things[idxThing]`).
  In particular, strongly avoid using single-letter variable names as indices; consider using `idx` at a minimum.
- Variables used to hold lengths of arrays should begin with `n` and should be pluralized (e.g.: `nThings`).

# [Examples](#tab/examples)

***

## Input Conventions

When a developer calls into an operation or function, the various inputs to that operation or function must be specified in a particular order, increasing the cognitive load that a developer faces in order to make use of a library.
In particular, the task of remembering input orderings is often a distraction from the task at hand: programming an implementation of a quantum algorithm.
Though rich IDE support can mitigate this to a large extent, good design and adherence to common conventions can also help to minimize the cognitive load imposed by an API.

Where possible, it can be helpful to reduce the number of inputs expected by an operation or function, so that the role of each input is more immediately obvious both to developers calling into that operation or function, and to developers reading that code later.
Especially when it is not possible or reasonable to reduce the number of arguments to an operation or function, it is important to have a consistent ordering that minimizes the surprise that a user faces when predicting the order of inputs.

We recommend an input ordering conventions that largely derives from thinking of partial application as a generalization of currying 𝑓(𝑥, 𝑦) ≡ 𝑓(𝑥)(𝑦).
Thus, partially applying the first arguments should result in a callable that is useful in its own right whenever that is reasonable.
Following this principle, consider using the following order of arguments:

- Classical non-callable arguments such as angles, vectors of powers, etc.
- Callable arguments (functions and arguments).
  If both functions and operations are taken as arguments, consider placing operations after functions.
- Collections acted upon by callable arguments in a similar way to `Map`, `Iter`, `Enumerate`, and `Fold`.
- Qubit arguments used as controls.
- Qubit arguments used as targets.

Consider an operation `ApplyPhaseEstimationIteration` for use in phase estimation that takes an angle and an oracle, passes the angle to `Rz` modified by an array of different scaling factors, and then controls applications of the oracle.
We would order the inputs to `ApplyPhaseEstimationIteration` in the following fashion:

```qsharp
operation ApplyPhaseEstimationIteration(
          angle : Double,
          callable : (Qubit => () : Controlled),
          scaleFactors : Double[],
          controlQubit : Qubit,
          targetQubits : Qubit[]) : ()
```
As a special case of minimizing surprise, some functions and operations mimic the behavior of the built-in functors `Adjoint` and `Controlled`.
For instance, `ControlledOnInt<'T>` has type `(Int, ('T => Unit : Adjoint, Controlled)) => ((Qubit[], 'T) => Unit : Adjoint, Controlled)`, such that `ControlledOnInt<Qubit[]>(5, _)` acts like the `Controlled` functor, but on the condition that the control register represents the state $\ket{5} = \ket{101}$.
Thus, a developer expects that the inputs to `ControlledOnInt` place the callable being transformed last, and that the resulting operation takes as its input `(Qubit[], 'T)` --- the same order as followed by the output of the `Controlled` functor.

# [Guidance](#tab/guidance)

We suggest:

- Use input orderings consistent with the use of partial application.
- Use input orderings consistent with built-in functors.
- Place all classical inputs before any quantum inputs.

# [Examples](#tab/examples)

***

## Documentation Conventions

The Q# language allows for attaching documentation to operations, functions, and user-defined types through the use of specially formatted documentation comments.
Denoted by triple-slashes (`///`), these documentation comments are small [DocFX-flavored Markdown](https://dotnet.github.io/docfx/spec/docfx_flavored_markdown.html) documents that can be used to describing the purpose of each operation, function, and user-defined type, what inputs each expects, and so forth.
The compiler provided with the Quantum Development Kit extracts these comments and uses them to help typeset documentation similar to that at https://docs.microsoft.com/azure/quantum.
Similarly, the language server provided with the Quantum Development Kit uses these comments to provide help to users when they hover over symbols in their Q# code.
Making use of documentation comments can thus help users to make sense of code by providing a useful reference for details that are not easily expressed using the other conventions in this document.

<div class="nextstepaction">
    [Documentation comment syntax reference](xref:microsoft.quantum.qsharp-ref.statements#documentation-comments)
</div>

In order to effectively use this functionality to help users, we recommend keeping a few things in mind as you write documentation comments.

# [Guidance](#tab/guidance)

We suggest:

- Each public function, operation, and user-defined type should be immediately preceded by a documentation comment.
- At a minimum, each documentation comment should include the following sections:
  - Summary
  - Input
  - Output (if applicable)
- Ensure that all summaries are two sentences or less. If more room is needed, provide a `# Description` section immediately following `# Summary` with complete details.
- Where reasonable, do not include math in summaries, as not all clients support TeX notation in summaries. Note that when writing prose documents (e.g. TeX or Markdown), it may be preferable to use longer line lengths.
- Provide all relevant mathematical expressions in the `# Description` section.
- When describing inputs, do not repeat the types of each input as these can be inferred by the compiler and risk introducing inconsistency.
- Provide examples as appropriate, each in their own `# Example` section.
- Briefly describe each example before listing code.
- Cite all relevant academic publications (e.g.: papers, proceedings, blog posts, and alternative implementations) in a `# References` section as a bulleted list of links.
- Ensure that, where possible, all citation links are to permanent and immutable identifiers (DOIs or versioned arXiv numbers).
- When an operation or function is related to other operations or functions by functor variants, list other variants as bullets in the `# See Also` section.
- Leave a blank comment line between level-1 (`/// #`) sections, but do not leave a blank line between level-2 (`/// ##`) sections.

# [Examples](#tab/examples)

#### ☑

```
/// # Summary
/// Applies a rotation about the X-axis by a given angle.
///
///
/// # Description
/// This operation rotates a single qubit by the unitary operation
/// \begin{align}
///     R_x(\theta) \mathrel{:=} e^{-i \theta \sigma_x / 2}.
/// \end{align}
///
/// # Input
/// ## theta
/// Angle about which the qubit is to be rotated.
/// ## qubit
/// Qubit to which the gate should be applied.
///
/// # Remarks
/// Equivalent to:
/// ```qsharp
/// R(PauliX, theta, qubit);
/// ```
///
/// # See Also
/// - Ry
/// - Rz
operation Rx(theta : Double, qubit : Qubit) : Unit {
    body (...) { R(PauliX, theta, qubit); }
    adjoint (...) { R(PauliX, -theta, qubit); }
    controlled auto;
    controlled adjoint auto;
}
```

***

## Formatting Conventions

In addition to the preceding suggestions, it is helpful to help make code as legible as possible to use consistent formatting rules.
Such formatting rules by nature tend to be somewhat arbitrary and strongly up to personal aesthetics.
Nonetheless, we recommend maintaining a consistent set of formatting conventions within a group of collaborators, and especially for large Q# projects such as the Quantum Development Kit itself.

# [Guidance](#tab/guidance)

We suggest:

- Use four spaces instead of tabs for portability.
  For instance, in VS Code:

  ```json
    "editor.insertSpaces": true,
    "editor.tabSize": 4
  ```

- Line wrap at 79 characters where reasonable.
- Use spaces around binary operators.
- Use spaces on either side of colons used for type annotations.
- Use a single space after commas used in array and tuple literals (e.g.: in inputs to functions and operations).

# [Examples](#tab/examples)

|   | Snippet | Description |
|---|---------|-------------|
| ☒ | <s>`2+3`</s> | Use spaces around binary operators. |
| ☒ | <s>`target:Qubit`</s> | Use spaces around type annotation colons. |
| ☑ | `Example(a, b, c)` | Items in input tuple are correctly spaced for readability. |

***
