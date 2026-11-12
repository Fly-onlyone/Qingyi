#!/bin/bash
# Qingyi Plugin Installation Script
# Usage: Run this script from the Qingyi project root directory

set -e

echo "========================================"
echo "Qingyi Plugin Installation Script"
echo "========================================"
echo ""

# Step 1: Remove existing marketplace if present
echo "[1/4] Removing existing marketplace (if any)..."
claude plugin marketplace remove qingyi 2>/dev/null || true
echo "Done."
echo ""

# Step 2: Add marketplace from current directory
echo "[2/4] Adding marketplace from current directory..."
if ! claude plugin marketplace add ./; then
    echo "ERROR: Failed to add marketplace. Make sure you are in the Qingyi root directory."
    exit 1
fi
echo "Done."
echo ""

# Step 3: Clear plugin cache to prevent EEXIST errors on reinstall
echo "[3/4] Clearing plugin cache..."
rm -rf "${HOME}/.claude/plugins/cache"
echo "Done."
echo ""

# Step 4: Install plugin
echo "[4/4] Installing plugin..."
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
echo "  /qingyi:project-init - Initialize project configuration (CLAUDE.md + .claude/rules/)"
echo ""
echo "Start a new Claude Code session, or run /reload-plugins in an open one, to use the plugin."
