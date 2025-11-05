#!/usr/bin/env python3
"""
FontAwesome Icon List Generator for Rofi
Version 2.0

This script automatically downloads FontAwesome metadata and generates
icon lists in the format required by rofi-fontawesome.

Features:
- Auto-download from FontAwesome GitHub releases
- Version selection (FA5, FA6.x, etc.)
- Multiple style support (solid, regular, brands, duotone, etc.)
- Smart caching to avoid redundant downloads
- Multiple output formats
"""

import json
import os
import sys
import argparse
import requests
from pathlib import Path
from typing import Dict, List, Optional, Set
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class FontAwesomeGenerator:
    """Generate rofi-compatible icon lists from FontAwesome metadata"""

    # FontAwesome 6 Free CDN metadata URLs
    FA6_METADATA_URL = "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/metadata/icons.json"
    FA5_METADATA_URL = "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/5.x/metadata/icons.json"

    # GitHub API for releases
    GITHUB_API_RELEASES = "https://api.github.com/repos/FortAwesome/Font-Awesome/releases"

    # Color palette for visual variety
    COLORS = [
        '#b2ffc1', '#f193f9', '#7dedc6', '#d3ffaf', '#78d5e8',
        '#a9b2fc', '#f2fc83', '#a0ff77', '#f7b0af', '#9890f4',
        '#fcedc2', '#a5e2f7', '#ffc1ca', '#babdff', '#8ff7ae',
        '#a4ff99', '#71f2ab', '#76edc5', '#f4a4c7', '#a5f78a'
    ]

    def __init__(self, cache_dir: str = ".cache", icons_dir: str = "icons"):
        self.cache_dir = Path(cache_dir)
        self.icons_dir = Path(icons_dir)
        self.cache_dir.mkdir(exist_ok=True)
        self.icons_dir.mkdir(exist_ok=True)

    def get_available_versions(self) -> List[str]:
        """Fetch available FontAwesome versions from GitHub"""
        try:
            logger.info("Fetching available FontAwesome versions...")
            response = requests.get(self.GITHUB_API_RELEASES, timeout=10)
            response.raise_for_status()
            releases = response.json()

            versions = []
            for release in releases[:20]:  # Last 20 releases
                tag = release.get('tag_name', '')
                if tag and not release.get('prerelease', False):
                    versions.append(tag)

            logger.info(f"Found {len(versions)} versions")
            return versions
        except Exception as e:
            logger.error(f"Failed to fetch versions: {e}")
            return ['6.5.1', '6.4.0', '6.3.0', '5.15.4']  # Fallback

    def download_metadata(self, version: str = "6") -> Dict:
        """Download FontAwesome metadata for specified version"""
        cache_file = self.cache_dir / f"fa{version}-metadata.json"

        # Check cache first
        if cache_file.exists():
            logger.info(f"Using cached metadata for FA{version}")
            with open(cache_file, 'r', encoding='utf-8') as f:
                return json.load(f)

        # Determine URL based on version
        if version.startswith('6'):
            url = self.FA6_METADATA_URL
        elif version.startswith('5'):
            url = self.FA5_METADATA_URL
        else:
            # Try to construct URL for specific version
            url = f"https://raw.githubusercontent.com/FortAwesome/Font-Awesome/{version}/metadata/icons.json"

        logger.info(f"Downloading metadata from {url}")

        try:
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            metadata = response.json()

            # Cache the metadata
            with open(cache_file, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2)

            logger.info(f"Metadata cached to {cache_file}")
            return metadata

        except Exception as e:
            logger.error(f"Failed to download metadata: {e}")
            raise

    def get_icon_styles(self, metadata: Dict) -> Set[str]:
        """Extract available icon styles from metadata"""
        styles = set()
        for icon_data in metadata.values():
            if isinstance(icon_data, dict) and 'styles' in icon_data:
                styles.update(icon_data['styles'])
        return styles

    def generate_list(
        self,
        metadata: Dict,
        style: str = "solid",
        use_colors: bool = False,
        output_format: str = "rofi"
    ) -> List[str]:
        """Generate icon list in specified format"""
        icons = []
        color_idx = 0

        for icon_name, icon_data in sorted(metadata.items()):
            if not isinstance(icon_data, dict):
                continue

            # Check if this icon is available in requested style
            styles = icon_data.get('styles', [])
            if style not in styles:
                continue

            # Get unicode codepoint
            unicode_char = icon_data.get('unicode', '')
            if not unicode_char:
                continue

            # Get label (human-readable name)
            label = icon_data.get('label', icon_name.replace('-', ' ').title())

            # Format based on output format
            if output_format == "rofi":
                if use_colors:
                    color = self.COLORS[color_idx % len(self.COLORS)]
                    line = f"<span lang='{icon_name}' foreground='{color}' face='Font Awesome 6 {style.title()}'>&#x{unicode_char};</span>  {label}"
                    color_idx += 1
                else:
                    # Map style to font face
                    font_face = self._get_font_face(style)
                    line = f"<span lang='{icon_name}' weight=\"normal\" fallback=\"true\" face='{font_face}'>&#x{unicode_char};</span>  {label}"

                icons.append(line)

            elif output_format == "simple":
                icons.append(f"{icon_name} {unicode_char} {label}")

            elif output_format == "json":
                icons.append({
                    'name': icon_name,
                    'unicode': unicode_char,
                    'label': label,
                    'styles': styles
                })

        return icons

    def _get_font_face(self, style: str) -> str:
        """Map style name to font face name"""
        style_map = {
            'solid': 'Font Awesome 6 Free Solid',
            'regular': 'Font Awesome 6 Free',
            'brands': 'Font Awesome 6 Brands',
            'duotone': 'Font Awesome 6 Duotone',
            'light': 'Font Awesome 6 Light',
            'thin': 'Font Awesome 6 Thin'
        }
        return style_map.get(style, f'Font Awesome 6 {style.title()}')

    def save_list(self, icons: List, filename: str, output_format: str = "rofi"):
        """Save icon list to file"""
        output_path = self.icons_dir / filename

        if output_format == "json":
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(icons, f, indent=2, ensure_ascii=False)
        else:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(icons))

        logger.info(f"Generated {len(icons)} icons -> {output_path}")
        return output_path

    def generate_all_styles(
        self,
        version: str = "6",
        use_colors: bool = False,
        styles: Optional[List[str]] = None
    ):
        """Generate icon lists for all available styles"""
        logger.info(f"Generating icon lists for FontAwesome {version}")

        # Download metadata
        metadata = self.download_metadata(version)

        # Get available styles
        available_styles = self.get_icon_styles(metadata)
        logger.info(f"Available styles: {', '.join(sorted(available_styles))}")

        # Filter styles if specified
        if styles:
            available_styles = available_styles.intersection(set(styles))

        # Generate list for each style
        generated_files = []
        for style in sorted(available_styles):
            filename = f"fa{version}-{style}.txt"
            icons = self.generate_list(metadata, style, use_colors)

            if icons:
                output_path = self.save_list(icons, filename)
                generated_files.append(output_path)

        # Also generate a combined "all" list
        all_icons = self.generate_list(metadata, style=list(available_styles)[0], use_colors=use_colors)
        for style in sorted(available_styles)[1:]:
            all_icons.extend(self.generate_list(metadata, style, use_colors))

        if all_icons:
            filename = f"fa{version}-all.txt"
            output_path = self.save_list(all_icons, filename)
            generated_files.append(output_path)

        return generated_files

    def generate_manifest(self, version: str, generated_files: List[Path]):
        """Generate a manifest file with metadata about generated lists"""
        manifest = {
            'version': version,
            'generated_at': datetime.now().isoformat(),
            'files': [
                {
                    'filename': f.name,
                    'path': str(f),
                    'size': f.stat().st_size,
                    'line_count': len(f.read_text().splitlines())
                }
                for f in generated_files
            ]
        }

        manifest_path = self.icons_dir / f"fa{version}-manifest.json"
        with open(manifest_path, 'w', encoding='utf-8') as f:
            json.dump(manifest, f, indent=2)

        logger.info(f"Manifest saved to {manifest_path}")
        return manifest_path


def main():
    parser = argparse.ArgumentParser(
        description='Generate FontAwesome icon lists for rofi',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate lists for FontAwesome 6 (latest)
  %(prog)s

  # Generate for specific version
  %(prog)s --version 6.5.1

  # Generate only specific styles
  %(prog)s --styles solid brands

  # Generate with colors
  %(prog)s --colors

  # List available versions
  %(prog)s --list-versions

  # Clear cache and regenerate
  %(prog)s --clear-cache
        """
    )

    parser.add_argument(
        '--version', '-v',
        default='6',
        help='FontAwesome version to generate (default: 6)'
    )

    parser.add_argument(
        '--styles', '-s',
        nargs='+',
        help='Specific styles to generate (default: all available)'
    )

    parser.add_argument(
        '--colors', '-c',
        action='store_true',
        help='Use colors in output'
    )

    parser.add_argument(
        '--list-versions',
        action='store_true',
        help='List available FontAwesome versions'
    )

    parser.add_argument(
        '--clear-cache',
        action='store_true',
        help='Clear cached metadata'
    )

    parser.add_argument(
        '--cache-dir',
        default='.cache',
        help='Cache directory (default: .cache)'
    )

    parser.add_argument(
        '--icons-dir',
        default='icons',
        help='Output directory for icon lists (default: icons)'
    )

    args = parser.parse_args()

    # Initialize generator
    generator = FontAwesomeGenerator(
        cache_dir=args.cache_dir,
        icons_dir=args.icons_dir
    )

    # Handle list versions
    if args.list_versions:
        print("Available FontAwesome versions:")
        versions = generator.get_available_versions()
        for v in versions:
            print(f"  - {v}")
        return 0

    # Handle clear cache
    if args.clear_cache:
        logger.info("Clearing cache...")
        for cache_file in generator.cache_dir.glob("*.json"):
            cache_file.unlink()
            logger.info(f"Removed {cache_file}")
        return 0

    # Generate icon lists
    try:
        generated_files = generator.generate_all_styles(
            version=args.version,
            use_colors=args.colors,
            styles=args.styles
        )

        # Generate manifest
        generator.generate_manifest(args.version, generated_files)

        print(f"\n✓ Successfully generated {len(generated_files)} icon lists")
        print(f"  Version: FontAwesome {args.version}")
        print(f"  Output directory: {generator.icons_dir}")

        return 0

    except Exception as e:
        logger.error(f"Generation failed: {e}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
