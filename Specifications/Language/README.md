# Q# Language

Q# is part of Microsoft's [Quantum Development Kit](http://www.microsoft.com/quantum), and comes with rich IDE support and tools for program visualization and analysis.
Our goal is to support the development of future large-scale applications while also allowing to execute first efforts in that direction on current quantum hardware. 

The type system permits to safely interleave and naturally represent the composition of classical and quantum computations. A Q# program may express arbitrary classical computations based on quantum measurements that are to be executed while qubits remain live, meaning they are not released and maintain their state. Even though the full complexity of such computations requires further hardware development, Q# programs can be targeted to execute on various quantum hardware backends in [Azure Quantum](https://azure.microsoft.com/services/quantum/).

Q# is a stand-alone language offering a high level of abstraction;
there is no notion of a quantum state or a circuit; instead, 
programs are implemented in terms of statements and expressions, much like in classical programming languages. Distinct quantum capabilities such as support for functors and control-flow constructs that are commonly used in quantum algorithms like, e.g., repeat-until-success loops facilitate expressing for instance phase estimation and quantum chemistry algorithms.


## Index

1. [Program Structure](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/1_ProgramStructure)    
1.1 [Namespaces](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/1_Namespaces.md)    
1.2 [Type Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/2_TypeDeclarations.md)    
1.3 [Callable Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/3_CallableDeclarations.md)    
1.4 [Specialization Declarations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/4_SpecializationDeclarations.md)    
1.5 [Attributes](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/5_Attributes.md)    
1.6 [Access Modifiers](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/1_ProgramStructure/6_AccessModifiers.md)

2. [Statements](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/2_Statements)    
2.1 [Call Statements](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/CallStatements.md)    
2.2 [Returns and Termination](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ReturnsAndTermination.md)    
2.3 [Variable Declaration \& Reassignment](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/VariableDeclarationsAndUpdates.md)    
2.4 [Iterations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Iterations.md)    
2.5 [Conditional Loops](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalLoops.md)    
2.6 [Conditional Branching](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/ConditionalBranching.md)    
2.7 [Conjugations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/Conjugations.md)    
2.8 [Quantum Memory Management](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md)

3. [Expressions](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/3_Expressions)    
3.1 [Precedence \& Associativity](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md)    
3.2 [Operators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#operators)    
    3.2.1 [Copy-and-Update Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/CopyAndUpdateExpressions.md)   
    3.2.2 [Conditional Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ConditionalExpressions.md)    
    3.2.3 [Comparative Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ComparativeExpressions.md)    
    3.2.4 [Logical Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/LogicalExpressions.md)    
    3.2.5 [Bitwise Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/BitwiseExpressions.md)  
    3.2.6 [Arithmetic Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ArithmeticExpressions.md)   
    3.2.7 [Concatenations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/Concatentation.md)    
3.3 [Modifiers \& Combinators](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PrecedenceAndAssociativity.md#modifiers-and-combinators)    
3.3.1 [Partial Application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/PartialApplication.md)    
3.3.1 [Functor Application](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/FunctorApplication.md)    
3.3.1 [Item Access Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ItemAccessExpressions.md)   
3.4 [Contextual Expressions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/3_Expressions/ContextualExpressions.md)   

4. [Type System](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language/4_TypeSystem)    
4.1 [Operations \& Functions](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/OperationsAndFunctions.md)    
4.2 [Quantum Data Types](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/QuantumDataTypes.md)  
4.3 [Immutability](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/Immutability.md)    
4.4 [Singleton Tuple Equivalence](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SingletonTupleEquivalence.md)   
4.5 [Subtyping and Variance](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/SubtypingAndVariance.md)    
4.6 [Type Parameterizations](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/TypeParameterizations.md)    
4.7 [Type Inference](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/4_TypeSystem/TypeInference.md)
