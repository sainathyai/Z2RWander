#!/bin/bash

# Script to update the color in the static HTML page
# Usage: ./scripts/update-color.sh <color>
# Example: ./scripts/update-color.sh "#ff6b6b"

set -e

COLOR=${1:-"#667eea"}
HTML_FILE="static-app/index.html"

if [ ! -f "$HTML_FILE" ]; then
    echo "❌ Error: $HTML_FILE not found"
    exit 1
fi

echo "🎨 Updating color to: $COLOR"

# Update color in HTML file
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|background-color:.*;|background-color: $COLOR;|g" "$HTML_FILE"
    sed -i '' "s|background: linear-gradient.*|background: $COLOR;|g" "$HTML_FILE"
else
    # Linux
    sed -i "s|background-color:.*;|background-color: $COLOR;|g" "$HTML_FILE"
    sed -i "s|background: linear-gradient.*|background: $COLOR;|g" "$HTML_FILE"
fi

echo "✅ Color updated in $HTML_FILE"
echo ""
echo "📝 Next steps:"
echo "   1. Review changes: git diff $HTML_FILE"
echo "   2. Commit: git add $HTML_FILE && git commit -m 'chore: update color to $COLOR'"
echo "   3. Push: git push origin main"
echo "   4. Watch GitHub Actions workflow deploy automatically!"

