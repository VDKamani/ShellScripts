#!/bin/bash

# Check if a username is provided
if [ -z "$1" ]; then
    echo "Please provide a username."
    exit 1
fi

# Get the username from the argument
USERNAME=$1

# Check if the user exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
else
    # Create the user if they don't exist
    sudo useradd $USERNAME
    echo "User $USERNAME created."
    
    # Create default shell configuration files
    # Create .bashrc
    sudo -u $USERNAME bash -c "cat > /home/$USERNAME/.bashrc <<EOF
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z \"\$PS1\" ] && return

# Set the default prompt
PS1=\"[\u@\h \W]\$ \"

# Enable color support for \`ls\` and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval \"\$(dircolors -b ~/.dircolors)\" || eval \"\$(dircolors -b)\"
    alias ls=\"ls --color=auto\"
    alias grep=\"grep --color=auto\"
fi

# Add handy directories to PATH
PATH=\"\$HOME/bin:\$PATH\"
EOF"

    # Create .bash_profile
    sudo -u $USERNAME bash -c "cat > /home/$USERNAME/.bash_profile <<EOF
# ~/.bash_profile: executed by bash for login shells.

# Source the .bashrc file
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF"
    
    echo "Default shell configuration files created."
fi

# Define the .pem file path
PEM_FILE="/home/$USERNAME/${USERNAME}.pem"
SSH_DIR="/home/$USERNAME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

# Generate SSH key pair if it doesn't exist
if [ ! -f "$PEM_FILE" ]; then
    # Create .ssh directory if it doesn't exist
    sudo mkdir -p $SSH_DIR
    sudo chmod 700 $SSH_DIR
    sudo chown $USERNAME:$USERNAME $SSH_DIR

    # Generate SSH key pair
    sudo ssh-keygen -t rsa -b 2048 -f "$PEM_FILE" -N "" -C "$USERNAME"
    
    # Move the public key to authorized_keys
    sudo cat "${PEM_FILE}.pub" | sudo tee -a $AUTH_KEYS > /dev/null
    sudo chmod 600 $AUTH_KEYS
    sudo chown $USERNAME:$USERNAME $AUTH_KEYS
    
    # Secure the .pem file
    sudo chmod 600 $PEM_FILE
    sudo chown $USERNAME:$USERNAME $PEM_FILE
    
    echo "SSH key pair created. Private key saved at $PEM_FILE."
else
    echo "PEM file already exists at $PEM_FILE."
fi

