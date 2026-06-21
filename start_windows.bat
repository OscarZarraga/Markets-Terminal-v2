@echo off
rem Delegate to the VBS launcher which runs python with no console.
rem This .bat window flashes for a fraction of a second on launch and
rem then closes - the actual server keeps running in the background.
cd /d "%~dp0"
start "" wscript.exe "%~dp0start_windows.vbs"
exit
