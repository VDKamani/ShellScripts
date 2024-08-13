#!/bin/bash

# Directories to be created within Downloads
BASE_DIR="/Users/viralkamani/Downloads"
DOCUMENTS_DIR="${BASE_DIR}/Documents"
AUDIO_DIR="${BASE_DIR}/Audio"
VIDEO_DIR="${BASE_DIR}/Video"
PEMFILES_DIR="${BASE_DIR}/PemFiles"
APPLICATIONS_DIR="${BASE_DIR}/Applications"
IMAGE_DIR="${BASE_DIR}/Images"

# Creating directories if they don't exist
mkdir -p "$DOCUMENTS_DIR" "$AUDIO_DIR" "$VIDEO_DIR" "$PEMFILES_DIR" "$APPLICATIONS_DIR" "IMAGE_DIR"

# Today's date
TODAY=$(date +%Y-%m-%d)

# Loop through the files downloaded today and move them to the appropriate directories
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
		mv "$file" "IMAGE_DIR"
		;;
            *)
                echo "File $file has an unrecognized extension."
                ;;
        esac
    fi
done

