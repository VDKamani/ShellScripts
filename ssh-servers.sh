#!/bin/bash

# List of server names and their corresponding SSH commands
servers=(
             <YOUR-PROJECT-NAME-HERE>

)

commands=(
   <YOUR-SSH-COMMANDS-HERE>
)

# Display server list with numbers
echo "Available Servers:"
for i in "${!servers[@]}"; do
    echo "$((i+1)). ${servers[$i]}"
done

# Ask the user to select a server
read -p "Enter the server number to SSH into: " server_number

# Validate the input
if [[ "$server_number" =~ ^[0-9]+$ ]] && [ "$server_number" -ge 1 ] && [ "$server_number" -le "${#servers[@]}" ]; then
    # SSH into the selected server
    selected_command="${commands[$((server_number-1))]}"
    echo "Connecting to ${servers[$((server_number-1))]}..."
    eval "$selected_command"
else
    echo "Invalid selection. Please enter a number between 1 and ${#servers[@]}."
fi
