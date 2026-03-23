@echo off
setlocal EnableDelayedExpansion

set "debug=0"
set "force_conda_missing=0"
set "conda_detected=0"
set "resolved_conda_root="
set "resolved_conda_entry="

call helpers\core\handler_flag_parser.bat %*
if errorlevel 1 endlocal & exit /b 1

set "debug=%parsed_debug_flag%"
set "force_conda_missing=%parsed_force_flag%"

for /f "delims=" %%I in ('conda info --base 2^>nul') do if not defined resolved_conda_root set "resolved_conda_root=%%I"
if not defined resolved_conda_root set "resolved_conda_root=%USERPROFILE%\miniforge3"
set "resolved_conda_entry=!resolved_conda_root!\condabin\conda.bat"

if exist "!resolved_conda_entry!" set "conda_detected=1"

if "!force_conda_missing!"=="1" (
    echo [info] Force flag detected. Resetting Conda exist status.
    set "conda_detected=0"
)

if "!conda_detected!"=="1" (
    echo [info] Conda already exists at "!resolved_conda_root!".
    endlocal & (
        set "conda_exists=1"
        set "conda_root=%resolved_conda_root%"
        set "conda_entry=%resolved_conda_entry%"
    ) & exit /b 0
)

set /a "conda_prompt_attempts=0"

:PROMPT_CONDA
echo.
echo [warning] If you proceed, please leave the Miniforge installation path as the DEFAULT:
echo           "%USERPROFILE%\miniforge3"
echo [warning] Only change this if you know how to manually configure your System PATH.
echo.

set "choice="
set /p "choice=Would you like to install Conda now? (y/n): "
set "choice=!choice: =!"

if /i "!choice!"=="y" goto DOWNLOAD
if /i "!choice!"=="n" (
    echo [error] Conda is required to continue.
    pause
    endlocal & exit /b 1
)

set /a "conda_prompt_attempts+=1"
if !conda_prompt_attempts! geq 5 (
    echo [error] Too many invalid responses.
    pause
    endlocal & exit /b 1
)
echo [error] Invalid input. Please type 'y' or 'n'.
goto PROMPT_CONDA

:DOWNLOAD
if "!debug!"=="1" (
    echo [debug] Simulating install...
    set "resolved_conda_root=%USERPROFILE%\miniforge3"
    set "resolved_conda_entry=!resolved_conda_root!\condabin\conda.bat"
    goto EXIT_SUCCESS
)

echo [info] Downloading Miniforge3...
curl -L https://github.com -o MiniforgeInstaller.exe

echo [info] Running installer. REMEMBER: Keep the default installation path.
start /wait MiniforgeInstaller.exe
del MiniforgeInstaller.exe

if exist "%USERPROFILE%\miniforge3\condabin\conda.bat" (
    set "resolved_conda_root=%USERPROFILE%\miniforge3"
    set "resolved_conda_entry=!resolved_conda_root!\condabin\conda.bat"
    set "PATH=%USERPROFILE%\miniforge3\condabin;%USERPROFILE%\miniforge3\Scripts;!PATH!"
    echo [info] Installation detected and added to current session.
    goto EXIT_SUCCESS
)

echo [error] Miniforge was not found in the default location.
echo [info] If you chose a custom path, you must add it to your PATH environment variable manually.
pause
endlocal & exit /b 1

:EXIT_SUCCESS
endlocal & (
    set "conda_exists=1"
    set "conda_root=%resolved_conda_root%"
    set "conda_entry=%resolved_conda_entry%"
) & exit /b 0
