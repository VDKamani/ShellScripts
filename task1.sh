#!/bin/bash 
#
# Task: Run 10 commands, one by one, without using if-else directly
#

# Read the input of 10 commands separated by commas
read -p "Enter 10 Linux commands separated by commas: " input

# Split the input by commas into an array
IFS=',' read -ra commands <<< "$input"

# Function to trim leading and trailing spaces
trim() {
    echo "$1" | xargs
}

# Execute each command in the array
for cmd in "${commands[@]}"; do
    # Trim any leading or trailing spaces
    cmd=$(trim "$cmd")
    
    # Extract the base command (first word) for validation
    base_command=$(echo "$cmd" | awk '{print $1}')
    
    echo "Checking and executing: $cmd if it's a valid command"
    
    # Check if the base command is valid
    command -v "$base_command" > /dev/null 2>&1 && {
        echo "'$cmd' is a valid command."
        eval "$cmd"
        echo "Moving to the next command."
    } || {
        echo "'$cmd' is not a valid command."
    }
done

