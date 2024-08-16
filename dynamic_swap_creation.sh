#!/bin/bash 

#task 5 : create a swap with the user input and make it up and running.

# Prompt the user for the swap size in MB
read -p "Enter the size of swap memory to create (in MB): " SWAP_SIZE

# Validate the input is a number
if ! [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a valid numeric value for the swap size."
    exit 1
fi

# Set the swap file path
SWAP_FILE="/swapfile"

# Create the swap file with the specified size
sudo fallocate -l "${SWAP_SIZE}M" $SWAP_FILE

# Set the correct permissions for the swap file
sudo chmod 600 $SWAP_FILE

# Set up the swap area
sudo mkswap $SWAP_FILE

# Enable the swap file
sudo swapon $SWAP_FILE

# Make the swap file permanent (add it to /etc/fstab)
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
fi

# Adjust swappiness to 10
sudo sysctl vm.swappiness=10

# Make swappiness change permanent
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null
else
    sudo sed -i 's/^vm.swappiness=.*/vm.swappiness=10/' /etc/sysctl.conf
fi

# Adjust vfs_cache_pressure to 50
sudo sysctl vm.vfs_cache_pressure=50

# Make vfs_cache_pressure change permanent
if ! grep -q "vm.vfs_cache_pressure" /etc/sysctl.conf; then
    echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf > /dev/null
else
    sudo sed -i 's/^vm.vfs_cache_pressure=.*/vm.vfs_cache_pressure=50/' /etc/sysctl.conf
fi

# Display the current swap status
echo "Swap memory of $SWAP_SIZE MB created successfully."
echo "Swappiness set to 10 and vfs_cache_pressure set to 50."
echo "Current swap status:"
sudo swapon --show

# Display the current system values
echo "Current system values:"
sudo sysctl vm.swappiness
sudo sysctl vm.vfs_cache_pressure

