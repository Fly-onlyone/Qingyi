#!/bin/bash
# Qingyi Plugin Reinstall Script (Bash)
# Automatically uninstalls and reinstalls the plugin after updates

echo "========================================"
echo "Qingyi Plugin Reinstall Script"
echo "========================================"
echo ""

echo "[1/3] Uninstalling current version..."
claude plugin uninstall qingyi 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Warning: Uninstall failed or plugin not installed"
    echo "Continuing with installation..."
fi
echo ""

echo "[2/3] Installing updated version..."
claude plugin install qingyi@qingyi-marketplace
if [ $? -ne 0 ]; then
    echo "Error: Installation failed!"
    echo "Please check that:"
    echo "  - marketplace.json exists in parent directory"
    echo "  - qingyi-marketplace is added with: /plugin marketplace add"
    exit 1
fi
echo ""

echo "[3/3] Reinstall complete!"
echo ""
echo "========================================"
echo "IMPORTANT: Restart Claude Code to load changes"
echo "========================================"
echo ""
