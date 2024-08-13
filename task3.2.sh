#!/bin/bash
#
# Task 3 : File Organizing using Cronjob and shell script to specific directory without using dictionary dataset
#

CONFIG_FILE="$HOME/.file_organizer_config"

# Function to prompt user for a valid base directory
prompt_for_base_dir() {
    while true; do
        read -p "Enter the base directory for organizing files (e.g., /Users/Uname/Downloads): " base_dir
        if [ -d "$base_dir" ]; then
            echo "$base_dir" > "$CONFIG_FILE"
            echo "Directory is valid: $base_dir"
            break
        else
            echo "Directory does not exist or is invalid. Please try again."
        fi
    done
}

# Check if the script was provided with a --dir argument
if [[ "$1" == "--dir" ]] && [[ -n "$2" ]]; then
    if [ -d "$2" ]; then
        BASE_DIR="$2"
        echo "$BASE_DIR" > "$CONFIG_FILE"  # Save the provided path to the config file
        echo "Directory is valid: $BASE_DIR"
    else
        echo "Provided directory does not exist or is invalid: $2"
        exit 1
    fi
elif [ -f "$CONFIG_FILE" ]; then
    # Read base directory from configuration file if no argument was provided
    BASE_DIR=$(cat "$CONFIG_FILE")
    if [ ! -d "$BASE_DIR" ]; then
        echo "Saved directory does not exist or is invalid: $BASE_DIR"
        prompt_for_base_dir
        BASE_DIR=$(cat "$CONFIG_FILE")
    else
        echo "Using saved valid directory: $BASE_DIR"
    fi
else
    # Prompt user for base directory if this is the first run
    prompt_for_base_dir
    BASE_DIR=$(cat "$CONFIG_FILE")
fi

# Directories to be created within the base directory
DOCUMENTS_DIR="${BASE_DIR}/Documents"
AUDIO_DIR="${BASE_DIR}/Audio"
VIDEO_DIR="${BASE_DIR}/Video"
PEMFILES_DIR="${BASE_DIR}/PemFiles"
APPLICATIONS_DIR="${BASE_DIR}/Applications"
IMAGE_DIR="${BASE_DIR}/Images"

# Creating directories if they don't exist
mkdir -p "$DOCUMENTS_DIR" "$AUDIO_DIR" "$VIDEO_DIR" "$PEMFILES_DIR" "$APPLICATIONS_DIR" "$IMAGE_DIR"

# Today's date
TODAY=$(date +%Y-%m-%d)

# Function to move files with potential name conflicts handled
move_file() {
    local src_file="$1"
    local dest_dir="$2"
    local filename=$(basename "$src_file")
    local dest_file="${dest_dir}/${filename}"

    if [ -e "$dest_file" ]; then
        local base="${filename%.*}"
        local ext="${filename##*.}"
        local new_filename="${base}_$(date +%Y%m%d%H%M%S).${ext}"
        dest_file="${dest_dir}/${new_filename}"
    fi

    mv "$src_file" "$dest_file"
}

# Loop through the files downloaded today and move them to the appropriate directories
for file in "${BASE_DIR}"/*; do
    if [ -f "$file" ] && [[ "$(date -r "$file" +%Y-%m-%d)" == "$TODAY" ]]; then
        extension="${file##*.}"
        case "$extension" in
            doc|docx|pdf|txt|rtf|odt|xls|xlsx|ppt|pptx|csv|md|ods|odp|epub|mobi|pages|tex|key|dotx)
                move_file "$file" "$DOCUMENTS_DIR"
                ;;
            mp3|wav|flac|aac|ogg|m4a|wma|aiff|alac|amr)
                move_file "$file" "$AUDIO_DIR"
                ;;
            mp4|mkv|avi|mov|wmv|flv|mpeg|webm|3gp|m4v)
                move_file "$file" "$VIDEO_DIR"
                ;;
            pem|cer|crt|der|key)
                move_file "$file" "$PEMFILES_DIR"
                ;;
            exe|msi|dmg|apk|deb|rpm|jar|bat|sh|iso)
                move_file "$file" "$APPLICATIONS_DIR"
                ;;
            jpg|png|jpeg|gif)
                move_file "$file" "$IMAGE_DIR"
                ;;
            *)
                echo "File $file has an unrecognized extension."
                ;;
        esac
    fi
done
