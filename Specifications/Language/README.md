# Q# Language

Q# is part of Microsoft's [Quantum Development Kit](https://www.microsoft.com/quantum), and comes with rich IDE support and tools for program visualization and analysis.
Our goal is to support the development of future large-scale applications while also allowing to execute first efforts in that direction on current quantum hardware. 

The type system permits to safely interleave and naturally represent the composition of classical and quantum computations. A Q# program may express arbitrary classical computations based on quantum measurements that are to be executed while qubits remain live, meaning they are not released and maintain their state. Even though the full complexity of such computations requires further hardware development, Q# programs can be targeted to execute on various quantum hardware backends in [Azure Quantum](https://azure.microsoft.com/services/quantum/).

Q# is a stand-alone language offering a high level of abstraction;
there is no notion of a quantum state or a circuit; instead, 
programs are implemented in terms of statements and expressions, much like in classical programming languages. Distinct quantum capabilities such as support for functors and control-flow constructs that are commonly used in quantum algorithms like, e.g., repeat-until-success loops facilitate expressing for instance phase estimation and quantum chemistry algorithms.


