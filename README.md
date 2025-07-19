# python-tools
Manage and automate tasks arround Python projects.

## Dependency management

> If I have seen further, it is by standing on the shoulders of giants
> 
> Issac Newton

The power of modern programming languages stems from the ability to use packages: Rather than building it yourself, you import it from someone else. With the combination of `pip` and `venv`, Python is bringing the basics. But if your project gets more complex or you want to collaborate with others, you will see their limitations.

While there are many package resp. dependency managers trying to solve this, none of them met my requirements:

- Lock package versions that are known to work for installing and building (with `pyproject.toml`)
- Allow to regularly upgrade all packages to their latest versions
- Make dependencies of dependencies transparent

Therefore I created my own solution based on [pip-tools](https://pypi.org/project/pip-tools/).

### Project setup
Create as many \*.in files as needed. I use:

- `requirements.in` for general (production) dependencies
- `dev-requirements.in` for development- and test-related dependencies

Specify the dependencies as you would do in a `requirements.txt` file. Unless I need a specific version, I don't specify the dependency versions in these files (i.e. use the latest ones). The scripts mentioned below will create \*.txt versions of these files with specific dependency versions. E.g. in `dev-requirements.in`:

```
build
pytest
```

Add the following content to the `pyproject.toml` file (assuming all your production dependencies are specified in `requirements.in`):

```toml
[project]
dynamic = ["dependencies"]

[tool.setuptools.dynamic]
dependencies = { file = ["requirements.txt"] }
```

### Powershell scripts
Scripts that work independent of a specific IDE. It is important that each script is executed in the root of the python project.

- **install-dependencies.ps1**: Install the dependencies of a python project into its virtual environment.
- **update-dependencies.ps1**: Update the dependencies of a python project to their latest versions and install them into the projects virtual environment.

### Visual Studio Code
If you are using Visual Studio Code as IDE, you can add the scripts as [tasks](https://code.visualstudio.com/docs/debugtest/tasks).

#### settings.json
The following settings need to be specified in the file `.vscode\settings.json`.

```json
{
    "in_files_included": ["dev-requirements.in", "requirements.in"],
    "venv_dir": "venv"
}
```

#### tasks.json
I recommend to add the following tasks to the global "User Tasks" file, so that they are available for each python project.

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Install dependencies",
            "type": "shell",
            "command": [
                // Get the specified .in files in the current directory.
                "$InFiles = '${config:in_files_included}' -split ',';",
                "${config:venv_dir}\\scripts\\Activate.ps1;",
                // Upgrade pip.
                "python -m pip install --upgrade pip;",
                // Upgrade pip-tools.
                "pip install -U --require-virtualenv pip-tools;",
                // Call pip-compile -U for all *.in files.
                "${config:venv_dir} | ForEach-Object { pip-compile -U $_ };",
                // Call pip-sync with all .txt versions of the *.in files.
                "pip-sync @($InFiles | ForEach-Object { $_.replace('.in', '.txt') });",
                "deactivate;"
            ],
            "problemMatcher": [],
            "detail": "sync requirements files into venv"
        },
        {
            "label": "Update dependencies",
            "type": "shell",
            "command": [
                // Get the specified .in files in the current directory.
                "$InFiles = '${config:in_files_included}' -split ',';",
                "${config:venv_dir}\\scripts\\Activate.ps1;",
                // Upgrade pip.
                "python -m pip install --upgrade pip;",
                // Upgrade pip-tools.
                "pip install -U --require-virtualenv pip-tools;",
                // Call pip-compile -U for all *.in files.
                "$InFiles | ForEach-Object { pip-compile -U $_ };",
                // Call pip-sync with all .txt versions of the *.in files.
                "pip-sync @($InFiles | ForEach-Object { $_.replace('.in', '.txt') });",
                "deactivate;"
            ],
            "problemMatcher": [],
            "detail": "update requirements files and sync them into venv"
        }
    ]
}
```