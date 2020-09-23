@echo off
if "%2"=="" echo usage: %~nx0 ^<file to send^> ^<url.conf^>&exit

for /f %%i in (%2) do set "url=%%i"&&goto :run_curl

:run_curl
java -jar send.jar "%url%" %1

