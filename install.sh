#!/bin/bash

# Rofi-FontAwesome Installation Script
# Version 2.0

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_msg() {
  local color=$1
  shift
  echo -e "${color}$@${NC}"
}

print_header() {
  clear
  echo ""
  print_msg "$BLUE" "═══════════════════════════════════════════════════════"
  print_msg "$BLUE" "  Rofi-FontAwesome Installation v2.0"
  print_msg "$BLUE" "═══════════════════════════════════════════════════════"
  echo ""
}

check_dependencies() {
  print_msg "$YELLOW" "Checking dependencies..."
  echo ""

  local deps=("rofi" "python3")
  local optional_deps=("xclip" "wl-copy" "notify-send" "jq")
  local missing_required=()
  local missing_optional=()

  # Check required dependencies
  for dep in "${deps[@]}"; do
    if command -v "$dep" &> /dev/null; then
      print_msg "$GREEN" "  ✓ $dep"
    else
      print_msg "$RED" "  ✗ $dep (required)"
      missing_required+=("$dep")
    fi
  done

  # Check optional dependencies
  for dep in "${optional_deps[@]}"; do
    if command -v "$dep" &> /dev/null; then
      print_msg "$GREEN" "  ✓ $dep"
    else
      print_msg "$YELLOW" "  ! $dep (optional)"
      missing_optional+=("$dep")
    fi
  done

  echo ""

  if [ ${#missing_required[@]} -ne 0 ]; then
    print_msg "$RED" "Missing required dependencies. Please install:"
    echo ""
    print_msg "$YELLOW" "Debian/Ubuntu:"
    echo "  sudo apt install rofi python3 python3-pip"
    echo ""
    print_msg "$YELLOW" "Fedora:"
    echo "  sudo dnf install rofi python3 python3-pip"
    echo ""
    print_msg "$YELLOW" "Arch:"
    echo "  sudo pacman -S rofi python python-pip"
    echo ""
    return 1
  fi

  if [ ${#missing_optional[@]} -ne 0 ]; then
    print_msg "$YELLOW" "Note: Some optional dependencies are missing:"
    for dep in "${missing_optional[@]}"; do
      case "$dep" in
        xclip)
          echo "  - xclip: Required for clipboard on X11"
          ;;
        wl-copy)
          echo "  - wl-copy (wl-clipboard): Required for clipboard on Wayland"
          ;;
        notify-send)
          echo "  - notify-send: For desktop notifications"
          ;;
        jq)
          echo "  - jq: For configuration file support"
          ;;
      esac
    done
    echo ""
    print_msg "$YELLOW" "You can install them later if needed."
    echo ""
  fi

  return 0
}

install_script() {
  print_msg "$BLUE" "Installing fontawesome-menu..."

  # Create install directory if it doesn't exist
  mkdir -p "$INSTALL_DIR"

  # Create symlink to the script
  local script_path="$SCRIPT_DIR/fontawesome-menu/fontawesome-menu"
  local install_path="$INSTALL_DIR/fontawesome-menu"

  if [ -L "$install_path" ]; then
    print_msg "$YELLOW" "Removing existing symlink..."
    rm "$install_path"
  elif [ -f "$install_path" ]; then
    print_msg "$YELLOW" "Backing up existing file..."
    mv "$install_path" "${install_path}.backup"
  fi

  ln -s "$script_path" "$install_path"
  chmod +x "$script_path"

  print_msg "$GREEN" "✓ Installed to: $install_path"

  # Check if install dir is in PATH
  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_msg "$YELLOW" "\nNote: $INSTALL_DIR is not in your PATH"
    print_msg "$YELLOW" "Add it to your shell configuration:"
    echo ""
    echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
    echo ""
    print_msg "$YELLOW" "Add this line to your ~/.bashrc or ~/.zshrc"
  fi
}

generate_initial_lists() {
  print_msg "$BLUE" "\nGenerating initial icon lists..."
  echo ""

  read -p "Generate FontAwesome 6 icon lists now? [Y/n]: " generate

  if [[ ! "$generate" =~ ^[Nn]$ ]]; then
    "$SCRIPT_DIR/update.sh" --quick
  else
    print_msg "$YELLOW" "Skipping icon list generation."
    print_msg "$YELLOW" "Run './update.sh' later to generate icon lists."
  fi
}

setup_keybinding_help() {
  echo ""
  print_msg "$BLUE" "═══════════════════════════════════════════════════════"
  print_msg "$BLUE" "  Setting up Keybinding (Optional)"
  print_msg "$BLUE" "═══════════════════════════════════════════════════════"
  echo ""

  print_msg "$YELLOW" "You can bind fontawesome-menu to a keyboard shortcut."
  echo ""
  echo "Common desktop environments:"
  echo ""

  print_msg "$GREEN" "i3 Window Manager:"
  echo "  Add to ~/.config/i3/config:"
  echo "    bindsym \$mod+F9 exec --no-startup-id fontawesome-menu"
  echo ""

  print_msg "$GREEN" "Sway:"
  echo "  Add to ~/.config/sway/config:"
  echo "    bindsym \$mod+F9 exec fontawesome-menu"
  echo ""

  print_msg "$GREEN" "GNOME:"
  echo "  Settings → Keyboard → Custom Shortcuts"
  echo "  Command: fontawesome-menu"
  echo ""

  print_msg "$GREEN" "KDE Plasma:"
  echo "  System Settings → Shortcuts → Custom Shortcuts"
  echo "  Command: fontawesome-menu"
  echo ""

  print_msg "$GREEN" "XFCE:"
  echo "  Settings → Keyboard → Application Shortcuts"
  echo "  Command: fontawesome-menu"
  echo ""
}

installation_complete() {
  echo ""
  print_msg "$GREEN" "═══════════════════════════════════════════════════════"
  print_msg "$GREEN" "  Installation Complete!"
  print_msg "$GREEN" "═══════════════════════════════════════════════════════"
  echo ""

  print_msg "$BLUE" "Quick Start:"
  echo ""
  echo "  1. Run fontawesome-menu:"
  echo "     $ fontawesome-menu"
  echo ""
  echo "  2. Update/generate icon lists:"
  echo "     $ cd $SCRIPT_DIR"
  echo "     $ ./update.sh --menu"
  echo ""
  echo "  3. See all options:"
  echo "     $ fontawesome-menu -h"
  echo ""

  print_msg "$BLUE" "Examples:"
  echo ""
  echo "  # Default usage (auto-detect latest)"
  echo "  $ fontawesome-menu"
  echo ""
  echo "  # Interactive list selection"
  echo "  $ fontawesome-menu -i"
  echo ""
  echo "  # Copy icon name instead of character"
  echo "  $ fontawesome-menu name"
  echo ""
  echo "  # Copy as HTML"
  echo "  $ fontawesome-menu html"
  echo ""
  echo "  # Select specific version and style"
  echo "  $ fontawesome-menu -V 6 -s brands"
  echo ""

  setup_keybinding_help

  print_msg "$GREEN" "\nEnjoy using rofi-fontawesome! 🎉"
  echo ""
}

uninstall() {
  print_header
  print_msg "$YELLOW" "Uninstalling rofi-fontawesome..."

  local install_path="$INSTALL_DIR/fontawesome-menu"

  if [ -L "$install_path" ] || [ -f "$install_path" ]; then
    rm "$install_path"
    print_msg "$GREEN" "✓ Removed from $INSTALL_DIR"
  else
    print_msg "$YELLOW" "! Not installed in $INSTALL_DIR"
  fi

  echo ""
  read -p "Remove generated icon lists? [y/N]: " remove_icons

  if [[ "$remove_icons" =~ ^[Yy]$ ]]; then
    rm -rf "$SCRIPT_DIR/icons"
    rm -rf "$SCRIPT_DIR/.cache"
    print_msg "$GREEN" "✓ Removed icon lists and cache"
  fi

  echo ""
  print_msg "$GREEN" "Uninstallation complete"
}

show_help() {
  print_header
  cat << EOF
Usage: $0 [OPTIONS]

Install rofi-fontawesome to your system.

OPTIONS:
    --install       Install fontawesome-menu (default)
    --uninstall     Uninstall fontawesome-menu
    --help, -h      Show this help message

INSTALLATION:
    The script will be installed to: $INSTALL_DIR
    A symlink will be created to the main script.

EXAMPLES:
    # Standard installation
    $ ./install.sh

    # Uninstall
    $ ./install.sh --uninstall

EOF
}

main() {
  case "${1:-}" in
    --uninstall)
      uninstall
      ;;
    --help|-h)
      show_help
      ;;
    --install|"")
      print_header

      if ! check_dependencies; then
        exit 1
      fi

      echo ""
      read -p "Continue with installation? [Y/n]: " confirm

      if [[ "$confirm" =~ ^[Nn]$ ]]; then
        print_msg "$YELLOW" "Installation cancelled"
        exit 0
      fi

      install_script
      generate_initial_lists
      installation_complete
      ;;
    *)
      print_msg "$RED" "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
}

main "$@"
