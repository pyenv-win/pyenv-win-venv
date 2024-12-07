@ECHO OFF
@REM Alias for pyenv-win-venv.bat

@REM "%USERPROFILE%\.pyenv-win-venv\bin\pyenv-win-venv.bat" %*

SET ScriptDir=%~dp0
SET ScriptDir=%ScriptDir:~0,-1%
"%ScriptDir%\pyenv-win-venv.bat" %*