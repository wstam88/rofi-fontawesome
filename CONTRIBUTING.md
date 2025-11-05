# Contributing to Rofi-FontAwesome

Thank you for your interest in contributing to rofi-fontawesome! This document provides guidelines and information for contributors.

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. Check if the issue already exists in the [issue tracker](https://github.com/wstam88/rofi-fontawesome/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (OS, Python version, etc.)

### Submitting Changes

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear, descriptive messages
6. Push to your fork
7. Create a Pull Request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/rofi-fontawesome.git
cd rofi-fontawesome

# Install dependencies
pip3 install -r generators/requirements.txt

# Test the generator
python3 generators/generate_icons.py --help

# Test icon generation
python3 generators/generate_icons.py --version 6
```

## Code Style

### Python (generator scripts)

- Follow [PEP 8](https://pep8.org/)
- Use descriptive variable names
- Add docstrings to functions and classes
- Keep functions focused and modular

### Bash (shell scripts)

- Use shellcheck for validation
- Add comments for complex logic
- Use consistent indentation (2 spaces)
- Quote variables to prevent word splitting

## Testing

Before submitting a PR, please test:

1. **Generator script:**
   ```bash
   # Test basic generation
   python3 generators/generate_icons.py --version 6

   # Test version listing
   python3 generators/generate_icons.py --list-versions

   # Test cache clearing
   python3 generators/generate_icons.py --clear-cache
   ```

2. **fontawesome-menu script:**
   ```bash
   # Test help
   ./fontawesome-menu/fontawesome-menu -h

   # Test list command
   ./fontawesome-menu/fontawesome-menu -l
   ```

3. **Update script:**
   ```bash
   # Test quick mode
   ./update.sh --quick

   # Test help
   ./update.sh --help
   ```

## Project Structure

```
rofi-fontawesome/
├── generators/
│   ├── generate_icons.py    # Icon list generator (Python)
│   ├── config.json          # Default configuration
│   └── requirements.txt     # Python dependencies
├── icons/                   # Generated icon lists (not in git)
├── fontawesome-menu/
│   └── fontawesome-menu     # Main user-facing script (Bash)
├── install.sh               # Installation helper
├── update.sh                # Update/generation helper
└── README.md                # Main documentation
```

## Adding New Features

### Adding a New FontAwesome Version

The generator should automatically support new FontAwesome versions. If special handling is needed:

1. Update `FontAwesomeGenerator` class in `generators/generate_icons.py`
2. Add version-specific URL mapping if needed
3. Test with the new version
4. Update documentation

### Adding New Output Formats

To add a new output format to fontawesome-menu:

1. Edit `fontawesome-menu/fontawesome-menu`
2. Add new case to the output mode switch statement
3. Implement the format conversion
4. Update help text and README
5. Add example usage

### Adding Generator Features

1. Update `generators/generate_icons.py`
2. Add command-line arguments if needed
3. Update help text
4. Add to `update.sh` menu if user-facing
5. Document in README

## Commit Message Guidelines

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and PRs when relevant

Examples:
```
Add support for FontAwesome 7

- Update metadata URL
- Add new styles handling
- Update documentation

Fixes #123
```

## Questions?

Feel free to open an issue for any questions about contributing!

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
