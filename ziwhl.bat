@echo off

if "%1"=="" (
    echo Pack [not only Python] unpacked archives into separate archives by f552p69@gmail.com
    echo Usage: %~xn0 ^<Source dir for UNPACKED whl^> [temp dir for whl]
    echo Sample: %~xn0 .\new2
    exit /B
)
REM call :checknotexist "unrena.bat" unrena
call :checknotexist "gzip" gzip
call :checknotexist "7za" SevenZip

call ::NORMALIZEPATH %1. ziwhl_search_path
REM echo ziwhl_search_path=1=%ziwhl_search_path%
call ::NORMALIZEPATH %2  ziwhl_dst_path
REM if "%2"=="" set "ziwhl_dst_path=%TEMP%"
if "%2"=="" set "ziwhl_dst_path=%ziwhl_search_path%\dist"
md %ziwhl_dst_path% > nul 2> nul

:: Rename all safe extentions into normal
call :unrena *.py# .py    "%ziwhl_search_path%\"
call :unrena *.ba# .bat   "%ziwhl_search_path%\"
call :unrena *.js# .js    "%ziwhl_search_path%\"
call :unrena *.sh# .sh    "%ziwhl_search_path%\"
call :unrena *.vb# .vbs   "%ziwhl_search_path%\"
call :unrena *.ex# .exe   "%ziwhl_search_path%\"
call :unrena *.co# .com   "%ziwhl_search_path%\"
call :unrena *.dl# .dll   "%ziwhl_search_path%\"
call :unrena *.cl# .class "%ziwhl_search_path%\"
call :unrena *.ja# .jar   "%ziwhl_search_path%\"
call :unrena *.wa# .war   "%ziwhl_search_path%\"
call :unrena *.ea# .ear   "%ziwhl_search_path%\"
call :unrena *.jp# .jpg   "%ziwhl_search_path%\"
call :unrena *.je# .jpeg  "%ziwhl_search_path%\"
call :unrena *.pn# .png   "%ziwhl_search_path%\"
call :unrena *.gi# .gif   "%ziwhl_search_path%\"

:: Can't suppress system error mesages:
::      The system cannot find the file specified. == path not exists
::      File Not Found == no dirs were found
REM echo ziwhl_search_path=2=%ziwhl_search_path%
REM exit
echo *** Looking *.whl^|*.zip dirs in '%ziwhl_search_path%'
for /F %%I in ('cmd /c dir /a:d /b %ziwhl_search_path%\*.whl %ziwhl_search_path%\*.zip') do (
    REM echo %ziwhl_search_path%\%%I
    REM exit
:: remove inside archive one level of dirs 
    pushd "%ziwhl_search_path%\%%I\"
:: add .zip to file name as set derictive to use ZIP format 
    echo *** %SevenZip% a -mfb=256 -mpass=15 "%ziwhl_dst_path%\%%I.zip"
    %SevenZip% a -mfb=256 -mpass=15 "%ziwhl_dst_path%\%%I.zip"
    popd
:: remove .zip from file name
    echo *** ren "%ziwhl_dst_path%\%%I.zip" "%%I"
    ren "%ziwhl_dst_path%\%%I.zip" "%%I"
)
echo *** Looking *.tar.gz dirs in '%ziwhl_search_path%'
for /F %%I in ('dir /a:d /b %ziwhl_search_path%\*.tar.gz') do (
    :: for Python inside dir we always have 'dist' dir
    for /F %%J in ('dir /a:d /b %ziwhl_search_path%\%%I\dist\*') do (
        echo *** call ::PACKGZ %ziwhl_search_path%\%%I\dist\%%J\ %%J 
        call ::PACKGZ %ziwhl_search_path%\%%I\dist\%%J\ %%J 
    )
)
:: ========== FUNCTIONS ==========
exit /B

:NORMALIZEPATH
    set RETVAL=%~dpfnx1
    if not "%~2"=="" set "%~2=%RETVAL%"
    exit /B

:FILENAMEEXT
    set RETVAL=%~nx1
    if not "%~2"=="" set "%~2=%RETVAL%"
    exit /B

:PACKGZ
    pushd %1
    echo tar cf %ziwhl_dst_path%\dist\%2 *
    call tar cf %ziwhl_dst_path%\dist\%2 *
    popd 

    pushd %ziwhl_dst_path%\
    echo %gzip% -9 dist\%2
:: convert .tar -> .tar.gz with right structure inside archive
:: original file .tar will be deleted
:: .tar.gz will be created at the SAME directory as .tar 
    call %gzip% -9 dist\%2
:: move to %ziwhl_dst_path%
    move dist\%2.gz .
    popd

    exit /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:checknotexist
set "nextcall=%~dpnx1"
if exist "%nextcall%" goto :checknotexist__result
set "temp_file=%temp%\checknotexist.tmp"
where "%~1" > "%temp_file%"
if not "%errorlevel%"=="0" goto :checknotexist__notfound
REM type "%temp_file%"
for /f "delims=" %%i in (%temp_file%) do set "nextcall=%%i"&&goto :checknotexist__definenextcall
:checknotexist__definenextcall
REM echo "nextcall=%nextcall%"
del "%temp_file%" > nul
if exist "%nextcall%" goto :checknotexist__result
REM goto :checknotexist__notfound
:checknotexist__notfound
echo :checknotexist: "%~1" doesn't exist. Next execution terminated.
exit
:checknotexist__result
if not "%~2"=="" set "%~2=%nextcall%"
exit /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:unrena
call ::NORMALIZEPATH %3. unrena_search_path
for /R "%unrena_search_path%" %%I in (%1) do (
    echo *** ren %%~fnxI %%~nI%2
    ren %%~fnxI %%~nI%2
)
exit /B
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
