#!/bin/bash
# Remove duplicates between Ideas001/RAWContent01/ and Ideas001/RAWContent01/downloads/
# Keep files in main folder, remove duplicates from downloads subfolder

set -e
echo "=== Removing Internal Duplicates ==="
echo "Starting at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

BASE_DIR="/home/amuldotexe/Desktop/Game20250926/number-12-grimmauld-place"
MAIN_DIR="$BASE_DIR/Ideas001/RAWContent01"
DOWNLOADS_DIR="$BASE_DIR/Ideas001/RAWContent01/downloads"

deleted_count=0
kept_count=0

echo "Checking for duplicates between main folder and downloads subfolder..."
echo ""

# Check if downloads subfolder exists
if [ ! -d "$DOWNLOADS_DIR" ]; then
    echo "Downloads subfolder not found - nothing to consolidate"
    exit 0
fi

# Process each file in downloads subfolder
find "$DOWNLOADS_DIR" -type f | while read -r file; do
    # Get just the filename
    filename=$(basename "$file")
    
    # Check if same file exists in main directory
    main_file="$MAIN_DIR/$filename"
    
    if [ -f "$main_file" ]; then
        # File exists in main directory, remove from downloads subfolder
        echo "  DELETE: $file (duplicate of $main_file)"
        rm "$file"
        deleted_count=$((deleted_count + 1))
    else
        # File doesn't exist in main directory, move it there
        echo "  MOVE: $file -> $main_file"
        mv "$file" "$main_file"
        kept_count=$((kept_count + 1))
    fi
done

# Remove empty directories in downloads subfolder
find "$DOWNLOADS_DIR" -type d -empty -delete 2>/dev/null || true

# Remove downloads subfolder if it's empty
if [ -d "$DOWNLOADS_DIR" ] && [ -z "$(ls -A "$DOWNLOADS_DIR")" ]; then
    echo ""
    echo "Removing empty downloads subfolder..."
    rmdir "$DOWNLOADS_DIR"
fi

echo ""
echo "=== Consolidation Complete ==="
echo "Files deleted (duplicates): $deleted_count"
echo "Files moved to main folder: $kept_count"
echo "Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "All content now in Ideas001/RAWContent01/ (no subfolders)"