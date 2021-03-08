---
description: Proposal for multidimensional array types in Q#
author: Chris Granade
date: 2021-03-01
---

# QEP 3: Multidimensional arrays

## Proposal

Currently, for any Q# type `'T`, the array type `'T[]` represents an immutable collection of values of type `'T` indexed by a single integer. It would be really helpful to add a new collection type that is indexed by tuples of integers instead, so as to allow for a more natural representation of concepts like matrices and tensors.

## Justification

Arrays of arrays as currently supported in Q# can be used to represent matrices and higher-rank tensors, but come with a number of disadvantages as compared with multidimensional arrays:

- Nested arrays can in general be jagged; having multidimensional arrays as a type can help enforce that arrays are rectangular at the type level.
- Performance: because nested arrays can be jagged, element lookup cannot in general be done as efficiently as with linear indexing.
- Copy-and-update expressions: Using the `w/` operator to modify elements of nested arrays can be awkward.
  ```qsharp
  mutable matrix = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
  set matrix w/ 2 <- (matrix[2] w/ 1 <- 20);
  // matrix is now [[1, 0, 0], [0, 1, 0], [0, 20, 1]]
  ```

## Description

### Current Status

Arrays types in Q# can be constructed from any element type `'T` as `'T[]`, including arrays of arrays such as `Int[][]`.
These *jagged arrays* can be used to represent multidimensional arrays of data (informally, _tensors_), such as matrices or vectors.

While jagged arrays are extremely useful in many contexts, such as representing sparse arrays (e.g.: the "list-of-lists" representation), using jagged arrays to represent vectors, matrices, and tensors requires extensive checking of array bounds to prevent mistakes in the shapes of jagged arrays.

#### Examples

Example 1:
Representing a complex-valued matrix with jagged arrays.

```qsharp
open Microsoft.Quantum.Math;

let y = [
    [Complex(0.0, 0.0), Complex(0.0, -1.0)],
    [Complex(0.0, 1.0), Complex(0.0, 0.0)]
];
// y: Complex[][]
let upperRight = y[0][1];
// upperRight: Complex = Complex(0.0, -1.0);
```

Example 2:
Representing the generators of a stabilizer group as dense arrays of Pauli operators.

```qsharp
open Microsoft.Quantum.Arrays;

let perfect = [
    [PauliI, PauliX, PauliZ, PauliZ, PauliX],
    [PauliX, PauliZ, PauliZ, PauliX, PauliI],
    [PauliZ, PauliZ, PauliX, PauliI, PauliX],
    [PauliZ, PauliX, PauliI, PauliX, PauliZ]
];
// perfect: Pauli[][]
let syndrome = ForEach(Measure(_, register), perfect);
// syndrome: Result[]
```

Example 3:
Representing the generators of a stabilizer group as a sparse array of Pauli operators and their indices.

```qsharp
let shor = [
    [(PauliX, 0), (PauliX, 1)],
    [(PauliX, 1), (PauliX, 2)],
    [(PauliX, 3), (PauliX, 4)],
    [(PauliX, 4), (PauliX, 5)],
    [(PauliX, 6), (PauliX, 7)],
    [(PauliX, 7), (PauliX, 8)],

    [(PauliZ, 0), (PauliZ, 1), (PauliZ, 2), (PauliZ, 3), (PauliZ, 4), (PauliZ, 6)],
    [(PauliZ, 3), (PauliZ, 4), (PauliZ, 6), (PauliZ, 7), (PauliZ, 8), (PauliZ, 9)],
];
// shor: (Pauli, Int)[][]
```

Example 4:
A prior distribution over phases represented as an array of double-precision real numbers.

```qsharp
open Microsoft.Quantum.Arrays;
open Microsoft.Quantum.Convert;

// suppose likelihood is a function of type Int -> Double.
let nPoints = 1000;
let prior = ConstantArray(nPoints, 1.0 / IntAsDouble(nPoints));
mutable posterior = prior;
for ((idx, pr) in Enumerated(posterior)) {
    set posterior w/= idx <- posterior[idx] * likelihood(idx);
}
set posterior = PNormalized(posterior, 1.0);
```

Example 5:
A function that returns an elementary matrix (that is, a matrix with a one in the (𝑖, 𝑗)th element and zeros elsewhere).

```qsharp
open Microsoft.Quantum.Arrays;

function ElementaryMatrix<'T>(
    (nRows : Int, nColumns : Int),
    (idxRow : Int, idxCol : Int),
    zero : 'T, one : 'T
) : 'T[][] {
    mutable matrix = ConstantArray(
        nRows,
        ConstantArray(nCols, zero)
    );
    return matrix w/ row <- (matrix[row] w/ col <- one);
}

let e01 = ElementaryMatrix((2, 2), (0, 1), 0.0, 1.0);
// e01: Double[][] = [[0.0, 1.0], [0.0, 0.0]]
```

### Proposed Modification

Building on the utility of 1-D array notation, this suggestion proposes modifying Q# to include new multidimensional array types `[|'T|]`, `[||'T||]`, and so forth. Like values of type `'T[]`, these new multidimensional would also be immutable, and could be manipulated by using the subscript (`[]`) and copy-and-update (`w/`) operators.

For any type `'T`, this proposal introduces a new two-dimensional array type `[|'T|]`, a three-dimensional array type `[||'T||]`, and so forth.
For consistency with these new types, this proposal also introduces `['T]` as alternative notation for `'T[]`; we will use new notation for `'T[]` in the remainder of the proposal.

New values of type `[|'T|]` can be written as literals using `[| ... |]` delimiters instead of `[]`, while literals of type `[||'T||]` can be written using `[|| ... ||]` delimiters (see example 1 below).
The `|` and `|` delimiters occurring within square brackets can be thought of as denoting a rectangular grid, and as constraining one level of indexing to be rectangular.
Similarly, new values of type `[|'T|]` can also be obtained by using the library functions in https://github.com/microsoft/QuantumLibraries/issues/408; e.g., `JaggedAsRectangular2([[2, 3], [4, 5]])` is equivalent to the literal `[|2, 3|, |4, 5|]`.

Within multidimensional array literals, it is a _compile-time_ error to declare jagged subarrays, such as in Example 1, below.
It is similarly a compile-time error to use a non-literal array expression for part of a multidimensional array literal, as is shown in Example 3, below.

Multidimensional arrays can also be created using extensions of the functionality in QEP 2.
For example, `[| element, size=(2, 3) |]` is equivalent to `[|element, element, element|, |element, element, element|]`.

Elements of a value of type `[|'T|]` can be retrieved using the subscript operator `[]` with a value of type `(Int, Int)` as the index, as in `data[(0, 1)]`.
For brevity, the parentheses marking the tuple can be dropped in this case, such that `data[(0, 1)]` and `data[0, 1]` are completely equivalent.
Similarly, elements of a value of type `[||'T||]` can be retrieved by subscripting with indices of type `(Int, Int, Int)`.

As with one-dimensional arrays, multidimensional arrays can also be subscripted by ranges.
Each axis of a multidimensional arrays can be sliced by _either_ a value of type `Range` or a value of type `Int`; for example, `(Int, Int)`, `(Range, Int)`, `(Int, Range)`, and `(Range, Range)` are valid subscripts for a value of type `[|'T|]`.
As shown in Example 5 below, for each `Int` in an index tuple, the dimensionality (aka rank) of the array is reduced by one.
That is, indexing a `[|'T|]` by `(Range, Range)` returns a rank-2 array (`[|'T|]`), while indexing by `(Int, Range)` or `(Range, Int)` returns an ordinary rank-1 array (`['T]`).

Just as with indices like `(Int, Int)` and `(Int, Int, Int)`, subscripts that return slices can also be used in copy-and-update expressions, as shown in Example 6.
Multidimensional indices can also be used with the copy-and-update operator (`w/`) to create a new array that replaces one or more specific element(s) of a multidimensional array, as shown in Example 4 below.
The `w/` operator can also be used with slices as well as indices, in which case the right-hand side of the `<-` arrow must be a multidimensional array whose size matches the slice being updated in the new copy, as shown in Example 6 below.
In the case of `w/` operators, the `()` around index tuples cannot be dropped.

When using values of type `Range` to index one or more axes in a multidimensional array the contextual `Range` expression `...`, e.g., is shorthand for the value `0..1..(n - 1)` where `n` is the length of the axis being indexed. The same [contextual expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions) as for the one-dimensional case are valid for each dimension in the array. 

When used in `for` loops, multidimensional arrays iterate "on the left," yielding loop variables of one rank lower than the array being looped over, as shown in Example 7, below.

Finally, to support multidimensional arrays, this proposal also suggests extending the `Microsoft.Quantum.Arrays` namespace with the following functions that can be used to implement libraries for working with multidimensional arrays:

- `internal function AsNDArrayUnsafe<'TElement, 'TArray>(data : ['TElement], strides : [Int], offset : Int, size : [Int]) : 'TArray`
- `internal function NDArrayDataUnsafe<'TElement, 'TArray>(data : 'TArray) : ['TElement]`
- `internal function NDArrayStridesUnsafe<'TArray>(data : 'TArray) : [Int]`
- `internal function NDArraySizeUnsafe<'TArray>(data : 'TArray) : [Int]`
- `internal function NDArrayOffsetUnsafe<'TArray>(data : 'TArray) : Int`

Each of these five functions would be `body intrinsic;`, and together form the contract between the runtime and the core Q# libraries needed to support this proposed feature (see Example 7, below). By necessity, these functions are "unsafe," in that direct access to these functions would allow violating invariants of multidimensional arrays or bypass the type system to expose runtime failures, necessitating the `internal` modifier. In particular, these functions may be given access to elements that do not exist insofar as Q# user code is concerned (i.e.: are not accessible given the current strides, shapes, and offsets); these elements may have reference counts of zero, such that referring to these elements results in undefined behavior. It is the responsibility of the Q# foundation, core, and standard libraries to ensure that undefined behavior is not exposed to user code.

In user code, multidimensional arrays can be created and manipulated using Q# standard library functions and operations built up using the above internal functions, as described in example 7 below.
For instance, the "diagonal" elements of a 2-D array can be extracted into a 1-D array using `Diagonal2<'T>(array : [|'T|]) : ['T]`, as shown in example 8, below.
Please see https://github.com/microsoft/QuantumLibraries/issues for more details about library functions for working with multidimensional arrays.

#### Examples

Example 1:
Declaring and indexing into variables of type `[|Double|]` and `[||Int||]` using literals.

```qsharp
let z = [
    // Inside [] delimiters, | | delimiters refer not to array expressions, but
    // to "rows" of the two-dimensional array literal.
    | 1.0, 0.0 |,
    | 0.0, -1.0 |
];
Message($"{z[0, 1]}"); // ← 0.0

// It is a compile-time error for the "rows" denoted by | ... | to be uneven:
let incorrect = [
    | 1.0, 2.0 |,
    | 10.0, 20.0, 30.0 | // ← error, since this would declare a "ragged" array
];

let data = [
    // We can nest two levels of | ... | to get three-dimensional arrays.
    |
        |0, 1|,
        |2, 3|
    |,

    |
        |4, 5|,
        |6, 7|
    |
];
Message($"{data[1, 1, 0]}"); // ← 6
```

Example 2:
Mixing 1D and multidimensional arrays.

```qsharp
// Here, we declare the first two levels of indexing as being rectangular,
// resulting in a three-dimensional array.
let data = [
    |
        // After rows, [] denote arrays as elements again.
        | [0], [1, 2] |,
        | [3, 4, 5], [6, 7, 8, 9] |
    |,

    |
        | [10, 11, 12, 13, 14], [15, 16, 17, 18, 19, 20] |,
        | [21, 22, 23, 24, 25, 26, 27], [28, 29, 30, 31, 32, 33, 34, 35] |
    |
];
// data is of type [||[Int]||] (that is, a three-dimensional array of arrays of integers)
// In the zero-th "plane", first "row", zero-th "column", get the element with index 2.
Message($"{data[0, 1, 0][2]}"); // ← 5
```

Example 3:
Using expressions as subarrays of multidimensional arrays results in a compile-time error.

```qsharp
let a = [2, 3];
// The following is a compile-time error, as `|0, 1|` is not an expression
// independent of its surrounding `[]` brackets.
let data = [
    | 0, 1 |,
    a
];
// Using new library functions that can `fail` at runtime, however, we can
// achieve the desired effect.
// In particular, JaggedAsRectangular2<'T>(jagged : 'T[][]) -> [|'T|] allows
// us to build a [|Int|] value from `a`, which we can then join to get `data` using
// the Concatenated2<'T>(axis : Int, left : [|'T|], right : [|'T|])
// -> [|'T|] function:
let data = Concatenated2(0, // concatenate along the 0th (row) axis
    [ | 0, 1 | ],
    JaggedAsRectangular2([a])
);
// data: [|Int|] = [
//     |0, 1|,
//     |2, 3|
// ];
```

Example 4:
Using the copy-and-update operator to manipulate multidimensional arrays.

```qsharp
function ElementaryMatrix(
    (nRows : Int, nCols : Int), (idxRow : Int, idxCol : Int)
) : [|Double|] {
    return [| 0.0, size = (nRows, nCols) |] w/ (idxRow, idxCol) <- 1.0;
}
```

Example 5:
Slicing multidimensional arrays.

```qsharp
let data = [
    |0, 1, 2|,
    |3, 4, 5|,
    |6, 7, 8|
];

// Slicing does not reduce the dimensionality of the resulting array.
let corners = data[0..2..2, 0..2..2];
// corners = [|0, 2|, |6, 8|] and is of type [|Int|]

// Subscripting by an Int reduces the dimensionality of the resulting array;
// here, since our index has one Int, the dimensionality reduces from
// [|Int|] to [Int].
let firstRow = data[0, ...];
// firstRow = [0, 1, 2]
// The same pattern holds no matter which index we subscript with an Int.
let firstColumn = data[..., 0];
// firstColumn = [0, 3, 6]

let data3 = [
    |
        |0, 1, 2|,
        |3, 4, 5|,
        |6, 7, 8|
    |,

    |
        |9, 10, 11|,
        |12, 13, 14|,
        |15, 16, 17|
    |,

    |
        |18, 19, 20|,
        |21, 22, 23|,
        |24, 25, 26|
    |
];
let corners3 = data3[0..2..2, 0..2..2, 0..2..2];
// corners3 is of type [||Int||]
let firstPlane = data3[0, ..., ...];
// firstPlane is of type [|Int|]
let firstRowOfFirstPlane = data3[0, 0, ...];
// firstRowOfFirstPlane = [0, 1, 2] and is of type [Int]
```

Example 6:
Using multidimensional slices in copy-and-update expressions.

```qsharp
let zeros =[|0, size = (3, 3)|];

let withCorners = zeros w/ (0..2..2, 0..2..2) <- [|1, 2|, |3, 4|];
// withCorners = [|1, 0, 2|, |0, 0, 0|, |3, 0, 4|] and is of type [|Int|].

let withFirstRow = zeros w/ (0, 0..2) <- [1, 2, 3];
// withFirstRow = [|1, 2, 3|, |0, 0, 0|, |0, 0, 0|] and is of type [|Int|].

let withFirstColumn = zeros w/ (0..2, 0) <- [1, 2, 3];
// withFirstColumn = [|1, 0, 0|, |2, 0, 0|, |3, 0, 0|] and is of type [|Int|]
```

Example 7:
Iterating over multidimensional arrays.

```qsharp
let data3 = [
    |
        |0, 1, 2|,
        |3, 4, 5|,
        |6, 7, 8|
    |,

    |
        |9, 10, 11|,
        |12, 13, 14|,
        |15, 16, 17|
    |,

    |
        |18, 19, 20|,
        |21, 22, 23|,
        |24, 25, 26|
    |
];
// data3 is of type [||Int||].

for plane in data {
    // plane is of type [|Int|]
    for row in plane {
        // row is of type [Int]
        Message($"{row}");
    }

    Message("");
}
// Output
// ======
// [0, 1, 2]
// [3, 4, 5]
// [6, 7, 8]
//
// [9, 10, 11]
// [12, 13, 14]
// [15, 16, 17]
//
// [18, 19, 20]
// [21, 22, 23]
// [24, 25, 26]

// Iteration "on the left" is equivalent to iterating over the leftmost index
// of a multidimensional array:
let data2 = [
    |0, 1|,
    |2, 3|
];
// In particular, the following loops are identical up to that the idxRow
// variable is not defined in the second loop.
for idxRow in 0..Fst(Size2(data2)) - 1 {
    let row = data2[idxRow, ...];
    // ...
}
for row in data2 {
    // ...
}
```
## Implementation

**NB: Code samples in this section are intended as pseudocode only, and may not work directly as written.**

This proposal can be implemented with minimal new data structures in the Q# runtime, using an approach similar to the [NumPy library for Python](http://numpy.scipy.org/), the [NumSharp library for C#](https://github.com/SciSharp/NumSharp), or the [ndarray library for Rust](https://github.com/rust-ndarray/ndarray/issues/597).

In particular, each of these libraries represents multidimensional arrays by a data structure similar to the following:

```qsharp
newtype MultidimensionalArray<'T> = (
    Data: ['T],
    Offset: Int,
    Size: [Int],
    Strides: [Int]
);
```

Together, `::Offset` and `::Strides` specify how to transform multidimensional indices into a linear index for use with `::Data`:

```qsharp
array[i, j, k]
// implemented by:
array::Data[array::Offset + i * array::Strides[0] + j * array::Strides[1] + k * array::Data[2]]
```

This allows for many common array manipulations to be performed without copying.
For example, a function implementing a matrix transpose need not modify `::Data`, but can reverse `::Strides` and `::Size`:

```qsharp
function Transposed2<'T>(array : [|'T|]) : [|'T|] {
    return array
        w/ Strides <- array::Strides[...-1...]
        w/ Size <- array::Size[...-1...];
}
```

Similarly, `array[..., 0..2...]` can be implemented by doubling `::Strides[1]`:

```qsharp
array[..., 0..2...]
// implemented by:
array
    w/ Strides <- [array::Strides[0], 2 * array::Strides[1]]
    w/ Size <- [array::Size[0], array::Size[1] / 2]
```

Reversing an axis can be implemented by using negative strides and modifications to `::Offset`.

By implementing multidimensional arrays in this way, we can reuse the existing infrastructure for immutable single-dimensional arrays.
Moreover, in many cases, multiple distinct multidimensional arrays can share the same `::Data` item without requiring a copy.
For example, in the variable binding `let view = array[0..2..., 0..2...];`, `view::Data` and `array::Data` can be the same single-dimensional array, as the difference between `view` and `data` can be expressed by only modifying `::Strides` and `::Size`.
The cases where copies may still be required are when constructing new arrays using a copy-and-update expression, or if a particular intrinsic function or operation is implemented in simulation by interoperating with native libraries such as BLAS and LAPACK, or when truncating the array.

### Timeline

This proposal does not depend on any other proposals (though it can be made easier-to-use in combination with other proposals; see _Anticipated Interactions with Future Modifications_, below).

Required implementation steps:

- Adapt compiler to recognize new types, subscript expressions, copy-and-replace expressions, and new literal expressions.
- Implement new data structures in QIR and runtime to represent values of new type, and fundamental operations on new type (e.g.: `w/` expressions).
- Design, review, and approve API design for extensions to the `Microsoft.Quantum.Arrays namespace` to support the new feature.
- Implement new library functions from previous step.
- Document new multidimensional arrays in language specification and conceptual documentation.

## Further Considerations

### Related Mechanisms

This proposal generalizes the existing array feature in Q#.
As such, the new features introduced by this proposal are designed to keep to user expectations formed by existing features.
In particular:

- Like existing arrays, multidimensional arrays are immutable values.
- Mutability can be handled using `set ... w/= ...;` statements in the same fashion as existing 1D arrays.
- Multidimensional arrays can be used as collections in loops.
- There are no subtyping relationships between array types. In particular, `[|'T|]` is not a subtype of `'T[][]` but a distinct type in its own right; nor is `[|('T => Unit is Adj)|]` a subtype of `[|('T => Unit)|]`. Similarly, `[|'T|]` is neither a subtype nor supertype of `[['T]]`.

### Impact on Existing Mechanisms

This proposal would not modify or invalidate existing functionality (e.g.: `Int[][]` will continue to be a valid type in Q#), and thus is not a breaking change.

### Anticipated Interactions with Future Modifications

#### Array comprehensions

This proposal is expected to be compatible with array comprehensions, as the comprehension expressions can be provided at each level of nesting.

For example, using a possible array comprehension feature, the following two statements could be equivalent:

```qsharp
let arr = [ | x, x + 1, x + 2 | for x in 0..3 ];
let arr = [ | 0, 1, 2 |, | 1, 2, 3 |, | 2, 3, 4 |, | 3, 4, 5 | ];
```

Similarly, multiple levels of array comprehension would be compatible with the literal syntax proposed here:

```qsharp
let arr = [ | x + y for y in 0..2 | for x in 0..3 ];
```

#### Handling runtime failure modalities

Some of the type conversions described above can fail at runtime, decreasing the safety of Q# programs.
To assist, the discriminated union and type-parameterized UDT feature suggestions (https://github.com/microsoft/qsharp-compiler/issues/406) could be used to represent the possibility of runtime failures in a typesafe fashion.

For example, the `JaggedAsRectangular2` function above could fail if its input is not actually rectangular.
Using `Maybe<'T>`, we could represent this directly:

```qsharp
function MaybeJaggedAsRectangular2<'T>(input : [['T]]) : Maybe<'T[,]> {
    if (IsRectangular2(input)) {
        // convert here
    } else {
        return Maybe<[|'T|]>::None();
    }
}
```

If in a particular application, it is definitely the case that a given jagged array can be converted, the `Maybe` can be unwrapped using a function that attempts to match on values of type `Maybe<'T>`:

```qsharp
function Forced<'T>(maybe : Maybe<'T>) : 'T {
    return maybe match {
        Some(value) -> value,
        None() -> fail "was None()"
    };
}
```

#### Removing type suffixes with bounded polymorphism

Were the bounded polymorphism feature suggested at https://github.com/microsoft/qsharp-compiler/issues/557 to be adopted, the different "overloads" for the library functions could be consolidated into a smaller number of concepts that then get implemented by each of `[|'T|]`, `[||'T||]`, and so forth.

For example:

```qsharp
// We define a new concept to represent subscripting a
// value by an index.
concept 'Array is IndexableBy<'Index, 'Element> when {
    function ElementAt(index : 'Index, array : 'Array) : 'Element;
}
// We can then use that concept to explain that
// ['T] is indexed by an Int to return a 'T in the
// same way that [|'T|] is indexed by (Int, Int).
example <'T> ['T] is IndexableBy<Int, 'T> {
    function ElementAt(index : Int, array : [|'T|]) {
        return array[index];
    }
}
example <'T> [|'T|] is IndexableBy<(Int, Int), 'T> {
    function ElementAt(index : (Int, Int), array : [|'T|]) {
        return array[index];
    }
}
example <'T> [||'T||] is IndexableBy<(Int, Int, Int), 'T> {
    function ElementAt(index : (Int, Int, Int), array : [|'T|]) {
        return array[index];
    }
}
// This allows us to use the concept to write out more
// general functions acting on arrays of different
// dimensionality.
function Subarray<'Array, 'Index, 'Element where 'Array is IndexableBy<'Index, 'Element>>(
    array : 'Array,
    indices : ['Index]
) : 'Element[] {
    mutable subarray = EmptyArray<'Element>();
    for (index in indices) {
        // We can use ElementAt to handle
        // arrays of different dimensionality in
        // a uniform fashion.
        set subarray += ElementAt(index, array);
    }
    return subarray;
}

// Similarly, if we use type-parameterized UDTs and
// discriminated unions, we can define a concept that
// specifies when a value of a given type can possibly
// be converted to another type.
concept 'TOutput is MaybeConvertableFrom<'TInput> when {
    function MaybeAs(input : 'TInput) : Maybe<'TOutput>;
}
// With that concept in place, we can say that some jagged
// arrays can be converted to rectangular arrays, obviating
// the need for JaggedAsRectangular2, JaggedAsRectangular3,
// and so forth.
example <'T> [|'T|] is MaybeConvertableFrom<[['T]]> when {
    function MaybeAs(input : [['T]]]) : [|'T|] {
        body intrinsic;
    }
}
example <'T> [||'T||]] is MaybeConvertableFrom<[[['T]]]> when {
    function MaybeAs(input : [[['T]]]]) : [||'T||] {
        body intrinsic;
    }
}
```

### Alternatives

#### Syntactic Sugar for Jagged Arrays

As an alternative, one could consider not adding any new types to Q#, but rather extending `w/` to act on values of type `'T[][]`, `'T[][][]` using tuple indices:

```qsharp
// Construct the elementary matrix 𝑒₀₁ = |0⟩⟨1| as the jagged array
// [[0, 1, 0], [0, 0, 0], [0, 0, 0]].
let e01 = ConstantArray(3, ConstantArray(3, 0.0)) w/ (0, 1) <- 1.0;
```

#### Alternative Syntax for Multidimensional Literals

As an alternative, one could consider keeping the new types and index expressions suggested by this proposal, but modifying the definition of multidimensional literals.

For example, alternative delimiters could be used to separate rows, planes, and so forth:

```qsharp
let data3 = [
    0, 1;  // Separate rows with ;
    2, 3;; // Separate planes with ;;

    4, 5;
    6, 7
];
// data3: [||Int||]
```

Other delimiters than `;` could be considered to avoid overloading statement separators.
For example, it may be considered less confusing to reuse the `|` character from `?|` expressions or the `\` character from string escapes:

```qsharp
let x = [
    0.0, 1.0 |
    1.0, 0.0
];

let z = [
    1.0, 0.0 \\ // LaTeX-style notation
    0.0, -1.0
];
```

### Comparison to Alternatives

#### Comparison to Syntactic Sugar for Jagged Arrays

While providing syntactic sugar for copy-and-update operations on jagged arrays helps address some of the more severe pain points in using jagged arrays to represent multidimensional data, that alternative does not address a few critical points:

- Multidimensional indices cannot efficiently be converted into linear indices, causing performance problems with common matrix and tensor operations.
- Jagged arrays do not guarantee at compile time that data is rectangular, introducing the possibility of runtime logic errors with respect to the shape of multidimensional data.

## Raised Concerns

## Response
