#!/bin/bash

# install-claude-templates.sh
# Automates the setup of TipTip's global CLAUDE.md files.

CLAUDE_DIR="$HOME/.claude"
STACKS_DIR="$CLAUDE_DIR/stacks"

# Ensure directories exist
mkdir -p "$STACKS_DIR"

echo "======================================"
echo "TipTip CLAUDE.md Setup Wizard"
echo "======================================"
echo "Select your primary engineering role:"
echo "1) Backend (Go)"
echo "2) Frontend (React/Next.js)"
echo "3) Mobile (Flutter)"
echo "4) Exit"
echo "======================================"

read -p "Enter choice [1-4]: " choice

STACK_SRC=""
STACK_DEST=""
IMPORT_STMT=""

case $choice in
  1)
    STACK_SRC="stacks/golang.md"
    STACK_DEST="$STACKS_DIR/golang.md"
    IMPORT_STMT="@~/.claude/stacks/golang.md"
    echo "Selected: Backend (Go)"
    ;;
  2)
    STACK_SRC="stacks/nextjs.md"
    STACK_DEST="$STACKS_DIR/nextjs.md"
    IMPORT_STMT="@~/.claude/stacks/nextjs.md"
    echo "Selected: Frontend (React/Next.js)"
    ;;
  3)
    STACK_SRC="stacks/flutter.md"
    STACK_DEST="$STACKS_DIR/flutter.md"
    IMPORT_STMT="@~/.claude/stacks/flutter.md"
    echo "Selected: Mobile (Flutter)"
    ;;
  4)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo ""

# Copy Global Template
GLOBAL_TEMPLATE_SRC="global/tiptip-engineering.md"
GLOBAL_TEMPLATE_DEST="$CLAUDE_DIR/CLAUDE.md"

if [ ! -f "$GLOBAL_TEMPLATE_SRC" ]; then
    # Adjust path assuming script might be run from root or within claude-templates folder
    if [ -f "claude-templates/$GLOBAL_TEMPLATE_SRC" ]; then
        cd claude-templates
    else
        echo "Error: Global template not found at $GLOBAL_TEMPLATE_SRC. Run this script from the project root or the claude-templates directory."
        exit 1
    fi
fi

# Always copy global to overwrite/initialize
cp "$GLOBAL_TEMPLATE_SRC" "$GLOBAL_TEMPLATE_DEST"
echo "✅ Copied global TipTip template to $GLOBAL_TEMPLATE_DEST"

# Copy Stack Template
cp "$STACK_SRC" "$STACK_DEST"
echo "✅ Copied $STACK_SRC to $STACK_DEST"

# Check if import already exists to be idempotent
if grep -q "$IMPORT_STMT" "$GLOBAL_TEMPLATE_DEST"; then
    echo "ℹ️  Import statement $IMPORT_STMT already exists in $GLOBAL_TEMPLATE_DEST."
else
    # Append the import
    echo -e "\n\n$IMPORT_STMT" >> "$GLOBAL_TEMPLATE_DEST"
    echo "✅ Linked stack template into your global CLAUDE.md."
fi

echo "======================================"
echo "🎉 Setup Complete!"
echo "Your global CLAUDE.md is ready."
echo "======================================"
