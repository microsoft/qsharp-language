# Variable Declarations and Reassignments

Values can be bound to symbols via `let`- and `mutable`-statements. 
Such bindings provide a convenient way to access a value via the defined handle. 
Despite the somewhat misleading terminology, borrowed from other languages, we will call handles that are declared on a local scope and contain values *variables*.
The reason that this may be somewhat misleading is that `let`-statements define "single-assignment handles", i.e. handles that for the duration of their validity will always be bound to the same value. Variables that can be re-bound to different values at different points in the code need to be explicitly declared as such, as specific by the `mutable`-statement. 

```qsharp
    let var1 = 3; 
    mutable var2 = 3; 
    set var2 = var2 + 1; 
```

Line 1 declares a variable named `var1` that cannot be reassigned and will always contain the value `3`. Line 2 on the other hand defines a variable `var2` that is temporarily bound to the value `3`, but can be reassigned to a different value later on. Such a reassignment can be done via a `set`-statement, as shown in Line 3. The same could have been expressed with the shorter version `set var2 += 1;` explained further [below](#evaluate-and-reassign-statements), as it is common in other languages as well. 

To summarize:
* `let` is used to create an immutable binding.
* `mutable` is used to create a mutable binding.
* `set` is used to change the value of a mutable binding.

For all three statements, the left hand side consists of a symbol or a symbol tuple;
i.e. if the right-hand side of the binding is a tuple, then that tuple may be fully or partially deconstructed upon assignment. The only requirement for deconstruction is that the shape of the tuple on the right hand side matches the shape of the symbol tuple.
The symbol tuple may contain nested tuples and/or omitted symbols, indicated by an underscore. 
For example:

```qsharp
let (a, (_, b)) = (1, (2, 3)); // a is bound to 1, b is bound to 3
mutable (x, y) = ((1, 2), [3, 4]); // x is bound to (1, 2), y is bound to [3, 4]
set (x, _, y) = ((5, 6), 7, [8]);  // x is re-bound to (5,6), y is re-bound to [8]
```

The same deconstruction rules are obeyed by all assignments in Q#, including, e.g., qubit allocations and loop-variable assignments. 

For both kinds of binding, the types of the variables are inferred from the right-hand side of the binding. The type of a variable always remains the same and a `set`-statement cannot change it.
Local variable can be declared as either being mutable or immutable, with some exceptions like loop-variables in `for`-loops for which the behavior is predefined and cannot be specified.
Function and operation arguments are always immutably bound; in combination with the lack of reference types, as discussed in the section on [immutability](xref:microsoft.quantum.qsharp.immutability#immutability), that means that a called function or operation can never change any values on the caller side. 
Since the states of `Qubit` values are not defined or observable from within Q#, this does not preclude the accumulation of quantum side effects, that are observable (only) via measurements (see also [this section](xref:microsoft.quantum.qsharp.quantumdatatypes#qubits)).

Independent on how a value is bound, the values themselves are immutable. 
This in particular also holds for arrays and array items. 
In contrast to popular classical languages where arrays often are reference types, arrays - like all type - are value types in Q# and always immutable; they cannot be modified after initialization.
Changing the values accessed by variables of array type thus requires explicitly constructing a new array and reassigning it to the same symbol, see also the section on [immutability](xref:microsoft.quantum.qsharp.immutability) and [copy-and-update expressions](xref:microsoft.quantum.qsharp.copyandupdateexpressions#copy-and-update-expressions) for more details.

## Evaluate-and-Reassign Statements

Statements of the form `set intValue += 1;` are common in many other languages. Here, `intValue` needs to be a mutably bound variable of type `Int`.
Such statements provide a convenient way of concatenation if the right hand side consists of the application of a binary operator and the result is to be rebound to the left argument to the operator. 
For example,
```qsharp
mutable counter = 0;
for i in 1 .. 2 .. 10 {
    set counter += 1;
    // ...
}
```
increments the value of the counter `counter` in each iteration of the `for` loop. The code above is equivalent to 
```qsharp
mutable counter = 0;
for i in 1 .. 2 .. 10 {
    set counter = counter + 1;
    // ...
}
```

Similar statements exist for a wide range of [operators](xref:microsoft.quantum.qsharp.precedenceandassociativity#operators). The `set` keyword in this case needs to be followed by a single mutable variable, which is inserted as the left-most sub-expression by the compiler.
Such evaluate-and-reassign statements exist for all operators where the type of the left-most sub-expression matches the expression type. 
More precisely, they are available for binary logical and bitwise operators including right and left shift, for arithmetic expressions including exponentiation and modulus, for concatenations, as well as for [copy-and-update expressions](xref:microsoft.quantum.qsharp.copyandupdateexpressions#copy-and-update-expressions).

The following function for example computes the sum of an array of [`Complex`](xref:microsoft.quantum.qsharp.typedeclarations#type-declarations) numbers:

```qsharp
function ComplexSum(values : Complex[]) : Complex {
    mutable res = Complex(0., 0.);
    for complex in values {
        set res w/= Re <- res::Re + complex::Re;
        set res w/= Im <- res::Im + complex::Im;
    }
    return res;
}
```

Similarly, the following function multiplies each item in an array with the given factor:

```qsharp
function Multiplied(factor : Double, array : Double[]) : Double[] {
    mutable res = new Double[Length(array)];
    for i in IndexRange(res) {
        set res w/= i <- factor * array[i];
    }
    return res;
}
```


The section on [contextual expressions](xref:microsoft.quantum.qsharp.contextualexpressions#contextual-and-omitted-expressions) contains other examples where expressions can be omitted in a certain context when a suitable expression can be inferred by the compiler.



