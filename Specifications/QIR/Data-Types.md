## Data Type Representation

We define LLVM representations for a variety of classical and quantum data types.

Representing the types used for qubits and measurement results as pointers to
opaque LLVM structure types allows each target to provide a structure definition
appropriate for that target.

### Reference and Alias Counting

QIR specifies a set of runtime functions for types that are represented as pointers that may be used by the language-specific compiler to expose them as immutable types in the language. 

- Runtime routines that create a new instance always initialize the instance
  with a reference count of 1.
- Each type has a `_reference` runtime routine that increments the reference
  count of an instance and an `_unreference` routine that decrements the
  reference count.
- The `_unreference` routine will release the instance if the reference count
  is decremented to zero.
- The `_unreference` routine should accept a null instance pointer and simply
  ignore the call if the pointer is null. This allows us to avoid null checks
  strewn through the QIR, with the attendant plethors of LLVM basic blocks.

A target is free to provide some other mechanism for garbage collection and
treat calls to these runtime functions as hints or as simple no-ops.

### Unit

For source languages that include a `Unit` type, the representation of this type
in LLVM depends on its usage.
If used as a return type for a callable, it should be translated into an LLVM
`void` function.

If it is used as a value, for instance as a user-defined type or as an element of
a tuple, a tuple type with no contained elements should be used.
In this case, the one possible value of `Unit`, `()`, should be represented as a
null tuple pointer.

### Simple Types

The simple types are those whose values are fixed-size and do not contain pointers.
They are represented as follows:

| Type     | LLVM Representation        | Comments |
|----------|----------------------------|----------|
| `Int`    | `i64`                      | A 64-bit signed integer. Targets should specify their behavior on integer overflow and division by zero. |
| `Double` | `double`                   | A 64-bit IEEE double-precision floating point number. Targets should specify their behavior on floating overflow and division by zero. |
| `Bool`   | `i1`                       | 0 is false, 1 is true. |
| `Result` | `%Result*`                 | `%Result` is an opaque type. |
| `Pauli`  | `%Pauli = {i2}`            | 0 is PauliI, 1 is PauliX, 3 is PauliY, and 2 is PauliZ. |
| `Qubit`  | `%Qubit*`                  | `%Qubit` is an opaque type. |
| `Range`  | `%Range = {i64, i64, i64}` | In order, these are the start, step, and inclusive end of the range. When passed as a function argument or return value to or from a compiled routine, ranges should be passed by value. |

LLVM and QIR place some limits on integer values.
Specifically, when raising an integer to a power, the exponent must fit
into a 32-bit integer, `i32`.
Also, bit shifts are limited to shift counts that are non-negative and
less than 64.

A `%Range` is an expression that represents a sequence of integers.
The first element of the sequence is the `start` of the range, the second
element is `start+step`, the third element is `start+2*step`, and so forth.
The `step` may be positive or negative, but not zero.
The last element of the range may be `end`; that is, `end` is inclusive.
A range is empty if `step` is positive and `end` is less than `start`,
or if `step` is negative and `end` is greater than `start`.
For example:

```
0..1..2 = {0, 1, 2}
0..2..4 = {0. 2. 4}
0..2..5 = {0, 2, 4}
4..-1..2 = {4, 3, 2}
5..-3..0 = {5, 2}
0..1..-1 = {}
0..-1..1 = {}
```

The following global constants are defined for use with the `%Result` and `%Pauli` types:

```LLVM
@ResultZero = external global %Result*
@ResultOne = external global %Result*

@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
```

The following utility functions are provided by the classical runtime to support
simple types:

| Function                          | Signature                | Description |
|-----------------------------------|--------------------------|-------------|
| __quantum__rt__result_equal       | `i1(%Result*, %Result*)` | Returns true if the two results are the same, and false if they are different. |
| __quantum__rt__result_reference   | `void(%Result*)`         | Increments the reference count of a Result pointer. |
| __quantum__rt__result_unreference | `void(%Result*)`         | Decrements the reference count of a Result pointer and releases the result if appropriate. |

### Strings

Strings are represented as pointers to an opaque type.

| Type   | LLVM Representation |
|--------|---------------------|
| String | `%String*`          |

The following utility functions should be provided by the classical runtime to support
strings:

| Function                          | Signature                      | Description |
|-----------------------------------|--------------------------------|-------------|
| __quantum__rt__string_create      | `%String*(i32, [0 x i8])`      | Creates a string from an array of UTF-8 bytes. |
| __quantum__rt__string_reference   | `void(%String*)`               | Indicates that a new reference has been added. |
| __quantum__rt__string_unreference | `void(%String*)`               | Indicates that an existing reference has been removed and potentially releases the string. |
| __quantum__rt__string_concatenate | `%String*(%String*, %String*)` | Creates a new string that is the concatenation of the two argument strings. |
| __quantum__rt__string_equal       | `i1(%String*, %String*)`       | Returns true if the two strings are equal, false otherwise. |

The following utility functions support converting values of other types to strings.
In every case, the returned string is allocated on the heap; the string can't be
allocated by the caller because the length of the string depends on the actual value.

| Function                         | Signature            | Description |
|----------------------------------|----------------------|-------------|
| __quantum__rt__int_to_string     | `%String*(i64)`      | Returns a string representation of the integer. |
| __quantum__rt__double_to_string  | `%String*(Double)`   | Returns a string representation of the double. |
| __quantum__rt__bool_to_string    | `%String*(i1)`       | Returns a string representation of the Boolean. |
| __quantum__rt__result_to_string  | `%String*(%Result*)` | Returns a string representation of the result. |
| __quantum__rt__pauli_to_string   | `%String*(%Pauli)`   | Returns a string representation of the Pauli. |
| __quantum__rt__qubit_to_string   | `%String*(%Qubit*)`  | Returns a string representation of the qubit. |
| __quantum__rt__range_to_string   | `%String*(%Range)`   | Returns a string representation of the range. |
| __quantum__rt__bigint_to_string  | `%String*(%BigInt*)` | Returns a string representation of the big integer. |

### Big Integers

Unlimited-precision integers, also known as "big integers", are represented
as pointers to an opaque type.

| Type   | LLVM Representation |
|--------|---------------------|
| BigInt | `%BigInt*`          |

The following utility functions are provided by the classical runtime to support
big integers.

| Function                          | Signature                      | Description |
|-----------------------------------|--------------------------------|-------------|
| __quantum__rt__bigint_create_i64  | `%BigInt*(i64)`                | Creates a big integer with the specified initial value. |
| __quantum__rt__bigint_create_array | `%BigInt*(i32, [0 x i8])`    | Creates a big integer with the initial value specified by the `i8` array. The 0-th element of the array is the highest-order byte, followed by the first element, etc. |
| __quantum__rt__bigint_reference   | `void(%BigInt*)`               | Indicates that a new reference has been added. |
| __quantum__rt__bigint_unreference | `void(%BigInt*)`               | Indicates that an existing reference has been removed and potentially releases the big integer. |
| __quantum__rt__bigint_negate      | `%BigInt*(%BigInt*)`           | Returns the negative of the big integer. |
| __quantum__rt__bigint_add         | `%BigInt*(%BigInt*, %BigInt*)` | Adds two big integers and returns their sum. |
| __quantum__rt__bigint_subtract    | `%BigInt*(%BigInt*, %BigInt*)` | Subtracts the second big integer from the first and returns their difference. |
| __quantum__rt__bigint_multiply    | `%BigInt*(%BigInt*, %BigInt*)` | Multiplies two big integers and returns their product. |
| __quantum__rt__bigint_divide      | `%BigInt*(%BigInt*, %BigInt*)` | Divides the first big integer by the second and returns their quotient. |
| __quantum__rt__bigint_modulus     | `%BigInt*(%BigInt*, %BigInt*)` | Returns the first big integer modulo the second. |
| __quantum__rt__bigint_power       | `%BigInt*(%BigInt*, i32)`      | Returns the big integer raised to the integer power. As with standard integers, the exponent must fit in 32 bits. |
| __quantum__rt__bigint_bitand      | `%BigInt*(%BigInt*, %BigInt*)` | Returns the bitwise-AND of two big integers. |
| __quantum__rt__bigint_bitor       | `%BigInt*(%BigInt*, %BigInt*)` | Returns the bitwise-OR of two big integers. |
| __quantum__rt__bigint_bitxor      | `%BigInt*(%BigInt*, %BigInt*)` | Returns the bitwise-XOR of two big integers. |
| __quantum__rt__bigint_bitnot      | `%BigInt*(%BigInt*)`           | Returns the bitwise complement of the big integer. |
| __quantum__rt__bigint_shiftleft   | `%BigInt*(%BigInt*, i64)`      | Returns the big integer arithmetically shifted left by the (positive) integer amount of bits. |
| __quantum__rt__bigint_shiftright  | `%BigInt*(%BigInt*, i64)`      | Returns the big integer arithmetically shifted right by the (positive) integer amount of bits. |
| __quantum__rt__bigint_equal       | `i1(%BigInt*, %BigInt*)`       | Returns true if the two big integers are equal, false otherwise. |
| __quantum__rt__bigint_greater     | `i1(%BigInt*, %BigInt*)`       | Returns true if the first big integer is greater than the second, false otherwise. |
| __quantum__rt__bigint_greater_eq  | `i1(%BigInt*, %BigInt*)`       | Returns true if the first big integer is greater than or equal to the second, false otherwise. |

### Tuples and User-Defined Types

Tuple data, including values of user-defined types, is represented as the corresponding LLVM structure type.
For instance, a tuple containing two integers, `(Int, Int)`, would be represented in LLVM as `type {i64, i64}`.

When passed to a callable function, tuples are passed as a pointer to an opaque LLVM structure, `%Tuple`. The pointer is expected to point to the contained data such that it can be cast to the correct data structures by the
receiving code.
This permits to define runtime functions that are common for all tuples.
For instance, this convention is used for callable wrapper functions; see
[below](#callable-values-and-wrapper-functions).

Many languages provide immutable tuples, along with operators that allow a modified copy of an existing tuple to be created.
QIR supports this by requiring the runtime to track and be able to access the following given a `%Tuple*`:
- The size of the tuple in bytes
- The alias count indicating how many handles to the tuple exist in the source code

The language specific compiler is responsible for injecting calls to increase and decrease the alias count as needed, as well as to accurately reflect when references to the LLVM structure representing a tuple are created and removed. 
See the section [above](#reference-and-alias-counting) regarding the distinction between alias and reference counting. 

In the case where the source language treats tuples as immutable values, the language-specific compiler is expected to request the necessary copies prior to modifying the tuple in place. 
This is done by invoking the runtime function `__quantum__rt__tuple_copy` to create a byte-by-byte copy of a tuple. Unless the copying is forced via the second argument, the runtime may omit copying the value and instead simply return a pointer to the given argument if the alias count is 0 and it is hence save to modify the tuple in place.

The following utility functions are provided by the classical runtime to support tuples and user-defined types:

| Function                         | Signature             | Description |
|----------------------------------|-----------------------|-------------|
| __quantum__rt__tuple_create      | `%Tuple*(i64)`  | Allocates space for a tuple requiring the given number of bytes, sets the reference count to 1 and the alias count to 0. |
| __quantum__rt__tuple_copy      | `%Tuple*(%Tuple*, i1)`  | Creates a shallow copy of the tuple if the alias count is larger than 0 or the second argument is `true`. Returns the given tuple pointer otherwise, after increasing its reference count by 1. |
| __quantum__rt__tuple_update_reference_count   | `void(%Tuple*, i64)` | Adds the given integer value to the reference count for the given tuple. Deallocates the tuple if the reference count becomes 0. Fails if the reference count becomes negative. |
| __quantum__rt__tuple_update_alias_count | `void(%Tuple*, i64)` | Adds the given integer value to the alias count *and* to the reference count for the given tuple. Deallocates the tuple if the reference count becomes 0. Fails if either count becomes negative. |

### Arrays

Array data is represented as the corresponding LLVM array type.
For instance, an array of integers, `Int[]`, would be represented in LLVM as `type {i64, i64}`.

When passed to a callable function, arrays are passed as a pointer to an opaque LLVM structure, `%Array`. The pointer is expected to point to the contained data such that it can be cast to the correct data structures by the
receiving code.
This permits to define runtime functions that are common for all arrays.
For instance, this convention is used for common array functions such as `array_get_length` and `array_slice`; see
[below](#callable-values-and-wrapper-functions).

Because LLVM does not provide any mechanism for type-parameterized functions,
runtime library routines that provide access to array elements return byte
pointers that the calling code must `bitcast` to the appropriate type before
using.
When creating an array, the size of each element in bytes must be provided.

Many languages provide immutable arrays, along with operators that allow a modified
copy of an existing array to be created.
In QIR, this is implemented by creating a new copy of the existing array and then
modifying the newly-created array in place.
In some cases, if the source-language compiler knows that the existing array is not
used after the creation of the modified copy, it is possible to avoid the copy and
modify the existing array as long as there are known to be no other references to the
array.

There are two special operations on arrays:

- An array *slice* is specified by providing a dimension to slice on and a `%Range` to
  slice with. The resulting array has the same number of dimensions as the original
  array, but only those elements in the sliced dimension whose original indexes were
  part of the resolution of the `%Range`. Those elements get new indices in the resulting
  array based on their appearance order in the `%Range`. In particular, if the step of
  the `%Range` is negative, the elements in the sliced dimension will be in the reverse
  order than they were in the original array. If the `%Range` is empty, the resulting
  array will be empty.
- An array *projection* is specified by providing a dimension to project on and an `i64`
  index value to project to. The resulting array has one fewer dimension than the original
  array, and is the segment of the original array with the projected dimension fixed to the
  given index value. Projection is the array access analog to partial application;
  effectively it creates a new array that has the same elements as the original array,
  but one of the indices is fixed at a constant value.

Both slicing and projecting are implemented by creating a new `%Array*` that
represents the resulting array as described above.
Runtime library implementations may optimize by initially sharing data between
the slice or projection and the original array and working with the source-language
compiler to implement a copy-on-write strategy to minimize data copying.
In particular, the source-language compiler should not assume that the result of a
slice or projection operation is safe to write unless it can prove that the original
array is no longer accessible.

In all cases, attempting to access an index or dimension outside the bounds of
an array should cause an immediate runtime failure.
This applies to slicing and projection operations as well as to element access.
When validating indices for slicing, only indices that are actually part of the
resolved range should be considered.

The following utility functions are provided by the classical runtime to support
arrays:

| Function                         | Signature                            | Description |
|----------------------------------|--------------------------------------|-------------|
| __quantum__rt__array_create_1d   | `%Array* void(i32, i64)`             | Creates a new 1-dimensional array. The `i32` is the size of each element in bytes. The `i64` is the length of the array. The bytes of the new array should be set to zero. If the length is zero, the result should be an empty 1-dimensional array. |
| __quantum__rt__array_copy        | `%Array*(%Array*)`                   | Returns a new array which is a copy of the passed-in `%Array*`. |
| __quantum__rt__array_concatenate | `%Array*(%Array*, %Array*)`          | Returns a new array which is the concatenation of the two passed-in arrays. |
| __quantum__rt__array_get_length  | `i64(%Array*, i32)`                  | Returns the length of a dimension of the array. The `i32` is the zero-based dimension to return the length of; it must be 0 for a 1-dimensional array. |
| __quantum__rt__array_get_element_ptr_1d | `i8*(%Array*, i64)`           | Returns a pointer to the element of the array at the zero-based index given by the `i64`. |
| __quantum__rt__array_slice       | `%Array*(%Array*, i32, %Range)`      | Creates and returns an array that is a slice of an existing array. The `i32` indicates which dimension the slice is on, which must be 0 for a 1-dimensional array. The `%Range` specifies the slice. |
| __quantum__rt__array_reference   | `void(%Array*)`                      | Indicates that a new reference has been added. |
| __quantum__rt__array_unreference | `void(%Array*)`                      | Indicates that an existing reference has been removed and potentially releases the array. |

The following utility functions are provided if multidimensional array support is enabled:

| Function                         | Signature                            | Description |
|----------------------------------|--------------------------------------|-------------|
| __quantum__rt__array_create_2d   | `%Array* void(i32, i64, i64)`        | Creates a new 2-dimensional array. The `i32` is the size of each element in bytes. The first`i64` is the length of the first dimension of the array, and the second `i64` the length of the second dimension. The bytes of the new array should be set to zero. If either length is zero, the result should be an empty 2-dimensional array. |
| __quantum__rt__array_create      | `%Array* void(i32, i32, i64*)`       | Creates a new array. The first `i32` is the size of each element in bytes. The second `i32` is the dimension count. The `i64*` should point to an array of `i64`s contains the length of each dimension. The bytes of the new array should be set to zero. If any length is zero, the result should be an empty array with the given number of dimensions. |
| __quantum__rt__array_get_dim     | `i32(%Array*)`                       | Returns the number of dimensions in the array. |
| __quantum__rt__array_get_element_ptr_2d | `i8*(%Array*, i64, i64)`      | Returns a pointer to the element of the array at the zero-based indices given by the two `i64` arguments. |
| __quantum__rt__array_get_element_ptr | `i8*(%Array*, i64*)`             | Returns a pointer to the indicated element of the array. The `i64*` should point to an array of `i64`s that are the indices for each dimension. |
| __quantum__rt__array_project     | `%Array*(%Array*, i32, i64)`         | Creates and returns an array that is a projection of an existing array. The `i32` indicates which dimension the projection is on, and the `i64` specifies the specific index value to project. |

There are special runtime functions defined for allocating or releasing an
array of qubits.
See [here](Quantum-Runtime.md#qubit-management-functions) for these functions.

---
_[Back to index](README.md)_
