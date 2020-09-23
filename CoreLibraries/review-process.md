# Introduction

This page defines the Q# API design review process, used to help review API proposals for consistency with the [Q# API Design Principles](https://docs.microsoft.com/quantum/resources/contributing/api-design-principles).

## Scope

The API design review process includes and addresses the following:

- New Q# library designs (i.e.: new namespace and/or package)
- Major new Q# library features
- Significant refactoring of existing Q# libraries

Code and API designs covered by this process may be in any public repository that includes Q# APIs. In particular:

- microsoft/qsharp-runtime (i.e.: subsets implementing QSharpCore)
- microsoft/QuantumLibraries
- microsoft/Quantum-NC

## Out of Scope

This document does not include and does not address:

- Q# applications not intended for use as libraries (NB: the Q# style guide still applies even to Q# applications without an API surface). For example, samples, katas, and other documentation code are not affected by this proposal, as design changes can be made without breaking user code.
- Fixes and improvements to Q# libraries made directly through GitHub pull requests that do not include API changes. Note that even small changes to API surface may be in scope, however.

## Principles

- **Consistency with design principles**: All Q# APIs and library designs produced through this process will be consistent with established [API design principles](https://docs.microsoft.com/quantum/resources/contributing/api-design-principles).

- **Transparency**: Decisions about Q# APIs and library designs will be traceable to help members of the quantum development community understand motivations and principles behind the Quantum Development Kit product.

- **User-driven**: Decisions about Q# API and library designs will be motivated by user needs, and offering the best user experience possible. The decision-making process will explicitly take into account user feedback, as well as the impact of breaking user code, weighing that impact against potential improvements that can be enabled via breaking changes.

- **Creative disagreement**: Providing input and feedback will not mean that suggestions and designs are automatically adopted. The libraries team will retain final say over Q# API designs and will work through this process to ensure that all disagreements are respectful and creative in nature.

- **Inclusive**: In keeping with the [Microsoft Open Source Code of Conduct](https://microsoft.github.io/codeofconduct/), this process will not tolerate discriminatory and exclusive behavior. Participants that act in contravention to the Code of Conduct will not be allowed to continue providing feedback or joining discussions.

## Process
### API Review Meeting
Early in each monthly release cycle, the libraries team will convene a 90-minute meeting. API designs for major refactoring of existing libraries, for major new library features, or for new libraries will be reviewed for adherence to design principles, and notes will be recorded on the result of this review and discussion. As time allows, these meetings will also consider future and early-stage proposals for new libraries, features, and refactorings.

### Broad Feedback Period
Notes from each meeting will be published as to reflect consensus thinking. The pull request for each new meeting summary will be used to collect discussions and feedback from internal and external members of the quantum development community.
