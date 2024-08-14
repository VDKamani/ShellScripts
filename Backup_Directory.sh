#!/bin/bash
#task 4 : Script to Backup single directory .File backup Task - if a new file is added, then only the script run 
# Prompt the user for the source directory
read -p "Enter the directory to back up: " SOURCE_DIR

# Validate the source directory path
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: The directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Extract the directory name from the provided path
DIR_NAME=$(basename "$SOURCE_DIR")

# Set the backup directory to the home directory
BACKUP_DIR="$HOME/backups"

# Set the maximum number of backups to keep
MAX_BACKUPS=5

# Define the log file path
LOG_FILE="$BACKUP_DIR/backup_log.log"

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Ensure the log file exists, creating it if necessary
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    echo "$(date): Log file created at $LOG_FILE" >> "$LOG_FILE"
    echo "$(date): Log file created at $LOG_FILE"
fi

# Function to create a backup
create_backup() {
    TIMESTAMP=$(date +"%Y%m%d%H%M%S")
    BACKUP_NAME="${DIR_NAME}-backup_$TIMESTAMP.tar.gz"
    tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$SOURCE_DIR" .
    echo "$(date): Backup created: $BACKUP_NAME" >> "$LOG_FILE"
    echo "$(date): Backup created: $BACKUP_NAME"
}

# Function to manage old backups
manage_backups() {
    BACKUP_COUNT=$(ls "$BACKUP_DIR" | grep "${DIR_NAME}-backup_.*\.tar\.gz" | wc -l)

    if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
        OLDEST_BACKUP=$(ls "$BACKUP_DIR" | grep "${DIR_NAME}-backup_.*\.tar\.gz" | head -n 1)
        rm "$BACKUP_DIR/$OLDEST_BACKUP"
        echo "$(date): Old backup deleted: $OLDEST_BACKUP" >> "$LOG_FILE"
        echo "$(date): Old backup deleted: $OLDEST_BACKUP"  

    fi
}

# Check for new or modified files and create a backup if any are found
if [ "$(find "$SOURCE_DIR" -type f -newer "$LOG_FILE")" ]; then
    create_backup
    manage_backups
else
    echo "$(date): No new files detected, no backup needed" >> "$LOG_FILE"
    echo "$(date): No new files detected, no backup needed"
fi
