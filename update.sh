#!/bin/bash

# Rofi-FontAwesome Update Script
# Version 2.0
# This script helps you generate/update FontAwesome icon lists

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATOR="$SCRIPT_DIR/generators/generate_icons.py"
CONFIG_FILE="$SCRIPT_DIR/generators/config.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_msg() {
  local color=$1
  shift
  echo -e "${color}$@${NC}"
}

print_header() {
  echo ""
  print_msg "$BLUE" "═══════════════════════════════════════════════════════"
  print_msg "$BLUE" "  Rofi-FontAwesome Icon List Generator v2.0"
  print_msg "$BLUE" "═══════════════════════════════════════════════════════"
  echo ""
}

check_dependencies() {
  print_msg "$YELLOW" "Checking dependencies..."

  local missing_deps=()

  if ! command -v python3 &> /dev/null; then
    missing_deps+=("python3")
  fi

  if ! command -v pip3 &> /dev/null; then
    missing_deps+=("pip3")
  fi

  if [ ${#missing_deps[@]} -ne 0 ]; then
    print_msg "$RED" "✗ Missing required dependencies:"
    for dep in "${missing_deps[@]}"; do
      echo "  - $dep"
    done
    echo ""
    print_msg "$YELLOW" "Install them with:"
    print_msg "$YELLOW" "  sudo apt install python3 python3-pip  # Debian/Ubuntu"
    print_msg "$YELLOW" "  sudo dnf install python3 python3-pip  # Fedora"
    print_msg "$YELLOW" "  sudo pacman -S python python-pip      # Arch"
    return 1
  fi

  print_msg "$GREEN" "✓ All required dependencies found"
  return 0
}

install_python_deps() {
  print_msg "$YELLOW" "Installing Python dependencies..."

  if [ -f "$SCRIPT_DIR/generators/requirements.txt" ]; then
    pip3 install -r "$SCRIPT_DIR/generators/requirements.txt" --user --quiet
    print_msg "$GREEN" "✓ Python dependencies installed"
  else
    print_msg "$YELLOW" "! No requirements.txt found, skipping"
  fi
}

show_menu() {
  print_header

  echo "What would you like to do?"
  echo ""
  echo "  1) Generate icon lists for FontAwesome 6 (recommended)"
  echo "  2) Generate icon lists for FontAwesome 5"
  echo "  3) Generate for a specific version"
  echo "  4) List available FontAwesome versions"
  echo "  5) Clear cache and regenerate"
  echo "  6) Configure settings"
  echo "  0) Exit"
  echo ""
  read -p "Enter your choice [0-6]: " choice

  case $choice in
    1) generate_fa6 ;;
    2) generate_fa5 ;;
    3) generate_custom ;;
    4) list_versions ;;
    5) clear_cache ;;
    6) configure ;;
    0) exit 0 ;;
    *) print_msg "$RED" "Invalid choice"; show_menu ;;
  esac
}

generate_fa6() {
  print_msg "$BLUE" "\nGenerating FontAwesome 6 icon lists..."
  python3 "$GENERATOR" --version 6
  print_msg "$GREEN" "\n✓ FontAwesome 6 icon lists generated successfully!"
  show_generated_files
  prompt_continue
}

generate_fa5() {
  print_msg "$BLUE" "\nGenerating FontAwesome 5 icon lists..."
  python3 "$GENERATOR" --version 5
  print_msg "$GREEN" "\n✓ FontAwesome 5 icon lists generated successfully!"
  show_generated_files
  prompt_continue
}

generate_custom() {
  echo ""
  read -p "Enter FontAwesome version (e.g., 6.5.1, 6, 5.15.4): " version

  if [ -z "$version" ]; then
    print_msg "$RED" "Version cannot be empty"
    prompt_continue
    return
  fi

  echo ""
  echo "Generate specific styles? (leave empty for all)"
  read -p "Enter styles separated by space (e.g., solid brands): " styles

  print_msg "$BLUE" "\nGenerating FontAwesome $version icon lists..."

  if [ -z "$styles" ]; then
    python3 "$GENERATOR" --version "$version"
  else
    python3 "$GENERATOR" --version "$version" --styles $styles
  fi

  print_msg "$GREEN" "\n✓ Icon lists generated successfully!"
  show_generated_files
  prompt_continue
}

list_versions() {
  print_msg "$BLUE" "\nFetching available FontAwesome versions..."
  python3 "$GENERATOR" --list-versions
  prompt_continue
}

clear_cache() {
  print_msg "$YELLOW" "\nClearing cache..."
  python3 "$GENERATOR" --clear-cache
  print_msg "$GREEN" "✓ Cache cleared"
  prompt_continue
}

configure() {
  print_msg "$BLUE" "\nConfiguration"
  echo ""

  if [ ! -f "$CONFIG_FILE" ]; then
    print_msg "$YELLOW" "No configuration file found. Creating default..."
    cat > "$CONFIG_FILE" << 'EOF'
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
EOF
  fi

  print_msg "$GREEN" "Configuration file: $CONFIG_FILE"
  echo ""
  echo "Edit this file to customize default settings:"
  echo "  - version: Default FontAwesome version"
  echo "  - styles: Which styles to generate"
  echo "  - use_colors: Enable colored output"
  echo "  - default_style: Default style for fontawesome-menu"
  echo ""

  if command -v nano &> /dev/null; then
    read -p "Open in nano? [y/N]: " edit
    if [[ "$edit" =~ ^[Yy]$ ]]; then
      nano "$CONFIG_FILE"
    fi
  else
    echo "Use your favorite editor to edit: $CONFIG_FILE"
  fi

  prompt_continue
}

show_generated_files() {
  echo ""
  print_msg "$GREEN" "Generated files:"
  if [ -d "$SCRIPT_DIR/icons" ]; then
    ls -lh "$SCRIPT_DIR/icons/"*.txt 2>/dev/null | awk '{printf "  %s (%s)\n", $9, $5}' | sed "s|$SCRIPT_DIR/icons/||"
  fi
}

prompt_continue() {
  echo ""
  read -p "Press Enter to continue..."
  show_menu
}

quick_mode() {
  print_header

  # Check if icon lists already exist
  if [ -d "$SCRIPT_DIR/icons" ] && [ -n "$(ls -A "$SCRIPT_DIR/icons"/*.txt 2>/dev/null)" ]; then
    print_msg "$GREEN" "Icon lists already exist:"
    show_generated_files
    echo ""
    read -p "Regenerate? [y/N]: " regenerate
    if [[ ! "$regenerate" =~ ^[Yy]$ ]]; then
      print_msg "$BLUE" "Using existing icon lists. Run with --menu for more options."
      exit 0
    fi
  fi

  print_msg "$BLUE" "Quick setup: Generating FontAwesome 6 icon lists..."
  python3 "$GENERATOR" --version 6
  print_msg "$GREEN" "\n✓ Setup complete! Icon lists generated."
  show_generated_files
  echo ""
  print_msg "$BLUE" "You can now run: ./fontawesome-menu/fontawesome-menu"
  print_msg "$BLUE" "Or run './update.sh --menu' for more options"
}

show_help() {
  print_header
  cat << EOF
Usage: $0 [OPTIONS]

Generate and manage FontAwesome icon lists for rofi-fontawesome.

OPTIONS:
    --menu          Show interactive menu
    --quick         Quick setup (generate FA6 lists)
    --help, -h      Show this help message

    --version VER   Generate lists for specific version
    --list          List available FontAwesome versions
    --clear-cache   Clear downloaded metadata cache

EXAMPLES:
    # Interactive menu
    $0 --menu

    # Quick setup (recommended for first time)
    $0 --quick

    # Generate specific version
    $0 --version 6.5.1

    # List available versions
    $0 --list

If no options are provided, quick mode is used.

EOF
}

# Main script logic
main() {
  cd "$SCRIPT_DIR"

  # Check dependencies first
  if ! check_dependencies; then
    exit 1
  fi

  # Install Python dependencies if needed
  install_python_deps

  # Parse arguments
  case "${1:-}" in
    --menu)
      show_menu
      ;;
    --quick)
      quick_mode
      ;;
    --version)
      if [ -z "$2" ]; then
        print_msg "$RED" "Error: --version requires a version number"
        exit 1
      fi
      print_header
      print_msg "$BLUE" "Generating FontAwesome $2 icon lists..."
      python3 "$GENERATOR" --version "$2"
      print_msg "$GREEN" "\n✓ Icon lists generated successfully!"
      show_generated_files
      ;;
    --list)
      print_header
      python3 "$GENERATOR" --list-versions
      ;;
    --clear-cache)
      print_header
      python3 "$GENERATOR" --clear-cache
      print_msg "$GREEN" "✓ Cache cleared"
      ;;
    --help|-h)
      show_help
      ;;
    "")
      quick_mode
      ;;
    *)
      print_msg "$RED" "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
}

main "$@"
