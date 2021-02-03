---
description: Proposal to introduce and require explicit copy-and-update expressions when constructing array modifications
author: Bettina Heim
date: 2019-04-02
---

# Copy-and-Update Expression for Arrays

## Proposal

The proposal is to introduce a dedicated copy-and-update expression in the form of a ternary operator 
that reduces the need for mutable bindings.
Along with the change the proposal is to make a breaking change and clearly distinguish the mutability of a handle and the behavior of a type 
by explicitly re-assigning a copy-and-update expression to the same symbol when arrays need to be modified after initialization.
Introducing a suitable update-and-reassign operator allows to reduce the verbosity of expressing modifications to array items for (immutable) arrays, 
and would be aligned with similar operators for other modifications (e.g. `+=`). 

## Justification

In Q#, all values are immutable and follow value semantics - 
with `Qubit`s taking on a somewhat special role, depending on interpretation.
Values can be bound to symbols ("handles") via let- and mutable-statements. 
Such bindings provide a convenient way to access a value via the defined handle. 
In a sense, let-statements define one-time handles, 
i.e. handles that for the duration of their validity will always be bound to the same value, 
whereas mutable-statements allow to define handles that can be reused to bind different values at different points in the code. 

Independent on how a value is bound, the values themselves are immutable. 
This in particular also holds for arrays and array items. 
However, it is currently possible to have a statement of the form <nobr>`set a[i] = 1;`</nobr>, 
where `a` is a mutable handle to a value of type array, giving the impression that the value itself is modified. 
Behaviorally, this is not the case, such that the content of any other handle that accesses the same value remains unchanged. 
In that sense, set-statements of this form can be seen as constructing a new array and re-assigning it to `a`, hence the need for `a` to be mutable. 
The discrepancy between the behavior suggested by the current syntax and the actual behavior of the language becomes even more evident for arrays of arrays. 
It is currently possible to have a statement <nobr>`set a[i][j] = 1;`</nobr> for a mutable symbol `a`, 
whereas the same statement would cause an error if the symbol `a` has been declared and bound as part of a let-statement. 

In that sense, Q# seemingly conflates mutability of a handle and the behavior of a value of a certain type 
by supporting a syntax commonly used to indicate changes to the items of an array value.
The current syntax is misleading since the behavior of a value is determined by its type rather than by how it is accessed. 
This proposal specifies a replacement for the current syntax that makes it clear that formally, a new value is being created and bound to a symbol. 
It thus reflects and clearly conveys the behavior that can be expected, 
without impacting existing optimizations to avoid unnecessary copies that the compiler chooses to do. 

The proposed change extends the current functionality by adding a new kind of expression 
that eliminates the need for one or several dedicated set-statements in some cases.
Adapting this proposal furthermore allows for a consistent treatment of all types that follow value semantics and support item access, 
and the proposed copy-and-update expression can be extended to include tuple items and items in user-defined types. 
The additional functionality provided by copy-and-update expressions reduces the need for declaring mutable bindings, 
and thus reduce the need for manual declaration of certain specializations. 

## Description

Q# provides the means to define mutable symbols, i.e. variables that can be reassigned. 
Mutability within Q# is a concept that applies to a *symbol* rather than a type or value. 
Local symbols can be declared as either being mutable or immutable, with some exceptions like loop-variables in for-loops 
for which the behavior is predefined and cannot be specified.
Put more broadly, the concept of mutability applies to the handle that allows one to access a value rather than to the value itself. 
Specifically, mutability is *not* represented in the type system, implicitly or explicitly. 

### Current Status

Currently, array items may occur on the left hand side of a set-statement if and only if the corresponding array is accessed via a mutable symbol. 
The behavior of the involved value(s) follows value semantics. 
In that sense, set-statements for array items incorporate an implicit copy-and-update expression followed by a reassignment to the same handle. 
Under the hood the copy mechanism is optimized and the actual execution of the copy is deferred until necessary. 

Since arguments passed to callables are considered to be immutable bindings within the callable, it is not possible to modify the content of an array as a side effect of a call expression. 
This is in contrast to other languages, where arrays are reference types and array items can correspondingly always be modified even if the binding of the reference itself is immutable.

#### Examples

Example 1:    
Mutable and Immutable Symbols

```qsharp
let step = 1;                               // declaration of an immutable symbol of type Int
mutable counter = 0;                        // declaration of a mutable symbol of type Int
for (i in 1..10) {
    set counter = counter + step;           // reassignment of `counter` to a new value
}
```

Example 2a:    
Value Semantics for Arrays - Assignment to Local Symbols
```qsharp
let imArr = new Int[5];                     // the symbol `imArr` is immutable  
mutable arr = imArr;                        // the current value in `imArr` is assigned to `arr`
mutable copy = arr;                         // the current value in `arr` is assigned to `copy`

set arr[0] = 1;                             // values access via `imArr` and `copy` are unchanged
set arr = new Int[0];                       // arr now contains an empty integer array
                                            // the set-statements above cannot be applied to `imArr`
```

Example 2b:    
Value Semantics for Arrays - Passing Arrays as Arguments
```qsharp
function Foo () : Unit {

    let imArr = [1,0,0];
    mutable arr = [1,0,0];
    Bar(imArr, arr);                        // `arr` and `imArr` always remain unmodified
}

function Bar (arr1 : Int[], arr2 : Int[]) : Unit {

    mutable tmp1 = arr1; 
    mutable tmp2 = arr2; 

    set tmp1[0] = 100;                      // `arr1` cannot be used in a set-statement
    set tmp2[0] = 100;                      // `arr2` cannot be used in a set-statement
}
```

Example 2c:    
Mutable Symbols Containing Arrays of Arrays
```qsharp
mutable arr = new Int[][10];                // `arr` is a mutable symbol of type Int[][]
let orig = arr;                             // `orig` contains the value currently assigned to `arr`

for (i in 0 .. Length(arr) - 1) {

    set arr[i] = new Int[Length(arr)];      // `orig` remains unchanged
    let row = arr[i];

    for (j in 0 .. Length(arr[i]) - 1) {
        set arr[i][j] = 1;                  // both `orig` and `row` remains unchanged
    }
}                                           // `arr` contains a square array with each entry set to one
```

### Proposed Modification

A new copy-and-update expression for arrays is introduced in the form of a ternary operator. 
It is of the form <nobr>`expression w/ expression <- expression`</nobr>, with suitable restrictions regarding the type of the inner expressions. 
The type of the middle expression in particular can be `Int`, `Range`, and possibly `Int[]`. 
If an index array can be used to indicate the items to update within a copy-and-update expressions, 
then the same should be permissible for array slicing in the interest of consistency. 
In terms of precedence, the copy-and-update operator is left-associative and has lowest precedence, 
and in particular lower precedence than the range operator (`..`) or the ternary conditional operator (`?|`). 
The chosen left associativity allows easy chaining of copy-and-update expressions. 

Array item expressions on the left hand side of a set-statement are no longer supported.
Like let- and mutable-statements, the left hand side of a set-statement then has to consist of a symbol or a symbol tuple.
It may contain (only) nested symbols and/or omitted symbol indicators. 
The shape of the set-statement thereby follows the shape <nobr>`symbolTuple = expression`</nobr>, respectively <nobr>`symbolTuple = initializerExpression`</nobr>, that is obeyed by all assignments, with loop-variables being the only exception. 

An array cannot be modified after initialization. 
A copy-and-update expression allows efficient creation of a new array based on the given one, with the items at the given indices replaced by the given values. 
The implementation for copy-and-update expressions avoids copying the entire array 
but merely duplicates the necessary parts to achieve the desired behavior, and performs an in-place modification if possible. 
Suitable means to initialize an array via e.g. an initialization function or similar means are to be provided by a suitable core library.
Array initialization via a call to such a core function thus does not incur additional overhead due to immutability. 

Requiring an explicit call to a copy-and-update expression followed by reassignment to reflect the behavior incurs a certain additional verbosity. 
The proposal includes having a suitable abbreviation `w/=` to reduce the verbosity 
for what was previously expressed as set statements with an array item on the left of the assignment.
With the ternary copy-and-update operator having lowest precedence, incorporating the corresponding behavior for this abbreviation is straightforward. 
Modifying an array of arrays via copy-and-update expressions remains significantly more wordy than the current syntax. 
It may be worth considering introducing a dedicated type for two-dimensional square arrays in particular. 
Such a type should also be a value type such that all possible side effects remain limited to quantum transformations on qubits. 
Introducing such a data type constitutes a non-trivial extension of Q# such that the details need to be worked out in a separate proposal. 

#### Examples

Example 1:     
Supported Set-Statements
```qsharp
let delims = (1, 10); 
mutable ((_, step), tot) = (delims, 0);     // `step` and `tot` both are mutable symbols

for (i in 1 .. step) {                      // iteration over the range 1 .. 10
    set (tot, step) = (tot+step, step-1);   // currently supported and remains supported
}
```
Example 2a:    
Copy-And-Update Expressions for Arrays
```qsharp
using (qs = Qubit[10]) {
    let mask = new Bool[Length(qs)];        // all entries are initialized to `false`

    for (i in Length(qs)-2 .. -1 .. 0) {
        let nbPair = mask 
            w/ i     <- true                // the copy-and-update expression is left-associative
            w/ i + 1 <- true;               // (only) entry `i` and `i+1` of `nbPair` are now `true`
        Apply(nbPair, qs);                  // apply a transformation based on the set items
    }

    for (i in Length(qs)-2 .. -1 .. 0) {
        let nbPair = mask w/                // several entries may be modified by index array
            [i, i+1] <- [true, true];       // index array is given within array item access brackets
        Apply(nbPair, qs);                  // (only) entry `i` and `i+1` of `nbPair` are `true`
    }
}
```
Example 2b:    
Copy-And-Update Expressions Followed by Reassignment
```qsharp
function InitializeArray<'T> (              // function that initializes an array
    size : Int,                             // of the specified size 
    initializer : (Int -> 'T)               // with the values returned by the given function
) : 'T[] {                                  // and returns it

    mutable arr = new 'T[size];             // allocates and assigns an array of length `size` and
    for (i in 0 .. size-1) {                // fills it with the values returned by `initializer`

        let val = initializer(i);           // computes and assigns the value to fill in at index `i`
        set arr w/= i <- val;               // performs an in-place modification if possible and 
                                            // replaces the no longer supported `set arr[i] = val;`
    }
    return arr;                             // returns the built array
}

function InitializeWith<'T> (
    size : Int,
    indices : Int[]
    initializer : (Int[] -> 'T)    
) : 'T[] {

    mutable arr = new 'T[size]; 
    let values = initializer(indices);      // the items to modify can be specified via 
    set arr w/= indices <- values;          // an index expression of type `Int`, `Range`, or `Int[]`
}
```
Example 2c:     
Tentative Example for an Array2D Data Type
```qsharp
mutable arr = new Array2D<Int>[10];

for (i in 0 .. Length(arr) - 1) {           // whether `Length` should be applicable 
    for (j in 0 .. Length(arr) - 1) {       // needs to be worked out in a separate proposal
        set arr w/=                         // the index expression needs to be of type `(Int, Int)` 
            (i,j) <- i == j ? 1 | 0;        // a copy-and-update expression has lowest precedence
    }   
} 
```

## Implementation

Mutability is clearly attributed to an identifier rather than to an expression. 
Since there is no behavior change associated with the proposal, the required adaptions are minimal. 
The added functionality of copy-and-update expressions requires support in the Q# data structures, 
and the existing data structures for set-statements need to be modified to expect a symbol tuple rather than an expression on the left hand side of the assignment. 

An efficient processing of copy-and-update expressions for arrays in the backend is possible by detecting copy-and-update expressions followed by re-assignment to the same symbol and leveraging the existing setup. 

To mitigate the impact on user code, support for processing no longer supported set-statement in the formatting tool is desirable. 
However, due to avoid further confusion, the suggestion is to make it a clear breaking change giving a compilation error for no longer supported syntax rather than merely a deprecated warning. 

### Timeline

The change is proposed as part of the December 2018 review cycle, with an expected implementation for Summer 2019. 
Since this proposal modifies the core functionality of the language, an adaption needs to happen within the preview phase and as early as possible. 
Any potential implementation of copy-and-update expressions for tuple items or items in user-defined types would overlap partially with the infrastructure required for this change. 

## Further Considerations

There is currently no concept of a reference or of reference type semantics in Q# - without prejudice regarding how and where values are stored. 
Arrays provide the only means to store an amount of data that is only determined at runtime and, like tuples, follow value semantics in Q#. 
Keeping arrays as value types is desirable due to the vast implications that introducing reference types within operations would have. 
The restriction to value types - combined with the imposed limitations on qubit allocations and de-allocations - allows to provide guarantees about program state that may be used for optimization with with little overhead and required infrastructure within the compiler. 
Extending the type system while maintaining these guarantees may be possible at a later point in time but requires careful evaluation and consideration. 
In any case, providing immutable arrays as data structures in Q# remains desirable. 

### Related Mechanisms

The behavior of a value is fully determined by its type. 
In particular, the behavior related to item access and manipulations should be the same for all types that follow value semantic and provide item access.
Correspondingly, this modification needs to be coordinated with any item access that we provide for tuples and user-defined types. 
There should be no direct interactions, but a consistent syntax for copy-and-update expressions is desirable.

Clarifying the concept of mutability and its role in Q# also allows us to meaningfully support syntactic abbreviations of the form "apply-and-reassign" like e.g. an increment-and-reassign operator `+=`. 
Since this proposal introduces such a construct into the language for the first time, it stands to reason that similar operators should be introduced as well. 
Introducing the corresponding construct for all arithmetic, bitwise, and logical operators seems reasonable.  

It seems intuitive that the same kinds of constructs are supported both within copy-and-update expressions as are for array item access respectively slicing. 
Extending the current mechanism for array slicing to support indexing into the array with an array of indices may be an extension of the current functionality worth considering. 
It is worth mentioning that the functionality of the current implementation needs to be extended to avoid certain performance penalties for slicing by index array compared to slicing by range. 

### Impact on Existing Mechanisms

The proposed modification is purely a syntactic change and has no impact on the behavior of the language besides the introduced additional functionalities. 

### Anticipated Interactions with Future Modifications

Particular care needs to be taken to achieve a consistent treatment of types that follow value semantics, 
and to syntactically distinguish different behavior e.g. if reference types were to be introduced in the future. 
This proposal allows us to make a clear separation between the two and clearly conveys what behavior can be expected for values of a certain type. 
It is therefore vital to ensure the extensibility of the type system in that regard in the future. 

Purely regarding the exact choice of syntax, care should be taken to avoid using any operators and keywords that may be preferable for potential future features such as lambda functions and operations. 
There should be no particular parsing challenges for introducing this change, as long as the copy-and-update operator remains the operator with lowest precedence. 
If this were no longer the case, appropriate workarounds may be needed to achieve a consistent behavior between the operator and the corresponding apply-and-reassign construct.  

### Alternatives

1. Leveraging existing language constructs:    
Introducing a dedicated syntax for copy-and-update expressions for arrays is not strictly necessary. 
The same functionality could be achieved by a call to a function `Replace` within the Q# core library. 

2. Alternative syntaxes:    
In terms of syntax choices there are several options worth considering. Worthwhile options to mention are the use of <nobr>`/. <-`</nobr> as ternary operator instead of <nobr>`w/ <-`</nobr>. 
A somewhat more cryptic alternative would be the use of <nobr>`\ <-`</nobr>, and a more verbose alternative would be given by <nobr>`with <-`</nobr>. 

Lastly, I would like to mention that for reasons that require a more elaborate discussions on quantum compilation, we will not consider introducing reference types in Q# at this point in time or in the near future. 
In order to preserve the guarantees regarding the behavior of a quantum program that we would like to give, 
any potential extension of the type system needs to be considered carefully. 
We are hence aiming to keep the value type semantics for arrays. 

### Comparison to Alternatives

1. Having a dedicated syntax for copy-and-update expressions aligns well with future features for user-defined types and tuples. 
In contrast to arrays, providing a copy-and-update mechanism for tuple items or items in user-defined types requires additional infrastructure. 
Such an additional infrastructure can either come in the form of dedicated syntax, 
or requires defining an interpretation for and suitable representation of items in tuples and/or user-defined types within the type system. 
Having a dedicated syntax overall seems worthwhile independent of any future role and interpretation of items within tuples and user-defined types. 

2. Regarding syntax choices, it seems reasonable to reserve the use of both `->` and `=>` for potential use in future lambda functions. 
Hence, a syntax choice inspired by Mathematica's `/. ->` syntax is not feasible, and would require deviating from that exact syntax.
Generally, we would like to avoid using constructs that are similar to but not quite the same as those in other languages. 
The somewhat more verbose syntax `with <-` would result in the corresponding apply-and-reassign operator `with=` that combines a keyword with a symbol into one operator. 

The proposed approach has the additional benefit of tying in nicely with other features 
as well as reducing data mutation which can simplify optimizations of quantum programs. 

## Raised Concerns and Further Remarks

In the spirit of building a common understanding of different mechanisms within Q#, it is worth pointing out that the functionality provided by the `mutable` keyword is fundamentally inconsistent with an interpretation that the current functionality somehow implies the existence of reference types in Q#. Such an interpretation is based on an implicit assumption that the `let` and `mutable` keywords used to introduce a binding have implications on the type of the assigned value via an implicit conversion upon assignment. It furthermore requires assumptions regarding relations and conversions between different types that do not align with the spirit of Q#, and would have a range of have severe and under the current circumstances undesirable implications for the Q# type system. 
