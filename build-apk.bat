@echo off
rem Double-click to build the Find My Car APK.
rem Result: dist\find-my-car.apk   Log: build-log.txt
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\build-apk.ps1"
echo.
echo Finished. Result: dist\find-my-car.apk  (log: build-log.txt)
pause
