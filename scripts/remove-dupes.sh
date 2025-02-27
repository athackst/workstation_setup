#!/usr/bin/bash

# md
# Removes duplicate files between two folders by comparing their checksums.
# If a file exists in both Folder A and Folder B, the file in Folder B will be deleted.
#
# ## Usage
#
# ```
# remove_dupes.sh <folder_a> <folder_b>
# ```
# /md

# Check if correct number of arguments are supplied
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <folder_a_path> <folder_b_path>"
    echo "This script deduplicates files between two folders by comparing their checksums."
    echo "If a file exists in both Folder A and Folder B, the file in Folder B will be deleted."
    exit 1
fi

folder_a="$1"
folder_b="$2"

# Validate if the provided folder paths exist
if [ ! -d "$folder_a" ]; then
    echo "Error: Folder A ($folder_a) does not exist."
    exit 1
fi

if [ ! -d "$folder_b" ]; then
    echo "Error: Folder B ($folder_b) does not exist."
    exit 1
fi

# Replace '/' with '-' in folder names for the checksum file names
folder_a_name=$(echo "$folder_a" | tr '/' '-')
folder_b_name=$(echo "$folder_b" | tr '/' '-')

# Construct the checksum file names using the folder names
folder_a_checksums="${folder_a_name}_checksums.txt"
folder_b_checksums="${folder_b__name}_cecksums.txt"

# Generate checksums for Folder A
find "$folder_a" -type f -exec md5sum {} + > $folder_a_checksums

# Generate checksums for Folder B, excluding Folder A
find "$folder_b" -type f -not -path "$folder_a/*" -exec md5sum {} + > $folder_b_checksums

# Compare checksums and delete duplicates in Folder B
awk '{print $1}' $folder_a_checksums | while read -r checksum_a; do
    file_b=$(grep "$checksum_a" $folder_b_checksums | awk '{print $2}')
    if [ -n "$file_b" ]; then
        rm "$file_b"
        echo "Deleted: $file_b"
    fi
done
