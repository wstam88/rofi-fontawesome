![example](https://raw.githubusercontent.com/wstam88/rofi-fontawesome/master/example.gif)

# Font Awesome icon list for Rofi

Search and select Font Awesome icons from a [rofi](https://github.com/davatorium/rofi) menu and copy them to your clipboard. Works on both X11 (xclip) and Wayland (wl-copy).

## Available icon lists

| File | Font Awesome | Description |
|------|-------------|-------------|
| `fa6-icon-list.txt` | **6 (Free)** | 2060 icons — solid, regular & brands |
| `fa6-icon-list-tags.txt` | **6 (Free)** | Same, with search tags for better filtering |
| `fa5-icon-list.txt` | 5 (Free) | 1329 icons — solid & brands |
| `fa5-icon-list-tags.txt` | 5 (Free) | Same, with search tags |
| `icon-list.txt` | 4 | Legacy icon list with class names |
| `unicode-list.txt` | 4 | Legacy unicode list |

## Requirements

* [Rofi](https://github.com/davatorium/rofi)
* [Font Awesome](https://fontawesome.com/) font installed
* A clipboard utility: [xclip](https://github.com/astrand/xclip) (X11) or [wl-copy](https://github.com/bugaevc/wl-clipboard) (Wayland)

## Quick start

### Copy an icon to clipboard (FA6)
```bash
selected=$(rofi -dmenu -i -markup-rows \
  -columns 6 -width 100 -location 1 -lines 20 -bw 2 -yoffset -2 \
  -p "Select icon: " < fa6-icon-list.txt)

# Exit if nothing selected
[[ -z $selected ]] && exit

# Copy icon to clipboard
echo -ne "$(echo "$selected" \
  | awk -F';' -v RS='>' '
      NR==2{sub("&#x","",$1);print "\\u" $1;exit}'
)" | xclip -selection clipboard
```

### Using fontawesome-menu (recommended)
```bash
# Default (FA5 icons)
fontawesome-menu -o '-i -columns 6 -width 100 -lines 20 -bw 2 -yoffset -2 -location 1'

# With FA6 icons
fontawesome-menu -f fa6-icon-list.txt \
  -o '-i -columns 6 -width 100 -lines 20' \
  -p "Select icon: "

# Copy icon name instead of the icon itself
fontawesome-menu -f fa6-icon-list.txt name

# Copy unicode value
fontawesome-menu -f fa6-icon-list.txt unicode
```

See [fontawesome-menu](fontawesome-menu/) for full documentation.

## Regenerating icon lists

To update the FA6 icon lists (e.g., when a new Font Awesome version is released):

```bash
# Requires: curl, python3
./generate-icon-list.sh
```

This downloads the latest Font Awesome 6 metadata and regenerates `fa6-icon-list.txt` and `fa6-icon-list-tags.txt`.

## License

[MIT](LICENSE)
