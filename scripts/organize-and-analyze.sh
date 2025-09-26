#!/bin/bash
# Organize files and analyze for duplicates
# Usage: ./organize-and-analyze.sh

set -e  # Exit on any error

DOWNLOADS_DIR="downloads"
TXT_FOLDER="A"
NON_TXT_FOLDER="B"

echo "=== File Organization and Duplicate Analysis ==="
echo "Starting at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Check if downloads directory exists
if [ ! -d "$DOWNLOADS_DIR" ]; then
    echo "Error: $DOWNLOADS_DIR directory not found!"
    exit 1
fi

cd "$DOWNLOADS_DIR"

# Create subdirectories
mkdir -p "$TXT_FOLDER" "$NON_TXT_FOLDER"

echo "Step 1: Converting non-txt files to txt and organizing..."

# Counter for tracking
converted_count=0
moved_count=0

# Process all files in downloads directory (not subdirectories)
for file in *; do
    # Skip if it's a directory
    if [ -d "$file" ]; then
        continue
    fi
    
    # Get file extension
    extension="${file##*.}"
    basename="${file%.*}"
    
    # Skip if already a .txt file
    if [ "$extension" = "txt" ]; then
        continue
    fi
    
    echo "Processing: $file"
    
    # Convert based on file type
    case "$extension" in
        "md")
            # Markdown files - copy as-is to txt
            cp "$file" "$TXT_FOLDER/${basename}.txt"
            converted_count=$((converted_count + 1))
            ;;
        "docx")
            # Try to extract text from docx using available tools
            if command -v pandoc >/dev/null 2>&1; then
                pandoc "$file" -t plain -o "$TXT_FOLDER/${basename}.txt" 2>/dev/null || {
                    echo "  Warning: Could not convert $file with pandoc, creating placeholder"
                    echo "[DOCX FILE: $file - conversion failed]" > "$TXT_FOLDER/${basename}.txt"
                }
            elif command -v unzip >/dev/null 2>&1; then
                # Try basic docx text extraction
                temp_dir=$(mktemp -d)
                if unzip -q "$file" -d "$temp_dir" 2>/dev/null; then
                    if [ -f "$temp_dir/word/document.xml" ]; then
                        # Extract text from XML (basic approach)
                        sed -e 's/<[^>]*>//g' "$temp_dir/word/document.xml" > "$TXT_FOLDER/${basename}.txt"
                    else
                        echo "[DOCX FILE: $file - no readable content found]" > "$TXT_FOLDER/${basename}.txt"
                    fi
                else
                    echo "[DOCX FILE: $file - extraction failed]" > "$TXT_FOLDER/${basename}.txt"
                fi
                rm -rf "$temp_dir"
            else
                echo "[DOCX FILE: $file - no conversion tools available]" > "$TXT_FOLDER/${basename}.txt"
            fi
            converted_count=$((converted_count + 1))
            ;;
        "pdf")
            # Try to extract text from PDF
            if command -v pdftotext >/dev/null 2>&1; then
                pdftotext "$file" "$TXT_FOLDER/${basename}.txt" 2>/dev/null || {
                    echo "[PDF FILE: $file - conversion failed]" > "$TXT_FOLDER/${basename}.txt"
                }
            else
                echo "[PDF FILE: $file - no conversion tools available]" > "$TXT_FOLDER/${basename}.txt"
            fi
            converted_count=$((converted_count + 1))
            ;;
        "html")
            # Extract text from HTML
            if command -v lynx >/dev/null 2>&1; then
                lynx -dump "$file" > "$TXT_FOLDER/${basename}.txt" 2>/dev/null || {
                    # Fallback: basic HTML tag removal
                    sed -e 's/<[^>]*>//g' "$file" > "$TXT_FOLDER/${basename}.txt"
                }
            else
                # Basic HTML tag removal
                sed -e 's/<[^>]*>//g' "$file" > "$TXT_FOLDER/${basename}.txt"
            fi
            converted_count=$((converted_count + 1))
            ;;
        "json")
            # JSON files - copy as-is to txt
            cp "$file" "$TXT_FOLDER/${basename}.txt"
            converted_count=$((converted_count + 1))
            ;;
        *)
            # For other file types, create a placeholder or try basic text extraction
            if file "$file" | grep -q "text"; then
                cp "$file" "$TXT_FOLDER/${basename}.txt"
                converted_count=$((converted_count + 1))
            else
                echo "[BINARY FILE: $file - type: $extension]" > "$TXT_FOLDER/${basename}.txt"
                converted_count=$((converted_count + 1))
            fi
            ;;
    esac
    
    # Move original file to folder B
    mv "$file" "$NON_TXT_FOLDER/"
    moved_count=$((moved_count + 1))
done

echo ""
echo "Step 1 Complete:"
echo "  - Converted $converted_count files to txt format"
echo "  - Moved $moved_count original files to folder B"
echo ""

# Go back to parent directory
cd ..

echo "Step 2: Running tree analysis..."
echo ""

# Run the tree analysis
if [ -f "tree-with-wc.sh" ]; then
    ./tree-with-wc.sh
else
    echo "Warning: tree-with-wc.sh not found, generating basic analysis..."
    echo "# Basic File Analysis"
    find downloads -name "*.txt" | while read -r file; do
        WC=$(wc -w "$file" 2>/dev/null | awk '{print $1}')
        LC=$(wc -l "$file" 2>/dev/null | awk '{print $1}')
        echo "$file | $LC lines | $WC words"
    done
fi

echo ""
echo "Step 3: Analyzing potential txt duplicates..."
echo ""

# Find potential duplicates by comparing file sizes and word counts
echo "## Potential Duplicates Analysis"
echo ""

# Create temporary file for analysis
temp_file=$(mktemp)

# Get word counts for all txt files
find downloads -name "*.txt" -exec wc -w {} \; | sort -n > "$temp_file"

echo "### Files with identical word counts:"
awk '{print $1}' "$temp_file" | uniq -d | while read -r wordcount; do
    echo ""
    echo "**$wordcount words:**"
    grep "^$wordcount " "$temp_file" | while read -r count file; do
        echo "  - $file"
    done
done

echo ""
echo "### Files with similar word counts (within 10% difference):"
echo ""

# More sophisticated duplicate detection
prev_count=0
prev_files=""

while read -r count file; do
    if [ "$prev_count" -ne 0 ]; then
        # Calculate 10% difference
        diff=$((count - prev_count))
        threshold=$((prev_count / 10))
        
        if [ "$diff" -le "$threshold" ] && [ "$diff" -ge 0 ]; then
            if [ -n "$prev_files" ]; then
                echo "**Similar word counts ($prev_count - $count words):**"
                echo "$prev_files"
                echo "  - $file"
                echo ""
                prev_files=""
            else
                prev_files="  - $file"
            fi
        else
            prev_files=""
        fi
    fi
    prev_count="$count"
done < "$temp_file"

# Clean up
rm "$temp_file"

echo ""
echo "=== Analysis Complete ==="
echo "Finished at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Next steps:"
echo "1. Review the files in downloads/A/ (converted txt files)"
echo "2. Check downloads/B/ (original non-txt files)"
echo "3. Examine potential duplicates identified above"
echo "4. Use 'diff' command to compare suspected duplicate files"