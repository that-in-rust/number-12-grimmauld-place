#!/bin/bash
# Consolidate downloads folder with Ideas001/RAWContent01
# Copy unique files, delete duplicates

set -e
echo "=== Consolidating Downloads Folder ==="
echo "Starting at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Ensure target directory exists
mkdir -p "Ideas001/RAWContent01"

copied_count=0
deleted_count=0
skipped_count=0

echo "Processing files in downloads folder..."
echo ""

# Check if downloads directory exists
if [ ! -d "downloads" ]; then
    echo "Downloads directory not found!"
    exit 1
fi

# Process each file in downloads
find downloads -type f | while read -r file; do
    # Get just the filename without the downloads/ prefix
    filename=$(basename "$file")
    
    # Check if file exists in Ideas001/RAWContent01 (either directly or in downloads subfolder)
    target_file1="Ideas001/RAWContent01/$filename"
    target_file2="Ideas001/RAWContent01/downloads/$filename"
    
    if [[ -f "$target_file1" || -f "$target_file2" ]]; then
        # File exists in target location, delete from downloads
        echo "  DELETE: $file (exists in Ideas001/RAWContent01)"
        rm "$file"
        deleted_count=$((deleted_count + 1))
    else
        # File doesn't exist in target, copy it
        echo "  COPY: $file -> Ideas001/RAWContent01/$filename"
        cp "$file" "Ideas001/RAWContent01/$filename"
        copied_count=$((copied_count + 1))
        
        # Also delete from downloads after copying
        rm "$file"
    fi
done

# Remove empty directories in downloads
find downloads -type d -empty -delete 2>/dev/null || true

# Remove downloads directory if it's empty
if [ -d "downloads" ] && [ -z "$(ls -A downloads)" ]; then
    echo ""
    echo "Removing empty downloads directory..."
    rmdir downloads
fi

echo ""
echo "=== Consolidation Complete ==="
echo "Files copied: $copied_count"
echo "Files deleted (duplicates): $deleted_count"
echo "Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "All content now consolidated in Ideas001/RAWContent01/"