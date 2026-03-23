@echo off

if "%parser_should_exit%"=="1" (
    if /i "%help_topic%"=="debug" (
        echo Debug Modes:
        echo   all         Simulate the full setup flow
        echo.
        echo Examples:
        echo   --debug all
        exit /b %parser_exit_code%
    )

    if /i "%help_topic%"=="main" (
        echo Usage: main.bat [--debug all] [--help debug]
        echo.
        echo Options:
        echo   --help, -h       Show this help message
        echo   --debug all      Simulate the full setup flow
        exit /b %parser_exit_code%
    )

    exit /b %parser_exit_code%
)

if not defined debug_mode exit /b 0
if /i not "%debug_mode%"=="all" exit /b 0

set "debug_enabled=1"
if not "%conda_exists%"=="1" (
    set "conda_exists=0"
    echo [debug] Conda setup will start from the install prompt.
)
set "force_ytdlp_install=1"
echo [debug] yt-dlp setup will start from the install prompt.
set "force_ffmpeg_install=1"
echo [debug] FFmpeg setup will start from the install prompt.

echo [debug] Debug mode is active.
echo [debug] Installer and download steps will be simulated, and the final Python command will be shown but not executed.

exit /b 0
