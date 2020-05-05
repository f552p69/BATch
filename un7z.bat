@echo off
echo *** Unpack 7z^|zip archive into separate unique directory
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
    exit /b
)

set dst_root=%2\
if "%2"=="" set dst_root=.%dst_root%
if "%dst_root:~-2%"=="\\" set dst_root=%dst_root:~0,-1%

:: 1) Get the list of files from archive
:: 2) Exclude directories from the list 
:: 3) Sort file names
:: 4) Fetch first directory (or file name if in the root of archive)
:: 5) Leave only unique directory or file name(s), and save into "%TEMP%\$tmp$.dstdir"
"%cli7za%" l "%src%" ^
 | "%perl%" -pe "s/(.{20}\..{32}(.*))|(.*)/\2/gs" ^
 | "%sort%" ^
 | "%perl%" -pe "s|([^\\\\]*).*|\1|" ^
 | "%uniq%" > "%TEMP%\$tmp$.dstdir"

:: 6) Count number of unique directories or file names
:: 7) Remove empty lines
:: 8) Take value (number) after ': ', and save into "%TEMP%\$tmp$.count_of_lines"
"%find%" /c /v "Dummy text" "%TEMP%\$tmp$.dstdir" ^
 | "%awk%" /./ ^
 | "%perl%" -pe "s/(^.*: (.*)$)/\2/" > "%TEMP%\$tmp$.count_of_lines"

:: 9) Save value (count of the lines in "%TEMP%\$tmp$.dstdir") into var %count_of_lines%
for /f "delims=" %%A in ('type "%TEMP%\$tmp$.count_of_lines"') do set "count_of_lines=%%A"&&goto :just_only_first_line
:just_only_first_line
:: echo count_of_lines=%count_of_lines%

:: If unique name is single, then all files were grouped inside one dir => unpack into %dst_dir%
:: else: unpack into dir with name of archive inside %dst_dir%
if "%count_of_lines%"=="1" (
rem if "grouped" dir already exists, then save into unique dir => so path will be not so beautiful: archive.000\archive\...
rem if NOT exists, so save into dir with name of archive/root dir inside archive => archive\...
    for /f "delims=" %%A in ('type "%TEMP%\$tmp$.dstdir"') do call :unique_if_exist "%dst_root%%%A"
) else (
rem Remove extenstion from %src% (archive.7z) and save into %dst% ((archive)
rem If such file/dir name ((archive) exists, so save into unique dir => archive.000\...
rem if NOT exists, so save into dir with name of archive => archive\...
    for /f "delims=" %%A in ("%src%") do call :unique_if_exist "%dst_root%%%~nA"
)
del "%TEMP%\$tmp$.dstdir" 2> nul
del "%TEMP%\$tmp$.count_of_lines" 2> nul

echo *** 7za.exe x "%src%" "-o%dst%\"
7za.exe x "%src%" "-o%dst%"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:unique_if_exist
:: In:  %1 as directory/file name
:: Out: %dst% as UNIQUE directory/file name, which doesn't exist
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set "dst=%~1"
if not exist "%dst%" goto :eof
set count_int=-1
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
setlocal
for %%* in ("%~1") do set "$VAR$=%%~nx*"
endlocal & set "$VAR$=%$VAR$%"

set "found_file=%~2"
if exist "%~2" goto :define_var
if "%~x2"==".bat" goto :look_in_PATH
if "%~x2"==".cmd" goto :look_in_PATH
if "%~x2"==".exe" goto :look_in_PATH
if "%~x2"==".py" goto :look_in_PATH
if "%~x2"==".pl" goto :look_in_PATH

echo Path of the file '%~2' which should be stored in variable %%%$VAR$%%% doesn't exists
exit
:look_in_PATH
for /f "delims=" %%A in ('where "%~nx2"') do set "found_file=%%A"&&goto :define_var
:define_var
call set "%$VAR$%=%found_file%"
::echo %$VAR$%=%found_file%
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
