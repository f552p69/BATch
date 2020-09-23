@echo off

if "%1"=="" (
    echo Repack [not only Python] archives into one solid 7z archive by f552p69@gmail.com
    echo Usage:  %~xn0 ^<tmp dir for unpacking^> [dir with archives, by default = current = .]
    echo Sample: %~xn0 .\new
    exit /B
)
call :checknotexist "unzip" unzip
REM call :checknotexist "unrena.bat" unrena
call :checknotexist "tar" tar
call :checknotexist "gzip" gzip
call :checknotexist "7za" SevenZip

call ::NORMALIZEPATH %1 dst_path
call ::FILENAMEEXT %1 dst_archive
set dst_archive=%dst_path%\%dst_archive%
call ::NORMALIZEPATH %2. search_path

md %dst_path% 2> nul
for /R "%search_path%" %%I in (*.whl,*.zip) do (
    echo "%unzip%" %%I -d %dst_path%\%%~xnI\
    call "%unzip%" %%I -d %dst_path%\%%~xnI\
)
for /R "%search_path%" %%I in (*.tar.gz) do (
    echo *** UNPACKGZ %%~fI %dst_path%\%%~nxI\dist\%%~nI
    call ::UNPACKGZ %%~fI %dst_path%\%%~nxI\dist\%%~nI
)

:: Rename all possible dangerous files into safe extentions
call :unrena *.py    .py# "%dst_path%\"
call :unrena *.bat   .ba# "%dst_path%\"
call :unrena *.js    .js# "%dst_path%\"
call :unrena *.sh    .sh# "%dst_path%\"
call :unrena *.vbs   .vb# "%dst_path%\"
call :unrena *.exe   .ex# "%dst_path%\"
call :unrena *.com   .co# "%dst_path%\"
call :unrena *.dll   .dl# "%dst_path%\"
call :unrena *.class .cl# "%dst_path%\"
call :unrena *.jar   .ja# "%dst_path%\"
call :unrena *.war   .wa# "%dst_path%\"
call :unrena *.ear   .ea# "%dst_path%\"
call :unrena *.jpg   .jp# "%dst_path%\"
call :unrena *.jpeg  .je# "%dst_path%\"
call :unrena *.png   .pn# "%dst_path%\"
call :unrena *.gif   .gi# "%dst_path%\"

pushd "%dst_path%"
:: Ultra compression with header encryption with password 654321  
echo *** "%SevenZip%" a -p654321 -mhe=on -mx9 %dst_archive%
"%SevenZip%" a -p654321 -mhe=on -mx9 %dst_archive%.7z
popd

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

:UNPACKGZ
:: Create dir for unpacked *.tar.gz 
    md %2 2> nul
:: *.tar.gz -> *.tar 
:: BUG-FEATURE: It's possible to creat *.tar ONLY in the same dir as *.tar.gz 
:: BAT: @D:\util\util_old\PortableGit-2.7.2-64-bit\usr\bin\gzip.exe %*
    call %gzip% -k -d %1
:: unpack *.tar
:: BAT: @D:\util\util_old\PortableGit-2.7.2-64-bit\usr\bin\tar.exe %* 
    call %tar% -xf %~pn1 -C %2
:: delete *.tar
    del %~pn1 > nul

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
