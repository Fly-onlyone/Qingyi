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

# Step 3: Install plugins
echo "[3/4] Installing plugins..."
echo "  - Installing qingyi..."
if ! claude plugin install qingyi@qingyi; then
    echo "ERROR: Failed to install qingyi plugin."
    exit 1
fi

echo "  - Installing qingyi-code-review..."
if ! claude plugin install qingyi-code-review@qingyi; then
    echo "ERROR: Failed to install qingyi-code-review plugin."
    exit 1
fi

echo "  - Installing qingyi-modernizer..."
if ! claude plugin install qingyi-modernizer@qingyi; then
    echo "ERROR: Failed to install qingyi-modernizer plugin."
    exit 1
fi
echo "Done."
echo ""

# Step 4: Verify installation
echo "[4/4] Verifying installation..."
echo ""
echo "Checking marketplace..."
claude plugin marketplace list | grep "qingyi"
echo ""

echo "Verifying supporting documentation in plugin cache..."
echo ""

# Check if docs were copied to cache
CACHE_PATH="$HOME/.claude/plugins/cache/qingyi/qingyi/1.3.2/docs/agent-supporting"
if [ -f "$CACHE_PATH/brave-search-agent/real-world-examples.md" ]; then
    echo "  ✓ Supporting docs copied to cache"
    echo "  Location: $CACHE_PATH"
else
    echo "  WARNING: Supporting docs not found in cache"
    echo "  Expected: $CACHE_PATH"
    echo "  Check VERIFICATION.md for manual verification"
fi
echo ""

echo "========================================"
echo "Installation complete!"
echo "========================================"
echo ""
echo "All plugins installed successfully!"
echo "Supporting documentation is accessible to agents."
echo ""
echo "Restart Claude Code to use the plugins."
