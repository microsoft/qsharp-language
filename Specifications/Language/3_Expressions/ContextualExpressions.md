# Contextual and omitted expressions

Contextual expressions are expressions that are only valid in certain contexts, such as the use of item names in [copy-and-update expressions](xref:microsoft.quantum.qsharp.copyandupdateexpressions#copy-and-update-expressions) without having to qualify them.

Expressions can be *omitted* when they can be inferred and automatically inserted by the compiler, for example, in the case of [evaluate-and-reassign statements](xref:microsoft.quantum.qsharp.variabledeclarationsandreassignments#evaluate-and-reassign-statements).

Open-ended ranges are another example that apply to both contextual and omitted expressions. They are are valid only within a certain context, and the compiler translates them into normal `Range` expressions during compilation by inferring suitable boundaries.

A value of type `Range` generates a sequence of integers, specified by a start value, a step value (optional), and an end value. For example, the `Range` literal expression `1..3` generates the sequence 1,2,3. Likewise, the expression `3..-1..1` generates the sequence 3,2,1. You can also use ranges to create a new array from an existing one by slicing, for example:

```qsharp
    let arr = [1,2,3,4];
    let slice1 = arr[1..2..4];  // contains [2,4] 
    let slice2 = arr[2..-1..0]; // contains [3,2,1]
```

You cannot define an infinite range in Q#; the start and end values always need to be specified. The only exception is when you use a `Range` to slice an array. In that case, the start or end values of the range can reasonably be inferred by the compiler.

In the previous array slicing examples, it is reasonable for the compiler to assume that the intended range end should be the index of the last item in the array if the step size is positive. If the step size is negative, then the range end likely should be the index of the first item in the array, `0`. The converse holds for the start of the range.

To summarize, if you omit the range start value, the inferred start value

- is zero if no step is specified or the specified step is positive.
- is the length of the array minus one if the specified step is negative.

If you omit the range end value, the inferred end value

- is the length of the array minus one if no step is specified or the specified step is positive.
- is zero if the specified step is negative.

Q# hence allows the use of open-ended ranges within array slicing expressions, for example:

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

Since the determination of whether the range step is positive or negative happens at runtime, the compiler inserts a suitable expression that will be evaluated at runtime. For omitted end values, the inserted expression is `step < 0 ? 0 | Length(arr)-1`, and for omitted start values it is `step < 0 ? Length(arr)-1 | 0`, where `step` is the expression given for the range step, or `1` if no step is specified.


