@echo off
setlocal EnableDelayedExpansion

set "missing_paths="
set "current_path=;%PATH%;"

if "%verbose_path_debug%"=="1" (
    echo [debug] PATH check: evaluating required PATH entries against the current session PATH.
)

:CHECK_NEXT
if "%~1"=="" goto DONE

set "candidate=%~1"
if not defined candidate (
    shift
    goto CHECK_NEXT
)

if "%verbose_path_debug%"=="1" echo [debug] PATH check: considering '%candidate%'.

if not exist "!candidate!" (
    if "%verbose_path_debug%"=="1" echo [debug] PATH check: skipping '%candidate%' because it does not exist.
    shift
    goto CHECK_NEXT
)

if /i "!current_path:;!candidate!;=!"=="!current_path!" (
    if "%verbose_path_debug%"=="1" echo [debug] PATH check: '%candidate%' is missing from PATH.
    if defined missing_paths (
        set "missing_paths=!missing_paths!;!candidate!"
    ) else (
        set "missing_paths=!candidate!"
    )
 ) else (
    if "%verbose_path_debug%"=="1" echo [debug] PATH check: '%candidate%' is already present on PATH.
)

shift
goto CHECK_NEXT

:DONE
endlocal & set "missing_paths=%missing_paths%"
exit /b 0
