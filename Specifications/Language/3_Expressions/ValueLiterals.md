# Literals

## Unit literal

The only existing literal for the [`Unit` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) is the value `()`.

The `Unit` value is commonly used as an argument to callables, either because no other arguments need to be passed or to delay execution. It is also used as return value when no other value needs to be returned, which is the case for unitary operations, that is, operations that support the `Adjoint` and/or the `Controlled` functor.

## Int literals

Value literals for the [`Int` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) can be expressed in binary, octal, decimal, or hexadecimal representation. Literals expressed in binary are prefixed with `0b`, with `0o` for octal, and with `0x` for hexadecimal. There is no prefix for the commonly used decimal representation.

| Representation | Value Literal |
| --- | --- |
| Binary | `0b101010` |
| Octal | `0o52` |
| Decimal | `42` |
| Hexadecimal | `0x2a` |

## BigInt literals

Value literals for the [`BigInt` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are always postfixed with `L` and can be expressed in binary, octal, decimal, or hexadecimal representation. Literals expressed in binary are prefixed with `0b`, with `0o` for octal, and with `0x` for hexadecimal. There is no prefix for the commonly used decimal representation.

| Representation | Value Literal |
| --- | --- |
| Binary | `0b101010L` |
| Octal | `0o52L` |
| Decimal | `42L` |
| Hexadecimal | `0x2aL` |

## Double literals

Value literals for the [`Double` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) can be expressed in standard or scientific notation.

| Representation | Value Literal |
| --- | --- |
| Standard | `0.1973269804` |
| Scientific | `1.973269804e-1` |

If nothing follows after the decimal point, then the digit after the decimal point may be omitted. For example, `1.` is a valid `Double` literal and the same as `1.0`. Similarly, if the digits before the decimal point are all zero, then they may be omitted. For example, `.1` is a valid `Double` literal and the same as `0.1`.

## Bool literals

Existing literals for the [`Bool` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are `true` and `false`.

## String literals

A value literal for the [`String` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) is an arbitrary length sequence of Unicode characters enclosed in double quotes.
Inside of a string, the back-slash character `\` may be used to escape
a double quote character, and to insert a new-line as `\n`, a carriage
return as `\r`, and a tab as `\t`.

The following are examples for valid string literals:

```qsharp
"This is a simple string."
"\"This is a more complex string.\", she said.\n"
```

Q# also supports *interpolated strings*.
An interpolated string is a string literal that may contain any number of interpolation expressions. These expressions can be of arbitrary types.
Upon construction, the expressions are evaluated and their `String` representation is inserted at the corresponding location within the defined literal. Interpolation is enabled by prepending the special character `$` directly before the initial quote, with no white space between them.

For instance, if `res` is an expression that evaluates to `1`, then the second sentence in the following `String` literal displays "The result was 1.":

```qsharp
$"This is an interpolated string. The result was {res}."
```

## Qubit literals

No literals for the [`Qubit` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) exist, since quantum memory is managed by the runtime. Values of type `Qubit` can hence only be obtained via [allocation](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md#quantum-memory-management).

Values of type `Qubit` represent an opaque identifier by which a quantum bit, or *qubit*, can be addressed. The only operator they support is [equality comparison](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md#equality-comparison). For more information on the `Qubit` data type, See [Qubits](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md#qubits).

## Result literals

Existing literals for the [`Result` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are `Zero` and `One`.

Values of type `Result` represent the result of a binary quantum measurement.
`Zero` indicates a projection onto the +1 eigenspace, `One` indicates a projection onto the -1 eigenspace.

## Pauli literals

Existing literals for the [`Pauli` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are `PauliI`, `PauliX`, `PauliY`, and `PauliZ`.

Values of type `Pauli` represent one of the four single-qubit [Pauli matrices](https://en.wikipedia.org/wiki/Pauli_matrices), with `PauliI` representing the identity.
Values of type `Pauli` are commonly used to denote the axis for rotations and to specify with respect to which basis to measure.

## Range literals

Value literals for the [`Range` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are expressions of the form `start..step..stop`, where `start`, `step`, and `end` are expressions of type `Int`. If the step size is one, it may be omitted. For example, `start..stop` is a valid `Range` literal and the same as `start..1..stop`.

Values of type `Range` represent a sequence of integers, where the first element in the sequence is `start`, and subsequent elements are obtained by adding `step` to the previous one, until `stop` is passed.
`Range` values are inclusive at both ends, that is, the last element of the range is `stop` if the difference between `start` and `stop` is a multiple of `step`.
A range may be empty if, for instance, `step` is positive and `stop < start`.

The following are examples for valid `Range` literals:

- `1..3` is the range 1, 2, 3.
- `2..2..5` is the range 2, 4.
- `2..2..6` is the range 2, 4, 6.
- `6..-2..2` is the range 6, 4, 2.
- `2..-2..1` is the range 2.
- `2..1` is the empty range.

For more information, see [Contextual expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions).

## Array literals

An [array](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) literal is a sequence of one or more expressions, separated by commas and enclosed in brackets `[` and `]`; for example, `[1,2,3]`.
All expressions must have a [common base type](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SubtypingAndVariance.md#subtyping-and-variance), which is the item type of the array.

Arrays of arbitrary length, and in particular empty arrays, may be created using a new array expression.
Such an expression is of the form `new <ItemType>[expr]`, where `expr` can be any expression of type `Int` and `<ItemType>` is to be replaced by the type of the array items.

For instance, `new Int[10]` creates an array of integers containing ten items.
The length of an array can be queried with the function `Length`. It is defined in the automatically opened namespace `Microsoft.Quantum.Core` and returns an `Int` value.

All items in the created array are set to the [default value](#default-values) of the item type.
Arrays containing qubits or callables must be properly initialized with non-default values before their elements may be safely used.
Suitable initialization routines can be found in the `Microsoft.Quantum.Arrays` namespace.

## Tuple literals

A [tuple](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) literal is a sequence of one or more expressions of any type, separated by commas and enclosed in parentheses `(` and `)`. The type of the tuple includes the information about each item type.

| Value Literal | Type |
| --- | --- |
| `("Id", 0, 1.)` | `(String, Int, Double)` |
| `(PauliX,(3,1))` | `(Pauli, (Int, Int))` |

Tuples containing a single item are treated as identical to the item itself, both in type and value, and are called a [singleton tuple equivalence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md#singleton-tuple-equivalence).

Tuples are used to bundle values together into a single value, making it easier to pass them around. This makes it possible for every callable to take exactly one input and return exactly one output.

## Literals for user-defined types

Values of a [user-defined type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are constructed by invoking their constructor. A default constructor is automatically generated when [declaring the type](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md#type-declarations). It is currently not possible to define custom constructors.

For instance, if `IntPair` has two items of type `Int`, then `IntPair(2, 3)` creates a new instance by invoking the default constructor.

## Operation literals

No literals exist for values of [operation type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types). Operations must be [declared](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md#callable-declarations) on a global scope and new operations can be constructed locally using [partial application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PartialApplication.md#partial-application).

## Function literal

No literals exist for values of [function type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types). Functions must be [declared](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md#callable-declarations) on a global scope and new functions can be constructed locally using [partial application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PartialApplication.md#partial-application).

## Default values

Type | Default
---------|----------
 `Unit` | `()`
 `Int` | `0`
 `BigInt` | `0L`
 `Double` | `0.0`
 `Bool` | `false`
 `String` | `""`
 `Qubit` | _invalid qubit_
 `Result` | `Zero`
 `Pauli` | `PauliI`
 `Range` | empty range
 Array | empty array
 Tuple | all items are set to default values
 User-defined type | all items are set to default values
 Operation | _invalid operation_
 Function | _invalid function_

For qubits and callables, the default is an invalid reference that cannot be used without causing a runtime error.

← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
