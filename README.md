<h1 align="center">pyenv-win-venv</h1>

A CLI manage virtual envs with pyenv-win<br><br>

To report issues for the CLI, open an issue at https://github.com/arzkar/pyenv-win-venv/issues

# Installation

## Dependencies

This script depends on the [pyenv-win](https://github.com/pyenv-win/pyenv-win) so it needs to be installed system to run this script.

## Git

```
git clone https://github.com/arzkar/pyenv-win-venv "$HOME\.pyenv-win-venv"
```

**Note:** Steps to [add System Settings](#add-system-settings)

### Add System Settings

Adding the following paths to your USER PATH variable in order to access the pyenv-win-venv command

```pwsh
[System.Environment]::SetEnvironmentVariable('path', $env:USERPROFILE + "\.pyenv-win-venv\bin;"  + [System.Environment]::GetEnvironmentVariable('path', "User"),"User")
```

# Update

- Run `pyenv-win-venv update self` (Recommended)

- Run `git pull`:

  Go to `%USERPROFILE%\.pyenv\pyenv-win-env` (which is your installed path) and run `git pull`

# Usage

```
> pyenv-win-venv
    pyenv-win-venv v0.1
    Copyright (c) Arbaaz Laskar <arzkar.dev@gmail.com>

    Usage: pyenv-win-venv <command> <args>

    A CLI manage virtual envs with pyenv-win

    Commands:
    activate            activate an env
    deactivate          deactivate an env
    install             install an env
    uninstall           uninstall an env
    list envs           list all installed envs
    list python         list all installed python versions
    config              show the app directory
    help                show this menu
```

**Note:** `pyenv-venv` is an alias for `pyenv-win-venv` so either one can be used to call the CLI.

# Example

- To install an env using Python v3.8.5 (should be already installed in the system using `pyenv`)

```

pyenv-venv install 3.8.5 env_name

```

- To uninstall an env

```

pyenv-venv uninstall env_name

```

- To activate an env

```

pyenv-venv activate env_name

```

- To deactivate an env

```

pyenv-venv deactivate

```

- To list all installed envs

```

pyenv-venv list envs

```

- To ist all installed python versions

```

pyenv-venv list python

```

- To show the app directory

```

pyenv-venv config

```

- To update the CLI to the latest version (requires `git`)

```

pyenv-venv update self

```

---
