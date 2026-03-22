@echo off
setlocal enabledelayedexpansion

set "debug_mode=0"

:PARSE_ARGS
if "%~1"=="" goto ARGS_DONE
if /i "%~1"=="--help" goto SHOW_HELP
if /i "%~1"=="-h" goto SHOW_HELP
if /i "%~1"=="--debug" (
    if "%~2"=="" (
        echo [!] Missing value for --debug.
        goto SHOW_HELP
    )
    if not "%~2"=="1" if not "%~2"=="2" if not "%~2"=="3" (
        echo [!] Invalid value for --debug: %~2
        goto SHOW_HELP
    )
    set "debug_mode=%~2"
    shift
    shift
    goto PARSE_ARGS
)
if "%~1:~0,1%"=="-" (
    echo [!] Invalid flag: %~1
    goto SHOW_HELP
)
echo [!] Unexpected argument: %~1
goto SHOW_HELP

:SHOW_HELP
echo Usage: main.bat [--debug MODE]
echo.
echo Options:
echo   --debug 1    Force the Miniforge prompt
echo   --debug 2    Force the yt-dlp prompt
echo   --debug 3    Force both prompts
echo   --help, -h   Show this help message
pause
exit /b 1

:ARGS_DONE
if "!debug_mode!"=="1" (
    echo [!] Debug mode 1 enabled.
    echo [!] The Miniforge install prompt will be forced.
) else if "!debug_mode!"=="2" (
    echo [!] Debug mode 2 enabled.
    echo [!] The yt-dlp install prompt will be forced.
) else if "!debug_mode!"=="3" (
    echo [!] Debug mode 3 enabled.
    echo [!] The Miniforge and yt-dlp install prompts will be forced.
)

:: 1. Check/Install Miniforge
where conda >nul 2>nul
if %errorlevel% neq 0 (
    set "needs_conda=1"
) else (
    set "needs_conda=0"
)

if "!debug_mode!"=="1" set "needs_conda=1"
if "!debug_mode!"=="3" set "needs_conda=1"

if "!needs_conda!"=="1" (
    if "!debug_mode!"=="1" (
        echo [!] Debug mode is forcing the Miniforge install prompt.
    ) else if "!debug_mode!"=="3" (
        echo [!] Debug mode is forcing the Miniforge install prompt.
    ) else (
        echo [!] Conda was not found on your system.
    )
    echo [!] Miniforge3 is required for the Conda environment.
    echo [!] Project page: https://github.com/conda-forge/miniforge
    
    :PROMPT_CONDA
    set /p "choice=Install Miniforge3 now? (y/n): "
    
    if /i "!choice!"=="y" (
        echo [+] Downloading Miniforge3...
        curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe -o MiniforgeInstaller.exe
        echo [+] Running installer... follow the prompts on screen.
        start /wait MiniforgeInstaller.exe
        del MiniforgeInstaller.exe
        echo [!] Please restart this script after installation completes.
        pause
        exit /b
    ) else if /i "!choice!"=="n" (
        echo [!] Miniforge is required to continue.
        pause
        exit /b
    ) else (
        echo [!] Invalid input. Please type 'y' or 'n'.
        goto PROMPT_CONDA
    )
)

:: 2. Choose Conda Environment
echo.
echo === Environment Setup ===
set "target_env=base"
echo [!] Choose the Conda environment for this downloader.
set /p "target_env=Environment name (press Enter for 'base'): "
echo [+] Activating !target_env!...
call conda activate !target_env!

:: 3. Check/Install yt-dlp
python -c "import yt_dlp" 2>nul
if %errorlevel% neq 0 (
    set "needs_ytdlp=1"
) else (
    set "needs_ytdlp=0"
)

if "!debug_mode!"=="2" set "needs_ytdlp=1"
if "!debug_mode!"=="3" set "needs_ytdlp=1"

if "!needs_ytdlp!"=="1" (
    if "!debug_mode!"=="2" (
        echo [!] Debug mode is forcing the yt-dlp install prompt for '!target_env!'.
    ) else if "!debug_mode!"=="3" (
        echo [!] Debug mode is forcing the yt-dlp install prompt for '!target_env!'.
    ) else (
        echo [!] yt-dlp is missing in environment '!target_env!'.
    )
    echo [!] yt-dlp is required for downloads.
    echo [!] Project page: https://github.com/yt-dlp/yt-dlp
    
    :PROMPT_YTDLP
    set /p "choice_dlp=Install yt-dlp in '!target_env!' now? (y/n): "
    
    if /i "!choice_dlp!"=="y" (
        echo [+] Installing yt-dlp into !target_env!...
        conda install -y -c conda-forge yt-dlp
    ) else if /i "!choice_dlp!"=="n" (
        echo [!] yt-dlp is required to run the program.
        pause
        exit /b
    ) else (
        echo [!] Invalid input. Please type 'y' or 'n'.
        goto PROMPT_YTDLP
    )
)

:: 4. User Inputs
echo.
echo === Download Configuration ===
set /p "url=>>> Paste the YouTube URL here: "
set /p "output_dir=>>> Save to which folder? (Press Enter for 'download/'): "

:: 5. Logging and Execution
if not exist "logs" mkdir logs
set "datestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%"
set "timestamp=%time:~0,2%%time:~3,2%%time:~6,2%"

if "%output_dir%"=="" (
    set "output_dir=download"
    set "log_path=logs/download_!datestamp!_!timestamp!.log"
    python src\__init__.py "!url!" -v --log-file "!log_path!"
) else (
    set "log_path=logs/!output_dir!_!datestamp!_!timestamp!.log"
    python src\__init__.py "!url!" "!output_dir!" -v --log-file "!log_path!"
)

echo.
echo [+] Task finished! View logs in the /logs/ folder.
echo [+] Log file: !log_path!
pause
