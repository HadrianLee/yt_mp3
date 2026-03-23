@echo off
setlocal EnableDelayedExpansion

set "target_env=yt_mp3"
set "export_target_env="
set "export_conda_prefix="
set "export_conda_default_env="
set "export_path="
set "debug=0"
set "target_env_exists=0"
set "env_created_now=0"
set "state_file=installer_state.properties"
set "tracked_package_env="

set "conda_root=%~1"
set "conda_entry=%~2"

if "!conda_entry!"=="" (
    echo [error] Usage: %~nx0 ^<conda_root^> ^<conda_entry^> [--debug]
    exit /b 1
)

shift
shift

:PARSE_FLAG
if "%~1"=="" goto FLAGS_DONE
if /i "%~1"=="--debug" (
    set "debug=1"
    shift
    goto PARSE_FLAG
)
echo [error] Invalid flag: %~1
echo [info] Usage: %~nx0 ^<conda_root^> ^<conda_entry^> [--debug]
endlocal & exit /b 1

:FLAGS_DONE
echo.
echo === Environment Setup ===
echo [info] Choose the Conda environment for this downloader.
set "target_env_input="
set /p "target_env_input=Environment name (press Enter for 'yt_mp3'): "
set "target_env_input=!target_env_input: =!"
if not "!target_env_input!"=="" set "target_env=!target_env_input!"

if exist "!state_file!" (
    for /f "usebackq tokens=1,* delims==" %%A in ("!state_file!") do (
        if /i "%%A"=="package_env_name" set "tracked_package_env=%%B"
    )
)

if "!debug!"=="1" if "%conda_exists%"=="1" (
    echo [debug] Simulating activation of Conda environment '!target_env!'.
    set "export_target_env=!target_env!"
    set "export_conda_prefix=!conda_root!"
    set "export_conda_default_env=!target_env!"
    set "export_path=!PATH!"
    goto FINALIZE_ACTIVATE_CONDA
)

if not exist "!conda_entry!" (
    echo [error] The Conda entrypoint was not found at "!conda_entry!".
    echo [info] Run helpers\conda\conda_handler.bat before activation.
    endlocal & exit /b 1
)

set "export_target_env=!target_env!"
set "PATH=!conda_root!\condabin;!conda_root!\Scripts;!conda_root!\Library\bin;!PATH!"

call "!conda_entry!" env list >nul 2>nul
for /f "tokens=1" %%I in ('call "!conda_entry!" env list 2^>nul ^| findstr /r /c:"^[* ]*!target_env![ ]"') do (
    set "target_env_exists=1"
)

if "!target_env_exists!"=="0" (
    if "!debug!"=="1" (
        echo [debug] Simulating creation of Conda environment '!target_env!'.
    ) else (
        echo [info] Conda environment '!target_env!' does not exist yet.
        echo [info] Creating Conda environment '!target_env!'...
        call "!conda_entry!" create -y -n "!target_env!" python
        if errorlevel 1 (
            echo [error] Failed to create the Conda environment '!target_env!'.
            pause
            endlocal & exit /b 1
        )
        set "env_created_now=1"
    )
)

echo [info] Activating !target_env!...
call "!conda_entry!" activate "!target_env!"
if errorlevel 1 (
    echo [error] Failed to activate the Conda environment '!target_env!'.
    pause
    endlocal & exit /b 1
)

set "export_conda_prefix=!CONDA_PREFIX!"
if not defined export_conda_prefix set "export_conda_prefix=!conda_root!"
set "export_conda_default_env=!CONDA_DEFAULT_ENV!"
if not defined export_conda_default_env set "export_conda_default_env=!target_env!"
set "export_path=!PATH!"

if not "!debug!"=="1" (
    call helpers\core\state_writer.bat "!state_file!" managed_by_script true
    call helpers\core\state_writer.bat "!state_file!" env_name "!target_env!"
    call helpers\core\state_writer.bat "!state_file!" env_created_by_script false
    if "!env_created_now!"=="1" (
        call helpers\core\state_writer.bat "!state_file!" env_created_by_script true
    )
    if /i not "!tracked_package_env!"=="!target_env!" (
        call helpers\core\state_writer.bat "!state_file!" package_env_name "!target_env!"
        call helpers\core\state_writer.bat "!state_file!" ffmpeg_installed_by_script false
        call helpers\core\state_writer.bat "!state_file!" ytdlp_installed_by_script false
    )
)

:FINALIZE_ACTIVATE_CONDA
endlocal & (
    set "target_env=%export_target_env%"
    set "CONDA_PREFIX=%export_conda_prefix%"
    set "CONDA_DEFAULT_ENV=%export_conda_default_env%"
    set "PATH=%export_path%"
) 

exit /b 0
