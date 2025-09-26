#!/bin/bash
# Duplicate File Cleanup Script
# Keeps one unique file per extension, deletes the rest
# Usage: ./cleanup-duplicates.sh [--dry-run] [--backup] [--force]

set -e

# Configuration
BACKUP_DIR="./zzArchive/backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
BACKUP=false
FORCE=false
TARGET_DIR="./downloads"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --backup)
            BACKUP=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--dry-run] [--backup] [--force]"
            echo "  --dry-run  Show what would be deleted without actually deleting"
            echo "  --backup   Create backup of files before deletion"
            echo "  --force    Skip confirmation prompts"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== Duplicate File Cleanup Script ==="
echo "Target directory: $TARGET_DIR"
echo "Dry run: $DRY_RUN"
echo "Backup: $BACKUP"
echo "Force: $FORCE"
echo ""

# Check if target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Target directory $TARGET_DIR does not exist"
    exit 1
fi

# Create backup directory if needed
if [[ "$BACKUP" == true && "$DRY_RUN" == false ]]; then
    mkdir -p "$BACKUP_DIR"
    echo "Backup directory created: $BACKUP_DIR"
fi

# Function to get file extension
get_extension() {
    local filename="$1"
    echo "${filename##*.}"
}

# Function to get base name without numbered suffix
get_base_name() {
    local filename="$1"
    # Remove numbered suffixes like " (1)", " (2)", etc.
    echo "$filename" | sed 's/ ([0-9]\+)//'
}

# Collect all files and group by extension
declare -A extensions
declare -A file_groups

echo "Analyzing files in $TARGET_DIR..."

while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        extension=$(get_extension "$filename")
        base_name=$(get_base_name "$filename")
        
        # Group files by extension and base name
        key="${extension}:${base_name}"
        if [[ -z "${file_groups[$key]}" ]]; then
            file_groups[$key]="$file"
        else
            file_groups[$key]="${file_groups[$key]}|$file"
        fi
        
        extensions[$extension]=1
    fi
done < <(find "$TARGET_DIR" -type f -print0)

echo "Found extensions: ${!extensions[*]}"
echo ""

# Process each group and identify duplicates
declare -a files_to_delete
declare -a files_to_keep

for key in "${!file_groups[@]}"; do
    IFS='|' read -ra files <<< "${file_groups[$key]}"
    
    if [[ ${#files[@]} -gt 1 ]]; then
        # Multiple files found - keep the first one (usually without numbered suffix)
        keep_file=""
        
        # Prefer files without numbered suffixes
        for file in "${files[@]}"; do
            filename=$(basename "$file")
            if [[ ! "$filename" =~ \([0-9]+\) ]]; then
                keep_file="$file"
                break
            fi
        done
        
        # If no file without suffix found, keep the first one
        if [[ -z "$keep_file" ]]; then
            keep_file="${files[0]}"
        fi
        
        files_to_keep+=("$keep_file")
        
        # Mark others for deletion
        for file in "${files[@]}"; do
            if [[ "$file" != "$keep_file" ]]; then
                files_to_delete+=("$file")
            fi
        done
    fi
done

# Show summary
echo "=== CLEANUP SUMMARY ==="
echo "Files to keep: ${#files_to_keep[@]}"
echo "Files to delete: ${#files_to_delete[@]}"
echo ""

if [[ ${#files_to_delete[@]} -eq 0 ]]; then
    echo "No duplicate files found. Nothing to clean up."
    exit 0
fi

# Show files to be deleted
echo "Files that will be DELETED:"
for file in "${files_to_delete[@]}"; do
    size=$(ls -lh "$file" | awk '{print $5}')
    echo "  - $file ($size)"
done
echo ""

echo "Files that will be KEPT:"
for file in "${files_to_keep[@]}"; do
    size=$(ls -lh "$file" | awk '{print $5}')
    echo "  + $file ($size)"
done
echo ""

# Calculate space savings
total_size=0
for file in "${files_to_delete[@]}"; do
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
    total_size=$((total_size + size))
done

echo "Estimated space savings: $(numfmt --to=iec $total_size)"
echo ""

# Confirmation
if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN - No files will be deleted"
    exit 0
fi

if [[ "$FORCE" != true ]]; then
    echo "WARNING: This will permanently delete ${#files_to_delete[@]} files!"
    echo "Type 'DELETE' to confirm:"
    read -r confirmation
    if [[ "$confirmation" != "DELETE" ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Perform cleanup
echo "Starting cleanup..."

deleted_count=0
for file in "${files_to_delete[@]}"; do
    if [[ -f "$file" ]]; then
        # Backup if requested
        if [[ "$BACKUP" == true ]]; then
            relative_path="${file#$TARGET_DIR/}"
            backup_path="$BACKUP_DIR/$relative_path"
            backup_dir=$(dirname "$backup_path")
            mkdir -p "$backup_dir"
            cp "$file" "$backup_path"
        fi
        
        # Delete the file
        rm "$file"
        echo "Deleted: $file"
        deleted_count=$((deleted_count + 1))
    fi
done

echo ""
echo "=== CLEANUP COMPLETE ==="
echo "Files deleted: $deleted_count"
echo "Files kept: ${#files_to_keep[@]}"

if [[ "$BACKUP" == true ]]; then
    echo "Backup created in: $BACKUP_DIR"
fi

echo "Space saved: $(numfmt --to=iec $total_size)"
echo ""
echo "Cleanup completed successfully!"