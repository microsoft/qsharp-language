# Considerations and Guidelines

There are several considerations that factor into design decisions for the Q# language and core libraries. The ease of adoption, the benefit over time, the cost of implementation and maintenance, alternative approaches, etc. are but a few examples.
Rather than attempting to compile an exhaustive list, we present some rough guidelines that may give a first impression for things we want to be mindful of. For the API design of the core libraries, please also take a look at the [style guide](https://github.com/microsoft/qsharp-language/tree/main/CoreLibraries). 

## Try to

- Maximize the utility of a new feature and syntax 
- Develop features that are useful for a wide range of use cases and audiences
- Evolve the language in a predictable manner; consider how a feature will evolve with future versions of Q# 
- Enhance consistency, intuitiveness, and readability
- Enable modularity and encapsulation
- Be mindful of how a feature can be executed on quantum hardware
- Reduce the development effort and burden on the developer
- ...

## Avoid

- Introducing functionality that cannot be supported on quantum hardware unless it serves debugging purposes
- Requiring the developer to be familiar with the details of the quantum hardware architecture
- Deferring errors until runtime 
- Introducing multiple ways to achieve the same thing
- Making breaking changes
- Suggesting features that are slight variations of features that have been declined previously
- ...
