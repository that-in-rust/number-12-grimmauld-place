#!/bin/bash
# Final Cleanup - Keep Longer Files Only
# Remove shorter versions when similar content exists

set -e
echo "=== Final Cleanup - Keep Longer Files ==="
echo "Starting at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

cd downloads

removed_count=0

echo "Removing shorter versions of similar files..."

# Remove shorter versions of PRDs files
if [[ -f "PRDsRust300p1.md.txt" && -f "PRDsRust300p1.txt" ]]; then
    # Keep PRDsRust300p1.txt (1869 words) vs PRDsRust300p1.md.txt (1838 words)
    echo "  Removing: PRDsRust300p1.md.txt (shorter version)"
    rm "PRDsRust300p1.md.txt"
    removed_count=$((removed_count + 1))
fi

# Remove shorter versions of Rust30020250815 files
if [[ -f "Rust30020250815_complete.md.txt" && -f "Rust30020250815_complete.txt" ]]; then
    # Keep Rust30020250815_complete.txt (1580 words) vs .md.txt (1569 words)
    echo "  Removing: Rust30020250815_complete.md.txt (shorter version)"
    rm "Rust30020250815_complete.md.txt"
    removed_count=$((removed_count + 1))
fi

if [[ -f "Rust30020250815_full.md.txt" && -f "Rust30020250815_full.txt" ]]; then
    # Keep Rust30020250815_full.txt (1796 words) vs .md.txt (1760 words)
    echo "  Removing: Rust30020250815_full.md.txt (shorter version)"
    rm "Rust30020250815_full.md.txt"
    removed_count=$((removed_count + 1))
fi

if [[ -f "Rust30020250815_minto.md.txt" && -f "Rust30020250815_minto.txt" ]]; then
    # Keep Rust30020250815_minto.txt (811 words) vs .md.txt (783 words)
    echo "  Removing: Rust30020250815_minto.md.txt (shorter version)"
    rm "Rust30020250815_minto.md.txt"
    removed_count=$((removed_count + 1))
fi

# Remove truncated file
if [[ -f "tokio-rs-axum-8a5edab282632443 TRUNC.txt" ]]; then
    echo "  Removing: tokio-rs-axum-8a5edab282632443 TRUNC.txt (truncated version)"
    rm "tokio-rs-axum-8a5edab282632443 TRUNC.txt"
    removed_count=$((removed_count + 1))
fi

# Remove tiny task tracker file
if [[ -f "task-tracker01.txt" ]]; then
    echo "  Removing: task-tracker01.txt (tiny file, 53 words)"
    rm "task-tracker01.txt"
    removed_count=$((removed_count + 1))
fi

# Keep WORKFLOW_TEMPLATES.txt (3149 words), remove smaller ones
if [[ -f "WORKFLOW_TEMPLATES.txt" && -f "workflow_templates.txt" ]]; then
    echo "  Removing: workflow_templates.txt (keeping larger WORKFLOW_TEMPLATES.txt)"
    rm "workflow_templates.txt"
    removed_count=$((removed_count + 1))
fi

cd ..

echo ""
echo "=== Final Cleanup Complete ==="
echo "Files removed: $removed_count"
echo "Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""