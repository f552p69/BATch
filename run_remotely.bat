@echo off
if "%5"=="" goto :usage
echo ### %~dpnx0 is running...

call :set_var_if_path_exists bzip2 "C:\Program Files (x86)\Git\usr\bin\bzip2.exe"
call :set_var_if_path_exists plink "R:\UTIL\plink.exe"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM set "srv=SERVER001"
REM set "usr=XXX"
REM set "psw=YYY"
REM set "hst=10.10.10.10"
REM set "cmd=find /tomcat/appserver/applications -name tibjms.jar -exec wc -c {} + | sort | grep -v "" total"""

set "srv=%~1"
REM echo srv=%srv%
set "usr=%~2"
REM echo usr=%usr%
set "psw=%~3"
REM echo psw=%psw%
set "hst=%~4"
REM echo hst=%hst%
set "cmd=%5"
set "cmd=%cmd:_SPC_= %"
REM If without ^, then impossible to print to screen
set "cmd=%cmd:_TUB_=|%"
set "cmd=%cmd:_DQT_="%"
REM set "cmd=%cmd:_TUB_=^|%"
REM set "cmd=%cmd:_DQT_=^"%"
REM echo cmd=%cmd%
set "log=&2"
if not "%6"=="" set "log=%~6"
REM echo log=%log%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo *** %srv%=%hst% >%log%
"%plink%" -C -pw %psw% %usr%@%hst% "%cmd% | bzip2 --best -c" | "%bzip2%" -dc >>%log%
 
goto :eof

:usage
echo *** Run at remote host ***
echo %~nx0 ^<srv^> ^<usr^> ^<psw^> ^<hst^> ^<command^> [log file]

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
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
