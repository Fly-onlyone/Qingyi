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

REM Step 3: Install plugins
echo [3/4] Installing plugins...
echo   - Installing qingyi...
claude plugin install qingyi@qingyi
if errorlevel 1 (
    echo ERROR: Failed to install qingyi plugin.
    pause
    exit /b 1
)

echo   - Installing qingyi-code-review...
claude plugin install qingyi-code-review@qingyi
if errorlevel 1 (
    echo ERROR: Failed to install qingyi-code-review plugin.
    pause
    exit /b 1
)

echo   - Installing qingyi-modernizer...
claude plugin install qingyi-modernizer@qingyi
if errorlevel 1 (
    echo ERROR: Failed to install qingyi-modernizer plugin.
    pause
    exit /b 1
)
echo Done.
echo.

REM Step 4: Verify installation
echo [4/4] Verifying installation...
echo.
echo Checking marketplace...
claude plugin marketplace list | findstr "qingyi"
echo.

echo Verifying supporting documentation in plugin cache...
echo.

REM Check if docs were copied to cache
set "CACHE_PATH=%USERPROFILE%\.claude\plugins\cache\qingyi\qingyi\1.3.2\docs\agent-supporting"
if exist "%CACHE_PATH%\brave-search-agent\real-world-examples.md" (
    echo   ✓ Supporting docs copied to cache
    echo   Location: %CACHE_PATH%
) else (
    echo   WARNING: Supporting docs not found in cache
    echo   Expected: %CACHE_PATH%
    echo   Check VERIFICATION.md for manual verification
)
echo.

echo ========================================
echo Installation complete!
echo ========================================
echo.
echo All plugins installed successfully!
echo Supporting documentation is accessible to agents.
echo.
echo Restart Claude Code to use the plugins.
echo.
pause
