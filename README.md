![example](https://raw.githubusercontent.com/wstam88/rofi-fontawesome/master/example.gif)

# Rofi-FontAwesome v2.0

**A smart FontAwesome icon picker for Rofi with automatic downloads, version selection, and multi-style support.**

Browse and select FontAwesome icons using [Rofi](https://github.com/davatorium/rofi), copy them to your clipboard in various formats (icon, unicode, name, CSS class, HTML). Perfect for developers, designers, and anyone working with FontAwesome.

## ✨ Version 2.0 Features

- 🚀 **Auto-download** FontAwesome metadata from GitHub
- 🎯 **Version selection** - Support for FA5, FA6.x, and future versions
- 🎨 **Multiple styles** - Solid, Regular, Brands, and more
- 🔧 **Smart generator** - Python-based with caching
- ⚙️ **Configuration system** - Customizable defaults
- 🔄 **Easy updates** - One command to update icon lists
- 💻 **Interactive menus** - User-friendly setup and selection
- 🪟 **Wayland & X11** - Auto-detection of clipboard tools
- 📋 **Multiple output formats** - Icon, unicode, name, CSS class, HTML

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/wstam88/rofi-fontawesome.git
cd rofi-fontawesome

# Run the installer
./install.sh

# Generate icon lists (FontAwesome 6)
./update.sh
```

### Basic Usage

```bash
# Launch icon picker (auto-detect latest version)
fontawesome-menu

# Select specific version and style
fontawesome-menu -V 6 -s brands

# Copy icon name instead of character
fontawesome-menu name

# Copy as HTML
fontawesome-menu html

# Interactive list selection
fontawesome-menu -i
```

## 📋 Requirements

**Required:**
- [Rofi](https://github.com/davatorium/rofi) - Application launcher
- Python 3 - For the generator script
- FontAwesome fonts - The actual icon fonts

**Optional:**
- `xclip` (X11) or `wl-clipboard` (Wayland) - For clipboard support
- `notify-send` - For desktop notifications
- `jq` - For configuration file support

### Installing Requirements

**Debian/Ubuntu:**
```bash
sudo apt install rofi python3 python3-pip xclip
```

**Fedora:**
```bash
sudo dnf install rofi python3 python3-pip xclip
```

**Arch Linux:**
```bash
sudo pacman -S rofi python python-pip xclip
```

**Wayland users:**
```bash
# Install wl-clipboard instead of xclip
sudo apt install wl-clipboard  # Debian/Ubuntu
sudo dnf install wl-clipboard  # Fedora
sudo pacman -S wl-clipboard    # Arch
```

## 📖 Usage

### fontawesome-menu Command

```bash
fontawesome-menu [OPTIONS] [OUTPUT_MODE]
```

**Options:**
- `-v` - Show version and exit
- `-h` - Show help
- `-l` - List available icon lists
- `-i` - Interactive list selection
- `-f LISTFILE` - Specify icon list file
- `-V VERSION` - FontAwesome version (default: 6)
- `-s STYLE` - Icon style: solid, regular, brands, etc.
- `-p PROMPT` - Rofi prompt text
- `-o OPTIONS` - Additional rofi options

**Output Modes:**
- `icon` - Copy icon character (default)
- `unicode` - Copy unicode hex value
- `name` - Copy icon name
- `class` - Copy CSS class (e.g., "fa-home")
- `html` - Copy HTML tag (e.g., "&lt;i class='fa fa-home'&gt;&lt;/i&gt;")

### Examples

```bash
# Basic - copy icon to clipboard
fontawesome-menu

# Copy icon name
fontawesome-menu name

# Copy as HTML tag
fontawesome-menu html

# Select FontAwesome 6 brands
fontawesome-menu -V 6 -s brands

# Custom rofi appearance
fontawesome-menu -o "-columns 8 -lines 15" -p "Pick icon:"

# Use specific icon list file
fontawesome-menu -f icons/fa6-solid.txt

# Interactive: choose from available lists
fontawesome-menu -i

# List all available icon lists
fontawesome-menu -l
```

## 🔧 Generator & Updates

### Generate Icon Lists

The `update.sh` script helps you generate and manage icon lists.

```bash
# Quick setup (generate FA6 lists)
./update.sh

# Interactive menu with all options
./update.sh --menu

# Generate specific version
./update.sh --version 6.5.1

# List available FontAwesome versions
./update.sh --list

# Clear cache and regenerate
./update.sh --clear-cache
```

### Manual Generation (Python)

```bash
# Generate FontAwesome 6 (all styles)
./generators/generate_icons.py

# Generate specific version
./generators/generate_icons.py --version 6.5.1

# Generate only specific styles
./generators/generate_icons.py --styles solid brands

# Generate with colors
./generators/generate_icons.py --colors

# List available versions from GitHub
./generators/generate_icons.py --list-versions

# Clear cached metadata
./generators/generate_icons.py --clear-cache
```

## ⚙️ Configuration

Edit `generators/config.json` to set your preferences:

```json
{
  "version": "6",
  "styles": ["solid", "regular", "brands"],
  "use_colors": false,
  "default_style": "solid",
  "rofi_options": {
    "columns": 6,
    "width": 100,
    "lines": 20,
    "location": 1
  }
}
```

**Configuration options:**
- `version` - Default FontAwesome version
- `styles` - Which styles to generate by default
- `use_colors` - Enable colored icon display
- `default_style` - Default style for fontawesome-menu
- `rofi_options` - Default rofi display settings

## 🎯 Keyboard Shortcuts

Set up a keyboard shortcut to quickly access fontawesome-menu:

**i3/Sway:**
```
# Add to ~/.config/i3/config or ~/.config/sway/config
bindsym $mod+F9 exec --no-startup-id fontawesome-menu
```

**GNOME:**
- Settings → Keyboard → Custom Shortcuts
- Command: `fontawesome-menu`

**KDE Plasma:**
- System Settings → Shortcuts → Custom Shortcuts
- Command: `fontawesome-menu`

## 📁 Directory Structure

```
rofi-fontawesome/
├── generators/
│   ├── generate_icons.py    # Main generator script
│   ├── config.json           # Configuration
│   └── requirements.txt      # Python dependencies
├── icons/                    # Generated icon lists
│   ├── fa6-solid.txt
│   ├── fa6-regular.txt
│   ├── fa6-brands.txt
│   └── ...
├── fontawesome-menu/
│   └── fontawesome-menu      # Main script
├── install.sh                # Installation script
├── update.sh                 # Update/generate script
└── README.md
```

## 🔄 Updating

To update to the latest FontAwesome version:

```bash
cd rofi-fontawesome
./update.sh --menu
# Select option 1 for latest FontAwesome 6
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📜 License

This project builds on the original work by budRich and continues to be open source.

## 🙏 Credits

- Original idea and script by [budRich](https://github.com/budRich)
- [FontAwesome](https://fontawesome.com) for the amazing icon library
- [Rofi](https://github.com/davatorium/rofi) for the launcher

## 📝 Changelog

### Version 2.0.0
- Complete rewrite with Python-based generator
- Automatic metadata download from GitHub
- Support for multiple FontAwesome versions (5, 6.x)
- Multiple style support (solid, regular, brands, etc.)
- Interactive installation and update scripts
- Configuration system
- Enhanced output modes (class, html)
- Wayland clipboard support
- Desktop notifications
- Auto-detection of icon lists
- Improved error handling and user experience

### Legacy (v0.001)
- Basic icon list for FontAwesome 4 and 5
- Simple rofi integration
- X11 clipboard support
