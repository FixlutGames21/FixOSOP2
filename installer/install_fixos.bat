@echo off
setlocal
title FixOS Installer
color 0B

echo ============================================
echo          FixOS Reimagine Installer
echo ============================================
echo.
set DEFAULT_DIR=%USERPROFILE%\Desktop\FixOS
set /p TARGET_DIR=Folder for install [%DEFAULT_DIR%]: 
if "%TARGET_DIR%"=="" set TARGET_DIR=%DEFAULT_DIR%

echo.
echo Creating folders...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
if not exist "%TARGET_DIR%\app" mkdir "%TARGET_DIR%\app"

echo Copying system files...
copy /Y "%~dp0..\app\index.html" "%TARGET_DIR%\app\index.html" >nul
copy /Y "%~dp0..\app\styles.css" "%TARGET_DIR%\app\styles.css" >nul
copy /Y "%~dp0..\app\app.js" "%TARGET_DIR%\app\app.js" >nul

echo Creating launcher...
(
echo @echo off
echo start "" "%TARGET_DIR%\app\index.html"
) > "%TARGET_DIR%\Launch FixOS.bat"

echo.
echo Installation complete.
echo FixOS installed to:
echo %TARGET_DIR%
echo.
echo Use "Launch FixOS.bat" to start the system.
echo.
pause
