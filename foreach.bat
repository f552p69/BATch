@echo off
if "%~2"=="" (
    echo Usage: %~nx0 ^<mask^> ^<command^>
    echo Sample: %~nx0 *.sql "type %%i"
    exit
)
echo Searching...

for /f %%i in ('dir /b /s %1') do (
    echo ******* %%i
    echo *** %~2
    %~2
)