#!/bin/bash
#
# Script to make a shell script as a command and than to use directly as command
#

# Prompt the user for the source script path
read -p "Enter the full path to the script you want to install as a command: " SCRIPT_SOURCE

# Check if the source script exists
if [ ! -f "$SCRIPT_SOURCE" ]; then
    echo "Error: Source script $SCRIPT_SOURCE does not exist."
    exit 1
fi

# Extract the filename to use as the command name
COMMAND_NAME=$(basename "$SCRIPT_SOURCE" .sh)

# Directory to install the command (choose a directory in your PATH)
INSTALL_DIR="/usr/local/bin"

# Full path of the destination command
COMMAND_PATH="${INSTALL_DIR}/${COMMAND_NAME}"

# Copy the script to the install directory and rename it
sudo cp "$SCRIPT_SOURCE" "$COMMAND_PATH"

# Make the script executable
sudo chmod +x "$COMMAND_PATH"

# Confirm the installation
if [ -f "$COMMAND_PATH" ]; then
    echo "Command '$COMMAND_NAME' installed successfully."
    echo "You can now use '$COMMAND_NAME' to run the script from anywhere."
else
    echo "Failed to install the command."
    exit 1
fi

