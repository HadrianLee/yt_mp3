@echo off
setlocal EnableDelayedExpansion

set "state_file=%~1"
set "state_key=%~2"
set "state_value=%~3"

if "!state_key!"=="" (
    echo [error] Usage: %~nx0 ^<properties_file^> ^<key^> ^<value^>
    endlocal & exit /b 1
)

if "!state_file!"=="" (
    echo [error] Usage: %~nx0 ^<properties_file^> ^<key^> ^<value^>
    endlocal & exit /b 1
)

set "temp_file=!state_file!.tmp"

if exist "!temp_file!" del /f /q "!temp_file!" >nul 2>nul
if exist "!state_file!" (
    findstr /v /b /i /c:"!state_key!=" "!state_file!" > "!temp_file!"
) else (
    type nul > "!temp_file!"
)

>> "!temp_file!" echo !state_key!=!state_value!
move /y "!temp_file!" "!state_file!" >nul

endlocal & exit /b 0
