@echo off
setlocal EnableDelayedExpansion

set "parsed_debug_mode="
set "parsed_should_exit=0"
set "parsed_exit_code=0"
set "parsed_help_topic="

:PARSE_ARGS
if "%~1"=="" goto PARSE_DONE
if /i "%~1"=="--help" goto HANDLE_HELP
if /i "%~1"=="-h" goto HANDLE_HELP
if /i "%~1"=="--debug" (
    if /i "%~2"=="--help" (
        set "parsed_help_topic=debug"
        set "parsed_should_exit=1"
        set "parsed_exit_code=0"
        goto FINALIZE
    )
    if /i "%~2"=="-h" (
        set "parsed_help_topic=debug"
        set "parsed_should_exit=1"
        set "parsed_exit_code=0"
        goto FINALIZE
    )
    if "%~2"=="" (
        echo [error] 'debug' requires an argument.
        echo [info] Usage: --debug all
        set "parsed_should_exit=1"
        set "parsed_exit_code=1"
        goto FINALIZE
    )
    if /i not "%~2"=="all" (
        echo [error] Invalid value for --debug: %~2
        echo [info] Usage: --debug all
        set "parsed_should_exit=1"
        set "parsed_exit_code=1"
        goto FINALIZE
    )
    set "parsed_debug_mode=all"
    shift
    shift
    goto PARSE_ARGS
)
if "%~1:~0,1%"=="-" (
    echo [error] Invalid flag: %~1
    echo [info] Use --help or -h to view usage information.
    set "parsed_should_exit=1"
    set "parsed_exit_code=1"
    goto FINALIZE
)
echo [error] Unexpected argument: %~1
echo [info] Use --help or -h to view usage information.
set "parsed_should_exit=1"
set "parsed_exit_code=1"
goto FINALIZE

:HANDLE_HELP
if /i "%~2"=="debug" (
    set "parsed_help_topic=debug"
) else (
    set "parsed_help_topic=main"
)
set "parsed_should_exit=1"
set "parsed_exit_code=0"
goto FINALIZE

:PARSE_DONE
goto FINALIZE

:FINALIZE
endlocal & (
    set "debug_mode=%parsed_debug_mode%"
    set "parser_should_exit=%parsed_should_exit%"
    set "parser_exit_code=%parsed_exit_code%"
    set "help_topic=%parsed_help_topic%"
)
exit /b 0
