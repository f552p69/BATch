@echo off
if "%1"=="" goto :usage
echo ### %~dpnx0 is running...

call :set_var_if_path_exists bzip2 "C:\Program Files (x86)\Git\usr\bin\bzip2.exe"
call :set_var_if_path_exists tar "C:\Program Files (x86)\Git\usr\bin\tar.exe"

call :cut_tail .tar "%~n1" archive

set "dst=."
if not "%~2"=="" set "dst=%~2"

mkdir "%dst%" 2> nul
mkdir "%dst%/%archive%" 2> nul

echo "%~1" =^> "%dst%/%archive%"
"%bzip2%" -dc "%~1" | "%tar%" -x -C "%dst%/%archive%"
echo Mission accomplished

exit
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:cut_tail
call :strlen "%~1"
set "cutted=%~2"
setLocal EnableExtensions EnableDelayedExpansion
set "tail=!cutted:~-%strlen%!"
set "cutted=!cutted:~0,-%strlen%!"
endlocal & set "cutted=%cutted%" & set "tail=%tail%" & set "%~3=%cutted%"
if /i not "%tail%"=="%~1" set "%~3=%~2"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:strlen
setLocal EnableExtensions EnableDelayedExpansion
set "output_var=%~0"
set "input_str=%~1"
set "str_len=0"
if "%input_str%"=="" goto :empty_str
set "str_len=1"
:next_char
for %%a in ("!input_str:~0,-%str_len%!") do set /a "str_len+=1" & if not "%input_str:~0,1%"=="%%~a" goto :next_char
:empty_str
endlocal & set "%output_var:~1%=%str_len%"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:usage
echo *** Unpack *.tar.bz2
echo %~nx0 ^<archive name^> [dst dir, by default current dir]
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
