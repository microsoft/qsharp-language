--- 
title: Multidimensional arrays
description: 
author:
date: 
---

# Proposal

Currently, for any Q# type `'T`, the array type `'T[]` represents an immutable collection of values of type `'T` indexed by a single integer. It would be really helpful to add a new collection type that is indexed by tuples of integers instead, so as to allow for a more natural representation of concepts like matrices and tensors.

# Justification

Arrays of arrays as currently supported in Q# can be used to represent matrices and higher-rank tensors, but come with a number of disadvantages as compared with multidimensional arrays:

- Nested arrays can in general be jagged; having multidimensional arrays as a type can help enforce that arrays are rectangular at the type level.
- Performance: because nested arrays can be jagged, element lookup cannot in general be done as efficiently as with linear indexing.
- Copy-and-update expressions: Using the `w/` operator to modify elements of nested arrays can be awkward.
  ```qsharp
  mutable matrix = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
  set matrix w/ 2 <- (matrix[2] w/ 1 <- 20);
  // matrix is now [[1, 0, 0], [0, 1, 0], [0, 20, 1]]
  ```

# Description

TODO:    
Describe the proposal and how it ties in with other aspects of the Q# language in more detail.    
Provide general information about the relevant mechanisms and their role in Q#, and how the proposal relates to them. 

## Current Status

Arrays types in Q# can be constructed from any element type `'T` as `'T[]`, including arrays of arrays such as `Int[][]`.
These *jagged arrays* can be used to represent multidimensional arrays of data (informally, _tensors_), such as matrices or vectors.

TODO:   
Describe all aspects of the current version of Q# that will be impacted by the proposed modification.     
Describe in detail the current behavior or limitations that make the proposed change necessary.      
Describe how the targeted functionality can be achieved with the current version of Q#.    
Refer to the examples given below to illustrate your descriptions. 

### Examples

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

## Proposed Modification

Building on the utility of 1-D array notation, this suggestion proposes modifying Q# to include new multidimensional array types `'T[,]`, `'T[,,]`, and so forth. Like values of type `'T[]`, these new multidimensional would also be immutable, and could be manipulated by using the subscript (`[]`) and copy-and-update (`w/`) operators.

For any type `'T`, this proposal introduces a new two-dimensional array type `'T[,]`, a three-dimensional array type `'T[,,]`, and so forth.

New values of type `'T[,]` can be written as literals using `#[]` delimiters instead of `[]`, while literals of type `'T[,,]` can be written using `##[]` delimiters (see example 1 below).
The `#` character can be thought of as denoting a rectangular grid, and as constraining one level of indexing to be rectangular.

Within multidimensional array literals, it is a _compile-time_ error to declare jagged subarrays, such as in Example 1, below.
It is similarly a compile-time error to use a non-literal array expression for part of a mutlidimensional array literal, as is shown in Example 3, below.

Elements of a value of type `'T[,]` can be retrieved using the subscript operator `[]` with a value of type `(Int, Int)` as the index, as in `data[(0, 1)]`.
For brevity, the parentheses marking the tuple can be dropped in this case, such that `data[(0, 1)]` and `data[0, 1]` are completely equivalent.
Similarly, elements of a value of type `'T[,,]` can be retrieved by subscripting with indices of type `(Int, Int, Int)`.
Multidimensional indices can also be used with the copy-and-update operator (`w/`) to replace elements of multidimensional arrays, as shown in Example 4 below.

As with one-dimensional arrays, multidimensional arrays can also be subscripted by ranges.
Each axis of a multidimensional arrays can be sliced by _either_ a value of type `Range` or a value of type `Int`; for example, `(Int, Int)`, `(Range, Int)`, `(Int, Range)`, and `(Range, Range)` are valid subscripts for a value of type `'T[,]`.
As shown in Example 5 below, for each `Int` in an index tuple, the dimensionality (aka rank) of the array is reduced by one.
That is, indexing a `'T[,]` by `(Range, Range)` returns a rank-2 array (`'T[,]`), while indexing by `(Int, Range)` or `(Range, Int)` returns an ordinary rank-1 array (`'T[]`).
Just as with indices like `(Int, Int)` and `(Int, Int, Int)`, subscripts that return slices can also be used in copy-and-replace expressions, as shown in Example 6.

To support multidimensional arrays, this proposal also suggests extending the `Microsoft.Quantum.Arrays` namespace with additional intrinsic library functions for creating, manipulating, and converting arrays of different dimensionality.
For example, for two- and three-dimensional arrays (higher dimensions should follow in a similar fashion):

- `function Transposed2<'T>(data : 'T[,]) : 'T[,]`
- `function Transposed3<'T>(axes : (Int, Int, Int), data : 'T[,,]) : 'T[,,]`
- `function Transposed4<'T>(axes : (Int, Int, Int, Int), data : 'T[,,,]) : 'T[,,,]`
- `function Concatenated<'T>(left : 'T[], right : 'T[]) : 'T[]`
- `function Concatenated2<'T>(axis : Int, left : 'T[,], right : 'T[,]) : 'T[,]`
- `function Concatenated3<'T>(axis : Int, left : 'T[,,], right : 'T[,,]) : 'T[,,]`
- `function JaggedAsRectangular2<'T>(jagged : 'T[][]) : 'T[,]`
- `function JaggedAsRectangular3<'T>(jagged : 'T[][][]) : 'T[,,]`
- `function Shape2<'T>(array : 'T[,]) : (Int, Int)`
- `function Shape3<'T>(array : 'T[,,]) : (Int, Int, Int)`
- `function ElementAt2<'T>(index : (Int, Int), array : 'T[,]) : 'T`
- `function ElementAt3<'T>(index : (Int, Int, Int), array : 'T[,,]) : 'T`
- `function Subarray2<'T>(indices : (Int, Int)[], array : 'T[,]) : 'T[]`
- `function Subarray3<'T>(indices : (Int, Int, Int)[], array : 'T[,,]) : 'T[]`
- `function ConstantArray2<'T>(shape : (Int, Int), value : 'T) : 'T[,]`
- `function ConstantArray3<'T>(shape : (Int, Int, Int), value : 'T) : 'T[,,]`
- `function EmptyArray2<'T>() : 'T[,]`
- `function EmptyArray3<'T>() : 'T[,,]`
- `function ReducedAlongAxis2<'TInput, 'TOutput>(reduction : ('TInput[] -> 'TOutput), axis : Int, array : 'TInput[,]) : 'TOutput[]`
- `function ReducedAlongAxis3<'TInput, 'TOutput>(reduction : ('TInput[] -> 'TOutput), axis : Int, array : 'TInput[,,]) : 'TOutput[,]`
- `function TimesD2(left : Double[,], right : Double[,]) : Double[,]`
- `function TimesC2(left : Complex[,], right : Complex[,]) : Complex[,]`
- `function Dot2With2<'T>(plus : (('T, 'T) -> 'T), times : (('T, 'T) -> 'T), (idxLeft : Int, idxRight : Int), left : 'T[,], right : 'T[,]) : 'T[,]`
- `function Dot3With2<'T>(plus : (('T, 'T) -> 'T), times : (('T, 'T) -> 'T), (idxLeft : Int, idxRight : Int), left : 'T[,,], right : 'T[,]) : 'T[,,]`
- `function Dot2With3<'T>(plus : (('T, 'T) -> 'T), times : (('T, 'T) -> 'T), (idxLeft : Int, idxRight : Int), left : 'T[,], right : 'T[,,]) : 'T[,,]`
- `function Dot3With3<'T>(plus : (('T, 'T) -> 'T), times : (('T, 'T) -> 'T), (idxLeft : Int, idxRight : Int), left : 'T[,,], right : 'T[,,]) : 'T[,,,]`
- `function Reshaped1To2<'T>(array : 'T[], newShape : (Int, Int)) : 'T[,]`
- `function Reshaped1To3<'T>(array : 'T[], newShape : (Int, Int, Int)) : 'T[,,]`
- `function Reshaped2To3<'T>(array : 'T[,], newShape : (Int, Int, Int)) : 'T[,,]`
- `function Reshaped3To3<'T>(array : 'T[,,], newShape : (Int, Int, Int)) : 'T[,,]`
- `function Reshaped3To2<'T>(array : 'T[,,], newShape : (Int, Int)) : 'T[,]`
- `function Broadcasted2<'TLeft, 'TRight, 'TOutput>(fn : (('TLeft, 'TRight) -> 'TOutput), left : 'TLeft[,], right : 'TRight[,]) : 'TOutput[,]`
- `function Broadcasted3<'T0, 'T1, 'T2, 'TOutput>(fn : (('T0, 'T1, 'T2) -> 'TOutput), in0 : 'T0[,], in1 : 'T1[,], in2 : 'T2[,]) : 'TOutput[,]`
- `function DiagonalMatrix<'T>(diag : 'T[]) : 'T[,]`
- `function Diagonal<'T>(array : 'T[,]) : 'T[]`

Many of these array functions can be written in Q# itself, while others would require implementation as intrinsics.
Note that above, we have used suffixes like `2` and `3` to denote ranks of inputs and outputs (or even `2With3` when inputs have different ranks), but these could be eliminated using additional language features, as discussed in "Anticipated Interactions with Future Modifications."

### Examples

Example 1:
Declaring and indexing into variables of type `Double[,]` and `Int[,,]` using literals.

```qsharp
let z = #[ // ← #[] marks a two-dimensional array instead of an array of arrays.
    // Inside #[] delimiters, [] delimiters refer not to array expressions, but
    // to "rows" of the two-dimensional array literal.
    [1.0, 0.0],
    [0.0, -1.0]
];
Message($"{z[0, 1]}"); // ← 0.0

// Inside of #[] delimiters, it is a compile-time error for the "rows" to be
// uneven:
let incorrect = #[
    [1.0, 2.0],
    [10.0, 20.0, 30.0] // ← error, since this would declare a "ragged" array
];

let data = ##[ // ← ##[] marks a three-dimensional array
    // Inside ##[] delimiters, [] refer to "planes", then to "rows."
    [
        [0, 1],
        [2, 3]
    ],

    [
        [4, 5],
        [6, 7]
    ]
];
Message($"{data[0, 1, 0]}"); // ← 6
```

Example 2:
Mixing 1D and multidimensional arrays.

```qsharp
// Use ##[] declare the first two levels of indexing as being rectangular,
// resulting in a three-dimensional array.
let data = ##[
    // Inside ##[] delimiters, [] refer to "planes", then to "rows."
    [
        // After rows, [] denote arrays as elements again.
        [[0], [1, 2]],
        [[3, 4, 5], [6, 7, 8, 9]]
    ],

    [
        [[10, 11, 12, 13, 14], [15, 16, 17, 18, 19, 20]],
        [[21, 22, 23, 24, 25, 26, 27], [28, 29, 30, 31, 32, 33, 34, 35]]
    ]
];
// data: Int[][,] (that is, a two-dimensional array of arrays of integers)
// Get the zero-th "plane," first "row", zeroth "column," and third element.
Message($"{data[0, 1, 0][2]}"); // ← 5
```

Example 3:
Using expressions as subarrays of multidimensional arrays results in a compile-time error.

```qsharp
let a = [2, 3];
// The following is a compile-time error, since `a` is not a 1D array literal
// of length 2.
let data = #[
    [0, 1],
    a
];
// Using a new library function that can `fail` at runtime works, however.
let data = Concatenated(0, // concatenate along the 0th (row) axis
    #[ [0, 1] ],
    a
);
// data: Int[,] = #[
//     [0, 1],
//     [2, 3]
// ];
```

Example 4:
Using the copy-and-replace operator to manipulate multidimensional arrays.

```qsharp
function ElementaryMatrix(
    (nRows : Int, nCols : Int), (idxRow : Int, idxCol : Int)
) : Double[,] {
    return ConstantArray2((nRows, nCols), 0.0) w/ (idxRow, idxCol) <- 1.0;
}
```

Example 5:
Slicing multidimensional arrays by ranges.

```qsharp
let data = #[
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8]
];

// Slicing an index by a Range does not reduce the dimensionality
// of the resulting array.
let corners = data[0..2..2, 0..2..2];
// corners: Int[,] = #[[0, 2], [6, 8]]

// Subscripting by an Int reduces the dimensionality of the resulting array;
// here, since our index has one Int, the dimensionality reduces from
// Int[,] to Int[].
let firstRow = data[0, ...];
// firstRow: Int[] = [0, 1, 2]
// The same pattern holds no matter which index we subscript with an Int.
let firstColumn = data[..., 0];
// firstColumn = [0, 3, 6]

let data3 = ##[
    [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8]
    ],

    [
        [9, 10, 11],
        [12, 13, 14],
        [15, 16, 17]
    ],

    [
        [18, 19, 20],
        [21, 22, 23],
        [24, 25, 26]
    ]
];
let corners3 = data3[0..2..2, 0..2..2, 0..2..2];
// corners3: Int[,,]
let firstPlane = data3[0, ..., ...];
// firstPlane: Int[,]
let firstRowOfFirstPlane = data3[0, 0, ...];
// firstRowOfFirstPlane: Int[] = [0, 1, 2]
```

Example 6:
Using multidimensional slices in copy-and-update expressions.

```qsharp
let zeros = ConstantArray2((3, 3), 0);

let withCorners = zeros w/ (0..2..2, 0..2..2) <- #[[1, 2], [3, 4]];
// withCorners: Int[,] = #[ [1, 0, 2], [0, 0, 0], [3, 0, 4]]

let withFirstRow = zeros w/ (0, 0..2) <- [1, 2, 3];
// withFirstRow: Int[,] = #[ [1, 2, 3], [0, 0, 0], [0, 0, 0] ]

let withFirstColumn = zeros w/ (0..2, 0) <- [1, 2, 3];
// withFirstColumn: Int[,] = #[ [1, 0, 0], [2, 0, 0], [3, 0, 0] ]
```

# Implementation

**NB: Code samples in this section are intended as pseudocode only, and may not work directly as written.**

This proposal can be implemented with minimal new data structures in the Q# runtime, using an approach similar to the NumPy library for Python, the NumSharp library for C#, or the ndarray library for Rust.
<!-- TODO: add links -->

In particular, each of these libraries represents multidimensional arrays by a data structure similar to the following:

```qsharp
newtype MultidimensionalArray<'T> = (
    Data: 'T[],
    Offset: Int,
    Shape: Int[],
    Strides: Int[]
);
```

Together, `::Offset` and `::Strides` specify how to transform multidimensional indices into a linear index for use with `::Data`:

```qsharp
array[i, j, k]
// implemented by:
array::Data[array::Offset + i * array::Strides[0] + j * array::Strides[1] + k * array::Data[2]]
```

This allows for many common array manipulations to be performed without copying.
For example, a function implementing a matrix transpose need not modify `::Data`, but can reverse `::Strides` and `::Shape`:

```qsharp
function Transposed2<'T>(array : 'T[,]) : 'T[,] {
    return array
        w/ Strides <- array::Strides[...-1...]
        w/ Shape <- array::Shape[...-1...];
}
```

Similarly, `array[..., 0..2...]` can be implemented by doubling `::Strides[1]`:

```qsharp
array[..., 0..2...]
// implemented by:
array
    w/ Strides <- [array::Strides[0], 2 * array::Strides[1]]
    w/ Shape <- [array::Shape[0], array::Shape[1] / 2]
```

Reversing an axis can be implemented by using negative strides and modifications to `::Offset`.

By implementing multidimensional arrays in this way, we can reuse the existing infrastructure for immutable single-dimensional arrays.
Moreover, in many cases, multiple distinct multidimensional arrays can share the same `::Data` item without requiring a copy.
For example, in the variable binding `let view = array[0..2..., 0..2...];`, `view::Data` and `array::Data` can be the same single-dimensional array, as the difference between `view` and `data` can be expressed by only modifying `::Strides` and `::Shape`.
The cases where copies may still be required are when reshaping from more indices to less, when using `w/` to update slices, or if a particular intrinsic function or operation is implemented in simulation by interoperating with native libraries such as BLAS and LAPACK.

## Timeline

TODO:    
List any dependencies that the proposed implementation relies on.    
Estimate the resources required to accomplish each step of the proposed implementation. 

# Further Considerations

TODO:    
Provide any context and background information that is needed to discuss the concepts in detail that are related to or impacted by your proposal.

## Related Mechanisms

TODO:    
Provide detailed information about the mechanisms and concepts that are relevant for or related to your proposal,
as well as their role, realization and purpose within Q#. 

## Impact on Existing Mechanisms

TODO:    
Describe in detail the impact of your proposal on existing mechanisms and concepts within Q#. 

## Anticipated Interactions with Future Modifications

TODO:    
Describe how the proposed modification ties in with possible future developments of Q#.
Describe what developments it can facilitate and/or what functionalities depend on the proposed modification.

## Alternatives

### Syntactic Sugar for Jagged Arrays

As an alternative, one could consider not adding any new types to Q#, but rather extending `w/` to act on values of type `'T[][]`, `'T[][][]` using tuple indices:

```qsharp
// Construct the elementary matrix 𝑒₀₁ = |0⟩⟨1| as the jagged array
// [[0, 1, 0], [0, 0, 0], [0, 0, 0]].
let e01 = ConstantArray(3, ConstantArray(3, 0.0)) w/ (0, 1) <- 1.0;
```

### Alternative Syntax for Multidimensional Literals

As an alternative, one could consider keeping the new types and index expressions suggested by this proposal, but modifying the definition of multidimensional literals.

For example, alternative delimiters could be used to separate rows, planes, and so forth:

```qsharp
let data3 = [
    0, 1;  // Separate rows with ;
    2, 3;; // Separate planes with ;;

    4, 5;
    6, 7
];
// data3: Int[,,]
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

These alternatives can possibly be combined with `#[]`:

```qsharp
let bellTableau = #[          // denote 2D array
    true, true, false, false; // separate rows instead of nesting [] inside #[]
    false, false, true, true
];
```

## Comparison to Alternatives

TODO:    
Compare your proposal to the possible alternatives and compare the advantages and disadvantages of each approach. 
Compare in particular their impact on the future development of Q#. 

# Raised Concerns

Any concerns about the proposed modification will be listed here and can be addressed in the [Response](#response) section below. 

## Response 




