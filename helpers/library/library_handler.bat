@echo off
setlocal EnableDelayedExpansion

:: 1. Environment Guard (base is allowed, empty is not)
if "%CONDA_DEFAULT_ENV%"=="" (
    echo [error] No active Conda environment detected.
    exit /b 1
)

set "debug=0"
set "force_library_missing=0"
set "library_exists=0"
set "library_installed_now=0"

:: 2. Arguments (Rephrased 'library' to 'exe' for clarity)
set "exe=%~1"
set "name=%~2"
set "description=%~3"
set "project_page_url=%~4"

if "!project_page_url!"=="" (
    echo [error] Usage: %~nx0 ^<exe_name^> ^<display_name^> ^<desc^> ^<url^> [-f] [--debug]
    exit /b 1
)

:: Shift past the first 4 args for flags
shift & shift & shift & shift

call helpers\core\handler_flag_parser.bat "%~1" "%~2" "%~3"
if errorlevel 1 endlocal & exit /b 1
set "force_library_missing=%parsed_force_flag%"
set "debug=%parsed_debug_flag%"

:: 3. Initial Check (Always executes)
where !exe! >nul 2>nul
if !errorlevel! equ 0 (
    set "library_exists=1"
)

:: Force Logic: override result if -f is set
if "!force_library_missing!"=="1" (
    echo [info] Force flag detected. Resetting exist status.
    set "library_exists=0"
)

:: Exit if found (and not forced)
if "!library_exists!"=="1" (
    echo [info] !name! already exists in: %CONDA_DEFAULT_ENV%
    endlocal & set "library_installed_now=0" & exit /b 0
)

echo [info] !name! is missing in environment: %CONDA_DEFAULT_ENV%
echo [info] Project page: !project_page_url!

:PROMPT_CHOICE
set "choice="
set /p "choice=Would you like to install !name! now? (y/n): "
set "choice=!choice: =!"

if /i "!choice!"=="y" (
    goto DOWNLOAD
) else if /i "!choice!"=="n" (
    echo [error] !name! is required to run the program.
    pause & endlocal & exit /b 1
) else (
    goto PROMPT_CHOICE
)

:DOWNLOAD
:: AXIOM jump ONLY when debug is true in download section
if "!debug!"=="1" (
    echo [debug] Simulating a successful !name! install via AXIOM.
    set "library_exists=1"
    set "library_installed_now=1"
    goto AXIOM_LIBRARY_EXISTS
)

echo [info] Installing !exe! via Conda...
call conda install -y -c conda-forge !exe!

where !exe! >nul 2>nul
if !errorlevel! neq 0 (
    echo [warn] Conda failed. Trying Pip fallback...
    call pip install !exe!
)

:VERIFIER
where !exe! >nul 2>nul
if !errorlevel! equ 0 (
    set "library_exists=1"
    set "library_installed_now=1"
)

:AXIOM_LIBRARY_EXISTS
if "!library_exists!"=="1" (
    echo [info] !name! exists in environment: %CONDA_DEFAULT_ENV%
    endlocal & set "library_installed_now=%library_installed_now%" & exit /b 0
) else (
    echo [error] Verify failed: !name! is not in current environment.
    endlocal & set "library_installed_now=0" & exit /b 1
)
