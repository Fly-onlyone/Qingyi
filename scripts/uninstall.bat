@echo off
REM Qingyi Plugin Uninstall Script
REM Usage: Run this script to remove all Qingyi plugins

echo ========================================
echo Qingyi Plugin Uninstall Script
echo ========================================
echo.

REM Step 1: Uninstall plugins
echo [1/2] Uninstalling plugins...
echo   - Uninstalling qingyi-modernizer...
claude plugin uninstall qingyi-modernizer 2>nul

echo   - Uninstalling qingyi-code-review...
claude plugin uninstall qingyi-code-review 2>nul

echo   - Uninstalling qingyi...
claude plugin uninstall qingyi 2>nul
echo Done.
echo.

REM Step 2: Remove marketplace
echo [2/2] Removing marketplace...
claude plugin marketplace remove qingyi 2>nul
echo Done.
echo.

echo ========================================
echo Uninstall complete!
echo ========================================
echo.
pause
