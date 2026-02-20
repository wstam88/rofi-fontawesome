#!/bin/bash
#
# generate-icon-list.sh - Generate Font Awesome 6 icon lists for rofi
#
# Downloads Font Awesome 6 metadata and generates icon lists in Pango
# markup format compatible with rofi's -markup-rows option.
#
# Dependencies: curl, python3
#
# Usage: ./generate-icon-list.sh
#
# Generates:
#   fa6-icon-list.txt      - Icon list (name + unicode glyph)
#   fa6-icon-list-tags.txt - Icon list with search tags
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
METADATA_URL="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/metadata/icons.json"
OUTPUT_FILE="${SCRIPT_DIR}/fa6-icon-list.txt"
OUTPUT_FILE_TAGS="${SCRIPT_DIR}/fa6-icon-list-tags.txt"

echo "Downloading Font Awesome 6 metadata..."
METADATA=$(curl -sfL "$METADATA_URL")

if [[ -z "$METADATA" ]]; then
    echo "Error: Failed to download metadata from ${METADATA_URL}" >&2
    exit 1
fi

echo "Generating icon lists..."

python3 -c "
import json
import sys
import hashlib

data = json.loads(sys.stdin.read())

# Font face and weight mapping for FA6 free icons
STYLE_MAP = {
    'solid':   ('Font Awesome 6 Free',   '900'),
    'regular': ('Font Awesome 6 Free',   '400'),
    'brands':  ('Font Awesome 6 Brands', '400'),
}

lines = []
lines_tags = []

for icon_id, icon in sorted(data.items()):
    free_styles = icon.get('free', [])
    if not free_styles:
        continue

    label = icon.get('label', icon_id)
    unicode_hex = icon.get('unicode', '')
    terms = icon.get('search', {}).get('terms', [])

    if not unicode_hex:
        continue

    for style in free_styles:
        if style not in STYLE_MAP:
            continue

        face, weight = STYLE_MAP[style]

        # Basic list (same format as fa5-icon-list.txt)
        line = (
            f\"<span lang='{icon_id}' weight=\\\"{weight}\\\" \"
            f\"fallback=\\\"true\\\" face='{face}'>\"
            f\"&#x{unicode_hex};</span>  {label}\"
        )
        lines.append((label.lower(), line))

        # Tags list (same format as fa5-icon-list-tags.txt)
        tags_str = ' '.join(str(t) for t in terms)
        # Generate a deterministic color from the icon id + style
        color_hash = hashlib.md5((icon_id + style).encode()).hexdigest()[:6]
        # Ensure the color is bright enough to be visible
        r = max(int(color_hash[0:2], 16), 100)
        g = max(int(color_hash[2:4], 16), 100)
        b = max(int(color_hash[4:6], 16), 100)
        color = f'#{r:02x}{g:02x}{b:02x}'

        line_tags = (
            f\"<span lang='{icon_id}___{tags_str}' foreground='{color}' \"
            f\"weight=\\\"{weight}\\\" fallback=\\\"true\\\" face='{face}'>\"
            f\"&#x{unicode_hex};</span>  {label}\"
        )
        lines_tags.append((label.lower(), line_tags))

# Sort by label
lines.sort(key=lambda x: x[0])
lines_tags.sort(key=lambda x: x[0])

# Write basic list
with open('${OUTPUT_FILE}', 'w') as f:
    for _, line in lines:
        f.write(line + '\n')

# Write tags list
with open('${OUTPUT_FILE_TAGS}', 'w') as f:
    for _, line in lines_tags:
        f.write(line + '\n')

print(f'Generated {len(lines)} icon entries in fa6-icon-list.txt')
print(f'Generated {len(lines_tags)} icon entries in fa6-icon-list-tags.txt')
" <<< "$METADATA"

echo "Done!"
