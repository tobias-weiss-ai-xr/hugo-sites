#!/usr/bin/env python3
"""
Media Caption Test for Hugo Site
Tests that all images and videos have proper captions
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Dict, Tuple

class MediaCaptionTest:
    def __init__(self, hugo_root: str):
        self.hugo_root = Path(hugo_root)
        self.content_dir = self.hugo_root / "myhugoapp" / "content"
        self.issues = []

    def find_all_markdown_files(self) -> List[Path]:
        """Find all markdown files in content directory"""
        return list(self.content_dir.rglob("*.md"))

    def test_image_captions(self, content: str, file_path: Path) -> List[Dict]:
        """Test images for proper captions"""
        issues = []

        # Find all <img> tags
        img_pattern = r'<img[^>]*>'
        img_matches = re.finditer(img_pattern, content, re.IGNORECASE)

        for match in img_matches:
            img_tag = match.group()

            # Check if image has alt text
            alt_match = re.search(r'alt\s*=\s*["\']([^"\']*)["\']', img_tag, re.IGNORECASE)
            if not alt_match or not alt_match.group(1).strip():
                issues.append({
                    'type': 'image_missing_alt',
                    'file': str(file_path),
                    'line': content[:match.start()].count('\n') + 1,
                    'tag': img_tag,
                    'message': 'Image missing alt text for accessibility'
                })
            else:
                alt_text = alt_match.group(1).strip()
                if len(alt_text) < 10:  # Very short alt text might not be descriptive enough
                    issues.append({
                        'type': 'image_short_alt',
                        'file': str(file_path),
                        'line': content[:match.start()].count('\n') + 1,
                        'tag': img_tag,
                        'alt_text': alt_text,
                        'message': f'Image alt text too short: "{alt_text}"'
                    })

        # Find all markdown images ![alt](url)
        md_img_pattern = r'!\[([^\]]*)\]\([^)]+\)'
        md_img_matches = re.finditer(md_img_pattern, content)

        for match in md_img_matches:
            alt_text = match.group(1).strip()

            if not alt_text:
                issues.append({
                    'type': 'markdown_image_missing_alt',
                    'file': str(file_path),
                    'line': content[:match.start()].count('\n') + 1,
                    'tag': match.group(),
                    'message': 'Markdown image missing alt text'
                })
            elif len(alt_text) < 10:
                issues.append({
                    'type': 'markdown_image_short_alt',
                    'file': str(file_path),
                    'line': content[:match.start()].count('\n') + 1,
                    'tag': match.group(),
                    'alt_text': alt_text,
                    'message': f'Markdown image alt text too short: "{alt_text}"'
                })

        return issues

    def test_video_captions(self, content: str, file_path: Path) -> List[Dict]:
        """Test videos for proper captions"""
        issues = []

        # Find all <iframe> tags (YouTube videos, etc.)
        iframe_pattern = r'<iframe[^>]*>.*?</iframe>'
        iframe_matches = re.finditer(iframe_pattern, content, re.IGNORECASE | re.DOTALL)

        for match in iframe_matches:
            iframe_tag = match.group()

            # Check if iframe has title attribute (for accessibility)
            title_match = re.search(r'title\s*=\s*["\']([^"\']*)["\']', iframe_tag, re.IGNORECASE)
            if not title_match or not title_match.group(1).strip():
                issues.append({
                    'type': 'iframe_missing_title',
                    'file': str(file_path),
                    'line': content[:match.start()].count('\n') + 1,
                    'tag': iframe_tag,
                    'message': 'Iframe missing title attribute for accessibility'
                })

            # Check if iframe is surrounded by caption text or descriptive paragraph
            lines_before = content[:match.start()].split('\n')
            lines_after = content[match.end():].split('\n')

            # Look for caption indicators in surrounding text
            caption_found = False
            caption_indicators = ['caption', 'video:', 'demo:', 'showcase:', 'tutorial:', 'example:', 'watch:']

            # Check preceding lines for caption
            for i in range(max(0, len(lines_before) - 5), len(lines_before)):
                if any(indicator in lines_before[i].lower() for indicator in caption_indicators):
                    caption_found = True
                    break

            # Check following lines for caption
            if not caption_found:
                for i in range(min(5, len(lines_after))):
                    if any(indicator in lines_after[i].lower() for indicator in caption_indicators):
                        caption_found = True
                        break

            # Check if it's in a section with descriptive heading
            section_heading = self.find_section_heading(content, match.start())
            if section_heading and any(word in section_heading.lower() for word in ['video', 'demo', 'showcase', 'media']):
                caption_found = True

            if not caption_found:
                issues.append({
                    'type': 'video_missing_caption',
                    'file': str(file_path),
                    'line': content[:match.start()].count('\n') + 1,
                    'tag': iframe_tag[:100] + '...' if len(iframe_tag) > 100 else iframe_tag,
                    'message': 'Video/iframe appears to lack descriptive caption or context'
                })

        # Find direct video links
        video_link_pattern = r'\[([^\]]*(?:video|demo|watch|showcase)[^\]]*)\]\([^)]*\.(?:mp4|avi|mov|webm|youtube\.com|youtu\.be)[^)]*\)'
        video_matches = re.finditer(video_link_pattern, content, re.IGNORECASE)

        for match in video_matches:
            link_text = match.group(1).strip()
            if len(link_text) < 15:  # Link text too short to be descriptive
                issues.append({
                    'type': 'video_link_short_text',
                    'file': str(file_path),
                    'line': content[:match.start()].count('\n') + 1,
                    'tag': match.group(),
                    'message': f'Video link text too short: "{link_text}"'
                })

        return issues

    def find_section_heading(self, content: str, position: int) -> str:
        """Find the section heading before a given position"""
        content_before = content[:position]
        lines = content_before.split('\n')

        # Look backwards for the nearest markdown heading
        for line in reversed(lines[-10:]):  # Check last 10 lines
            stripped = line.strip()
            if stripped.startswith('#'):
                return stripped.lstrip('#').strip()

        return ""

    def test_file(self, file_path: Path) -> List[Dict]:
        """Test a single markdown file"""
        issues = []

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            issues.extend(self.test_image_captions(content, file_path))
            issues.extend(self.test_video_captions(content, file_path))

        except Exception as e:
            issues.append({
                'type': 'file_read_error',
                'file': str(file_path),
                'message': f'Could not read file: {str(e)}'
            })

        return issues

    def run_all_tests(self) -> List[Dict]:
        """Run tests on all markdown files"""
        print("🔍 Running media caption tests...")

        markdown_files = self.find_all_markdown_files()
        print(f"📄 Found {len(markdown_files)} markdown files to test")

        all_issues = []

        for file_path in markdown_files:
            if 'node_modules' in str(file_path):
                continue  # Skip node_modules

            print(f"🔎 Testing {file_path.relative_to(self.hugo_root)}")
            issues = self.test_file(file_path)
            all_issues.extend(issues)

            # Also log what media elements were found
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Count media elements found
            img_count = len(re.findall(r'<img[^>]*>', content, re.IGNORECASE)) + len(re.findall(r'!\[[^\]]*\]\([^)]+\)', content))
            iframe_count = len(re.findall(r'<iframe[^>]*>.*?</iframe>', content, re.IGNORECASE | re.DOTALL))
            video_link_count = len(re.findall(r'\[([^\]]*(?:video|demo|watch|showcase)[^\]]*)\]\([^)]*\.(?:mp4|avi|mov|webm|youtube\.com|youtu\.be)[^)]*\)', content, re.IGNORECASE))

            if img_count > 0 or iframe_count > 0 or video_link_count > 0:
                print(f"   📊 Found: {img_count} images, {iframe_count} iframes, {video_link_count} video links")

        return all_issues

    def generate_report(self, issues: List[Dict]) -> str:
        """Generate a formatted report of all issues"""
        if not issues:
            return "🎉 All media elements have proper captions! Great job!"

        report = []
        report.append("📊 MEDIA CAPTION TEST REPORT")
        report.append("=" * 50)
        report.append(f"❌ Found {len(issues)} issues:")
        report.append("")

        # Group issues by type
        issues_by_type = {}
        for issue in issues:
            issue_type = issue['type']
            if issue_type not in issues_by_type:
                issues_by_type[issue_type] = []
            issues_by_type[issue_type].append(issue)

        # Report by type
        type_descriptions = {
            'image_missing_alt': '❌ Images missing alt text (accessibility issue)',
            'image_short_alt': '⚠️  Images with too short alt text',
            'markdown_image_missing_alt': '❌ Markdown images missing alt text',
            'markdown_image_short_alt': '⚠️  Markdown images with too short alt text',
            'iframe_missing_title': '❌ Iframes missing title attribute',
            'video_missing_caption': '⚠️  Videos without descriptive captions',
            'video_link_short_text': '⚠️  Video links with short text',
            'file_read_error': '🔴 File read errors'
        }

        for issue_type, type_issues in issues_by_type.items():
            report.append(f"\n{type_descriptions.get(issue_type, issue_type)} ({len(type_issues)}):")
            report.append("-" * 40)

            for issue in type_issues:
                relative_file = Path(issue['file']).relative_to(self.hugo_root)
                report.append(f"📁 {relative_file}:{issue.get('line', '?')}")
                report.append(f"   {issue['message']}")
                if 'tag' in issue:
                    tag_preview = issue['tag'][:80] + '...' if len(issue['tag']) > 80 else issue['tag']
                    report.append(f"   Tag: {tag_preview}")
                report.append("")

        # Add recommendations
        report.append("\n📋 RECOMMENDATIONS:")
        report.append("-" * 50)
        report.append("1. ✅ Add descriptive alt text to all images (min 10 characters)")
        report.append("2. ✅ Include title attribute on all iframes")
        report.append("3. ✅ Add descriptive captions for all videos")
        report.append("4. ✅ Use descriptive link text for video links")
        report.append("5. ✅ Ensure all media provides context and accessibility")

        return "\n".join(report)

    def suggest_fixes(self, issues: List[Dict]) -> str:
        """Generate specific fix suggestions for the issues found"""
        if not issues:
            return ""

        suggestions = []
        suggestions.append("\n🔧 SPECIFIC FIX SUGGESTIONS:")
        suggestions.append("=" * 50)

        # Group by file for easier fixing
        issues_by_file = {}
        for issue in issues:
            file_path = issue['file']
            if file_path not in issues_by_file:
                issues_by_file[file_path] = []
            issues_by_file[file_path].append(issue)

        for file_path, file_issues in issues_by_file.items():
            relative_file = Path(file_path).relative_to(self.hugo_root)
            suggestions.append(f"\n📝 {relative_file}:")
            suggestions.append("-" * 30)

            for issue in file_issues:
                line_num = issue.get('line', '?')

                if 'alt' in issue['type']:
                    suggestions.append(f"  Line {line_num}: Add descriptive alt text")
                    if 'tag' in issue:
                        suggestions.append(f"    Current: {issue['tag'][:60]}...")
                        if 'alt=""' in issue.get('tag', ''):
                            suggestions.append(f"    Suggested: Replace alt='' with alt='Descriptive text about the image'")

                elif 'title' in issue['type']:
                    suggestions.append(f"  Line {line_num}: Add title attribute to iframe")
                    suggestions.append(f"    Add: title='Descriptive title for the video content'")

                elif 'caption' in issue['type']:
                    suggestions.append(f"  Line {line_num}: Add descriptive caption")
                    suggestions.append(f"    Add text before/after the video describing what it shows")

                elif 'video_link_short_text' in issue['type']:
                    suggestions.append(f"  Line {line_num}: Make video link text more descriptive")
                    if 'alt_text' in issue:
                        suggestions.append(f"    Current text: '{issue['alt_text']}'")
                        suggestions.append(f"    Suggested: 'Watch: AI Agent Demo - Research Showcase'")

        return "\n".join(suggestions)

def main():
    # Get Hugo root directory
    script_dir = Path(__file__).parent
    if script_dir.name == 'hugo-tobias-weiss-org':
        hugo_root = script_dir
    else:
        hugo_root = script_dir.parent

    if not (hugo_root / "myhugoapp" / "content").exists():
        print("❌ Error: Could not find Hugo content directory")
        print(f"   Looked for: {hugo_root / 'myhugoapp' / 'content'}")
        sys.exit(1)

    # Run tests
    tester = MediaCaptionTest(str(hugo_root))
    issues = tester.run_all_tests()

    # Generate reports
    report = tester.generate_report(issues)
    suggestions = tester.suggest_fixes(issues)

    print("\n" + report)

    if issues:
        print(suggestions)
        print(f"\n❌ {len(issues)} issues found. Please fix them for better accessibility and user experience.")
        sys.exit(1)
    else:
        print("\n🎉 Perfect! All media elements have proper captions and accessibility attributes.")
        sys.exit(0)

if __name__ == "__main__":
    main()