@echo off
echo *** Rename ^<*.htm*^|file mask in %%1^> files (not directories) in current directory which consist of spaces into '_'

set mask=%~1
if "%1"=="" set mask=*.htm*

setlocal EnableDelayedExpansion
for /f "tokens=*" %%i in ('cmd /c dir /b /a:-d %mask%') do (
    set dst_name=%%~nxi
    set dst_name=!dst_name: =_!
    set dst_name=!dst_name:..=.!
    set dst_name=!dst_name:__=_!
    set dst_name=!dst_name:_.=.!
    if not "%%~i"=="!dst_name!" (
        echo ren "%%~i" !dst_name!
        ren "%%~i" !dst_name!
    )
)
endlocal

