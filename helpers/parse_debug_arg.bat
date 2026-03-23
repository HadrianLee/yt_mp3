@echo off

if /i "%~1"=="--help" goto SHOW_DEBUG_HELP
if /i "%~1"=="-h" goto SHOW_DEBUG_HELP

if "%~1"=="" (
    echo [error] 'debug' requires an argument.
    echo [info] Usage: --debug ^<MODE^>  to enable a debug mode.
    echo [info] Use '--help debug' for details.
    exit /b 1
)

if not "%~1"=="1" if not "%~1"=="2" if not "%~1"=="3" if not "%~1"=="4" if not "%~1"=="5" if not "%~1"=="6" if not "%~1"=="7" (
    echo [error] Invalid value for --debug: %~1
    exit /b 1
)

set "debug_mode=%~1"
exit /b 0

:SHOW_DEBUG_HELP
echo Debug Modes:
echo   1    Force the Miniforge setup prompt
echo   2    Force the yt-dlp setup prompt
echo   3    Force the Miniforge and yt-dlp setup prompts
echo   4    Force the FFmpeg setup prompt
echo   5    Force the Miniforge, FFmpeg, and yt-dlp setup prompts
echo   6    Enable verbose PATH helper output
echo   7    Force PATH helper checks without changing PATH
exit /b 0
