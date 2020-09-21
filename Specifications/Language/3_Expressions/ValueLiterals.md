# Literals


## Unit Literal

The only existing literal for the [`Unit` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) is the value `()`.

The `Unit` value is commonly used as an argument to callables, e.g. either because no other arguments need to be passed or to delay execution. It is also used as return value when no other value needs to be returned, which is in particular the case for unitary operations, i.e. operations that support the `Adjoint` and/or the `Controlled` functor.

## Int Literals

Value literals for the [`Int` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) can be expressed in binary, octal, decimal, or hexadecimal representation. Literals expressed in binary are prefixed with `0b`, with `0o` for octal, and with `0x` for hexadecimal. There is no prefix for the commonly used decimal representation.

| Representation | Value Literal |
| --- | --- | 
| Binary | `0b101010` | 
| Octal | `0o52` |
| Decimal | `42` |
| Hexadecimal | `0x2a` |
| | |

## BigInt Literals

Value literals for the [`BigInt` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are always postfixed with `L` and can be expressed in decimal or hexadecimal representation. Literals expressed in hexadecimal are prefixed with `0x`. There is no prefix for the commonly used decimal representation.

| Representation | Value Literal |
| --- | --- | 
| Decimal | `42L` |
| Hexadecimal | `0x2aL` |
| | |

## Double Literals

Value literals for the [`Double` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) can be expressed in standard or scientific notation.  

| Representation | Value Literal |
| --- | --- | 
| Standard | `0.1973269804` |
| Scientific | `1.973269804e-1` |
| | |

If nothing follows after the decimal point, then the digit after dot may be omitted, e.g. `1.` is a valid `Double` literal and the same as `1.0`. Similarly, if the digits before the decimal point are all zero, then they may be omitted, e.g. `.1` is a valid `Double` literal and the same as `0.1`. 

## Bool Literals

Existing literals for the [`Bool` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are `true` and `false`.

## String Literals

Value literals for the [`String` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are an arbitrary length sequence of Unicode characters enclosed in double quotes. 
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

No literals for the [`Qubit` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) exist, since quantum memory is managed by the runtime. Values of type `Qubit` can hence only be obtained via [allocation](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md).

Values of type `Qubit` represent an opaque identifier by which a quantum bit, a.k.a. a qubit, can be addressed. The only operator they support is [equality comparison](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md). See [this section](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md#qubits) for more details on the `Qubit` data type.

## Result Literals

Existing literals for the [`Result` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are `Zero` and `One`. 

Values of type `Result` represent the result of a binary quantum measurement.
`Zero` indicates a projection onto the +1 eigenspace, `One` indicates a projection onto the -1 eigenspace.

## Pauli Literals

Existing literals for the [`Pauli` type](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#available-types) are `PauliI`, `PauliX`, `PauliY`, and `PauliZ`.

Values of type `Pauli` represent one of the four single-qubit [Pauli matrices](https://en.wikipedia.org/wiki/Pauli_matrices), with `PauliI` representing the identity.
Values of type `Pauli` are commonly used to denote the axis for rotations and to specify with respect to which basis to measure.

## Range Literals

Values of type `Range` represent a sequence of integers, denoted by `start..step..stop`, where denoting the step is options. 
That is `start .. stop` corresponds to `start..1..stop`, and e.g. `1..2..7` represents the sequence $\{1, 3, 5, 7\}$.

## Array Literals

An array literal is a sequence of one or more expressions, separated by commas, enclosed in `[` and `]`, e.g. `[1,2,3]`.
All expressions must have a [common base type](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SubtypingAndVariance.md), which will be the item type of the array.

Arrays or arbitrary length, and in particular empty arrays, may be created using a new array expression. 
Such an expression is of the form `new <ItemType>[expr]`, where `expr` can be any expression of type `Int` and `<ItemType>` is to be replace by the type of the array items.   

For instance, `new Int[10]` creates an array of integers with containing ten items. 
The length of an array can be queries with the function `Length`. It is defined in the automatically opened namespace Microsoft.Quantum.Core and returns an `Int` value.

All items in the create array are set to the [default value](#default-values) of the item type. 
Arrays containing qubits or callables must be properly initialized with non-default values before their elements may be safely used. 
Suitable initialization routines can be found in the Microsoft.Quantum.Arrays namespace.

## Tuple Literals

An tuple literal is a sequence of one or more expressions of any type, separated by commas, enclosed in `(` and `)`. The type of the tuple includes the information about each item type.

| Value Literal | Type |
| --- | --- | 
| `("Id", 0, 1.)` | `(String, Int, Double)` |
| `(PauliX,(3,1))` | `(Pauli, (Int, Int))` |
| | |

Tuples containing a single item are treated as identical to the item itself, both in type and value. We refer to this a [singleton tuple equivalence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md). 

Tuples are used to bundle values together into a single value, making it easier to pass them around. This makes it possible that every callable takes exactly one input and returns exactly one output.

## User Defined Type Literals

## Operation Literals

## Function Literals


# Default Values

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
 | | |

For qubits and callables, the default is an invalid reference that cannot be used without causing a runtime error.

