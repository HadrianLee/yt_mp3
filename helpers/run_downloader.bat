@echo off

if not exist "logs" mkdir logs
set "datestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%"
set "timestamp=%time:~0,2%%time:~3,2%%time:~6,2%"

if "%output_dir%"=="" (
    set "output_dir=download"
    set "log_path=logs/download_%datestamp%_%timestamp%.log"
    python src\__init__.py "%url%" -v --log-file "%log_path%"
) else (
    set "log_path=logs/%output_dir%_%datestamp%_%timestamp%.log"
    python src\__init__.py "%url%" "%output_dir%" -v --log-file "%log_path%"
)

echo.
echo [info] Task finished! View logs in the /logs/ folder.
echo [info] Log file: %log_path%
pause

exit /b %errorlevel%
