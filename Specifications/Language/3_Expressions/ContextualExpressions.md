# Contextual and Omitted Expressions

The usage of item names in [copy-and-update expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions) without having to qualify them is an example for an expression that is only valid in a certain context.

Furthermore, expressions can be omitted when they can be inferred and automatically inserted by the compiler, as it is the case in [evaluate-and-reassign statements](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#evaluate-and-reassign-statements).

There is one more example for both; open-ended ranges are valid only within a certain context, and the compiler will translate them into normal `Range` expressions during compilation by inferring suitable boundaries. 

A value of type `Range` generates a sequence of integers, specified by a start, optionally a step, and an end value. For example, the `Range` literal expressions `1..3` generates the sequence 1,2,3, and the expression `3..-1..1` generates the sequence 3,2,1. Ranges can be used for example to create a new array from an existing one by slicing: 
```qsharp
    let arr = [1,2,3,4];
    let slice1 = arr[1..2..4];  // contains [2,4] 
    let slice2 = arr[2..-1..0]; // contains [3,2,1]
```
No infinite ranges exist in Q#, such that start and end value always need to be specified, expect when a `Range` is used to slice an array. In that case, the start and/or end value of the range can reasonably be inferred. 

Looking at the array slicing expressions above, it is reasonable for the compiler to assume that the intended range end should be the index of the last item in the array if the step size is positive. If the step size on the other hand is negative, then the range end likely should be the index of the first item in the array, i.e. `0`. The converse holds for the start of the range. 

To summarize, if the range start value is omitted, then the inferred start value 
- is zero if no step is specified or the specified step is positive, 
- is the length of the array minus one if the specified step is negative. 

If the range end value is omitted,  then the inferred end value 
- is the length of array minus one if no step is specified or the specified step is positive, and 
- is zero if the specified step is negative. 

Q# hence allows to use open-ended ranges within array slicing expressions: 

```qsharp
let arr = [1,2,3,4,5,6];
let slice1  = arr[3...];      // slice1 is [4,5,6];
let slice2  = arr[0..2...];   // slice2 is [1,3,5];
let slice3  = arr[...2];      // slice3 is [1,2,3];
let slice4  = arr[...2..3];   // slice4 is [1,3];
let slice5  = arr[...2...];   // slice5 is [1,3,5];
let slice7  = arr[4..-2...];  // slice7 is [5,3,1];
let slice8  = arr[...-1..3];  // slice8 is [6,5,4];
let slice9  = arr[...-1...];  // slice9 is [6,5,4,3,2,1];
let slice10 = arr[...];       // slice10 is [1,2,3,4,5,6];
```

Since the information whether the range step is positive or negative is runtime information, the compiler inserts a suitable expression that will be evaluated at runtime. For omitted end values, the inserted expression is `step < 0 ? 0 | Length(arr)-1`, and for omitted start values it is `step < 0 ? Length(arr)-1 | 0`, where `step` is the expression given for the range step, or `1` if no step is specified. 
