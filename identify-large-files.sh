#!/bin/bash
# Identify Files Over 1MB
# Shows files larger than 1MB with their sizes and word counts

echo "=== Files Over 1MB Analysis ==="
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

echo "## Files Over 1MB (sorted by size):"
echo ""

# Find files over 1MB and sort by size
find downloads -type f -size +1M -exec ls -lh {} \; | sort -k5 -hr | while read -r line; do
    # Extract filename from ls output
    file=$(echo "$line" | awk '{print $NF}')
    size=$(echo "$line" | awk '{print $5}')
    
    # Get word count if it's a text file
    if file "$file" | grep -qE "(text|JSON data)"; then
        wc=$(wc -w "$file" 2>/dev/null | awk '{print $1}')
        lc=$(wc -l "$file" 2>/dev/null | awk '{print $1}')
        echo "- **$file** | $size | $lc lines | $wc words"
    else
        echo "- **$file** | $size | [binary file]"
    fi
done

echo ""
echo "## Summary of Large Files:"

total_large_files=$(find downloads -type f -size +1M | wc -l)
total_size=$(find downloads -type f -size +1M -exec ls -l {} \; | awk '{sum += $5} END {print sum}')
total_size_mb=$((total_size / 1024 / 1024))

echo "- **Total files over 1MB**: $total_large_files"
echo "- **Combined size**: ${total_size_mb}MB"
echo ""

echo "## Breakdown by file type:"
echo ""

echo "### JSON files over 1MB:"
find downloads -name "*.json" -size +1M -exec ls -lh {} \; | wc -l | xargs echo "Count:"

echo ""
echo "### Text files over 1MB:"
find downloads -name "*.txt" -size +1M -exec ls -lh {} \; | wc -l | xargs echo "Count:"

echo ""
echo "### Markdown files over 1MB:"
find downloads -name "*.md" -size +1M -exec ls -lh {} \; | wc -l | xargs echo "Count:"