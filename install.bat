@echo off
title Invariant Installer
echo.
echo ========================================
echo    Invariant - Master Project Hub
echo ========================================
echo.
echo Installing Invariant...
echo.

REM 설치 디렉토리 생성
if not exist "C:\Invariant" mkdir "C:\Invariant"

REM EXE 파일 복사
copy "Invariant.exe" "C:\Invariant\Invariant.exe"

REM 바로가기 생성
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Invariant.lnk'); $Shortcut.TargetPath = 'C:\Invariant\Invariant.exe'; $Shortcut.WorkingDirectory = 'C:\Invariant'; $Shortcut.Save()"

echo.
echo ✅ Installation complete!
echo.
echo Invariant has been installed to C:\Invariant
echo Desktop shortcut created
echo.
echo Press any key to launch Invariant...
pause >nul

REM Invariant 실행
start "" "C:\Invariant\Invariant.exe"

exit
