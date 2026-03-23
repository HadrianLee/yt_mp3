@echo off

set "requested_tool=%~1"
if "%requested_tool%"=="" exit /b 0

set "tool_missing=0"
where "%requested_tool%" >nul 2>nul
if %errorlevel% neq 0 set "tool_missing=1"

if "%verbose_path_debug%"=="1" (
    if "%tool_missing%"=="1" (
        echo [debug] PATH check: '%requested_tool%' was not found on PATH before helper processing.
    ) else (
        echo [debug] PATH check: '%requested_tool%' is already available on PATH before helper processing.
    )
)

if "%tool_missing%"=="0" if not "%force_path_probe%"=="1" exit /b 0

if not defined CONDA_PREFIX (
    if "%verbose_path_debug%"=="1" echo [debug] PATH check: the active Conda environment path could not be confirmed.
    exit /b 0
)

call helpers\find_missing_paths.bat "%CONDA_PREFIX%" "%CONDA_PREFIX%\Scripts" "%CONDA_PREFIX%\Library\bin"
if "%verbose_path_debug%"=="1" (
    if defined missing_paths (
        echo [debug] PATH check: missing Conda environment PATH entries for '%requested_tool%': %missing_paths%
    ) else (
        echo [debug] PATH check: no missing Conda environment PATH entries were found for '%requested_tool%'.
    )
)

if not defined missing_paths exit /b 0

if "%tool_missing%"=="1" (
    if not "%debug_mode%"=="0" (
        echo [debug] Debug mode is active, so the missing Conda environment folders will not be added to PATH.
    ) else (
        echo [info] Adding the missing Conda environment folders to PATH for this session.
        set "PATH=%PATH%;%missing_paths%"
    )
    set "missing_paths="
    exit /b 0
)

if "%force_path_probe%"=="1" (
    if "%verbose_path_debug%"=="1" (
        echo [debug] PATH check: probe mode is enabled, so PATH will not be changed.
    )
)

set "missing_paths="

exit /b 0
