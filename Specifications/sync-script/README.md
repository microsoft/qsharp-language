## Script to adapt the documents for the official docs page

### Description of the process

#### Files 

There are 4 relevant files:

- `uid-map.csv`: this is a `*.csv` file containing the map between paths and UIDs in the quantum-docs-private markdown files. The `csv` file can be hosted anywhere as long the link is accessible. It is stored in the same folder as the stub files, *quantum-docs-private/articles/user-guide/language/*, so any modifications or additions can be easily reflected in the mapping file.

- `replace_links.yml`: a `*.yml` file containing the workflow for the GitHub action that is described below. This file is in `.github/workflows`.

- `setup.py`: python file to install the Click command-line application.

- `replace_links.py`: python script that imports the map from the url where the .csv file is hosted and replaces the markdown files in a specific path.

#### Workflow

First, there are two branches used in the *qsharp-language* repo, `main` and a copy of main, `⭐Docs`, where the modified version of the docs are stored. The GitHub Actions workflow does the following whenever a change is detected under *qsharp-language/Specifications/Language/*:

1. Opens a Windows console and checks out to the repository.
1. Resets the `⭐Docs` branch to match `main`.
1. Installs the script and runs it through a click command.
1. Commits and pushes the changes to `⭐Docs`.

### Background

Because of the open source nature of Q#, the language specification content under *qsharp-language/Specifications/Language/* needs to remain accessible to users in GitHub. Due to the formatting within GitHub, however, the content files cannot be pulled directly into the publishing repo for Microsoft Learn, *quantum-docs-private*, as is - links with local GitHub urls need to be converted to xref uids, navigation links removed, and headers formatted correctly. The script and GitHub action described here does that. 

From the publishing side in the *quantum-docs-private* repo, the *qsharp-language/⭐Docs* branch is configured as a dependent repo in *.openpublishing.publish.config.json*. For each topic file under *qsharp-language/Specifications/Language/*, there is a corresponding topic file under *quantum-docs-private/articles/user-guide/language/* which has an INCLUDE link to its *qsharp-language* counterpart. 

#### Submitting changes

To update articles, submit your changes as a PR to the *qsharp-language/main* branch. When the PR is merged, the GitHub action will update the `⭐Docs` branch, and *quantum-docs-private* will include the updates in the next publishing cycle. 

**Adding a new topic, removing a topic, or changing the filename of a topic**.
These modifications are NOT automatically updated as part of this workflow. You should merge your PR as usual, and then contact *quantumdocwriters@microsoft.com* with the details so the mapping table and table of contents can be modified accordingly.
