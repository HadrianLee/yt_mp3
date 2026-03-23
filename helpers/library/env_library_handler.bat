@echo off
setlocal EnableDelayedExpansion

set "debug=0"
set "force_libraries_missing=0"
set "state_file=installer_state.properties"

call helpers\core\handler_flag_parser.bat %*
if errorlevel 1 endlocal & exit /b 1

set "debug=%parsed_debug_flag%"
set "force_libraries_missing=%parsed_force_flag%"

set "ffmpeg_flags="
if "!force_libraries_missing!"=="1" set "ffmpeg_flags=-f"
if "%force_ffmpeg_install%"=="1" (
    echo [debug] Simulating 'ffmpeg' as not yet installed in '%target_env%'.
    set "ffmpeg_flags=-f"
)
if "!debug!"=="1" (
    if defined ffmpeg_flags (
        set "ffmpeg_flags=!ffmpeg_flags! --debug"
    ) else (
        set "ffmpeg_flags=--debug"
    )
)

call helpers\library\library_handler.bat ffmpeg FFmpeg "FFmpeg is required for audio conversion and metadata embedding." https://ffmpeg.org/ !ffmpeg_flags!
if errorlevel 1 endlocal & exit /b %errorlevel%
if not "!debug!"=="1" if "!library_installed_now!"=="1" (
    call helpers\core\state_writer.bat "!state_file!" managed_by_script true
    call helpers\core\state_writer.bat "!state_file!" package_env_name "%CONDA_DEFAULT_ENV%"
    call helpers\core\state_writer.bat "!state_file!" ffmpeg_installed_by_script true
)

set "ytdlp_flags="
if "!force_libraries_missing!"=="1" set "ytdlp_flags=-f"
if "%force_ytdlp_install%"=="1" (
    echo [debug] Simulating 'yt-dlp' as not yet installed in '%target_env%'.
    set "ytdlp_flags=-f"
)
if "!debug!"=="1" (
    if defined ytdlp_flags (
        set "ytdlp_flags=!ytdlp_flags! --debug"
    ) else (
        set "ytdlp_flags=--debug"
    )
)

call helpers\library\library_handler.bat yt-dlp yt-dlp "yt-dlp is required for downloads." https://github.com/yt-dlp/yt-dlp !ytdlp_flags!
if errorlevel 1 endlocal & exit /b %errorlevel%
if not "!debug!"=="1" if "!library_installed_now!"=="1" (
    call helpers\core\state_writer.bat "!state_file!" managed_by_script true
    call helpers\core\state_writer.bat "!state_file!" package_env_name "%CONDA_DEFAULT_ENV%"
    call helpers\core\state_writer.bat "!state_file!" ytdlp_installed_by_script true
)

endlocal & (
    set "ffmpeg_exists=1"
    set "ytdlp_exists=1"
    set "force_ffmpeg_install=0"
    set "force_ytdlp_install=0"
) & exit /b 0
