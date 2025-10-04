@echo off
title Invariant - Master Project Hub
echo.
echo ========================================
echo    Invariant - Master Project Hub
echo ========================================
echo.
echo Starting Invariant...
echo.

Invariant.exe

if %errorLevel% neq 0 (
    echo.
    echo Error: Failed to start Invariant
    pause
)
