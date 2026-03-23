@echo off
setlocal EnableDelayedExpansion

set "state_file=installer_state.properties"
set "managed_by_script=false"
set "conda_installed_by_script=false"
set "conda_root="
set "conda_entry="
set "env_name="
set "env_created_by_script=false"
set "package_env_name="
set "ffmpeg_installed_by_script=false"
set "ytdlp_installed_by_script=false"
set "env_exists=0"
set "custom_env_count=0"
set "package_action=keep"
set "env_action=keep"
set "remove_conda=0"
set "remove_project_files=0"

if exist "%state_file%" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%state_file%") do (
        set "%%A=%%B"
    )
)

echo.
echo === Uninstall Summary ===
echo [info] Conda installed by this script: %conda_installed_by_script%
echo [info] Managed environment name: %env_name%
echo [info] Environment created by this script: %env_created_by_script%
echo [info] FFmpeg installed by this script: %ffmpeg_installed_by_script%
echo [info] yt-dlp installed by this script: %ytdlp_installed_by_script%
echo [info] Project files removable on request: main.bat, uninstall.bat, helpers\, src\, logs\

if not exist "%state_file%" (
    echo [warning] No installer state file was found.
    echo [info] Only cache cleanup will be performed.
    goto CLEAN_CACHES
)

if defined conda_root if defined conda_entry (
    if exist "%conda_entry%" (
        set "PATH=%conda_root%\condabin;%conda_root%\Scripts;%conda_root%\Library\bin;%PATH%"
    )
)

if defined env_name if defined conda_entry if exist "%conda_entry%" (
    call :CHECK_ENV_EXISTS "%env_name%"
)

if /i "%env_created_by_script%"=="true" (
    call :PROMPT_ENV_ACTION
    if /i "!env_action!"=="delete" call :DELETE_ENV
    if /i "!env_action!"=="packages" call :REMOVE_TRACKED_PACKAGES
) else (
    if /i "%ffmpeg_installed_by_script%"=="true" set "package_action=packages"
    if /i "%ytdlp_installed_by_script%"=="true" set "package_action=packages"
    if /i "!package_action!"=="packages" call :PROMPT_PACKAGE_ACTION
    if /i "!package_action!"=="packages" call :REMOVE_TRACKED_PACKAGES
)

if /i "%conda_installed_by_script%"=="true" if defined conda_entry if exist "%conda_entry%" (
    call :COUNT_CUSTOM_ENVS
    if "!custom_env_count!"=="0" (
        call :PROMPT_CONDA_REMOVE
        if "!remove_conda!"=="1" call :REMOVE_CONDA
    ) else (
        echo [info] Miniforge will be kept because custom Conda environments still exist.
    )
)

call :PROMPT_PROJECT_CLEANUP
if "!remove_project_files!"=="1" call :REMOVE_PROJECT_FILES

call :MAYBE_DELETE_STATE_FILE

:CLEAN_CACHES
echo [info] Cleaning Python caches under src\...
if exist "src" (
    pushd "src" >nul
    for /d /r %%D in (__pycache__) do if exist "%%D" rmdir /s /q "%%D" >nul 2>nul
    for /r %%F in (*.pyc) do if exist "%%F" del /f /q "%%F" >nul 2>nul
    for /r %%F in (*.pyo) do if exist "%%F" del /f /q "%%F" >nul 2>nul
    if exist ".pytest_cache" rmdir /s /q ".pytest_cache" >nul 2>nul
    popd >nul
)
if exist "MiniforgeInstaller.exe" del /f /q "MiniforgeInstaller.exe" >nul 2>nul

echo [info] Uninstall routine finished.
pause
exit /b 0

:PROMPT_ENV_ACTION
set "env_action="
echo.
echo [info] The environment '%env_name%' was created by this script.
echo [info] Choose what to do:
echo   d = delete the environment
echo   p = keep the environment but remove tracked packages only
echo   k = keep everything
set /p "env_action=Select d/p/k: "
set "env_action=!env_action: =!"
if /i "!env_action!"=="d" set "env_action=delete" & exit /b 0
if /i "!env_action!"=="p" set "env_action=packages" & exit /b 0
if /i "!env_action!"=="k" set "env_action=keep" & exit /b 0
echo [error] Invalid input. Please type d, p, or k.
goto PROMPT_ENV_ACTION

:PROMPT_PACKAGE_ACTION
set "package_action="
echo.
echo [info] Tracked packages can be removed from environment '%env_name%'.
set /p "package_action=Remove tracked packages now? (y/n): "
set "package_action=!package_action: =!"
if /i "!package_action!"=="y" set "package_action=packages" & exit /b 0
if /i "!package_action!"=="n" set "package_action=keep" & exit /b 0
echo [error] Invalid input. Please type y or n.
goto PROMPT_PACKAGE_ACTION

:PROMPT_CONDA_REMOVE
set "remove_conda="
echo.
echo [warning] This script originally installed Miniforge at:
echo           "%conda_root%"
set /p "remove_conda=Delete that Miniforge installation too? (y/n): "
set "remove_conda=!remove_conda: =!"
if /i "!remove_conda!"=="y" set "remove_conda=1" & exit /b 0
if /i "!remove_conda!"=="n" set "remove_conda=0" & exit /b 0
echo [error] Invalid input. Please type y or n.
goto PROMPT_CONDA_REMOVE

:PROMPT_PROJECT_CLEANUP
set "remove_project_files="
echo.
echo [info] Optional project cleanup can remove:
echo   - main.bat
echo   - uninstall.bat
echo   - helpers\  (recursive)
echo   - src\      (recursive)
echo   - logs\     (recursive)
echo [info] The following will be kept:
echo   - downloads\
echo   - README.md
echo   - note.md
echo   - .gitignore
echo   - any unrelated folders such as Rimuru\
set /p "remove_project_files=Remove this project's scripts and source files too? (y/n): "
set "remove_project_files=!remove_project_files: =!"
if /i "!remove_project_files!"=="y" set "remove_project_files=1" & exit /b 0
if /i "!remove_project_files!"=="n" set "remove_project_files=0" & exit /b 0
echo [error] Invalid input. Please type y or n.
goto PROMPT_PROJECT_CLEANUP

:CHECK_ENV_EXISTS
set "env_exists=0"
for /f "tokens=1" %%I in ('call "%conda_entry%" env list 2^>nul ^| findstr /r /c:"^[* ]*%~1[ ]"') do (
    set "env_exists=1"
)
exit /b 0

:COUNT_CUSTOM_ENVS
set "custom_env_count=0"
for /f "tokens=1" %%I in ('call "%conda_entry%" env list 2^>nul ^| findstr /r /v /c:"^#"') do (
    if not "%%I"=="" if /i not "%%I"=="base" set /a "custom_env_count+=1"
)
exit /b 0

:REMOVE_TRACKED_PACKAGES
if not defined env_name (
    echo [warning] No managed environment name was recorded, so package removal was skipped.
    exit /b 0
)
call :CHECK_ENV_EXISTS "%env_name%"
if not "!env_exists!"=="1" (
    echo [warning] Environment '%env_name%' was not found. Clearing tracked package state.
    call helpers\core\state_writer.bat "%state_file%" ffmpeg_installed_by_script false
    call helpers\core\state_writer.bat "%state_file%" ytdlp_installed_by_script false
    exit /b 0
)

if /i "%ffmpeg_installed_by_script%"=="true" (
    echo [info] Removing FFmpeg from '%env_name%'...
    call "%conda_entry%" remove -n "%env_name%" -y ffmpeg >nul 2>nul
    if errorlevel 1 (
        echo [warning] FFmpeg could not be removed automatically from '%env_name%'.
    ) else (
        call helpers\core\state_writer.bat "%state_file%" ffmpeg_installed_by_script false
        set "ffmpeg_installed_by_script=false"
    )
)

if /i "%ytdlp_installed_by_script%"=="true" (
    echo [info] Removing yt-dlp from '%env_name%'...
    call "%conda_entry%" remove -n "%env_name%" -y yt-dlp >nul 2>nul
    if errorlevel 1 (
        call "%conda_entry%" run -n "%env_name%" python -m pip uninstall -y yt-dlp >nul 2>nul
    )
    if errorlevel 1 (
        echo [warning] yt-dlp could not be removed automatically from '%env_name%'.
    ) else (
        call helpers\core\state_writer.bat "%state_file%" ytdlp_installed_by_script false
        set "ytdlp_installed_by_script=false"
    )
)
exit /b 0

:DELETE_ENV
if not defined env_name (
    echo [warning] No managed environment name was recorded.
    exit /b 0
)
call :CHECK_ENV_EXISTS "%env_name%"
if not "!env_exists!"=="1" (
    echo [warning] Environment '%env_name%' no longer exists. Clearing tracked state.
    call helpers\core\state_writer.bat "%state_file%" env_name
    call helpers\core\state_writer.bat "%state_file%" env_created_by_script false
    call helpers\core\state_writer.bat "%state_file%" ffmpeg_installed_by_script false
    call helpers\core\state_writer.bat "%state_file%" ytdlp_installed_by_script false
    call helpers\core\state_writer.bat "%state_file%" package_env_name
    set "env_name="
    set "env_created_by_script=false"
    set "ffmpeg_installed_by_script=false"
    set "ytdlp_installed_by_script=false"
    exit /b 0
)

echo [info] Removing Conda environment '%env_name%'...
call "%conda_entry%" env remove -n "%env_name%" -y
if errorlevel 1 (
    echo [warning] Environment '%env_name%' could not be removed automatically.
    exit /b 0
)

call helpers\core\state_writer.bat "%state_file%" env_name
call helpers\core\state_writer.bat "%state_file%" env_created_by_script false
call helpers\core\state_writer.bat "%state_file%" ffmpeg_installed_by_script false
call helpers\core\state_writer.bat "%state_file%" ytdlp_installed_by_script false
call helpers\core\state_writer.bat "%state_file%" package_env_name
set "env_name="
set "env_created_by_script=false"
set "ffmpeg_installed_by_script=false"
set "ytdlp_installed_by_script=false"
exit /b 0

:REMOVE_CONDA
if not exist "%conda_root%" (
    echo [warning] Miniforge root '%conda_root%' was not found.
    call helpers\core\state_writer.bat "%state_file%" conda_installed_by_script false
    exit /b 0
)

echo [info] Removing Miniforge from '%conda_root%'...
rmdir /s /q "%conda_root%"
if errorlevel 1 (
    echo [warning] Miniforge could not be removed automatically.
    exit /b 0
)

call helpers\core\state_writer.bat "%state_file%" conda_installed_by_script false
call helpers\core\state_writer.bat "%state_file%" conda_root
call helpers\core\state_writer.bat "%state_file%" conda_entry
set "conda_installed_by_script=false"
set "conda_root="
set "conda_entry="
exit /b 0

:REMOVE_PROJECT_FILES
echo [info] Scheduling removal of project scripts and source files...
start "" cmd /c "timeout /t 2 /nobreak >nul & if exist logs rmdir /s /q logs & if exist src rmdir /s /q src & if exist helpers rmdir /s /q helpers & if exist main.bat del /f /q main.bat & if exist uninstall.bat del /f /q uninstall.bat"
exit /b 0

:MAYBE_DELETE_STATE_FILE
if /i "%conda_installed_by_script%"=="true" exit /b 0
if /i "%env_created_by_script%"=="true" exit /b 0
if /i "%ffmpeg_installed_by_script%"=="true" exit /b 0
if /i "%ytdlp_installed_by_script%"=="true" exit /b 0
if exist "%state_file%" del /f /q "%state_file%" >nul 2>nul
exit /b 0
