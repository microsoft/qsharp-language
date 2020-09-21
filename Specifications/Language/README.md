# Q# Language

Q# is part of Microsoft's [Quantum Development Kit](http://www.microsoft.com/quantum), and comes with rich IDE support and tools for program visualization and analysis.
Our goal is to support the development of future large-scale applications while also allowing to execute first efforts in that direction on current quantum hardware. 

The type system permits to safely interleave and naturally represent the composition of classical and quantum computations. A Q# program may express arbitrary classical computations based on quantum measurements that are to be executed while qubits remain live, meaning they are not released and maintain their state. Even though the full complexity of such computations requires further hardware development, Q# programs can be targeted to execute on various quantum hardware backends in [Azure Quantum](https://azure.microsoft.com/services/quantum/).

Q# is a stand-alone language offering a high level of abstraction;
there is no notion of a quantum state or a circuit; instead, 
programs are implemented in terms of statements and expressions, much like in classical programming languages. Distinct quantum capabilities such as support for functors and control-flow constructs that are commonly used in quantum algorithms like, e.g., repeat-until-success loops facilitate expressing for instance phase estimation and quantum chemistry algorithms.


## Index


1. [Program Structure](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/1_ProgramStructure)
    1. [Namespaces](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/1_Namespaces.md)
    1. [Type Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md)
    1. [Callable Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md)
    1. [Specialization Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md)
    1. [Attributes](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/5_Attributes.md)
    1. [Access Modifiers](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/6_AccessModifiers.md)

1. [Statements](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/2_Statements)
    1. [Call Statements](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md)
    1. [Returns and Termination](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ReturnsAndTermination.md)
    1. [Variable Declaration \& Reassignment](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndUpdates.md)
    1. [Iterations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Iterations.md)
    1. [Conditional Loops](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalLoops.md)
    1. [Conditional Branching](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalBranching.md)
    1. [Conjugations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Conjugations.md)
    1. [Quantum Memory Management](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md)

1. [Expressions](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/3_Expressions)
    1. [Precedence \& Associativity](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md)
    2. [Operators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#operators)
        1. [Copy-and-Update Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md)
        1. [Conditional Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ConditionalExpressions.md)
        1. [Comparative Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md)
        1. [Logical Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/LogicalExpressions.md)
        1. [Bitwise Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md)
        1. [Arithmetic Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md)
        1. [Concatenations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Concatentation.md)
    1. [Modifiers \& Combinators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#modifiers-and-combinators)
        1. [Partial Application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PartialApplication.md)
        1. [Functor Application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/FunctorApplication.md)
        1. [Item Access Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md)
    1. [Contextual Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md)
    1. [Value Literals](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ValueLiterals.md) \& [Default Values](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ValueLiterals.md#default-values)
    1. [Identifiers](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Identifiers.md)


1. [Type System](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem)
    1. [Operations \& Functions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/OperationsAndFunctions.md)
    1. [Quantum Data Types](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md)
    1. [Immutability](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md)
    1. [Singleton Tuple Equivalence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md)
    1. [Subtyping and Variance](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SubtypingAndVariance.md)
    1. [Type Parameterizations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/TypeParameterizations.md)
    1. [Type Inference](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/TypeInference.md)

