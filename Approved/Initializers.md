<!-- 
title: Initializers for qubit allocations
description: Allows to initialize types containing qubits and qubits to a certain state
author: Bettina Heim
date: 10/03/2020
-->

# Proposal

The proposal is to introduce a more general notion of initializers for qubit allocations. It achieves to support three important functionalities as part of using- and borrowing statements:
- Creating instances of user defined types containing qubits
- Initializing the allocated qubits with a certain operation upon allocation
- Automatic allocation and de-allocation of temporary qubits used during initialization

# Justification

The current qubit allocation is limited. While all of the three bullets above can be achieved with the current support, expressing them is somewhat verbose. This proposal introduces a much more convenient and readable syntax and automation around these scenarios. 

The proposed modification allows for nesting of initializers; i.e. the initialized values can be used as part of other initializers in the same allocation, making it possible to automatically manage temporary qubit values that are only used as part of the initialization. 

Furthermore, this proposal makes it possible to support defining custom constructors for user defined types that contain qubits, without requiring that the necessary qubits are passed as arguments to the constructor.    

# Description

This proposal formalizes/introduces a couple of concepts that are outlined in the following. See [this section](#overview-over-different-kinds-of-initializer-expressions) for an overview based on examples of the different kinds of initializers and initializer expressions.

### *Allocatable types*:   
A type is allocatable if it either is one of the built-in allocatable types, or if it contains one or more items which are allocatable. There are two built-in allocatable types: the type Qubit and the type Qubit[], or more generally n-dimensional rectangular Qubit arrays (as suggested [here](https://github.com/microsoft/qsharp-language/issues/39)). 

### *Initializers for allocatable types*:    
Initializers are special callables that return values of an allocatable type. Initializers are *neither* operations nor functions. They are their own distinct type with no subtyping relation to operation or function types; they cannot be used when a value of operation or function type is required. Initializers can only be used as part of [qubit allocation statements](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/2_Statements/QuantumMemoryManagement.md#quantum-memory-management).   
In addition to the built-in and compiler-generated default initializers for allocatable types described in the next paragraph, in the future it would make sense to allow to define custom initializer as part of a type declaration, much like custom constructors (not currently supported). 

### *Automatically generated initializers*:  
There are two built-in initializers; one for allocating a single qubit, and one for allocating an (n-dimensional) array of qubits. See the table below for details.   
Additionally, a default initializer based on the default constructor is generated automatically for each defined allocatable type. That initializer has the same name as the type. Its argument is constructed by replacing the type of each allocatable item in the constructor with the argument type of the corresponding default initializer. The initializer returns an initialized value by first invoking the default initializer for each allocatable item with the corresponding argument and then invoking the default constructor with the constructed argument. 

### *Custom initializers for user defined types:*    
Support for defining custom initializers for user defined types is intended to be added if and when custom constructors can be defined. Important considerations for what can and cannot be supported for such custom initializers, however, are part of this proposal to ensure that the proposed additions can be extended to cover that scenario as well.    
In contrast to operations, initializers allocate and return qubits that remain live after their execution terminates. Such qubits are allocated via a dedicated statement, consisting of the keyword `initialize` followed by a symbol or symbol tuple, an equals sign `=`, and either an initializer or an initializer tuple.      
Initializers may thus call other initializers, but they cannot be directly or indirectly recursive. Furthermore, they are not allowed to call operations, or allocate temporary qubits that are released when the initializer terminates. If a common usage of the type requires contained qubits to be initialized to a certain state, then a suitable operation that can be elevated to an initializer expression should be defined instead. 
Custom initializers take an argument of an arbitrary type, provided it does not contain items of allocatable types. This restriction makes it possible to safely allocate and de-allocate temporary qubits when nesting initializer expressions (see the paragraph further below). 

### *Creating initializers on the fly by elevating operations*:   
Since it is a common scenario to initialize qubits to a certain state, this proposal includes the means to construct initializers on the fly that do just that. There are two distinct cases that are common. 
1. One is that an operation should be invoked on the allocated qubits after initialization, followed by further computations before the qubits are measured and released. In this case, it is not necessary or desirable that the operation performed upon initialization is un-computed upon release. 
2. In the second case, the computations following the initialization lead to the qubits being in the same state as they were initialized. In this case, the adjoint of the operation used for initialization needs to be applied upon releasing the qubits. 

The proposal is to syntactically distinguish the two cases. The table below contains examples for both cases. In the first case, the initializer consists of the keyword `init`, followed by the initializer argument tuple, the keyword `then` and an operation-valued expression. The initializer argument tuple may be omitted if the required argument is of type `Unit`. The second case follows the same pattern with the exception that instead of the keyword `then`, then keyword `within` should be used, and the operation-valued expression needs to support the `Adjoint` functor.   
In both cases, the elevated operation has to return `Unit`.
The allocated value matches the argument of the elevated operation and will be bound to the symbol(s) specified on the left hand side of the allocation statement.  

### *Initializer expressions and nesting of initializers*:    
An initializer expressions consists either of a call to an initializer, or of a tuple of multiple calls. ...

### Overview over different kinds of initializer expressions

Initializers for built-in types:
| Built-in Initializer | Description | Allocated Type | Initializer Argument Type | Initializer Expression | 
| --- | --- | --- | --- | --- |
| Qubit | allocates a single qubit | `Qubit` | `Unit` | `Qubit()` |
| Qubits | allocates a 1D array of qubits | `Qubit[]` | `Int` | `Qubits(4)` |
| Qubits | allocates a [2D array](https://github.com/microsoft/qsharp-language/issues/39) of qubits | `Qubit[,]` | `(Int, Int)` | `Qubits(2,4)` |

Generated default initializers for custom types:
| Allocated Type | Type of Contained Items | Initializer Argument Type | Initializer Expression |
| --- | --- | --- | --- |
| BigEndian | `Qubit[]` | `Int` | `BigEndian(4)` |
| QubitArray | `(Int, Qubit[])` | `(Int, Int)` | `QubitArray(4, 4)` |

Initializers built by elevating operations:
| Operation Valued Expression | Allocated Type | Initializer Argument Type | Initializer Expression | Uncompute upon Release |
| --- | --- | --- | --- | --- |
| `H` | `Qubit` | `Unit` | `init within H` | Yes |
| `Reset` | `Qubit` | `Int` | `init then Reset` | No |
| `ApplyToEachA(H, _)` | `Qubit[]` | `Int` | `init(3) within ApplyToEachA(H, _)` | Yes |
| `ApplyToEach(H, _)` | `Qubit[]` | `Int` | `init(3) then ApplyToEach(H, _)` | No |

## Current Status

TODO:   
Describe all aspects of the current version of Q# that will be impacted by the proposed modification.     
Describe in detail the current behavior or limitations that make the proposed change necessary.      
Describe how the targeted functionality can be achieved with the current version of Q#.    
Refer to the examples given below to illustrate your descriptions. 

### Examples

Example 1:    
TODO: insert title and caption

```qsharp
// TODO: 
// Insert code example that illustrates what is described above.
// Comment your code to further elaborate and clarify the example.

```
TODO:   
Add more examples following the structure above. 

## Proposed Modification

TODO:    
Describe how the proposed modification changes the behavior and/or syntax described in [Current Status](#current-status).   
Describe in detail how the proposed modification is supposed to behave how it is supposed to be used.    
Describe in detail any impact on existing code and how to interpret all new language structures.    
Refer to the code examples below to illustrate your descriptions. 

### Examples

Example 1:    
TODO: insert title and caption

```qsharp
// TODO: 
// Insert code example that illustrates what is described above.
// Comment your code to further elaborate and clarify the example.

```
TODO:   
Add more examples following the structure above. 

# Implementation

TODO:    
Describe how the made proposal could be implemented and why it should be implemented in this way.    
Be specific regarding the efficiency, and potential caveats of such an implementation.    
Based on that description a user should be able to determine when to use or not to use the proposed modification and how.

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

TODO:    
Explain alternative mechanisms that would serve a similar purpose as the proposed modification.    
For each one, discuss what the implications are for the future development of Q#.

## Comparison to Alternatives

TODO:    
Compare your proposal to the possible alternatives and compare the advantages and disadvantages of each approach. 
Compare in particular their impact on the future development of Q#. 

# Raised Concerns

Any concerns about the proposed modification will be listed here and can be addressed in the [Response](#response) section below. 

## Response 

