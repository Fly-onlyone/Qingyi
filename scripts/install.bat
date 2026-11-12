@echo off
REM Qingyi Plugin Installation Script
REM Usage: Run this script from the Qingyi project root directory

echo ========================================
echo Qingyi Plugin Installation Script
echo ========================================
echo.

REM Step 1: Remove existing marketplace if present
echo [1/4] Removing existing marketplace (if any)...
claude plugin marketplace remove qingyi 2>nul
echo Done.
echo.

REM Step 2: Add marketplace from current directory
echo [2/4] Adding marketplace from current directory...
claude plugin marketplace add ./
if errorlevel 1 (
    echo ERROR: Failed to add marketplace. Make sure you are in the Qingyi root directory.
    pause
    exit /b 1
)
echo Done.
echo.

REM Step 3: Clear plugin cache to prevent EEXIST errors on reinstall
echo [3/4] Clearing plugin cache...
if exist "%USERPROFILE%\.claude\plugins\cache" (
    rmdir /s /q "%USERPROFILE%\.claude\plugins\cache"
)
echo Done.
echo.

REM Step 4: Install plugin
echo [4/4] Installing plugin...
echo   - Installing qingyi...
claude plugin install qingyi@qingyi
if errorlevel 1 (
    echo ERROR: Failed to install qingyi plugin.
    pause
    exit /b 1
)
echo Done.
echo.

echo ========================================
echo Installation complete!
echo ========================================
echo.
echo Qingyi plugin installed successfully!
echo.
echo Available command:
echo   /qingyi:project-init - Initialize project configuration (CLAUDE.md + .claude/rules/)
echo.
echo Start a new Claude Code session, or run /reload-plugins in an open one, to use the plugin.
echo.
pause
