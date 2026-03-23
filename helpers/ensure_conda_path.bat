@echo off

if not exist "%USERPROFILE%\miniforge3\condabin\conda.bat" exit /b 0

call helpers\find_missing_paths.bat ^
    "%USERPROFILE%\miniforge3" ^
    "%USERPROFILE%\miniforge3\Scripts" ^
    "%USERPROFILE%\miniforge3\Library\bin" ^
    "%USERPROFILE%\miniforge3\condabin"

if not defined missing_paths (
    echo [info] The required Miniforge3 folders are already present on PATH.
    exit /b 0
)

if not "%debug_mode%"=="0" (
    echo [debug] Debug mode is active, so the required Miniforge3 folders will not be added to PATH.
    echo [debug] Missing Miniforge3 PATH entries: %missing_paths%
    set "missing_paths="
    exit /b 0
)

echo [info] The required Miniforge3 folders will be added to PATH for this session.
set "PATH=%PATH%;%missing_paths%"
echo [info] PATH has been updated for this session.
set "missing_paths="

exit /b 0
