# Q# Language

Q# is part of Microsoft's [Quantum Development Kit](https://www.microsoft.com/quantum) and provides rich IDE support and tools for program visualization and analysis.
Our goal is to support the development of future large-scale applications while supporting user's first efforts in that direction on current quantum hardware. 

The type system permits Q# programs to safely interleave and naturally represent the composition of classical and quantum computations. A Q# program may express arbitrary classical computations based on quantum measurements that execute while qubits remain live, meaning they are not released and maintain their state. Even though the full complexity of such computations requires further hardware development, Q# programs can be targeted to run on various quantum hardware backends in [Azure Quantum](https://azure.microsoft.com/services/quantum/).

Q# is a stand-alone language offering a high level of abstraction. 
There is no notion of a quantum state or a circuit; instead, 
Q# implements programs in terms of statements and expressions, much like classical programming languages. Distinct quantum capabilities (such as support for functors and control-flow constructs) facilitate expressing, for example, phase estimation and quantum chemistry algorithms.


## Index


1. [Program Structure](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/1_ProgramStructure#program-execution)
    1. [Namespaces](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/1_Namespaces.md#namespaces)
    1. [Type Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md#type-declarations)
    1. [Callable Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md#callable-declarations)
    1. [Specialization Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md#specialization-declarations)
    1. [Attributes](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/5_Attributes.md#attributes)
    1. [Access Modifiers](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/6_AccessModifiers.md#access-modifiers)
    1. [Comments & Documentation](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/7_Comments.md#comments)

1. [Statements](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/2_Statements#statements)
    1. [Quantum Memory Management](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md#quantum-memory-management)
    1. [Conditional Branching](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalBranching.md#conditional-branching)
    1. [Conditional Loops](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalLoops.md#conditional-loops)
    1. [Iterations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Iterations.md#iterations)
    1. [Conjugations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Conjugations.md#conjugations)
    1. [Call Statements](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md#call-statements)
    1. [Returns and Termination](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ReturnsAndTermination.md#returns-and-termination)
    1. [Variable Declaration \& Reassignment](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndReassignments.md#variable-declarations-and-reassignments)
    1. [Visibility of Local Variables](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/BindingScopes.md#visibility-of-local-variables)


1. [Expressions](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/3_Expressions#expressions)
    1. [Precedence \& Associativity](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#precedence-and-associativity)
    2. [Operators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#operators)
        1. [Copy-and-Update Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md#copy-and-update-expressions)
        1. [Conditional Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ConditionalExpressions.md#conditional-expressions)
        1. [Comparative Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md#equality-comparison)
        1. [Logical Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/LogicalExpressions.md#logical-expressions)
        1. [Bitwise Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md#bitwise-expressions)
        1. [Arithmetic Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md#arithmetic-expressions)
        1. [Concatenations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Concatentation.md#concatenation)
    1. [Modifiers \& Combinators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#modifiers-and-combinators)
        1. [Partial Application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PartialApplication.md#partial-application)
        1. [Functor Application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/FunctorApplication.md#functor-application)
        1. [Item Access Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md#item-access)
    1. [Contextual Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md#contextual-and-omitted-expressions)
    1. [Value Literals](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ValueLiterals.md#literals) \& [Default Values](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ValueLiterals.md#default-values)
    1. [Identifiers](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Identifiers.md#identifiers)


1. [Type System](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem#type-system)
    1. [Operations \& Functions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/OperationsAndFunctions.md#operations-and-functions)
    1. [Quantum Data Types](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md#quantum-specific-data-types)
    1. [Immutability](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md#immutability)
    1. [Singleton Tuple Equivalence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md#singleton-tuple-equivalence)
    1. [Subtyping and Variance](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SubtypingAndVariance.md#subtyping-and-variance)
    1. [Type Parameterizations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/TypeParameterizations.md#type-parameterizations)
    1. [Type Inference](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/TypeInference.md#type-inference)

1. [Grammar](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/5_Grammar#grammar)
