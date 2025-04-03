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

echo "Setting up .NET SDK (version 9.0)..."
# Download and install the Microsoft package repository configuration package for Ubuntu 24.04.
wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Update package lists and install the .NET SDK.
sudo apt update
sudo apt install -y dotnet-sdk-9.0

installCursor() {
    if ! [ -f /opt/cursor.appimage ]; then
        echo "Installing Cursor AI IDE..."

        # URLs for Cursor AppImage and Icon
        CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
        ICON_URL="https://raw.githubusercontent.com/rahuljangirwork/copmany-logos/refs/heads/main/cursor.png"

        # Paths for installation
        APPIMAGE_PATH="/opt/cursor.appimage"
        ICON_PATH="/opt/cursor.png"
        DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"

        # Download Cursor AppImage
        echo "Downloading Cursor AppImage..."
        sudo curl -L $CURSOR_URL -o $APPIMAGE_PATH
        sudo chmod +x $APPIMAGE_PATH

        # Download Cursor icon
        echo "Downloading Cursor icon..."
        sudo curl -L $ICON_URL -o $ICON_PATH

        # Create a .desktop entry for Cursor using tee.
        echo "Creating .desktop entry for Cursor..."
        sudo tee $DESKTOP_ENTRY_PATH > /dev/null <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=$APPIMAGE_PATH
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
