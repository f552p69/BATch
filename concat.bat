@echo off
:: Concatenate files with mask %1 (if not set, then *.xpath in current directory)
:: into single file %2 (if not set, then '$tmp$')
set "src=%1"
if "%src%"=="" set "src=*.xpath"

set "dst=%2"
if "%dst%"=="" set "dst=$tmp$"

:: Create empty file
copy nul "%dst%" > nul

for /f %%i in ('dir /s /b %src%') do (
    echo %%i
    copy "%dst%" + "%%i" > nul
)

setlocal enableextensions enabledelayedexpansion
for %%i in ("%dst%") do if %%~zi equ 0 (
    del "%dst%"
    echo *** Nothing done
) else (
    echo *** CONCATINATED SUCCESSFULY
)
endlocal
