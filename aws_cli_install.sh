#!/bin/bash

# Script to install AWS CLI on Linux

# Function to print messages in bold
bold_text() {
    echo -e "\033[1m$1\033[0m"
}

bold_text "Checking if AWS CLI is already installed..."

# Check if AWS CLI is already installed
if command -v aws >/dev/null 2>&1; then
    bold_text "AWS CLI is already installed. Version:"
    aws --version
    exit 0
fi

bold_text "AWS CLI is not installed. Proceeding with installation..."

# Update the package manager and install prerequisites
bold_text "Updating package manager and installing prerequisites..."
sudo apt update -y && sudo apt install -y unzip curl

# Download the AWS CLI installation file
INSTALL_DIR="/tmp"
AWS_CLI_ZIP="awscliv2.zip"
bold_text "Downloading AWS CLI..."
curl -o "$INSTALL_DIR/$AWS_CLI_ZIP" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

# Extract the downloaded file
bold_text "Extracting AWS CLI installation files..."
unzip -q "$INSTALL_DIR/$AWS_CLI_ZIP" -d "$INSTALL_DIR"

# Install AWS CLI
bold_text "Installing AWS CLI..."
sudo "$INSTALL_DIR/aws/install"

# Verify the installation
if command -v aws >/dev/null 2>&1; then
    bold_text "AWS CLI installed successfully. Version:"
    aws --version
else
    echo "Error: AWS CLI installation failed."
    exit 1
fi

# Clean up temporary files
bold_text "Cleaning up temporary files..."
rm -rf "$INSTALL_DIR/aws" "$INSTALL_DIR/$AWS_CLI_ZIP"

bold_text "Installation complete!"

