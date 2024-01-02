# Q# Language

Q# is part of Microsoft's [Quantum Development Kit](https://www.microsoft.com/quantum) and provides rich IDE support and tools for program visualization and analysis.
Our goal is to support the development of future large-scale applications while supporting user's first efforts in that direction on current quantum hardware.

The type system permits Q# programs to safely interleave and naturally represent the composition of classical and quantum computations. A Q# program may express arbitrary classical computations based on quantum measurements that execute while qubits remain live, meaning they are not released and maintain their state. Even though the full complexity of such computations requires further hardware development, Q# programs can be targeted to run on various quantum hardware backends in [Azure Quantum](https://azure.microsoft.com/services/quantum/).

Q# is a stand-alone language offering a high level of abstraction. There is no notion of a quantum state or a circuit; instead, Q# implements programs in terms of statements and expressions, much like classical programming languages. Distinct quantum capabilities (such as support for functors and control-flow constructs) facilitate expressing, for example, phase estimation and quantum chemistry algorithms.

