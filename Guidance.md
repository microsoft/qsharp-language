# Good Practices and Considerations

There are a couple of things we want to be mindful of when making design decisions for the Q# language and core libraries, such as 
- the ease of adoption
- the benefit over time
- the cost of implementation
- alternative approaches
- ...

The considerations listed in this document are by no means exhaustive, but they give a first impression of what we factor into our considerations. For the API design of the core libraries, please also take a look at the style guide. 

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