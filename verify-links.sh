#!/bin/bash
# Verification script for internal markdown links

HANDBOOK_ROOT="/home/jirka/GitHub/Olbrasoft/engineering-handbook"
cd "$HANDBOOK_ROOT" || exit 1

echo "=== Verifying Internal Markdown Links ==="
echo ""

BROKEN_COUNT=0
TOTAL_COUNT=0

# Find all markdown files
while IFS= read -r file; do
    # Extract all markdown links from the file
    while IFS= read -r link; do
        # Skip external links (http/https)
        if [[ "$link" =~ ^https?:// ]]; then
            continue
        fi
        
        # Skip anchors
        if [[ "$link" =~ ^# ]]; then
            continue
        fi
        
        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        
        # Get directory of current file
        FILE_DIR=$(dirname "$file")
        
        # Resolve relative path
        TARGET="$FILE_DIR/$link"
        
        # Remove anchor fragments
        TARGET_FILE="${TARGET%%#*}"
        
        # Check if target exists
        if [ ! -f "$TARGET_FILE" ]; then
            echo "❌ BROKEN: $file"
            echo "   Link: $link"
            echo "   Target: $TARGET_FILE (NOT FOUND)"
            echo ""
            BROKEN_COUNT=$((BROKEN_COUNT + 1))
        fi
    done < <(grep -oP '\[.*?\]\(\K[^)]+(?=\))' "$file" 2>/dev/null || true)
done < <(find . -name "*.md" -type f)

echo "=== Summary ==="
echo "Total links checked: $TOTAL_COUNT"
echo "Broken links found: $BROKEN_COUNT"

if [ $BROKEN_COUNT -eq 0 ]; then
    echo "✅ All links verified successfully!"
    exit 0
else
    echo "⚠️  Found $BROKEN_COUNT broken link(s)"
    exit 1
fi
