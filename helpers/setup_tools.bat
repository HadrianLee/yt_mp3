@echo off

call helpers\ensure_tool_path.bat ffmpeg
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    set "needs_ffmpeg=1"
) else (
    set "needs_ffmpeg=0"
)

if "%force_ffmpeg_prompt%"=="1" set "needs_ffmpeg=1"

if "%needs_ffmpeg%"=="1" (
    if "%force_ffmpeg_prompt%"=="1" (
        echo [debug] Debug mode is forcing the FFmpeg install prompt for '%target_env%'.
    ) else (
        echo [error] FFmpeg is missing in environment '%target_env%'.
    )
    echo [info] FFmpeg is required for audio conversion and metadata embedding.
    echo [info] Project page: https://ffmpeg.org/

    :PROMPT_FFMPEG
    set /p "choice_ffmpeg=Would you like to install FFmpeg in '%target_env%' now? (y/n): "

    if /i "%choice_ffmpeg%"=="y" (
        if not "%debug_mode%"=="0" (
            echo [debug] Debug mode is active, so FFmpeg will not be installed.
            echo [debug] This prompt was shown for testing only.
        ) else (
            echo [info] Installing FFmpeg into %target_env%...
            conda install -y -c conda-forge ffmpeg
            call helpers\ensure_tool_path.bat ffmpeg
            where ffmpeg >nul 2>nul
            if %errorlevel% neq 0 (
                echo [error] FFmpeg was installed, but it is not yet available on PATH in this session.
                echo [info] Please restart and run the script again.
                pause
                exit /b 1
            )
        )
    ) else if /i "%choice_ffmpeg%"=="n" (
        echo [error] FFmpeg is required to run the program.
        pause
        exit /b 1
    ) else (
        echo [error] Invalid input. Please type 'y' or 'n'.
        goto PROMPT_FFMPEG
    )
)

call helpers\ensure_tool_path.bat yt-dlp
python -c "import yt_dlp" 2>nul
if %errorlevel% neq 0 (
    set "needs_ytdlp=1"
) else (
    set "needs_ytdlp=0"
)

if "%force_ytdlp_prompt%"=="1" set "needs_ytdlp=1"

if "%needs_ytdlp%"=="1" (
    if "%force_ytdlp_prompt%"=="1" (
        echo [debug] Debug mode is forcing the yt-dlp install prompt for '%target_env%'.
    ) else (
        echo [error] yt-dlp is missing in environment '%target_env%'.
    )
    echo [info] yt-dlp is required for downloads.
    echo [info] Project page: https://github.com/yt-dlp/yt-dlp

    :PROMPT_YTDLP
    set /p "choice_dlp=Would you like to install yt-dlp in '%target_env%' now? (y/n): "

    if /i "%choice_dlp%"=="y" (
        if not "%debug_mode%"=="0" (
            echo [debug] Debug mode is active, so yt-dlp will not be installed.
            echo [debug] This prompt was shown for testing only.
            pause
        ) else (
            echo [info] Installing yt-dlp into %target_env%...
            conda install -y -c conda-forge yt-dlp
            call helpers\ensure_tool_path.bat yt-dlp
            echo [info] yt-dlp installation step finished.
            pause
        )
    ) else if /i "%choice_dlp%"=="n" (
        echo [error] yt-dlp is required to run the program.
        pause
        exit /b 1
    ) else (
        echo [error] Invalid input. Please type 'y' or 'n'.
        goto PROMPT_YTDLP
    )
)

exit /b 0
