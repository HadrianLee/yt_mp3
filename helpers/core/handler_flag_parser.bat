@echo off
setlocal EnableDelayedExpansion

set "parsed_force_flag=0"
set "parsed_debug_flag=0"

:PARSE_FLAG
if "%~1"=="" goto FINALIZE
if /i "%~1"=="-f" (
    set "parsed_force_flag=1"
    shift
    goto PARSE_FLAG
)
if /i "%~1"=="--debug" (
    set "parsed_debug_flag=1"
    shift
    goto PARSE_FLAG
)

echo [error] Invalid flag: %~1
echo [info] Usage: %~nx0 [-f] [--debug]
endlocal & exit /b 1

:FINALIZE
endlocal & (
    set "parsed_force_flag=%parsed_force_flag%"
    set "parsed_debug_flag=%parsed_debug_flag%"
)
exit /b 0
