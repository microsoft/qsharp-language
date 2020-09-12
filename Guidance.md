# Considerations and Guidelines

There are several considerations that factor into design decisions for the Q# language and core libraries. The ease of adoption, the benefit over time, the cost of implementation, alternative approaches, etc. are but a few examples.
Rather than attempting to compile an exhaustive list, we present some rough guidelines that may give a first impression for things we want to be mindful of. For the API design of the core libraries, please also take a look at the [style guide](https://github.com/microsoft/qsharp-language/tree/main/CoreLibraries). 

## Try to
- Be mindful of the design space
- Evolve the language in a predictable manner
- Develop features that are useful for a wide range of audience
- Support the growth of an ecosystem that can power a wide range of applications
- Enhance consistency, intuitiveness, and readability
- Enable modularity and encapsulation
- Facilitate classical-quantum communication and be mindful of the execution on quantum hardware
- Reduce the development effort and burden on the developer
- ...

## Avoid to

- Introduce functionality that cannot be supported on quantum hardware unless it serves debugging purposes
- Require the developer to be familiar with the details of the quantum hardware architecture
- ...
