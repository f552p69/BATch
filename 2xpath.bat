@echo off
if "%1"=="" echo %~xn0 [file1.^<json^|xml^>] [file2.^<json^|xml^>] [fileN.^<json^|xml^>]

set "tmp_file=%~dpnx1.$tmp$"
set "native_dir=%~dp0"

:run_more
if "%1"=="" goto :eof

rem Remove comments
set "perl=C:\Program Files (x86)\Git\usr\bin\perl.exe"
"%perl%" -pe "BEGIN { $/=undef } s|<!--.*-->\r\n\r\n||gs" %1 > "%tmp_file%"

rem Check the file format
for /f %%i in (%tmp_file%) do set "first_line=%%i"&goto :break
:break
set "first_char=%first_line:~0,1%"
if "%first_char%"=="<" goto :convert_xml
if "%first_char%"=="{" goto :convert_json

echo Format of '%1' is unknown
exit 

rem Convertion into xpath
:convert_xml
call py32.bat %native_dir%\xml2xpath.py -xns %tmp_file% > "%~xn1.xpath"
:: 1) remove line started with ***
:: 2) add struct['
:: 3) \t==\t into ']\t= "
:: 4) add to the end "
"%perl%" -pe "s|^\*\*\*.*$/||gs" "%~xn1.xpath" | "%perl%" -pe "s|^\/|struct['/|gs" | "%perl%" -pe "s|\t==\t'|']\t= \x22|gs" | "%perl%" -pe "s|\r|\x22|" > "%~xn1.xpath.py"
goto :finish

:convert_json
call py32.bat %native_dir%\json2xpath.py %tmp_file%  > "%~xn1.xpath"
"%perl%" -pe "s|^\[|struct[|gs" "%~xn1.xpath" > "%~xn1.xpath.py"
goto :finish

:finish
::del %tmp_file%
shift
goto :run_more