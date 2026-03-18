#!/usr/bin/env bash
# scripts/install-hooks.sh
# Automated installer for TipTip Claude Code hooks

set -e

echo "============================================================"
echo " TipTip Claude Code Hooks Installer"
echo "============================================================"

# 1. Check prerequisites
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git and try again."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Warning: jq is not installed. Some hooks require jq to parse JSON."
    echo "Please install jq (e.g., 'brew install jq' on macOS or 'apt-get install jq' on Linux)."
fi

# 2. Require script to be run from aiad-claude root
if [ ! -d "hooks/global" ] || [ ! -d "settings" ]; then
    echo "Error: This script must be run from the root of the cloned aiad-claude repository."
    echo "Please navigate to the aiad-claude directory and run: ./install-hooks.sh"
    exit 1
fi
echo "-> Verified execution from aiad-claude repository root"

# 3. Install global hooks
echo "-> Installing global hooks (secret guard, notifications)..."
mkdir -p ~/.claude/hooks
if [ -d "hooks/global" ]; then
    cp hooks/global/* ~/.claude/hooks/
    chmod +x ~/.claude/hooks/*.sh
    echo "   Global hooks installed successfully."
else
    echo "   Warning: No global hooks found in ./hooks/global"
fi

# 4. Interactive project config
echo "============================================================"
echo " Project-Level Setup"
echo "============================================================"
echo "Are you running this script from the root of your project repository?"
read -p "(y/N): " IS_ROOT
if [[ "$IS_ROOT" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Select your project stack:"
    echo "  1) Backend / Go"
    echo "  2) Frontend / Next.js"
    echo "  3) Skip project-level setup"
    read -p "Select an option (1-3): " STACK_CHOICE

    mkdir -p .claude/hooks

    case "$STACK_CHOICE" in
        1)
            echo "   Installing Backend/Go hooks..."
            if [ -d "hooks/backend" ]; then
                cp hooks/backend/* .claude/hooks/
                chmod +x .claude/hooks/*.sh
                echo "   Backend hooks installed successfully."
            else
                echo "   Error: Backend hooks directory not found."
            fi
            ;;
        2)
            echo "   Installing Frontend/Next.js hooks..."
            if [ -d "hooks/frontend" ]; then
                cp hooks/frontend/* .claude/hooks/
                chmod +x .claude/hooks/*.sh
                echo "   Frontend hooks installed successfully."
            else
                echo "   Error: Frontend hooks directory not found."
            fi
            ;;
        3)
            echo "   Skipping project-level hooks."
            ;;
        *)
            echo "   Invalid selection. Skipping project-level hooks."
            ;;
    esac

    echo ""
    echo "-> Remember to copy the relevant settings block from:"
    echo "   settings/project-settings.json"
    echo "   into your local .claude/settings.json file."
else
    echo "-> Skipping project-level setup."
    echo "   To install project hooks, navigate to your project root and run this script again."
fi

echo "============================================================"
echo " Setup Complete!"
echo "============================================================"
