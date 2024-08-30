
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

# Get the file system type
FSTYPE=$(lsblk -no FSTYPE $DEVICE)

# Check if the file system exists; if not, create one
if [ -z "$FSTYPE" ]; then
  read -p "No file system detected. Do you want to create an XFS file system on $DEVICE? (y/n): " CONFIRM
  if [ "$CONFIRM" = "y" ]; then
    echo "Creating XFS file system on $DEVICE..."
    sudo mkfs -t xfs $DEVICE

    # If mkfs fails, suggest installing xfsprogs
    if [ $? -ne 0 ]; then
      echo "Error: Failed to create file system. You might need to install xfsprogs."
      echo "To install xfsprogs, run: sudo yum install xfsprogs"
      exit 1
    fi
    FSTYPE="xfs"
  else
    echo "Exiting without making any changes."
    exit 1
  fi
else
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

# Get the UUID of the device
UUID=$(blkid -s UUID -o value $DEVICE)

# Make the changes permanent
echo "Making the mount permanent by adding to /etc/fstab..."
echo "UUID=$UUID $DIRNAME $FSTYPE defaults,nofail 0 2" | sudo tee -a /etc/fstab

# Confirmation
echo "The device $DEVICE has been successfully mounted to $DIRNAME and the changes have been made permanent."

