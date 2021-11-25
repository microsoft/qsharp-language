# Data Type Representation

QIR defines LLVM representations for a variety of classical and quantum data types that may be used as part of a compiled quantum program. For more information about classical memory management including reference and alias counting, see [here](Classical-Runtime.md#memory-management).

There are several error conditions that are specified as causing a runtime failure.
The `quantum__rt__fail` function is the mechanism to use to cause a runtime failure;
it is documented in the [Classical Runtime](Classical-Runtime.md) section.

## Simple Types

The simple types are those whose values are fixed-size and do not contain pointers.
They are represented as follows:

| Type     | LLVM Representation        | Comments |
|----------|----------------------------|----------|
| `Int`    | `i64`                      | A 64-bit signed integer. Targets should specify their behavior on integer overflow and division by zero. |
| `Double` | `double`                   | A 64-bit IEEE double-precision floating point number. Targets should specify their behavior on floating overflow and division by zero. |
| `Bool`   | `i1`                       | 0 is false, 1 is true. |
| `Pauli`  | `%Pauli = i2`            | 0 is PauliI, 1 is PauliX, 3 is PauliY, and 2 is PauliZ. |
| `Range`  | `%Range = {i64, i64, i64}` | In order, these are the start, step, and inclusive end of the range. When passed as a function argument or return value, ranges should be passed by value. |

LLVM and QIR place some limits on integer values.
Specifically, when raising an integer to a power, the exponent must fit
into a 32-bit integer, `i32`.
Also, bit shifts are limited to shift counts that are non-negative and
less than 64.

A `%Range` is an expression that represents a sequence of integers.
The first element of the sequence is the `start` of the range, the second
element is `start+step`, the third element is `start+2*step`, and so forth.
The `step` may be positive or negative, but not zero. An attempt to create a `%Range` with a zero step should cause a runtime failure.

The last element of the range may be `end`; that is, `end` is inclusive.
A range is empty if `step` is positive and `end` is less than `start`,
or if `step` is negative and `end` is greater than `start`.
For example:

```
0..1..2 = {0, 1, 2}
0..2..4 = {0, 2, 4}
0..2..5 = {0, 2, 4}
4..-1..2 = {4, 3, 2}
5..-3..0 = {5, 2}
0..1..-1 = {}
0..-1..1 = {}
```

The following global constants are defined for use with `%Pauli` type:

```LLVM
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1 ; The value 3 (binary 11) is displayed as a 2-bit signed value of -1 (binary 11).
@PauliZ = constant i2 -2 ; The value 2 (binary 10) is displayed as a 2-bit signed value of -2 (binary 10).
```

## Measurement Results

Measurement results are represented as pointers to an opaque LLVM structure type, `%Result`.
This allows each target implementation to provide a structure definition appropriate for that target.
In particular, this makes it easier for implementations where measurement results might come back asynchronously.

The following utility functions are provided by the classical runtime for use with
values of type `%Result*`:

| Function                          | Signature                | Description |
|-----------------------------------|--------------------------|-------------|
| __quantum__rt__result_get_zero    | `%Result*()`             | Returns a constant representing a measurement result zero.
| __quantum__rt__result_get_one     | `%Result*()`             | Returns a constant representing a measurement result one.
| __quantum__rt__result_equal       | `i1(%Result*, %Result*)` | Returns true if the two results are the same, and false if they are different. If a `%Result*` parameter is null, a runtime failure should occur. |
| __quantum__rt__result_update_reference_count   | `void(%Result*, i32)` | Adds the given integer value to the reference count for the result. Deallocates the result if the reference count becomes 0. The behavior is undefined if the reference count becomes negative. The call should be ignored if the given `%Result*` is a null pointer. |

## Qubits

Qubits are represented as pointers to an opaque LLVM structure type, `%Qubit`.
This is done so that qubit values may be distinugished from other value types.
It is not expected that qubit values actually be valid memory addresses,
and neither user code nor runtime code should ever attempt to dereference a qubit value.

A qubit value should be thought of as an integer identifier that has been bit-cast
into a special type so that it cen be distinguished from normal integers.
The only operation that may be performed on a qubit value is to pass it to a function.

Qubits may be managed either statically or dynamically.
Static qubits have target-specific identifiers known at compile time, while dynamic
qubits are managed by the quantum runtime.

A statc qubit value may be created using the LLVM `inttoptr` instruction.
For instance, to initialize a value that identifies device qubit 3,
the following LLVM code would be used:

```llvm
    %qubit3 = inttoptr i32 3 to %Qubit addrspace(2)*
```

Dynamic qubits are managed using the [quantum runtime](Quantum-Runtime.md) functions.

## Strings

Strings are represented as pointers to an opaque type.

| Type   | LLVM Representation |
|--------|---------------------|
| String | `%String*`          |

The following utility functions should be provided by the classical runtime to support
strings:

| Function                          | Signature                      | Description |
|-----------------------------------|--------------------------------|-------------|
| __quantum__rt__string_create      | `%String*(i8*)`      | Creates a string from an array of UTF-8 bytes. The byte array is expected to be zero-terminated. |
| __quantum__rt__string_get_data    | `i8*(%String*)`      | Returns a pointer to the zero-terminated array of UTF-8 bytes. |
| __quantum__rt__string_get_length  | `i32(%String*)`      | Returns the length of the byte array that contains the string data. |
| __quantum__rt__string_update_reference_count   | `void(%String*, i32)` | Adds the given integer value to the reference count for the string. Deallocates the string if the reference count becomes 0. The behavior is undefined if the reference count becomes negative. The call should be ignored if the given `%String*` is a null pointer. |
| __quantum__rt__string_concatenate | `%String*(%String*, %String*)` | Creates a new string that is the concatenation of the two argument strings. If a `%String*` parameter is null, a runtime failure should occur. |
| __quantum__rt__string_equal       | `i1(%String*, %String*)`       | Returns true if the two strings are equal, false otherwise. If a `%String*` parameter is null, a runtime failure should occur. |

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

In all cases, if a pointer parameter is null, a runtime failure should occur.

## Big Integers

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
| __quantum__rt__bigint_create_array | `%BigInt*(i32, i8*)`    | Creates a big integer with the value specified by the `i8` array. The 0-th element of the array is the highest-order byte, followed by the first element, etc. |
| __quantum__rt__bigint_get_data    | `i8*(%BigInt*)`      | Returns a pointer to the `i8` array containing the value of the big integer. |
| __quantum__rt__bigint_get_length  | `i32(%BigInt*)`      | Returns the length of the `i8` array that represents the big integer value. |
| __quantum__rt__bigint_update_reference_count   | `void(%BigInt*, i32)` | Adds the given integer value to the reference count for the big integer. Deallocates the big integer if the reference count becomes 0. The behavior is undefined if the reference count becomes negative. The call should be ignored if the given `%BigInt*` is a null pointer. |
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

In all cases other than to `__quantum__rt__bigint_update_reference_count`, if a `%BigInt*` parameter is null, a runtime failure should occur.

## Tuples and User-Defined Types

Tuple data, including values of user-defined types, is represented as the corresponding LLVM structure type.
For instance, a tuple containing two integers, `(Int, Int)`, would be represented in LLVM as `type {i64, i64}`.

When [invoking callable values](Callables.md#invoking-a-callable-value) using the `__quantum__rt__callable_invoke` runtime function, 
tuples are passed as a pointer to an opaque LLVM structure, `%Tuple`. The pointer is expected to point to the contained data such that it can be cast to the correct data structures by the
receiving code.
This permits the definition of runtime functions that are common for all tuples, such as the functions listed below.

Many languages provide immutable tuples, along with operators that allow a modified copy of an existing tuple to be created.
QIR supports this by requiring the runtime to track and be able to access the following given a `%Tuple*`:
- The size of the tuple in bytes
- The alias count indicating how many handles to the tuple exist in the source code

The language specific compiler is responsible for injecting calls to increase and decrease the alias count as needed, as well as to accurately reflect when references to the LLVM structure representing a tuple are created and removed. 
See [this section](Classical-Runtime.md#reference-and-alias-counting) for further details on the distinction between alias and reference counting. 

In the case where the source language treats tuples as immutable values, the language-specific compiler is expected to request the necessary copies prior to modifying the tuple in place. 
This is done by invoking the runtime function `__quantum__rt__tuple_copy` to create a byte-by-byte copy of a tuple. Unless the copying is forced via the second argument, the runtime may omit copying the value and instead simply return a pointer to the given argument if the alias count is 0 and it is therefore safe to modify the tuple in place.

The following utility functions are provided by the classical runtime to support tuples and user-defined types:

| Function                         | Signature             | Description |
|----------------------------------|-----------------------|-------------|
| __quantum__rt__tuple_create      | `%Tuple*(i64)`  | Allocates space for a tuple requiring the given number of bytes, sets the reference count to 1 and the alias count to 0. |
| __quantum__rt__tuple_copy      | `%Tuple*(%Tuple*, i1)`  | Creates a shallow copy of the tuple if the alias count is larger than 0 or the second argument is `true`. Returns the given tuple pointer (the first parameter) otherwise, after increasing its reference count by 1. The reference count of the tuple elements remains unchanged. If the `%Tuple*` parameter is null, a runtime failure should occur. |
| __quantum__rt__tuple_update_reference_count   | `void(%Tuple*, i32)` | Adds the given integer value to the reference count for the tuple. Deallocates the tuple if the reference count becomes 0. The behavior is undefined if the reference count becomes negative. The call should be ignored if the given `%Tuple*` is a null pointer. |
| __quantum__rt__tuple_update_alias_count | `void(%Tuple*, i32)` | Adds the given integer value to the alias count for the tuple. Fails if the count becomes negative. The call should be ignored if the given `%Tuple*` is a null pointer. |

## Unit

For source languages that include a unit type, the representation of this type
in LLVM depends on its usage.
If used as a return type for a callable, it should be translated into an LLVM
`void` function.
If it is used as a value, for instance as an element of a tuple, it should be represented as a null tuple pointer.

## Arrays

Within QIR, arrays are represented and passed around as a pointer to an opaque LLVM structure, `%Array`. 
How array data is represented, i.e., what that pointer points to, is at the discretion of the runtime. All array manipulations, including item access, hence need to be performed by invoking the corresponding runtime function(s).

Because LLVM does not provide any mechanism for type-parameterized functions,
runtime library routines that provide access to array elements return byte
pointers that the calling code must `bitcast` to the appropriate type before
using.
When creating an array, the size of each element in bytes must be provided.

Many languages provide immutable arrays, along with operators that allow a modified
copy of an existing array to be created.
In QIR, this is implemented by creating a new copy of the existing array and then
modifying the newly-created array in place.
If the existing array is not used after the creation of the modified copy, it is possible to avoid the copy and modify the existing array in place instead. 
To achieve such a behavior, the language specific compiler should ensure that the alias count for arrays accurately reflects their use in the source language, and rely on the runtime function for copying to omit the copy when the alias count is 0.

In addition to creating modified copies of arrays, there are two other ways of constructing new arrays that permit for similar optimizations; array slicing and array projections.

- An array *slice* is specified by providing a dimension to slice on and a `%Range` to
  slice with. The resulting array has the same number of dimensions as the original
  array, but only those elements in the sliced dimension whose original indices were
  part of the resolution of the `%Range`. Those elements get new indices in the resulting
  array based on their appearance order in the `%Range`. In particular, if the step of
  the `%Range` is negative, the elements in the sliced dimension will be in the reverse
  order than they were in the original array. If the `%Range` is empty, the resulting
  array will be empty.   
  Array slices can be created using the `__quantum__rt__array_slice_1d` or `__quantum__rt__array_slice` runtime functions.
- An array *projection* is specified by providing a dimension to project along and an `i64`
  index value to project to. The resulting array has one fewer dimension than the original
  array, and is the segment of the original array with the projected dimension fixed to the
  given index value. Projection is the array access analog to partial application;
  effectively it creates a new array that has the same elements as the original array,
  but one of the indices is fixed at a constant value.  
  Array projections can be created using the `__quantum__rt__array_project` runtime function.

Attempting to access an index or dimension outside the bounds of
an array should cause an immediate runtime failure.
This applies to slicing and projection operations as well as to element access.
When validating indices for slicing, only indices that are actually part of the
resolved range should be considered.

The following utility functions are provided by the classical runtime to support
arrays:

| Function                         | Signature                            | Description |
|----------------------------------|--------------------------------------|-------------|
| __quantum__rt__array_create_1d   | `%Array* void(i32, i64)`             | Creates a new 1-dimensional array. The `i32` is the size of each element in bytes. The `i64` is the length of the array. The bytes of the new array should be set to zero. If the length is zero, the result should be an empty 1-dimensional array. |
| __quantum__rt__array_copy        | `%Array*(%Array*, i1)`                   | Creates a shallow copy of the array if the alias count is larger than 0 or the second argument is `true`. Returns the given array pointer (the first parameter) otherwise, after increasing its reference count by 1. The reference count of the array elements remains unchanged. |
| __quantum__rt__array_concatenate | `%Array*(%Array*, %Array*)`          | Returns a new array which is the concatenation of the two passed-in one-dimensional arrays. If either array is not one-dimensional or if the array element sizes are not the same, then a runtime failure should occur. |
| __quantum__rt__array_slice_1d       | `%Array*(%Array*, %Range, i1)`      | Creates and returns an array that is a slice of an existing 1-dimensional array. The slice may be accessing the same memory as the given array unless its alias count is larger than 0 or the last argument is `true`. The `%Range` specifies the indices that should be the elements of the returned array. The reference count of the elements remains unchanged. |
| __quantum__rt__array_get_size_1d  | `i64(%Array*)`                  | Returns the length of a 1-dimensional array. |
| __quantum__rt__array_get_element_ptr_1d | `i8*(%Array*, i64)`           | Returns a pointer to the element of the array at the zero-based index given by the `i64`. |
| __quantum__rt__array_update_reference_count   | `void(%Array*, i32)` | Adds the given integer value to the reference count for the array. Deallocates the array if the reference count becomes 0. The behavior is undefined if the reference count becomes negative. The call should be ignored if the given `%Array*` is a null pointer. |
| __quantum__rt__array_update_alias_count | `void(%Array*, i32)` | Adds the given integer value to the alias count for the array. Fails if either count becomes negative. The call should be ignored if the given `%Array*` is a null pointer. |

For all of these functions other than `__quantum__rt__array_update_reference_count` or `__quantum__rt__array_update_alias_count`, if an `%Array*` pointer is null, a runtime failure should result.

The following utility functions are provided if multidimensional array support is enabled:

| Function                         | Signature                            | Description |
|----------------------------------|--------------------------------------|-------------|
| __quantum__rt__array_create      | `%Array* void(i32, i32, i64*)`       | Creates a new array. The first `i32` is the size of each element in bytes. The second `i32` is the dimension count. The `i64*` should point to an array of `i64`s contains the length of each dimension. The bytes of the new array should be set to zero. If any length is zero, the result should be an empty array with the given number of dimensions. |
| __quantum__rt__array_get_dim     | `i32(%Array*)`                       | Returns the number of dimensions in the array. |
| __quantum__rt__array_get_size  | `i64(%Array*, i32)`                  | Returns the length of a dimension of the array. The `i32` is the zero-based dimension to return the length of; it must be smaller than the number of dimensions in the array. |
| __quantum__rt__array_get_element_ptr | `i8*(%Array*, i64*)`             | Returns a pointer to the indicated element of the array. The `i64*` should point to an array of `i64`s that are the indices for each dimension. |
| __quantum__rt__array_slice       | `%Array*(%Array*, i32, %Range, i1)`      | Creates and returns an array that is a slice of an existing array. The slice may be accessing the same memory as the given array unless its alias count is larger than 0 or the last argument is `true`. The `i32` indicates which dimension the slice is on, and must be smaller than the number of dimensions in the array. The `%Range` specifies the indices in that dimension that should be the elements of the returned array. The reference count of the elements remains unchanged. |
| __quantum__rt__array_project     | `%Array*(%Array*, i32, i64, i1)`         | Creates and returns an array that is a projection of an existing array. The projection may be accessing the same memory as the given array unless its alias count is larger than 0 or the last argument is `true`. The `i32` indicates which dimension the projection is on, and the `i64` specifies the index in that dimension to project. The reference count of all array elements remains unchanged. If the existing array is one-dimensional then a runtime failure should occur. |

There are special runtime functions defined for allocating or releasing an
array of qubits.
See [here](Quantum-Runtime.md#qubits) for these functions.

For all of these functions, if an `%Array*` pointer is null, a runtime failure should occur.

---
_[Back to index](README.md)_
