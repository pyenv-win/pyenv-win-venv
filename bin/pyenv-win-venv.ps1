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

Param($subcommand1, $subcommand2, $subcommand3)
$app_dir = "$HOME\.pyenv-win-venv"
$app_env_dir = "$app_dir\envs"
$cli_version = Get-Content "$app_dir\.version"

$pyenv_versions_dir = "$env:PYENV_HOME\versions"


function  main {
    AppDirInit # Initialize the app directories

    if ($subcommand1 -eq "init") {
        #search for .python-version file in the current directory and activate the env
        $python_version_file = "$((Get-Location).Path)\.python-version"
        if (test-path $python_version_file) {
            $env_name = (Get-Content $python_version_file)
            if ($env_name -And (test-path -PathType container "$app_env_dir\$env_name")) {
                &"$app_env_dir\$env_name\Scripts\Activate.ps1" 
            }
        }
    }
    elseif ($subcommand1 -eq "activate") {
        if (test-path -PathType container "$app_env_dir\$subcommand2") {
            &"$app_env_dir\$subcommand2\Scripts\Activate.ps1"
            
        }
        else {
            Write-Host "Env: $subcommand2 is not installed. Install using `"pyenv-win-venv install <python_version> $subcommand2"`"
        }
    }
    elseif ($subcommand1 -eq "activate") {
        if (test-path -PathType container "$app_env_dir\$subcommand2") {
            &"$app_env_dir\$subcommand2\Scripts\Activate.ps1"
            
        }
        else {
            Write-Host "Env: $subcommand2 is not installed. Install using `"pyenv-win-venv install <python_version> $subcommand2"`"
        }
    }
    elseif ($subcommand1 -eq "deactivate") {
        deactivate
    }
    elseif ($subcommand1 -eq "install") {
        if (test-path -PathType container "$pyenv_versions_dir\$subcommand2") {
            if ($subcommand3 -ne "self") {
                Write-Host "Installing env: $subcommand3 using Python v$subcommand2"
                pyenv shell $subcommand2
                python -m venv "$app_env_dir\$subcommand3"
            }
            else {
                Write-Host "Cannot create an env called `"self`" since while uninstalling pyenv-venv uninstall self is already a pre-existing command!"
            }
        }
        else {
            Write-Host "Python v$subcommand2 is not installed. Install using `"pyenv install $subcommand2"`"
        }

    }
    elseif ($subcommand1 -eq "uninstall") {
        if ($subcommand2 -eq "self") {
            $title = 'Uninstall pyenv-venv and all the installed envs!'
            $question = 'Are you sure you want to proceed?'
            $choices = '&Yes', '&No'

            $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
            if ($decision -eq 0) {
                Remove-PyEnvWinVenv
            }
        }
        elseif (test-path -PathType container "$app_env_dir\$subcommand2") {
            Write-Host "Uninstalling env: $subcommand2"
            Remove-Item -Recurse -Force "$app_env_dir\$subcommand2" 
        }
        else {
            Write-Host "$subcommand2 is not installed so it cannot be uninstalled"
        }

    }
    elseif ($subcommand1 -eq "list") {
        if ($subcommand2 -eq "envs") { FetchEnvs }
        elseif ($subcommand2 -eq "python") { FetchPythonVersions }
    }
    elseif ($subcommand1 -eq "config") {
        ConfigInfo
    }
    elseif ($subcommand1 -eq "update" -And $subcommand2 -eq "self") {
        # check if the CLI was installed using Git
        (git -C $app_dir rev-parse) | out-null
        if ($LastExitCode -eq 0) {
            (git -C  $app_dir fetch origin) | out-null
            Write-Host "Changelog:" -ForegroundColor Blue
            git -C $app_dir log ..origin/main --pretty=format:"%Cblue* %C(auto)%h: %Cgreen%s%n%b"
            git -C $app_dir pull origin
        }
        else {
            # Download and run the installation script
            Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win-venv/main/bin/install-pyenv-win-venv.ps1" -OutFile "$HOME\install-pyenv-win-venv.ps1";
            &"$HOME\install-pyenv-win-venv.ps1"
        }

    }
    elseif ($subcommand1 -eq "help" -Or (!$subcommand1 -And !$subcommand2) ) {
        # Show the help menu if help command used or no commands are used
        HelpMenu
    }
    else { Write-Host "Command is not valid. Run `"pyenv-win-venv help`" for the HelpMenu" }
}


function HelpMenu {
    Write-Host "    pyenv-win-venv v$cli_version
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
    list envs           list all installed envs
    list python         list all installed python versions
    config              show the app directory
    update self         update the CLI to the latest version
    help                show this menu
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
        (New-Item -ItemType Directory -Path $dir) | out-null
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



main