#!/bin/bash

# Display block devices and their file systems
echo "Listing all block devices and their file systems:"
lsblk -f

# Prompt the user for the device name
read -p "Enter the device name you want to attach (e.g., xvdf): " DEVICE

# Check if the device exists (only checking the name after /dev/)
if ! lsblk | awk '{print $1}' | grep -q "^$DEVICE$"; then
  echo "Error: The device $DEVICE does not exist."
  exit 1
fi

# Prepend /dev/ to the device name
DEVICE="/dev/$DEVICE"

# Ask if the user wants to mount directly or format first
read -p "Do you want to format the device before mounting? (y/n): " FORMAT_CONFIRM

if [ "$FORMAT_CONFIRM" = "y" ]; then
  # Ask for the file system type
  read -p "Enter the file system type you want to create (e.g., xfs, ext4): " FSTYPE_CHOICE

  # Confirm formatting
  read -p "You have chosen to format $DEVICE with $FSTYPE_CHOICE file system. Do you want to proceed? (y/n): " FINAL_CONFIRM
  if [ "$FINAL_CONFIRM" != "y" ]; then
    echo "Exiting without making any changes."
    exit 1
  fi

  # Format the device
  echo "Creating $FSTYPE_CHOICE file system on $DEVICE..."
  if ! sudo mkfs -t $FSTYPE_CHOICE $DEVICE; then
    echo "Error: Failed to create file system. Attempting to install necessary packages."
    sudo yum install -y xfsprogs || sudo apt-get install -y xfsprogs
    sudo mkfs -t $FSTYPE_CHOICE $DEVICE
    if [ $? -ne 0 ]; then
      echo "Error: Failed to create file system even after attempting to install necessary packages."
      exit 1
    fi
  fi
  FSTYPE=$FSTYPE_CHOICE
else
  # Get the file system type if not formatting
  FSTYPE=$(lsblk -no FSTYPE $DEVICE)
  if [ -z "$FSTYPE" ]; then
    echo "Error: No file system detected on $DEVICE. You must format it before mounting."
    exit 1
  fi
  echo "File system detected: $FSTYPE"
fi

# Prompt the user for the directory name to attach
read -p "Enter the directory name where you want to mount the file system (e.g., /data): " DIRNAME

# Check if the directory already exists
if [ -d "$DIRNAME" ]; then
  echo "Error: The directory $DIRNAME already exists."
  exit 1
fi

# Create the directory
echo "Creating directory $DIRNAME..."
sudo mkdir -p $DIRNAME

# Check if the file system is already mounted
if grep -qs "$DEVICE" /proc/mounts; then
  echo "Error: The device $DEVICE is already mounted."
  exit 1
fi

# Mount the file system
echo "Mounting $DEVICE to $DIRNAME..."
sudo mount $DEVICE $DIRNAME

# Verify the mount
echo "Verifying the mount:"
df -h | grep "$DEVICE"

# Ask to make the mount permanent
read -p "Do you want to make this mount permanent by adding it to /etc/fstab? (y/n): " PERM_CONFIRM
if [ "$PERM_CONFIRM" = "y" ]; then
  # Get the UUID of the device
  UUID=$(blkid -s UUID -o value $DEVICE)

  # Make the changes permanent
  echo "Adding the mount to /etc/fstab..."
  echo "UUID=$UUID $DIRNAME $FSTYPE defaults,nofail 0 2" | sudo tee -a /etc/fstab
  echo "The mount has been added to /etc/fstab."
else
  echo "Mounting has been done, but changes were not added to /etc/fstab."
fi

# Confirmation
echo "The device $DEVICE has been successfully mounted to $DIRNAME."

