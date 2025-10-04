@echo off
title Invariant - Master Project Hub
echo.
echo ========================================
echo    Invariant - Master Project Hub
echo ========================================
echo.
echo Starting Invariant...
echo.

python Master_Launcher.py

if %errorLevel% neq 0 (
    echo.
    echo Error: Failed to start Invariant
    echo Please make sure Python is installed
    pause
)
