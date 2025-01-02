# cSpell: disable
# This script is based on https://github.com/Moeologist/scoop-completion

# powershell completion for pyenv-win-venv

###-start-pyenv-venv-completion-###
$script:PyenvVenvCommands = @(
    'activate',
    'deactivate',
    'init',
    'install',
    'config',
    'completion',
    'list'
    'local',
    'uninstall',
    'update self',
    'which',
    'help'
)

$script:PyenvVenvSubCommands = @{
    init  = 'root'
    list  = 'envs python'
    which = 'python python3 pip pip3'
    help  = 'activate completion init install list uninstall which'
}

function script:PyenvVenvExpandCmd($filter) {
    $cmdList = @()
    $cmdList += $PyenvVenvCommands
    $cmdList -like "$filter*"
}

function script:PyenvVenvEnvNames($filter, $activate) {
    if ($activate) {
        @( pyenv-venv list envs | Where-Object { $_ -like "$filter*" })
    } else {
        @( pyenv-venv list envs | Where-Object { $_ -like "$filter*" }) + "self"
    }
}

function script:PyenvVenvPythonVersions($filter) {
    @(& Get-ChildItem -Path "$env:PYENV_HOME\versions" -Name | Where-Object { $_ -like "$filter*" })
}

function script:PyenvVenvExpandCmdParams($commands, $command, $filter) {
    $commands.$command -split ' ' | Where-Object { $_ -like "$filter*" }
}

function script:PyenvVenvTabExpansion($lastBlock) {
    switch -regex ($lastBlock) {
        # pyenv-venv uninstall <env_name>|self
        "^uninstall\s+(?:.+\s+)?(?<env_name>[\w][\-\.\w]*)?$" {
            return PyenvVenvEnvNames $matches['env_name'] $false
        }

        # pyenv-venv activate <env_name>
        "^activate\s+(?:.+\s+)?(?<env_name>[\w][\-\.\w]*)?$" {
            return PyenvVenvEnvNames $matches['env_name'] $true
        }

        # pyenv-venv install <python_version> <env_name>
        "^install\s+(?:.+\s+)?(?<python_version>[\w][\-\.\w]*)?$" {
            return PyenvVenvPythonVersions $matches['python_version']
        }

        # pyenv-venv <cmd>
        "^(?<cmd>\S*)$" {
            return PyenvVenvExpandCmd $matches['cmd'] $true
        }

        # pyenv-venv <cmd> <subcmd>
        "^(?<cmd>$($PyenvVenvSubCommands.Keys -join '|'))\s+(?<op>\S*)$" {
            return PyenvVenvExpandCmdParams $PyenvVenvSubCommands $matches['cmd'] $matches['op']
        }
    }
}

$scriptBlock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $rest = $commandAst.CommandElements[1..$commandAst.CommandElements.Count] -join ' '
    if ($rest -ne "" -and $wordToComplete -eq "") {
        $rest += " "
    }
    PyenvVenvTabExpansion $rest
}

Register-ArgumentCompleter -Native -CommandName @('pyenv-venv', 'pyenv-win-venv') -ScriptBlock $scriptBlock

###-end-pyenv-venv-completion-###
