# Quantum Intermediate Representation: Profiles

A *profile* of a specification is a subset of the specification that defines a coherent
set of functionalities and capabilities that might be offered by a system.
Defining profiles allows a specification to be forward-looking and expansive while
implementations are not yet capable of meeting the full specification.
Profiles also provide a roadmap for implementors by specifying stages they can progress
through that will be useful to consumers of the specification.

This document defines two initial profiles of the QIR specification.
We expect additional profiles to be added in the future.

## Profile A: Basic Quantum Functionality

The *Basic Quantum Functionality* profile defines a minimal subset of the QIR that includes
quantum operations but explicitly rules out any decision making or "fast feedback" based on
measurement results.

In terms of the intermediate representation, this translates into the following restrictions:

- Values of type `%Result` may be stored in memory, stored as part of a tuple or as an element
  of an array, or returned from an operation or function. No other actions may be performed with
  them. In particular, they may not be compared against other `%Result` values or converted into
  values of any other type. Note that this implies that control flow cannot be based on the result
  of a measurement.
- Once a qubit is measured, nothing further will be done with it other than releasing it.
- No arithmetic or other calculations may be performed with classical values. Any such computations
  in the original source code are performed in the service before passing the QIR to the target
  and the results folded in as constants in the QIR.
- The only LLVM primitives allowed are: `call`, `bitcast`, `getelementptr`, `load`, `store`, `ret`,
  and `extractvalue`.
- The only QIR runtime functions allowed are: **TBD**.
- LLVM functions will always be passed null pointers for the capture tuple.
- The only classical value types allowed are `%Int`, `%Double`, `%Result`, `%Pauli`, and tuples of these
  values.
- The argument tuple passed to an operation will be a tuple of the above types.
- Outside of the argument tuple, values of types other than `%Result` will only appear as literals.

## Profile B: Basic Measurement Feedback

The *Basic Measurement Feedback* profile expands on the Basic Quantum Functionality profile
to allow limited capabilities to control the execution of quantum operations based on prior
measurement results.
These capabilities correspond roughly to what are commonly known as "binary controlled gates".

In terms of the intermediate representation, this translates into the following restrictions:

- Comparison of `%Result` values is allowed, but only to compute the input to a conditional branch.
- Boolean computations are not allowed. Boolean expressions on `%Result` comparisons must be represented
  by a sequence of simple comparisons and branches. Effectively, complex "if" clauses must be translated
  into embedded simple "if"s.
- Any basic blocks whose execution depends on the result of a `%Result` comparison may only include
  calls to quantum operations, comparisons of `%Result`s, and branches. In particular, classical
  arithmetic and other purely classical operations may not be performed inside of such a basic block.
- Basic blocks that depend on the result of a `%Result` comparison may not form a cycle (loop).
- No arithmetic or other calculations may be performed with classical values. Any such computations
  in the original source code are performed in the service before passing the QIR to the target
  and the results folded in as constants in the QIR.
- The only LLVM primitives allowed are: `call`, `bitcast`, `getelementptr`, `load`, `store`, `ret`,
  `extractvalue`, `icmp`, `alloca`, and `br`.
- The only QIR runtime functions allowed are: **TBD**.
- LLVM functions will always be passed a null pointer for the capture tuple.
- LLVM functions may fill in the result tuple. If they do, the result tuple may only contain `%Result`
  values or tuples of `%Result` values.
- The only classical value types allowed are `%Int`, `%Double`, `%Result`, `%Pauli`, `%Unit`, and tuples
  of these values.
- The argument tuple passed to an operation will be a tuple of the above types.
- Outside of the argument tuple, values of types other than `%Result` will only appear as literals.
