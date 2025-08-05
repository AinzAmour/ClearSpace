@echo off
title System Cleaner Tool
color 0A

echo.
echo ========================================
echo    System Cleaner Tool
echo ========================================
echo.

REM Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: PowerShell is not available on this system.
    echo Please install PowerShell 5.1 or higher.
    pause
    exit /b 1
)

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: Not running as Administrator.
    echo Some cleaning operations may require elevated privileges.
    echo.
    echo Press any key to continue anyway, or close this window to run as Administrator.
    pause >nul
)

REM Run the System Cleaner
echo Starting System Cleaner...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0SystemCleaner.ps1" %*

echo.
echo System Cleaner completed.
echo Press any key to exit...
pause >nul 