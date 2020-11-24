## Script to adapt the documents for the official docs page

### Description of the process

#### Files 

There are 4 relevant files:

- `uid-map.csv`: this is a `*.csv` file containing the map between paths and uids that Brad created. This file can be hosted anywhere as long the link is accessible. I recommend storing this file in the same folder as the stub files, so any modification or addition can be easily reflected in the map.

- `replace_links.yml`: a `*.yml` file containing the workflow for the GitHub action that is described below. This file is in `.github/workflows`.

- `setup.py`: python file to install the Click command-line application.

- `replace_links.py`: python script that imports the map from the url where the .csv file is hosted and replaces the files in a specific path.

 

#### Workflow

First, there are at least two different branches, `main` and a copy of main where we are going to host the uid version of the docs (`⭐Docs`). The GitHub Actions workflow does the following:

1. Opens a Windows console and checkouts to the repository.
1. Resets the `⭐Docs` branch to match `main`.
1. Installs the script and runs it through a click command.
1. Commits and pushes the changes to `⭐Docs`.
