#!/bin/bash
#
#task 1 : make a shell script that will create a if not exist and will create a pem file for that user and will give$
#
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

