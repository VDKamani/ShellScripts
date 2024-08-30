#!/bin/bash

# Display mounted file systems
echo "Listing all currently mounted file systems:"
df -h

# Prompt the user for the mount point or device name to unmount
read -p "Enter the mount point or device name you want to unmount (e.g., /data or /dev/xvdf): " MOUNT_POINT

# Check if the input is a mount point or device and confirm it is mounted
if mount | grep -q "$MOUNT_POINT"; then
  echo "Mount point or device $MOUNT_POINT is currently mounted."
else
  echo "Error: $MOUNT_POINT is not currently mounted."
  exit 1
fi

# Unmount the file system
echo "Unmounting $MOUNT_POINT..."
sudo umount $MOUNT_POINT

# Check if the unmount was successful
if mount | grep -q "$MOUNT_POINT"; then
  echo "Error: Failed to unmount $MOUNT_POINT."
  exit 1
else
  echo "$MOUNT_POINT has been successfully unmounted."
fi

# Prompt to remove the entry from /etc/fstab
read -p "Do you want to remove the corresponding entry from /etc/fstab? (y/n): " REMOVE_FSTAB

if [ "$REMOVE_FSTAB" = "y" ]; then
  # Use sed to remove the entry from /etc/fstab
  sudo sed -i.bak "\|$MOUNT_POINT|d" /etc/fstab

  # Verify the removal
  if grep -qs "$MOUNT_POINT" /etc/fstab; then
    echo "Error: Failed to remove the entry from /etc/fstab."
    exit 1
  else
    echo "The entry for $MOUNT_POINT has been successfully removed from /etc/fstab."
  fi
else
  echo "The entry for $MOUNT_POINT in /etc/fstab was not modified."
fi

# Optionally remove the directory if it's empty
read -p "Do you want to remove the mount directory $MOUNT_POINT if it's empty? (y/n): " REMOVE_DIR

if [ "$REMOVE_DIR" = "y" ]; then
  if [ -d "$MOUNT_POINT" ]; then
    if [ -z "$(ls -A $MOUNT_POINT)" ]; then
      echo "Removing the empty directory $MOUNT_POINT..."
      sudo rmdir $MOUNT_POINT
      echo "Directory $MOUNT_POINT has been removed."
    else
      echo "Error: Directory $MOUNT_POINT is not empty and will not be removed."
    fi
  else
    echo "Directory $MOUNT_POINT does not exist."
  fi
fi

echo "Unmounting process completed."

