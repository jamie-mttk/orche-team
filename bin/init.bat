@echo off
set /p CONFIRM=Init system may cause unexpected problems,type YES to confirm:
if /I "%CONFIRM%"=="YES" goto confirmed
echo Init abort,type any key to continue!
pause
exit
:confirmed

server.bat init  %1 %2 %3 %4 %5 %6
pause