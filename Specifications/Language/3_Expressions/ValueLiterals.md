# Literals


## Unit Literal

The only existing literal for the [`Unit` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) is the value `()`.

The `Unit` value is commonly used as an argument to callables, e.g. either because no other arguments need to be passed or to delay execution. It is also used as return value when no other value needs to be returned, which is in particular the case for unitary operations, i.e. operations that support the `Adjoint` and/or the `Controlled` functor.

## Int Literals

Value literals for the [`Int` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) can be expressed in binary, octal, decimal, or hexadecimal representation. Literals expressed in binary are prefixed with `0b`, with `0o` for octal, and with `0x` for hexadecimal. There is no prefix for the commonly used decimal representation.

| Representation | Value Literal |
| --- | --- | 
| Binary | `0b101010` | 
| Octal | `0o52` |
| Decimal | `42` |
| Hexadecimal | `0x2a` |

## BigInt Literals

Value literals for the [`BigInt` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) are always postfixed with `L` and can be expressed in binary, octal, decimal, or hexadecimal representation. Literals expressed in binary are prefixed with `0b`, with `0o` for octal, and with `0x` for hexadecimal. There is no prefix for the commonly used decimal representation.

| Representation | Value Literal |
| --- | --- | 
| Binary | `0b101010L` | 
| Octal | `0o52L` |
| Decimal | `42L` |
| Hexadecimal | `0x2aL` |

## Double Literals

Value literals for the [`Double` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) can be expressed in standard or scientific notation.  

| Representation | Value Literal |
| --- | --- | 
| Standard | `0.1973269804` |
| Scientific | `1.973269804e-1` |

If nothing follows after the decimal point, then the digit after dot may be omitted, e.g. `1.` is a valid `Double` literal and the same as `1.0`. Similarly, if the digits before the decimal point are all zero, then they may be omitted, e.g. `.1` is a valid `Double` literal and the same as `0.1`. 

## Bool Literals

Existing literals for the [`Bool` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) are `true` and `false`.

## String Literals

A value literal for the [`String` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) is an arbitrary length sequence of Unicode characters enclosed in double quotes. 
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
Upon construction, the expressions are evaluated and their `String` representation is inserted at the corresponding location within the defined literal. Interpolation is enabled by prepending the special character `$` directly before the initial quote, i.e. without any white space between them. 

For instance, if `res` is an expression that evaluates to `1`, then the second sentence in the following `String` literal will say "The result was 1.":
```qsharp
$"This is an interpolated string. The result was {res}."
```

## Qubit Literals

No literals for the [`Qubit` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) exist, since quantum memory is managed by the runtime. Values of type `Qubit` can hence only be obtained via [allocation](xref:microsoft.quantum.qsharp.quantummemorymanagement#quantum-memory-management).

Values of type `Qubit` represent an opaque identifier by which a quantum bit, a.k.a. a qubit, can be addressed. The only operator they support is [equality comparison](xref:microsoft.quantum.qsharp.comparativeexpressions#equality-comparison). See [this section](xref:microsoft.quantum.qsharp.quantumdatatypes#qubits) for more details on the `Qubit` data type.

## Result Literals

Existing literals for the [`Result` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) are `Zero` and `One`. 

Values of type `Result` represent the result of a binary quantum measurement.
`Zero` indicates a projection onto the +1 eigenspace, `One` indicates a projection onto the -1 eigenspace.

## Pauli Literals

Existing literals for the [`Pauli` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) are `PauliI`, `PauliX`, `PauliY`, and `PauliZ`.

Values of type `Pauli` represent one of the four single-qubit [Pauli matrices](https://en.wikipedia.org/wiki/Pauli_matrices), with `PauliI` representing the identity.
Values of type `Pauli` are commonly used to denote the axis for rotations and to specify with respect to which basis to measure.

## Range Literals

Value literals for the [`Range` type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) are expressions of the form `start..step..stop`, where `start`, `step`, and `end` are expressions of type `Int`. If the step size is one, it may be omitted, i.e. `start..stop` is a valid `Range` literal and the same as `start..1..stop`.

Values of type `Range` represent a sequence of integers, where the first element in the sequence is `start`, and subsequent elements are obtained by adding `step` to the previous one, until `stop` is passed.
`Range` values are inclusive at both ends; i.e. the last element of the range will be `stop` if the difference between `start` and `stop` is a multiple of `step`.
A range may be empty if, for instance, `step` is positive and `stop < start`.

The following are examples for valid `Range` literals:
- `1..3` is the range 1, 2, 3.
- `2..2..5` is the range 2, 4.
- `2..2..6` is the range 2, 4, 6.
- `6..-2..2` is the range 6, 4, 2.
- `2..-2..1` is the range 2.
- `2..1` is the empty range.

See also the section on [contextual expressions](xref:microsoft.quantum.qsharp.contextualexpressions#contextual-and-omitted-expressions).

## Array Literals

An [array](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) literal is a sequence of one or more expressions, separated by commas, enclosed in `[` and `]`, e.g. `[1,2,3]`.
All expressions must have a [common base type](xref:microsoft.quantum.qsharp.subtypingandvariance#subtyping-and-variance), which will be the item type of the array.

Arrays or arbitrary length, and in particular empty arrays, may be created using a new array expression. 
Such an expression is of the form `new <ItemType>[expr]`, where `expr` can be any expression of type `Int` and `<ItemType>` is to be replace by the type of the array items.   

For instance, `new Int[10]` creates an array of integers with containing ten items. 
The length of an array can be queries with the function `Length`. It is defined in the automatically opened namespace `Microsoft.Quantum.Core` and returns an `Int` value.

All items in the create array are set to the [default value](#default-values) of the item type. 
Arrays containing qubits or callables must be properly initialized with non-default values before their elements may be safely used. 
Suitable initialization routines can be found in the `Microsoft.Quantum.Arrays` namespace.

## Tuple Literals

A [tuple](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) literal is a sequence of one or more expressions of any type, separated by commas, enclosed in `(` and `)`. The type of the tuple includes the information about each item type.

| Value Literal | Type |
| --- | --- | 
| `("Id", 0, 1.)` | `(String, Int, Double)` |
| `(PauliX,(3,1))` | `(Pauli, (Int, Int))` |

Tuples containing a single item are treated as identical to the item itself, both in type and value. We refer to this a [singleton tuple equivalence](xref:microsoft.quantum.qsharp.singletontupleequivalence#singleton-tuple-equivalence). 

Tuples are used to bundle values together into a single value, making it easier to pass them around. This makes it possible that every callable takes exactly one input and returns exactly one output.

## Literals for User Defined Types

Values of a [user defined type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types) are constructed by invoking their constructor. A default constructor is automatically generated when [declaring the type](xref:microsoft.quantum.qsharp.typedeclarations#type-declarations). It is currently not possible to define custom constructors. 

For instance, if `IntPair` has two items of type `Int`, then `IntPair(2, 3)` creates a new instance by invoking the default constructor.

## Operation Literals

No literals exist for values of [operation type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types); operations have to be [declared](xref:microsoft.quantum.qsharp.callabledeclarations#callable-declarations) on a global scope and new operations can be constructed locally using [partial application](xref:microsoft.quantum.qsharp.partialapplication#partial-application).

## Function Literals

No literals exist for values of [function type](xref:microsoft.quantum.qsharp.typesystem-overview#available-types); functions have to be [declared](xref:microsoft.quantum.qsharp.callabledeclarations#callable-declarations) on a global scope and new functions can be constructed locally using [partial application](xref:microsoft.quantum.qsharp.partialapplication#partial-application).


## Default Values

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
 User defined type | all items are set to default values
 Operation | _invalid operation_
 Function | _invalid function_

For qubits and callables, the default is an invalid reference that cannot be used without causing a runtime error.


