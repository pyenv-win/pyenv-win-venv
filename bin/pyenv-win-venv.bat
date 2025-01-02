@ECHO OFF
@REM Determine script location for Windows Batch File

@REM Get current folder with no trailing slash
SET ScriptDir=%~dp0
SET ScriptDir=%ScriptDir:~0,-1%

powershell -File "%ScriptDir%\pyenv-win-venv.ps1" %*