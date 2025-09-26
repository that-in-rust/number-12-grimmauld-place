#!/bin/bash
# Cleanup Obvious Duplicates - Phase 1
# Removes numbered duplicates and clear copies

set -e
echo "=== Automated Duplicate Cleanup - Phase 1 ==="
echo "Starting at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

cd downloads

# Counter for tracking
removed_count=0
space_saved=0

echo "Removing numbered JSON duplicates..."

# Remove numbered JSON duplicates (keep base file)
for pattern in "trun_*"; do
    if [[ -f "${pattern} (1).json" ]]; then
        echo "  Removing: ${pattern} (1).json"
        rm "${pattern} (1).json"
        removed_count=$((removed_count + 1))
    fi
    
    if [[ -f "${pattern} (2).json" ]]; then
        echo "  Removing: ${pattern} (2).json"
        rm "${pattern} (2).json"
        removed_count=$((removed_count + 1))
    fi
    
    if [[ -f "${pattern} (3).json" ]]; then
        echo "  Removing: ${pattern} (3).json"
        rm "${pattern} (3).json"
        removed_count=$((removed_count + 1))
    fi
    
    if [[ -f "${pattern} (copy).txt" ]]; then
        echo "  Removing: ${pattern} (copy).txt"
        rm "${pattern} (copy).txt"
        removed_count=$((removed_count + 1))
    fi
done

# Specific numbered duplicates
duplicates_to_remove=(
    "trun_82b88932a051498485c362bd64070533 (1).json"
    "trun_82b88932a051498485c362bd64070533 (2).json"
    "trun_82b88932a0514984a4fd517f37b144be (1).json"
    "trun_82b88932a0514984a4fd517f37b144be (2).json"
    "trun_82b88932a0514984a4fd517f37b144be (3).json"
    "trun_1b986480e1c84d75bc94381ba6d21189 (1).json"
    "trun_4122b840faa84ad7a24867ec3a76c16a (1)(1).json"
    "trun_4122b840faa84ad7a24867ec3a76c16a (1).json"
    "trun_82b88932a0514984bc2d6d98eab7423f (1) (1).json"
    "trun_82b88932a0514984bc2d6d98eab7423f (1).json"
    "trun_da5838edb25d44d3b54fe7c1fd3e5d2a (1).json"
    "trun_82b88932a0514984bbc73cb821649c97 (1).json"
    "trun_8a68e63f9ca642388121233cd75ecef5 (1).json"
    "trun_8a68e63f9ca6423894b4dc079ec90d29 (1).json"
    "trun_8a68e63f9ca64238ab97093c27d9e02b (1).json"
    "trun_8a68e63f9ca64238b7fb5a71bce5e74c (1).json"
    "trun_c30434831bfd40aba2819290f7c83f33 (1).json"
    "trun_c30434831bfd40aba2819290f7c83f33 (2).json"
    "trun_c30434831bfd40abac93f716bac62274 (1).json"
    "trun_c30434831bfd40abad60893b9aa5c659 (1).json"
    "trun_c30434831bfd40abad60893b9aa5c659 (2).json"
    "trun_c30434831bfd40abb830834705a1c6c4 (1).json"
    "trun_da5838edb25d44d389074277f64aa5e8 (1).json"
    "trun_1b986480e1c84d75b1db55a0eab78357 (1).json"
)

echo ""
echo "Removing specific numbered duplicates..."
for file in "${duplicates_to_remove[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  Removing: $file"
        rm "$file"
        removed_count=$((removed_count + 1))
    fi
done

echo ""
echo "Removing Rust300 duplicates in folder A..."
cd A

# Remove Rust300 duplicates (keep one of each)
rust_duplicates=(
    "Rust300 Rust CPU Library Idea Generation(1).txt"
    "Rust300 Rust CPU Library Idea Generation(2).txt"
    "Rust Micro-Libraries for CPU-Intensive Tasks(1).txt"
    "Rust300 Rust Micro-Library Idea Generation(1).txt"
    "Rust Micro-Libraries for CPU(1).txt"
    "RustLLM Rust300 Consolidated Pre-Development Specification for Minimalist Rust Utilities.txt"
    "RustLLM Rust300 Rust Library Idea Generation.txt"
)

for file in "${rust_duplicates[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  Removing: $file"
        rm "$file"
        removed_count=$((removed_count + 1))
    fi
done

# Remove A01 duplicates (keep one)
a01_duplicates=(
    "A01Rust300Doc20250923.docx.txt"
    "A01Rust300Doc20250923.txt"
)

for file in "${a01_duplicates[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  Removing: $file"
        rm "$file"
        removed_count=$((removed_count + 1))
    fi
done

cd ../..

echo ""
echo "=== Cleanup Complete ==="
echo "Files removed: $removed_count"
echo "Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Running tree analysis to verify results..."