#!/bin/bash

# Check if both service name and email address were provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <service_name> <email_address>"
    exit 1
fi

# Define the service name from the first argument
SERVICE_NAME="$1"

# Define the email address from the second argument
EMAIL="$2"

# Define the string to search for in the logs that indicates a service failure
FAILURE_STRING="stopped"

# Function to send an email notification
send_email() {
    local subject="Service Failure Detected: $SERVICE_NAME"
    local body="The $SERVICE_NAME service has failed and was restarted automatically. Please check the logs for more details."
    echo -e "Subject: $subject\n\n$body" | ssmtp "$EMAIL"
}

# Function to restart the service
restart_service() {
    echo "[$(date)] Restarting $SERVICE_NAME service..."  
    sudo systemctl restart "$SERVICE_NAME"
    if [[ $? -eq 0 ]]; then
        echo "[$(date)] $SERVICE_NAME service restarted successfully." 
        send_email
    else
        echo "[$(date)] Failed to restart $SERVICE_NAME service." 
    fi
}

# Monitor the system logs for any service failure
journalctl -u "$SERVICE_NAME" -n 1 | while read -r line; do
    echo "Log Line: $line" # Debug: Show each log line
    if echo "$line" | grep -i "$FAILURE_STRING" > /dev/null; then
        echo "[$(date)] Failure detected in $SERVICE_NAME service." 
        restart_service
    fi
done

