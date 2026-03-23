@echo off
setlocal enabledelayedexpansion

set "debug_mode="
set "debug_enabled=0"
set "force_ytdlp_install=0"
set "force_ffmpeg_install=0"
set "conda_exists=0"
set "conda_root="
set "conda_entry="
set "ffmpeg_exists=0"
set "ytdlp_exists=0"
set "parser_should_exit=0"
set "parser_exit_code=0"
set "help_topic="

call helpers\core\parser.bat %*
if errorlevel 1 exit /b %errorlevel%

call helpers\core\execute_options.bat
if errorlevel 1 exit /b %errorlevel%
if "%parser_should_exit%"=="1" exit /b %parser_exit_code%

if "%debug_enabled%"=="1" (
    call helpers\conda\conda_handler.bat --debug
) else (
    call helpers\conda\conda_handler.bat
)
if errorlevel 1 exit /b %errorlevel%

if "%debug_enabled%"=="1" (
    call helpers\conda\environment_handler.bat "%conda_root%" "%conda_entry%" --debug
) else (
    call helpers\conda\environment_handler.bat "%conda_root%" "%conda_entry%"
)
if errorlevel 1 exit /b %errorlevel%

if "%debug_enabled%"=="1" (
    call helpers\library\env_library_handler.bat --debug
) else (
    call helpers\library\env_library_handler.bat
)
if errorlevel 1 exit /b %errorlevel%

call helpers\service\yt_mp3_service.bat
exit /b %errorlevel%
