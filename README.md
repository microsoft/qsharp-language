# Q# Language and Core Libraries Design

Welcome to the official repository for design of the Q# language and core libraries. This is where new Q# features are developed and specified, and where you can share ideas and suggestions about the future evolution of the Q# language and core libraries.

Q# is designed by the Q# Language Design Team in collaboration with many contributors, partners, and the Quantum Systems team at Microsoft.

## Contributing

Suggestions for features and adaptions are filed and tracked in the form of issues on this repository. 
We greatly appreciate your feedback and contribution to the discussion in the form of comments and votes on open issues. Better understanding the needs of the community will help us make better decisions. 

If you have a suggestion for a feature and would like to share your thoughts, we encourage you to file an issue following our suggestion template. The [following section](#process-&-implementation) describes the process and workflow in more detail. For a suggestion to be adopted it needs to align with the general vision for Q# and the Q# language [design principles](#design-principles). We do not generally revisit design decisions that have been made unless there is new information to consider, e.g. due to scientific or technical breakthroughs. 

We also highly welcome contributions to help implement new features. Please take a look at the section on [implementation](#implementation) for information regarding how to engage.   

We refer to this document regarding contributing and the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).

# Design Principles

A multitude of aspects ultimately factor into the decision to pursue a certain design direction. Given the early stages of quantum computing and the uncertainty around the architecture of future quantum hardware, designing a high-level language is challenging. Nonetheless, we believe it is worth the effort.  
The following list may give some insight into the principles guiding the Q# language design:

1.	**Q# is hardware agnostic.**    
We strive to design a language that provides the means to express and leverage powerful quantum computing concepts independent on how hardware evolves in the future. 

2.	**Q# is designed to scale to the full range of quantum applications.**    
To be useable across a wide range of applications, Q# allows to build reusable components and layers of abstractions. To achieve performance with growing quantum hardware size we need automation. We want to ensure the scalability of both applications and development effort. 

3.	**Q# is meant to make quantum solutions accessible and shareable across disciplines.**    
We are designing Q# to enable people to collaborate across disciplines, to make it easy to build on knowledge and share ideas, independent of background or education. 

4.	**Q# is focused on expressing information to optimize execution.**    
Our goal is to ensure an efficient execution of quantum components, independent of the context within which they are invoked. Q# allows the developer to communicate their knowledge about a computation so that the compiler can make an informed decision regarding how to translate it into instructions, leveraging information about the end-to-end application that is not available to the developer. 

5.	**Q# is a living body of work that will grow and evolve over time.**    
We share a vision of how quantum devices will revolutionize computing in the future. We also believe the quantum stack of the future will go beyond our current imagination. Correspondingly, our vision for Q# will adapt and change as the technology advances.

In addition to these principles, we try to adhere to a general set of good practices, and there are other aspects to consider that factor into a decision whether to pursue a certain feature. Please take a look at this document for a more detailed list of considerations. We also refer to our FAQs for further questions. 

## Process & Implementation

The development of a language feature consists of the following stages:

### *Suggestion:*
An addition or modification to the Q# language starts with a suggestion. A suggestion is filed as issue on this repository following the suggestion template.     
Once a suggestion has been filed, it will be discussed on the issue, resulting in a first conclusion regarding whether to further pursue it. It will be tagged either with `UnderReview` or `Declined` by the Language Design Team depending on the outcome.    
This stage should be fairly quick and will take a couple of weeks to a month or two. If a conclusion can't be reached at this time, e.g. because it is not clear that it can be supported by hardware or it depends on other features that are currently under development, it will be tagged with `OnHold`.

### *Review:*
Once a feature is tagged as `UnderReview`, the next step is to work out a more detailed proposal for how the feature should look like. Such a proposal is made by filling out the proposal template. For the purpose of discussion and collaboration when working out the details, and for us to give early feedback, we encourage to make a draft PR early on even when the template is not yet fully filled in. Once the template is sufficiently filled in, the PR is published and will be reviewed.     
Based on full proposal, the issue with the suggestion will either be tagged with `ApprovedInPrinciple` and the proposal is merged into the Approved folder, or it will be tagged with `Declined` and the PR is merged into the Declined folder for archiving purposes. The issue itself will be closed.     
How long it takes to work out the full proposal can vary a lot depending on the functionality. 

### *Implementation:*
All proposals that have been approved in principle and are ready to be implemented can be found in the Approved folder. When implementation starts, a new issue is created using the implementation template to track the progress. These issues are tagged with `Implementation`. The readme in the Approved folder also contains a list of all proposals and a link to the corresponding issue if development has already started.     
If you would like to contribute to an ongoing implementation, please indicate your interest and offer your help on the corresponding issue. If you would like to start the implementation of a proposal that is not actively being developed, please create a new issue following the implementation template. We will respond on the issue for an initial discussion on how to go about implementing it.     
Any revisions to the original proposal based on insights gained during implementation will be raised and discussed via comments on the issue.

### *Release:*
Once the implementation is complete, the proposal that reflects the implemented functionality is moved from the Approved folder into the Implemented folder. As a last step before closing the corresponding issue, a PR to update the Q# language specification needs to be create and merged. The PR will only be merged once the functionality has been released as part of the QDK. We release a new QDK version at the end of each month and implemented features can be incorporated into any such release. At that time the corresponding issue will be tagged as `Released` and closed.


## Repository structure

The specification for the Q# language shipped with the latest QDK can be found here.   
The specification for the Quantum Intermediate Representation (QIR) into which Q# is compiled can be found here.    
Notes from the libraries API design meetings can be found here.    
Proposals that have been approved but are not yet implemented can be found in the Approved folder.    
Proposals for features that are implemented in the latest Q# version can be found in the Implemented folder.    
Proposals for features that have been rejected are archived in the Declined folder.     
Templates for suggestions and proposals can be found in the Templates folder.    
