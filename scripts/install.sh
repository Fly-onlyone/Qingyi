#!/bin/bash
# Qingyi Plugin Installation Script
# Usage: Run this script from the Qingyi project root directory

set -e

echo "========================================"
echo "Qingyi Plugin Installation Script"
echo "========================================"
echo ""

# Step 1: Remove existing marketplace if present
echo "[1/3] Removing existing marketplace (if any)..."
claude plugin marketplace remove qingyi 2>/dev/null || true
echo "Done."
echo ""

# Step 2: Add marketplace from current directory
echo "[2/3] Adding marketplace from current directory..."
if ! claude plugin marketplace add ./; then
    echo "ERROR: Failed to add marketplace. Make sure you are in the Qingyi root directory."
    exit 1
fi
echo "Done."
echo ""

# Step 3: Install plugin
echo "[3/3] Installing plugin..."
echo "  - Installing qingyi..."
if ! claude plugin install qingyi@qingyi; then
    echo "ERROR: Failed to install qingyi plugin."
    exit 1
fi
echo "Done."
echo ""

echo "========================================"
echo "Installation complete!"
echo "========================================"
echo ""
echo "Qingyi plugin installed successfully!"
echo ""
echo "Available command:"
echo "  /init - Initialize project configuration (CLAUDE.md + .claude/rules/)"
echo ""
echo "Restart Claude Code to use the plugin."
