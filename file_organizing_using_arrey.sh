#!/bin/bash
#
# Task 3 : File Organizing using Cronjob and shell script to specific directory
#
# Directories to be created within Downloads
BASE_DIR="/Users/viralkamani/Downloads"
DOCUMENTS_DIR="${BASE_DIR}/Documents"
AUDIO_DIR="${BASE_DIR}/Audio"
VIDEO_DIR="${BASE_DIR}/Video"
PEMFILES_DIR="${BASE_DIR}/PemFiles"
APPLICATIONS_DIR="${BASE_DIR}/Applications"
IMAGE_DIR="${BASE_DIR}/Images"
# Creating directories if they don't exist
mkdir -p "$DOCUMENTS_DIR" "$AUDIO_DIR" "$VIDEO_DIR" "$PEMFILES_DIR" "$APPLICATIONS_DIR" "$IMAGE_DIR"

# Associating extensions with directories
declare -A FILE_TYPES
FILE_TYPES=(
    ["Documents"]="doc docx pdf txt rtf odt xls xlsx ppt pptx csv md ods odp epub mobi pages tex key dotx"
    ["Audio"]="mp3 wav flac aac ogg m4a wma aiff alac amr"
    ["Video"]="mp4 mkv avi mov wmv flv mpeg webm 3gp m4v"
    ["PemFiles"]="pem cer crt der key"
    ["Applications"]="exe msi dmg apk deb rpm jar bat sh iso"
    ["Images"]="jpg jpeg heic gif png"
)

# Today's date
TODAY=$(date +%Y-%m-%d)

# Loop through the files downloaded today and move them to the appropriate directories
for file in "${BASE_DIR}"/*; do
    if [ -f "$file" ] && [[ "$(date -r "$file" +%Y-%m-%d)" == "$TODAY" ]]; then
        extension="${file##*.}"
        for category in "${!FILE_TYPES[@]}"; do
            if [[ " ${FILE_TYPES[$category]} " =~ " $extension " ]]; then
                case $category in
                    "Documents")
                        mv "$file" "$DOCUMENTS_DIR/"
                        ;;
                    "Audio")
                        mv "$file" "$AUDIO_DIR/"
                        ;;
                    "Video")
                        mv "$file" "$VIDEO_DIR/"
                        ;;
                    "PemFiles")
                        mv "$file" "$PEMFILES_DIR/"
                        ;;
                    "Applications")
                        mv "$file" "$APPLICATIONS_DIR/"
                        ;;
                    "Applications")
                        mv "$file" "$IMAGE_DIR/"
                        ;;
                esac
                break
            fi
        done
    fi
done

