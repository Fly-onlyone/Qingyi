#!/usr/bin/env pwsh
# Qingyi Plugin Reinstall Script (PowerShell)
# Automatically uninstalls and reinstalls the plugin after updates

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Qingyi Plugin Reinstall Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Uninstalling current version..." -ForegroundColor Yellow
& claude plugin uninstall qingyi 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: Uninstall failed or plugin not installed" -ForegroundColor Yellow
    Write-Host "Continuing with installation..." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "[2/3] Installing updated version..." -ForegroundColor Yellow
& claude plugin install qingyi@qingyi-marketplace
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Installation failed!" -ForegroundColor Red
    Write-Host "Please check that:" -ForegroundColor Red
    Write-Host "  - marketplace.json exists in parent directory" -ForegroundColor Red
    Write-Host "  - qingyi-marketplace is added with: /plugin marketplace add" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[3/3] Reinstall complete!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IMPORTANT: Restart Claude Code to load changes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
