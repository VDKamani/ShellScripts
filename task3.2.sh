#!/bin/bash
#
# Task 3 : File Organizing using Cronjob and shell script to specific directory without using dictionary dataset
# also using conf file 

CONFIG_FILE="$HOME/.file_organizer_config"

# Function to prompt user for base directory
prompt_for_base_dir() {
    read -p "Enter the base directory for organizing files (e.g., /Users/viralkamani/Downloads): " base_dir
    echo "$base_dir" > "$CONFIG_FILE"
}

# Check if the script was provided with an argument
if [ "$#" -gt 0 ]; then
    BASE_DIR="$1"
    echo "$BASE_DIR" > "$CONFIG_FILE"  
elif [ -f "$CONFIG_FILE" ]; then
    # Read base directory from configuration file if no argument was provided
    BASE_DIR=$(cat "$CONFIG_FILE")
else

    prompt_for_base_dir
    BASE_DIR=$(cat "$CONFIG_FILE")
fi


DOCUMENTS_DIR="${BASE_DIR}/Documents"
AUDIO_DIR="${BASE_DIR}/Audio"
VIDEO_DIR="${BASE_DIR}/Video"
PEMFILES_DIR="${BASE_DIR}/PemFiles"
APPLICATIONS_DIR="${BASE_DIR}/Applications"
IMAGE_DIR="${BASE_DIR}/Images"


mkdir -p "$DOCUMENTS_DIR" "$AUDIO_DIR" "$VIDEO_DIR" "$PEMFILES_DIR" "$APPLICATIONS_DIR" "$IMAGE_DIR"

TODAY=$(date +%Y-%m-%d)


for file in "${BASE_DIR}"/*; do
    if [ -f "$file" ] && [[ "$(date -r "$file" +%Y-%m-%d)" == "$TODAY" ]]; then
        extension="${file##*.}"
        case "$extension" in
            doc|docx|pdf|txt|rtf|odt|xls|xlsx|ppt|pptx|csv|md|ods|odp|epub|mobi|pages|tex|key|dotx)
                mv "$file" "$DOCUMENTS_DIR/"
                ;;
            mp3|wav|flac|aac|ogg|m4a|wma|aiff|alac|amr)
                mv "$file" "$AUDIO_DIR/"
                ;;
            mp4|mkv|avi|mov|wmv|flv|mpeg|webm|3gp|m4v)
                mv "$file" "$VIDEO_DIR/"
                ;;
            pem|cer|crt|der|key)
                mv "$file" "$PEMFILES_DIR/"
                ;;
            exe|msi|dmg|apk|deb|rpm|jar|bat|sh|iso)
                mv "$file" "$APPLICATIONS_DIR/"
                ;;
            jpg|png|jpeg|gif)
                mv "$file" "$IMAGE_DIR/"
                ;;
            *)
                echo "File $file has an unrecognized extension."
                ;;
        esac
    fi
done
