@echo off
for /f "skip=1" %%x in ('wmic os get localdatetime') do (set yyyymmdd=%%x&&goto :break)
:break
set yyyy=%yyyymmdd:~0,4%
set yy=%yyyymmdd:~2,2%
set mm=%yyyymmdd:~4,2%
set dd=%yyyymmdd:~6,2%
set hour=%yyyymmdd:~8,2%
set minute=%yyyymmdd:~10,2%
set second=%yyyymmdd:~12,2%
set milisec=%yyyymmdd:~15,3%
set microsec=%yyyymmdd:~15,6%
set timestamp=%yy%%mm%%dd%_%hour%%minute%
set unique_sepa=%dd%_%hour%%minute%_%second%
set unique=%dd%%hour%%minute%%second%%milisec%
set unique_filename=%unique%
echo yyyymmdd=%yyyymmdd%
echo timestamp=%timestamp%
echo unique=%unique%
echo unique_filename=%unique_filename%
exit /b