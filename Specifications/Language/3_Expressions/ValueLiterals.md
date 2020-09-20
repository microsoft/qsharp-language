# Literals


## Array Literals

An array literal is a sequence of one or more expressions, separated by commas, enclosed in `[` and `]`.
All expressions must have a [common base type](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SubtypingAndVariance.md), which will be the item type of the array.

Arrays or arbitrary length, and in particular empty arrays, may be created using a new array expression. 
Such an expression is of the form `new <ItemType>[expr]`, where `expr` can be any expression of type `Int` and `<ItemType>` is to be replace by the type of the array items.   
For instance, `new Int[10]` creates an array of integers with containing ten items. All items in the create array are set to the [default value](#default-values) of the item type.   
Arrays containing qubits or callables must be properly initialized with non-default values before their elements may be safely used. 
Suitable initialization routines can be found in the Microsoft.Quantum.Arrays namespace.


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
 | | |

For qubits and callables, the default is an invalid reference that cannot be used without causing a runtime error.

