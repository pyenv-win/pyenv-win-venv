<h1 align="center">pyenv-win-venv</h1>

A CLI manage virtual envs with pyenv-win<br>

To report issues for the CLI, open an issue at https://github.com/arzkar/pyenv-win-venv/issues

# Installation

## Dependencies

This script depends on the [pyenv-win](https://github.com/pyenv-win/pyenv-win) so it needs to be installed system to run this script.

## Power Shell

```
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/arzkar/pyenv-win-venv/main/bin/install-pyenv-win-venv.ps1" -OutFile "$HOME\install-pyenv-win-venv.ps1";
&"$HOME\install-pyenv-win-venv.ps1"
```

**Note:** Skip the [Add System Settings](#add-system-settings) Section

## Git

```
git clone https://github.com/arzkar/pyenv-win-venv "$HOME\.pyenv-win-venv"
```

You need to add the `\bin` path to your environment variables using the following steps.

### Add System Settings

Adding the following paths to your USER PATH variable in order to access the pyenv-win-venv command

```pwsh
[System.Environment]::SetEnvironmentVariable('path', $env:USERPROFILE + "\.pyenv-win-venv\bin;"  + [System.Environment]::GetEnvironmentVariable('path', "User"),"User")
```

# Update

- Automatically using `pyenv-venv update self` (Recommended)

- Manually:

  - Using `git pull`:

  Go to `%USERPROFILE%\.pyenv\pyenv-win-venv` (which is your installed path) and run `git pull`

  - Using `install-pyenv-win-venv.ps1` script:
    Follow these steps: [Power Shell](#power-shell)

# Uninstallation

## CLI

```
pyenv-venv uninstall self
```

## Power Shell

```
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/arzkar/pyenv-win-venv/main/bin/install-pyenv-win-venv.ps1" -OutFile "$HOME\install-pyenv-win-venv.ps1";
&"$HOME\install-pyenv-win-venv.ps1" -Uninstall
```

# Usage

```
> pyenv-win-venv
    pyenv-win-venv v0.2
    Copyright (c) Arbaaz Laskar <arzkar.dev@gmail.com>

    Usage: pyenv-win-venv <command> <args>

    A CLI manage virtual envs with pyenv-win

    Commands:
    activate            activate an env
    init                search for .python-version file in the
                        current directory and activate the env
    deactivate          deactivate an env
    install             install an env
    uninstall           uninstall an env
    uninstall self      uninstall the CLI and its envs
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

# Note

## Env automatic activation using `.python-version` file

- You can set the env for a directory using a `.python-version`
  file and the cli can automatically activate the env if a shell is
  opened in that directory

- `.python-verion` file: It should only contain the name of the env

- You can manually do this by calling `pyenv-venv init`

- To enable the automatic feature, you need to add `pyenv-venv init` to your the PowerShell Profile.
  Steps to do this:

  - First check if you already have a powershell profile.

    ```
    Test-Path $profile
    ```

    If its `False`, then you need to create a new profile.

  - Create a new profile using:

    ```
    New-Item -path $profile -type file –force
    ```

    The location to the profile will be shown on the shell.

  - Open the `profile.ps1` file and append the following line.

    ```
    pyenv-venv init
    ```

    Save and restart the shell.

---
