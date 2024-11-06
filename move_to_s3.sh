#!/bin/bash

# Define the local directory where PM2 logrotate stores zip files
LOGS_DIR="/home/ubuntu/.pm2/logs"

# Define your S3 bucket path
S3_BUCKET="s3://rummy-rani-pm2-logs/"

# Define log file for output
LOG_FILE="/home/ubuntu/.pm2/s3-log/move-to-s3.log"

# Redirect all output (stdout and stderr) to the log file
exec > "$LOG_FILE" 2>&1

# Move only the logs that are not already in S3
for file in "$LOGS_DIR"/*.gz; do
    if [ -f "$file" ]; then
        file_name=$(basename "$file")
        
        # Check if the file already exists in S3
        if aws s3 ls "$S3_BUCKET/$file_name" > /dev/null 2>&1; then
            echo "$(date) - $file_name already exists in S3, skipping upload."
        else
            echo "$(date) - Uploading $file_name to $S3_BUCKET"
            aws s3 cp "$file" "$S3_BUCKET" && rm -f "$file"
            echo "$(date) - $file_name uploaded and removed from local storage."
        fi
    fi
done

