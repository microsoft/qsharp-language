# Variable declarations and reassignments

Values can be bound to symbols using the `let` and `mutable` statements. 
These kinds of bindings provide a convenient way to access a value via the defined handle. 
Despite the misleading terminology borrowed from other languages, handles declared on a local scope and containing values are called *variables*.
This may be misleading because `let` statements define *single-assignment handles*, which are handles that remain bound to the same value for the duration of their validity. Variables that can be re-bound to different values at different points in the code need to be explicitly declared as such, and are specified using the `mutable` statement. 

```qsharp
    let var1 = 3; 
    mutable var2 = 3; 
    set var2 = var2 + 1; 
```

In this example, the `let` statement declares a variable named `var1` that cannot be reassigned and always contains the value `3`. The `mutable` statement defines a variable `var2` that is temporarily bound to the value `3` but can be reassigned to a different value later on using a `set` statement, as shown in the last line. You can express the same statement with the shorter version `set var2 += 1;`, as is common in other languages. For more information, see [Evaluate and reassign statements](#evaluate-and-reassign-statements).

To summarize:

* `let` is used to create an immutable binding.
* `mutable` is used to create a mutable binding.
* `set` is used to change the value of a mutable binding.

For all three statements, the left-hand side consists of a symbol or a symbol tuple.
If the right-hand side of the binding is a tuple, then that tuple may be fully or partially deconstructed upon assignment. The only requirement for deconstruction is that the shape of the tuple on the right-hand side matches the shape of the symbol tuple on the left side.
The symbol tuple may contain nested tuples or omitted symbols, or both, indicated by an underscore. 
For example:

```qsharp
let (a, (_, b)) = (1, (2, 3)); // a is bound to 1, b is bound to 3
mutable (x, y) = ((1, 2), [3, 4]); // x is bound to (1, 2), y is bound to [3, 4]
set (x, _, y) = ((5, 6), 7, [8]);  // x is re-bound to (5,6), y is re-bound to [8]
```

All assignments in Q# obey the same deconstruction rules, including, for example, qubit allocations and loop-variable assignments. 

For both kinds of bindings, the types of the variables are inferred from the right-hand side of the binding. The type of a variable always remains the same, and a `set` statement cannot change it.
Local variables can be declared as either being mutable or immutable. There are some exceptions, such as loop-variables in `for` loops, where the behavior is predefined and cannot be specified.
Function and operation arguments are always immutably bound. In combination with the lack of reference types, as discussed in the [Immutability](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md#immutability) topic, this means that a called function or operation can never change any values on the caller side. 

Since the states of `Qubit` values are not defined or observable from within Q#, this does not preclude the accumulation of quantum side effects, which are observable only via measurements. For more information, see [Quantum data types](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md#qubits)).

Independent of how a value is bound, the values themselves are immutable. 
In particular, this is true for arrays and array items. 
In contrast to popular classical languages where arrays often are reference types, arrays in Q# - like all types - are value types and always immutable; that is, you cannot modify them after initialization.
Changing the values accessed by array-type variables thus requires explicitly constructing a new array and reassigning it to the same symbol. For more information, see [Immutability](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md) and [Copy and update expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions).

## Evaluate-and-reassign statements

Statements of the form `set intValue += 1;` are common in many other languages. Here, `intValue` needs to be a mutably bound variable of type `Int`.
Such statements provide a convenient way of concatenation if the right-hand side consists of applying a binary operator and the result is rebound to the left argument of the operator. 
For example, this code segment

```qsharp
mutable counter = 0;
for i in 1 .. 2 .. 10 {
    set counter += 1;
    // ...
}
```

increments the value of the counter `counter` in each iteration of the `for` loop and is equivalent to

```qsharp
mutable counter = 0;
for i in 1 .. 2 .. 10 {
    set counter = counter + 1;
    // ...
}
```

Similar statements exist for a wide range of [operators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#operators). The `set` keyword in such evaluate-and-reassign statements must be followed by a single mutable variable, which is inserted as the left-most sub-expression by the compiler.
Such evaluate-and-reassign statements exist for all operators where the type of the left-most sub-expression matches the expression type. 
More precisely, they are available for binary logical and bitwise operators including right and left shift, arithmetic expressions including exponentiation and modulus, and concatenations, as well as [copy-and-update expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions).

The following function example computes the sum of an array of [`Complex`](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md#type-declarations) numbers:

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

For more information, see [Contextual expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions), which contains other examples where expressions can be omitted in a specific context when a suitable expression can be inferred by the compiler.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
