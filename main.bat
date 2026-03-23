@echo off
setlocal enabledelayedexpansion

set "debug_mode=0"
set "force_conda_prompt=0"
set "force_ytdlp_prompt=0"
set "force_ffmpeg_prompt=0"
set "verbose_path_debug=0"
set "force_path_probe=0"
set "help_exit_code=0"

:PARSE_ARGS
if "%~1"=="" goto ARGS_DONE
if /i "%~1"=="--help" goto HANDLE_HELP
if /i "%~1"=="-h" goto HANDLE_HELP
if /i "%~1"=="--debug" (
    call helpers\parse_debug_arg.bat "%~2"
    if errorlevel 1 (
        set "help_exit_code=1"
        goto SHOW_HELP_HINT
    )
    shift
    shift
    goto PARSE_ARGS
)
if "%~1:~0,1%"=="-" (
    set "help_exit_code=1"
    echo [error] Invalid flag: %~1
    goto SHOW_HELP_HINT
)
set "help_exit_code=1"
echo [error] Unexpected argument: %~1
goto SHOW_HELP_HINT

:HANDLE_HELP
    if /i "%~2"=="debug" (
        shift
        goto SHOW_DEBUG_HELP
    )
    goto SHOW_HELP

:SHOW_HELP
echo Usage: main.bat [--debug MODE] [--help debug]
echo.
echo Options:
echo   --help, -h       Show this help message
echo   --debug ^<MODE^>  Enable debug mode; use '--help debug' for details
exit /b %help_exit_code%

:SHOW_DEBUG_HELP
call helpers\parse_debug_arg.bat --help
exit /b 0

:SHOW_HELP_HINT
echo [info] Use --help or -h to view usage information.
exit /b %help_exit_code%

:ARGS_DONE
call helpers\apply_debug_mode.bat
if errorlevel 1 exit /b %errorlevel%

call helpers\setup_conda.bat
if errorlevel 1 exit /b %errorlevel%

call helpers\setup_tools.bat
if errorlevel 1 exit /b %errorlevel%

call helpers\collect_inputs.bat
if errorlevel 1 exit /b %errorlevel%

call helpers\run_downloader.bat
exit /b %errorlevel%
