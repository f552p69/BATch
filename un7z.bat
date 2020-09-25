@echo off
echo *** Unpack 7z^|zip archive into separate unique directory v0.02
:: My most favorite free archiver (https://www.7-zip.org/download.html):
call :set_var_if_path_exists cli7za "7za.exe"
:: Required external utilities. Most of them are from GIT package (https://git-scm.com/download/win):
call :set_var_if_path_exists perl "perl.exe"
call :set_var_if_path_exists awk "awk.exe"
call :set_var_if_path_exists uniq "uniq.exe"
:: Standard Windows utilities, but could be substituted with GNU
call :set_var_if_path_exists sort "sort.exe"
:: MUST be standard Windows utility. GNU find.exe is not compatible!
call :set_var_if_path_exists find "find.exe"

set "src=%~1"
if "%src%"=="" (
    echo Usage: %~nx0 ^<archive.(7z^|zip^)^> [destination directory]
    echo If optional argument [destination directory] is not defined, archive will be unpacked into current directory.
    exit
)
set "src_fname=%~n1"

set dst_root=%2
if "%2"=="" set dst_root=.%dst_root%
if "%dst_root:~-1%"=="\" set dst_root=%dst_root:~0,-1%

for /f "skip=1" %%x in ('wmic os get localdatetime') do (set yyyymmdd=%%x&&goto break_generate_unique)
:break_generate_unique
set "unique=%yyyymmdd:~2,12%%yyyymmdd:~15,3%"

:: 1) Get the list of files from archive
:: 2) Exclude directories from the list
:: 3) Sort file names
:: 4) Fetch first directory (or file name if in the root of archive)
:: 5) Leave only unique directory or file name(s), and save into "%TEMP%\$tmp$.dstdir"
"%cli7za%" l "%src%" ^
 | "%perl%" -pe "s/(.{20}\..{32}(.*))|(.*)/\2/gs" ^
 | "%sort%" ^
 | "%perl%" -pe "s|([^\\\\]*).*|\1|" ^
 | "%uniq%" > "%TEMP%\%unique%.dstdir.tmp"

:: 6) Count number of unique directories or file names
:: 7) Remove empty lines
:: 8) Take value (number) after ': ', and save into "%TEMP%\$tmp$.count_of_lines"
"%find%" /c /v "Dummy text" "%TEMP%\%unique%.dstdir.tmp" ^
 | "%awk%" /./ ^
 | "%perl%" -pe "s/(^.*: (.*)$)/\2/" > "%TEMP%\%unique%.count_of_lines.tmp"

:: 9) Save value (count of the lines in "%TEMP%\$tmp$.dstdir") into var %count_of_lines%
for /f "delims=" %%A in ('type "%TEMP%\%unique%.count_of_lines.tmp"') do set "count_of_lines=%%A"&&goto :break_read_only_first_line
:break_read_only_first_line
:: echo count_of_lines=%count_of_lines%

if not "%count_of_lines%"=="1" goto :generate_dst_dir
:generate_tmp_dir
set "postfix_for_temp_dir=.%unique%"
:generate_dst_dir
call :unique_if_exist "%dst_root%\%src_fname%%postfix_for_temp_dir%"

:: Unpack to final directory (if several dirs in the root of archive) or temporary root (if just only single dir in the root of archive)
echo *** 7za.exe x "%src%" "-o%dst%\"
7za.exe x "%src%" "-o%dst%\"

if not "%count_of_lines%"=="1" goto :final
:: if just only single dir in the root of archive, move files from temporary dir into final
set "unpacked_root_dir=%dst%"
for /f "delims=" %%A in ('type "%TEMP%\%unique%.dstdir.tmp"') do set "unpacked_dir=%unpacked_root_dir%\%%A"&&set "dst=%dst_root%\%%A"
call :unique_if_exist "%dst%"
echo *** move "%unpacked_dir%" "%dst%"
move "%unpacked_dir%" "%dst%" > nul
echo *** rmdir "%unpacked_root_dir%"
rmdir "%unpacked_root_dir%"

:final
del "%TEMP%\%unique%.dstdir.tmp" 2> nul
del "%TEMP%\%unique%.count_of_lines.tmp" 2> nul
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:unique_if_exist
:: In:  %1 as directory/file name
:: Out: %dst% as UNIQUE directory/file name, which doesn't exist
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "dst=%~1"
if not exist "%~1" goto :eof
REM set count_int=0
:next_unique_file
set /a count_int=%count_int%+1
set count_str=00%count_int%
set count_str=%count_str:~-3%
set "dst=%~1.%count_str%"
if exist "%dst%" goto :next_unique_file
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
