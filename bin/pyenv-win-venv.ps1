# Copyright 2022 Arbaaz Laskar

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#   http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Param($subcommand1, $subcommand2, $subcommand3, $subcommand4)
$app_dir = "$HOME\.pyenv-win-venv"
$app_env_dir = "$app_dir\envs"
$cli_version = Get-Content "$app_dir\.version"

$pyenv_versions_dir = "$env:PYENV_HOME\versions"
$python_version_file = "$((Get-Location).Path)\.python-version"
function  main {
    AppDirInit # Initialize the app directories

    if ($subcommand2 -eq "init") {
        # search for .python-version file in the current directory and move up a
        # directory towards the root till a .python-version file is found then activate the env
        if ($subcommand3 -eq "root") {
            $cwd = $((Get-Location).Path)
            while ($cwd.length -ne 0) {
                if (test-path "$cwd\.python-version") {
                    $env_name = (Get-Content "$cwd\.python-version")
                    if ($env_name -And (test-path -PathType container "$app_env_dir\$env_name")) {
                        if ($subcommand1 -eq "ps1") {
                            &"$app_env_dir\$env_name\Scripts\Activate.ps1" 
                        }
                        else {
                            cmd /k "$app_env_dir\$env_name\Scripts\activate.bat"
                        }
                    }
                    exit
                }
                else { $cwd = Split-Path $cwd }
            }
        }
        else {
            # search for .python-version file in the current directory and activate the env
            if (test-path $python_version_file) {
                $env_name = (Get-Content $python_version_file)
                if ($env_name -And (test-path -PathType container "$app_env_dir\$env_name")) {
                    if ($subcommand1 -eq "ps1") {
                        &"$app_env_dir\$env_name\Scripts\Activate.ps1" 
                    }
                    else {
                        cmd /k "$app_env_dir\$env_name\Scripts\activate.bat"
                    } 
                }
            }
        }
    }
    elseif ($subcommand2 -eq "activate") {
        if (!$subcommand3) {
            HelpActivate
        }
        elseif (test-path -PathType container "$app_env_dir\$subcommand3") {
            if ($subcommand1 -eq "ps1") {
                $env:PYENV_VENV_ACTIVE = $subcommand3
                &"$app_env_dir\$subcommand3\Scripts\Activate.ps1" 
            }
            else {
                cmd /k "$app_env_dir\$subcommand3\Scripts\activate.bat"
            }
            
        }
        else {
            Write-Host "Env: $subcommand3 is not installed. Install using `"pyenv-win-venv install <python_version> $subcommand3"`"
        }
    }
    elseif ($subcommand2 -eq "deactivate") {
        if ($env:VIRTUAL_ENV) {
            $env:PYENV_VENV_ACTIVE = ""
            if ($subcommand1 -eq "ps1") {
                deactivate
            }
            else {
                cmd /k deactivate
            }
        }
    }
    elseif ($subcommand2 -eq "install") {
        if (!$subcommand3 -Or !$subcommand4) {
            HelpInstall
        }
        elseif (test-path -PathType container "$pyenv_versions_dir\$subcommand3") {
            if ($subcommand4 -ne "self") {
                if (!(test-path -PathType container "$app_env_dir\$subcommand4")) {
                    Write-Host "Installing env: $subcommand4 using Python v$subcommand3"
                    # Deactivate the active python env if any
                    if ($env:VIRTUAL_ENV) {
                        $PYENV_VENV_ACTIVE = $env:PYENV_VENV_ACTIVE # Copy the active python venv
                        deactivate
                    }
                    pyenv shell $subcommand3
                    python -m venv "$app_env_dir\$subcommand4"

                    # Reactivate the python env if any
                    if ($PYENV_VENV_ACTIVE) {
                        pyenv-venv activate $PYENV_VENV_ACTIVE 
                    }
                }
                else {
                    Write-Host "`"$subcommand4`" already exists. Please choose another name for the env."
                }
            }
            else {
                Write-Host "Cannot create an env called `"self`" since while uninstalling `pyenv-venv uninstall self` is already a pre-existing command."
            }
        }
        else {
            Write-Host "Python v$subcommand3 is not installed. Install using `"pyenv install $subcommand3"`"
        }

    }
    elseif ($subcommand2 -eq "uninstall") {
        if (!$subcommand3) { HelpUninstall }
        elseif ($subcommand3 -eq "self") {
            $title = 'Uninstall pyenv-venv and all the installed envs!'
            $question = 'Are you sure you want to proceed?'
            $choices = '&Yes', '&No'

            $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
            if ($decision -eq 0) {
                Remove-PyEnvWinVenv
            }
        }
        elseif (test-path -PathType container "$app_env_dir\$subcommand3") {
            Write-Host "Uninstalling env: $subcommand3"
            Remove-Item -Recurse -Force "$app_env_dir\$subcommand3" 
        }
        else {
            Write-Host "$subcommand3 is not installed so it cannot be uninstalled"
        }

    }
    elseif ($subcommand2 -eq "list") {
        if (!$subcommand3) { HelpList }
        elseif ($subcommand3 -eq "envs") { FetchEnvs }
        elseif ($subcommand3 -eq "python") { FetchPythonVersions }
    }
    elseif ($subcommand2 -eq "config") {
        ConfigInfo
    }
    elseif ($subcommand2 -eq "local") {
        if (test-path -PathType container "$app_env_dir\$subcommand3") {
            Set-Content -Path $python_version_file -Value $subcommand3
        }
        else {
            Write-Host "Env: $subcommand3 is not installed. Install using `"pyenv-win-venv install <python_version> $subcommand3"`"
        }
    }
    elseif ($subcommand2 -eq "config") {
        ConfigInfo
    }
    elseif ($subcommand2 -eq "update" -And $subcommand3 -eq "self") {
        # check if the CLI was installed using Git
        (git -C $app_dir rev-parse) *> $null
        if ($LastExitCode -eq 0) {
            (git -C  $app_dir fetch origin) *> $null
            Write-Host "Changelog:" -ForegroundColor Blue
            git -C $app_dir log ..origin/main --pretty=format:"%Cblue* %C(auto)%h: %Cgreen%s%n%b"
            git -C $app_dir pull origin
        }
        else {
            $LastExitCode = 0 # reset the exit code after the git command
            # Download and run the installation script
            Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win-venv/main/bin/install-pyenv-win-venv.ps1" -OutFile "$HOME\install-pyenv-win-venv.ps1";
            &"$HOME\install-pyenv-win-venv.ps1"
        }

    }
    elseif ($subcommand2 -eq "which") {
        
        if (!$subcommand3) {
            HelpWhich
        }
        elseif (Test-Path "$env:VIRTUAL_ENV\Scripts\$subcommand3.exe") {
            Write-Host "$env:VIRTUAL_ENV\Scripts\$subcommand3.exe"
        }
        else {
            pyenv which $subcommand3
        }
    }
    elseif ($subcommand2 -eq "help" -Or !$subcommand2) {
        if (!$subcommand3) {
            # Show the help menu if help command used or no commands are used
            HelpMenu
        }
        elseif ($subcommand3 -eq "init") {
            HelpInit
        }
        elseif ($subcommand3 -eq "activate") {
            HelpActivate
        }
        elseif ($subcommand3 -eq "install") {
            HelpInstall
        }
        elseif ($subcommand3 -eq "uninstall") {
            HelpUninstall
        }
        elseif ($subcommand3 -eq "list") {
            HelpList
        }
        elseif ($subcommand3 -eq "which") {
            HelpWhich
        }
    }
    else { Write-Host "Command is not valid. Run `"pyenv-win-venv help`" for the HelpMenu" }
}


function HelpMenu {
    Write-Host "pyenv-win-venv v$cli_version
Copyright (c) Arbaaz Laskar <arzkar.dev@gmail.com>

Usage: pyenv-win-venv <command> <args>

A CLI to manage virtual envs with pyenv-win

Commands:
init                search for .python-version file in the 
                    current directory and activate the env
activate            activate an env
deactivate          deactivate an env
install             install an env
uninstall           uninstall an env
uninstall self      uninstall the CLI and its envs
list <command>      list all installed envs/python versions
local               set the given env in .python-version file
config              show the app directory
update self         update the CLI to the latest version
which <command>     show the full path to an executable
help <command>      show the CLI/<command> menu
"
}


# Command functions
function FetchPythonVersions {
    Write-Host "Python Versions installed:"
    pyenv versions
}

function FetchEnvs {
    Write-Host "Envs installed:"
    (Get-ChildItem -Directory $app_env_dir | Select-Object -Expand Name)
}

function ConfigInfo {
    Write-Host "App Directory: $app_dir"
    Write-Host "App Env Directory:  $app_env_dir"
}

function AppDirInit {
    MakeDirRecursive($app_dir)
    MakeDirRecursive($app_env_dir)
}

Function Remove-PyEnvWinVenv() {
    Write-Host "Removing $app_dir"
    If (Test-Path $app_dir) {
        Remove-Item -Path $app_dir -Recurse -Force
    }
    Write-Host "Removing environment variables"
    Remove-PyEnvVenvVars
    Remove-PyEnvVenvProfile
}

# Helper functions
function MakeDirRecursive($dir) {
    if (!(test-path -PathType container $dir)) {
        (New-Item -ItemType Directory -Path $dir) *> $null
    }
}

Function Remove-PyEnvVenvVars() {
    $PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"
    $NewPathParts = $PathParts.Where{ $_ -ne $BinPath }
    $NewPath = $NewPathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "User")
}

Function Remove-PyEnvVenvProfile() {
    $CurrentProfile = Get-Content $Profile
    $UpdatedProfile = $CurrentProfile.Replace("pyenv-venv init", "")
    Set-Content -Path  $Profile -Value $UpdatedProfile
}

# Help functions
Function HelpInit() {
    Write-Host "Usage: pyenv-venv init <command>

Search for .python-version file in the 
current directory and activate the env

Commands:
root    search for .python-version file by traversing from
the current working directory to the root
    
Example: `pyenv-venv init root`
"
}
Function HelpActivate() {
    Write-Host "Usage: pyenv-venv activate <env_name>

Parameters:
env_name    name of the installed virtualenv

Example: `pyenv-venv activate test_env`
"
}
Function HelpInstall() {
    Write-Host "Usage: pyenv-venv install <python_ver> <env_name>

Parameters:
envs        list all installed envs
python      list all installed python versions

Example: `pyenv-venv install 3.8.5 test_env`
"
}
Function HelpUninstall() {
    Write-Host "Usage: pyenv-venv uninstall <env_name>

Parameters:
env_name    name of the env
self        uninstall the CLI itself

Example: `pyenv-venv uninstall test_env`
"
}
Function HelpList() {
    Write-Host "Usage: pyenv-venv list <command>

Commands:
envs        list all installed envs
python      list all installed python versions

Example: `pyenv-venv list envs`
"
}

Function HelpWhich() {
    Write-Host "Usage: pyenv-venv which <exec_name>

Shows the full path of the executable selected. 

Parameters:
exec_name   name of the executable

Example: `pyenv-venv which python`
"
}

main