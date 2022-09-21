<#
    .SYNOPSIS
    Installs pyenv-win-venv

    .DESCRIPTION
    Installs pyenv-win-venv to $HOME\.pyenv-win-venv
    If pyenv-win-venv is already installed, try to update to the latest version.

    .PARAMETER Uninstall
    Uninstall pyenv-win-venv. Note that this uninstalls all the venvs installed with pyenv-win-venv.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> install-pyenv-win-venv.ps1

    .LINK
    Online version: https://github.com/pyenv-win/pyenv-win-venv
#>
    
param (
    [Switch] $Uninstall = $False
)
    
$PyEnvWinVenvDir = "${env:USERPROFILE}\.pyenv-win-venv"
$BinPath = "${PyEnvWinVenvDir}\bin"
    
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

Function Remove-PyEnvWinVenv() {
    Write-Host "Removing $PyEnvWinVenvDir"
    If (Test-Path $PyEnvWinVenvDir) {
        Remove-Item -Path $PyEnvWinVenvDir -Recurse -Force
    }
    Write-Host "Removing environment variables"
    Remove-PyEnvVenvVars
    Remove-PyEnvVenvProfile
}

Function Get-CurrentVersion() {
    $VersionFilePath = "$PyEnvWinVenvDir\.version"
    If (Test-Path $VersionFilePath) {
        $CurrentVersion = Get-Content $VersionFilePath
    }
    Else {
        $CurrentVersion = ""
    }

    Return $CurrentVersion
}

Function Get-LatestVersion() {
    $LatestVersionFilePath = "$PyEnvWinVenvDir\latest.version"
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/pyenv-win/pyenv-win-venv/main/.version", $LatestVersionFilePath)
    $LatestVersion = Get-Content $LatestVersionFilePath

    Remove-Item -Path $LatestVersionFilePath -Force

    Return $LatestVersion
}

Function Main() {
    If ($Uninstall) {
        Remove-PyEnvWinVenv
        If ($LastExitCode -eq 0) {
            Write-Host "pyenv-win-venv successfully uninstalled."
        }
        Else {
            Write-Host "Uninstallation failed."
        }
        exit
    }

    $BackupDir = "${env:Temp}\pyenv-win-venv-backup-$(-join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}))"
    
    $CurrentVersion = Get-CurrentVersion
    If ($CurrentVersion) {
        Write-Host "pyenv-win-venv $CurrentVersion installed."
        $LatestVersion = Get-LatestVersion
        If ($CurrentVersion -eq $LatestVersion) {
            Write-Host "No updates available."
            exit
        }
        Else {
            Write-Host "New version available: $LatestVersion. Updating..."
            
            Write-Host "Backing up existing envs to $BackupDir"
            $FoldersToBackup = "envs"
            ForEach ($Dir in $FoldersToBackup) {
                If (-not (Test-Path $BackupDir)) {
                    (New-Item -ItemType Directory -Path $BackupDir) | out-null
                }
                Copy-Item -Path "${PyEnvWinVenvDir}\${Dir}" -Destination $BackupDir -Force -Recurse
            }
            Write-Host "Removing $PyEnvWinVenvDir"
            Remove-Item -Path $PyEnvWinVenvDir -Recurse -Force
        }   
    }
    else {
        # First installation,
        # Add the \bin path to the User's Environment Variables
        [System.Environment]::SetEnvironmentVariable('path', $env:USERPROFILE + "\.pyenv-win-venv\bin;" + [System.Environment]::GetEnvironmentVariable('path', "User"), "User")
    }

    (New-Item -Path $PyEnvWinVenvDir -ItemType Directory) | out-null

    $DownloadPath = "$PyEnvWinVenvDir\pyenv-win-venv.zip"

    (New-Object System.Net.WebClient).DownloadFile("https://github.com/pyenv-win/pyenv-win-venv/archive/main.zip", $DownloadPath)
    Expand-Archive -Path $DownloadPath -DestinationPath $PyEnvWinVenvDir
    Move-Item -Path "$PyEnvWinVenvDir\pyenv-win-venv-main\*" -Destination "$PyEnvWinVenvDir" -Force
    Remove-Item -Path "$PyEnvWinVenvDir\pyenv-win-venv-main" -Recurse -Force
    Remove-Item -Path $DownloadPath -Force

    If (Test-Path $BackupDir) {
        Write-Host "Restoring Python installations"
        Copy-Item -Path "$BackupDir\*" -Destination $PyEnvWinVenvDir -Force -Recurse
    }
    
    If ($LastExitCode -eq 0) {
        Write-Host "pyenv-win-venv is successfully installed. You may need to close and reopen your terminal before using it."
    }
    Else {
        Write-Host "pyenv-win-venv was not installed successfully. If this issue persists, please open a ticket: https://github.com/pyenv-win/pyenv-win-venv/issues"
    }
}

Main
