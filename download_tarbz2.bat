@echo off
if "%7"=="" goto :usage
echo ### %~dpnx0 is running...

call :set_var_if_path_exists plink "T:\Implementation\180 Release\hotfix_19.4.8\bau-hotfix_hotfix_19.4.8.2\deployment\script\plink.exe"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "srv=%~1"
set "usr=%~2"
set "psw=%~3"
set "hst=%~4"
set "src=%~5"
set "msk=%~6"
set "dst=%~7"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM set "srv=SERVER001"
REM set "usr=XXX"
REM set "psw=XXX"
REM set "hst=10.10.10.10"
REM set "src=/opt/tibco/tibco_5_13_home/home/tra/domain/TECH_DEVELOPMENT/datafiles"
REM REM ::::: Only parameters :::::
REM set "msk=./*/defaultVars/"
REM REM ::::: All :::
REM REM set "msk=."
REM REM ::::: Save into current dir :::::
REM set "dst=."

echo %hst%%src%%msk% =^> %dst%/%srv%.tar.bz2
"%plink%" -C -pw %psw% %usr%@%hst% ^
 "cd %src%"^
 "&&tar cf - %msk%|bzip2 --best -c"^
 > "%dst%/%srv%.tar.bz2"
 

if "%8"=="" goto :eof
start "%~dp0unpack_tarbz2.bat" "%dst%/%srv%.tar.bz2" "%dst%"

goto :eof

:usage
echo *** Pack and download all files in directories from remote host
echo %~nx0 ^<srv^> ^<usr^> ^<psw^> ^<hst^> ^<src^> ^<msk^> ^<dst^> [add any word to unpack]

goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:set_var_if_path_exists
:: In:  %1 as var name, %2 exe/bat file name
:: Out: !%1! == %2 or interrupt of execution
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "found_file=%~2"
if exist "%~2" goto :define_var
if "%~x2"==".bat" goto :look_in_PATH
if "%~x2"==".cmd" goto :look_in_PATH
if "%~x2"==".exe" goto :look_in_PATH
if "%~x2"==".py" goto :look_in_PATH
if "%~x2"==".pl" goto :look_in_PATH
:notfound_in_PATH
echo File '%~2' which should be stored in variable %%%~1%% doesn't exists
exit
:look_in_PATH
for /f "delims=" %%A in ('where "%~nx2"') do set "found_file=%%A"&&goto :define_var
goto :notfound_in_PATH
:define_var
set "%~1=%found_file%"
goto :eof
