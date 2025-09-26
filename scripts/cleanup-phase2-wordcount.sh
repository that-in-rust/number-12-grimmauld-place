#!/bin/bash
# Cleanup Phase 2 - Remove duplicates by word count (keep longer filename)
# Strategy: If word counts match, keep the file with the longer name

set -e
echo "=== Phase 2 Cleanup - Word Count Duplicates ==="
echo "Starting at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

cd downloads

removed_count=0

echo "Analyzing files with identical word counts..."

# Create temporary file for word count analysis
temp_file=$(mktemp)
find . -name "*.txt" -o -name "*.json" -o -name "*.md" | while read -r file; do
    wc=$(wc -w "$file" 2>/dev/null | awk '{print $1}')
    echo "$wc|$file"
done | sort -n > "$temp_file"

echo ""
echo "Processing duplicate word counts..."

# Process duplicates
current_count=""
current_files=()

while IFS='|' read -r count file; do
    if [[ "$count" == "$current_count" ]]; then
        # Add to current group
        current_files+=("$file")
    else
        # Process previous group if it had duplicates
        if [[ ${#current_files[@]} -gt 1 ]]; then
            echo ""
            echo "Found ${#current_files[@]} files with $current_count words:"
            
            # Sort by filename length (longest first)
            longest_file=""
            longest_length=0
            
            for f in "${current_files[@]}"; do
                echo "  - $f (${#f} chars)"
                if [[ ${#f} -gt $longest_length ]]; then
                    longest_length=${#f}
                    longest_file="$f"
                fi
            done
            
            echo "  → Keeping: $longest_file (longest name)"
            
            # Remove all others
            for f in "${current_files[@]}"; do
                if [[ "$f" != "$longest_file" ]]; then
                    echo "  → Removing: $f"
                    rm "$f"
                    removed_count=$((removed_count + 1))
                fi
            done
        fi
        
        # Start new group
        current_count="$count"
        current_files=("$file")
    fi
done < "$temp_file"

# Process last group
if [[ ${#current_files[@]} -gt 1 ]]; then
    echo ""
    echo "Found ${#current_files[@]} files with $current_count words:"
    
    longest_file=""
    longest_length=0
    
    for f in "${current_files[@]}"; do
        echo "  - $f (${#f} chars)"
        if [[ ${#f} -gt $longest_length ]]; then
            longest_length=${#f}
            longest_file="$f"
        fi
    done
    
    echo "  → Keeping: $longest_file (longest name)"
    
    for f in "${current_files[@]}"; do
        if [[ "$f" != "$longest_file" ]]; then
            echo "  → Removing: $f"
            rm "$f"
            removed_count=$((removed_count + 1))
        fi
    done
fi

# Clean up temp file
rm "$temp_file"

echo ""
echo "Additional cleanup - remaining obvious duplicates..."

# Remove remaining (copy) and numbered variants
remaining_duplicates=(
    "trun_82b88932a05149848977c59a26485225 (1).json"
    "trun_4122b840faa84ad7bd2e860325ea0a58 (2).json"
    "trun_c30434831bfd40aba2819290f7c83f33 (copy).txt"
    "trun_c30434831bfd40abad60893b9aa5c659 (copy).txt"
    "trun_c30434831bfd40abadd29858a9d0d260 (copy).txt"
    "Rust Parallel 20250919 trun_c30434831bfd40abac93f716bac62274 (copy).txt"
)

for file in "${remaining_duplicates[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  Removing remaining duplicate: $file"
        rm "$file"
        removed_count=$((removed_count + 1))
    fi
done

cd ..

echo ""
echo "=== Phase 2 Cleanup Complete ==="
echo "Files removed: $removed_count"
echo "Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Running tree analysis to verify results..."