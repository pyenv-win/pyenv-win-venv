# cSpell: disable
# pyenv-win-venv completion start
$script:PyenvVenvCommands = @(
    'activate',  
    'deactivate', 
    'init', 
    'install',
    'config',
    'completion',
    'list envs', 
    'list python', 
    'local', 
    'uninstall self', 
    'uninstall', 
    'update self', 
    'which',
    'help'
)
function script:PyenvVenvExpandCmd($filter) {
    $cmdList = @()
    $cmdList += $PyenvVenvCommands
    $cmdList -like "$filter*"
}

function script:PyenvVenvTabExpansion($lastBlock) {
    switch -regex ($lastBlock) {
        "^(?<cmd>\S*)$" {
            return PyenvVenvExpandCmd $matches['cmd'] $true
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

@('pyenv-venv', 'pyenv-win-venv') | ForEach-Object {
    Register-ArgumentCompleter -Native -CommandName $_ -ScriptBlock $scriptBlock
}
# pyenv-win-venv completion end