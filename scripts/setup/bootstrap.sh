#!/bin/bash

# Bootstrap script for setting up dotfiles with chezmoi
# This script installs chezmoi and initializes the dotfiles

set -e

echo "🚀 Setting up dotfiles with chezmoi..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "📱 Detected OS: $OS"

# Install chezmoi if not already installed
if ! command -v chezmoi &> /dev/null; then
    echo "📦 Installing chezmoi..."
    
    if [[ "$OS" == "macOS" ]]; then
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            echo "🍺 Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        brew install chezmoi
    else
        # Linux installation
        sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $USER
    fi
else
    echo "✅ chezmoi is already installed"
fi

# Get the repository URL
REPO_URL="https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/')"

if [[ -z "$REPO_URL" ]]; then
    echo "❌ Could not determine repository URL. Please set it manually:"
    echo "   chezmoi init --apply https://github.com/yourusername/dotfiles.git"
    exit 1
fi

echo "🔗 Repository URL: $REPO_URL"

# Initialize chezmoi with the current repository
echo "🎯 Initializing chezmoi..."
chezmoi init --apply "$REPO_URL"

echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Review the applied configuration: chezmoi diff"
echo "2. Make any necessary adjustments to the templates"
echo "3. Re-apply if needed: chezmoi apply"
echo ""
echo "🔧 Useful commands:"
echo "   chezmoi edit ~/.zshrc     # Edit and apply a file"
echo "   chezmoi add ~/.newfile    # Add a new file to management"
echo "   chezmoi update            # Update from repository"
echo "   chezmoi managed           # List managed files"