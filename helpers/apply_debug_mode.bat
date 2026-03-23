@echo off

if "%debug_mode%"=="1" (
    set "force_conda_prompt=1"
    echo [debug] Debug mode 1 enabled.
    echo [debug] The Miniforge setup prompt will be forced.
) else if "%debug_mode%"=="2" (
    set "force_ytdlp_prompt=1"
    echo [debug] Debug mode 2 enabled.
    echo [debug] The yt-dlp setup prompt will be forced.
) else if "%debug_mode%"=="3" (
    set "force_conda_prompt=1"
    set "force_ytdlp_prompt=1"
    echo [debug] Debug mode 3 enabled.
    echo [debug] The Miniforge and yt-dlp setup prompts will be forced.
) else if "%debug_mode%"=="4" (
    set "force_ffmpeg_prompt=1"
    echo [debug] Debug mode 4 enabled.
    echo [debug] The FFmpeg setup prompt will be forced.
) else if "%debug_mode%"=="5" (
    set "force_conda_prompt=1"
    set "force_ytdlp_prompt=1"
    set "force_ffmpeg_prompt=1"
    echo [debug] Debug mode 5 enabled.
    echo [debug] The Miniforge, FFmpeg, and yt-dlp setup prompts will be forced.
) else if "%debug_mode%"=="6" (
    set "verbose_path_debug=1"
    echo [debug] Debug mode 6 enabled.
    echo [debug] Verbose PATH helper output will be enabled.
) else if "%debug_mode%"=="7" (
    set "verbose_path_debug=1"
    set "force_path_probe=1"
    echo [debug] Debug mode 7 enabled.
    echo [debug] PATH helper checks will be forced without changing PATH.
)

if not "%debug_mode%"=="0" (
    echo [debug] Debug prompt-only mode is enabled.
    echo [debug] Setup actions will be shown, but they will not be performed.
)

exit /b 0
