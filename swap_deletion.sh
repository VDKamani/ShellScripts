#!/bin/bash

# Task 5.1 : swap removel / deletion.

# Turn off the swap file
sudo swapoff /swapfile

# Remove the swap file entry from /etc/fstab
sudo sed -i '/\/swapfile/d' /etc/fstab

# Delete the swap file
sudo rm /swapfile

# Reset swappiness to the default value (60)
sudo sysctl vm.swappiness=60

# Remove swappiness from /etc/sysctl.conf or reset to default
if grep -q "vm.swappiness=10" /etc/sysctl.conf; then
    sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
fi

# Reset vfs_cache_pressure to the default value (100)
sudo sysctl vm.vfs_cache_pressure=100

# Remove vfs_cache_pressure from /etc/sysctl.conf or reset to default
if grep -q "vm.vfs_cache_pressure=50" /etc/sysctl.conf; then
    sudo sed -i '/vm.vfs_cache_pressure/d' /etc/sysctl.conf
fi

# Confirm the swap file has been removed and settings are reverted
echo "Swap file removed, swappiness reset to default (60), and vfs_cache_pressure reset to default (100)."

