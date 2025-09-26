#!/bin/bash
# Quick file organization and analysis
# Usage: ./quick-organize.sh

cd downloads

# Create folders
mkdir -p A B

# Convert non-txt files to txt and organize
for file in *.{md,docx,pdf,html,json}; do
    [ -f "$file" ] || continue
    basename="${file%.*}"
    
    case "${file##*.}" in
        "md"|"json") cp "$file" "A/${basename}.txt" ;;
        "html") sed 's/<[^>]*>//g' "$file" > "A/${basename}.txt" ;;
        *) echo "[FILE: $file]" > "A/${basename}.txt" ;;
    esac
    
    mv "$file" "B/"
done

cd ..

# Run analysis
./tree-with-wc.sh

echo ""
echo "=== Potential Duplicates by Word Count ==="
find downloads -name "*.txt" -exec wc -w {} \; | sort -n | awk '{print $1}' | uniq -d | while read count; do
    echo "Files with $count words:"
    find downloads -name "*.txt" -exec wc -w {} \; | grep "^$count " | awk '{print "  " $2}'
done