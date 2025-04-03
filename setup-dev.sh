#!/bin/bash
set -e

echo "Updating package lists and upgrading packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing essential development tools and utilities..."
sudo apt install -y build-essential cmake gdb curl wget apt-transport-https
sudo apt install -y git

echo "Setting up Node.js (latest from 22 branch, e.g., 22.14)..."
# The NodeSource script for the 22 branch will install the latest 22.x release.
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

installCursor() {
    if ! [ -f /opt/cursor.appimage ]; then
        echo "Installing Cursor AI IDE..."
        APPIMAGE_PATH="/opt/cursor.appimage"
        ICON_PATH="/opt/cursor.png"
        DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"

        echo "Copy Cursor AppImage..."
        sudo cp Cursor.AppImage $APPIMAGE_PATH
        sudo chmod +x $APPIMAGE_PATH

        echo "Downloading Cursor icon..."
        sudo cp icon.png $ICON_PATH

        echo "Creating .desktop entry for Cursor..."
        sudo bash -c "cat > $DESKTOP_ENTRY_PATH" <<EOL
[Desktop Entry]
Name=Cursor AI
Exec=$APPIMAGE_PATH --no-sandbox
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOL

        echo "Cursor AI IDE installation complete. You can find it in your application menu."
    else
        echo "Cursor AI IDE is already installed."
    fi
}

installCursor

echo "Development environment setup complete!"
