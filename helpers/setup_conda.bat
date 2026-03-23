@echo off

set "conda_in_path=0"
where conda >nul 2>nul
if %errorlevel% equ 0 set "conda_in_path=1"

if "%force_conda_prompt%"=="1" set "conda_in_path=0"

if "%conda_in_path%"=="0" (
    if exist "%USERPROFILE%\miniforge3\condabin\conda.bat" (
        echo [info] Conda was not found on PATH on this system.
        echo [info] An existing Miniforge3 installation was found at %USERPROFILE%\miniforge3
        call helpers\ensure_conda_path.bat
        echo [info] Please restart and run the script again.
        pause
        exit /b 1
    ) else (
        if "%force_conda_prompt%"=="1" (
            echo [debug] Debug mode is forcing the Miniforge install prompt.
        ) else (
            echo [error] Conda was not found on your system.
        )
        echo [info] Miniforge3 is required for the Conda environment.
        echo [info] Project page: https://github.com/conda-forge/miniforge
        echo [info] Please install it to %USERPROFILE%\miniforge3
        echo [info] unless you prefer to configure the Conda paths yourself.

        :PROMPT_CONDA
        set /p "choice=Would you like to install Miniforge3 now? (y/n): "

        if /i "%choice%"=="y" (
            if not "%debug_mode%"=="0" (
                echo [debug] Debug mode is active, so the Miniforge3 installer will not be downloaded or run.
                echo [debug] This prompt was shown for testing only.
            ) else (
                echo [info] Downloading the Miniforge3 installer...
                curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe -o MiniforgeInstaller.exe
                echo [info] Running the installer. Please follow the setup prompts on screen.
                start /wait MiniforgeInstaller.exe
                del MiniforgeInstaller.exe
                if exist "%USERPROFILE%\miniforge3\condabin\conda.bat" (
                    echo [info] Miniforge3 now appears to be installed at %USERPROFILE%\miniforge3
                    echo [info] If setup added or updated the required paths,
                    echo [info] the current session will need to be restarted before they are available.
                    echo [info] Please restart and run the script again.
                ) else (
                    echo [info] Setup has finished. Please restart and run the script again.
                )
            )
            pause
            exit /b 1
        ) else if /i "%choice%"=="n" (
            echo [error] Miniforge is required to continue.
            pause
            exit /b 1
        ) else (
            echo [error] Invalid input. Please type 'y' or 'n'.
            goto PROMPT_CONDA
        )
    )
)

echo.
echo === Environment Setup ===
set "target_env=base"
echo [info] Choose the Conda environment for this downloader.
set /p "target_env=Environment name (press Enter for 'base'): "
echo [info] Activating %target_env%...
call conda activate %target_env%
if errorlevel 1 (
    echo [error] Failed to activate the Conda environment '%target_env%'.
    pause
    exit /b 1
)

exit /b 0
