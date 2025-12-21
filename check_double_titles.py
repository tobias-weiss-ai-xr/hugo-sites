import os
import re

def check_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split front matter and body
    # Assuming TOML/YAML front matter delimited by +++ or ---
    match = re.match(r'^(\+\+\+|---)\n(.*?)\n\1\n(.*)', content, re.DOTALL)
    if not match:
        return None

    delimiter = match.group(1)
    front_matter = match.group(2)
    body = match.group(3).strip()

    # Extract title from front matter
    title_match = re.search(r'^title\s*[:=]\s*["\\]?([^"\\]*)["\\]?$', front_matter, re.MULTILINE | re.IGNORECASE)
    if not title_match:
        return None
    
    fm_title = title_match.group(1).strip()

    # Check first few lines of body for H1
    body_lines = body.splitlines()
    for line in body_lines[:3]: # Check first 3 lines
        line = line.strip()
        if not line:
            continue
        
        # Check for # Header
        h1_match = re.match(r'^#\s+(.*)', line)
        if h1_match:
            h1_title = h1_match.group(1).strip()
            # Simple fuzzy match or exact match?
            # Let's flag if they are very similar or if H1 exists at top
            return (filepath, fm_title, h1_title)
        
        # Check for underline header (Setext style)
        # Title
        # =====
        # This is harder to check line-by-line without state, but strict # is common.
        
        # If we encounter text that isn't a header first, maybe it's fine.
        break
    
    return None

def scan_directory(root_dir):
    issues = []
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith('.md'):
                filepath = os.path.join(dirpath, filename)
                result = check_file(filepath)
                if result:
                    issues.append(result)
    return issues

if __name__ == "__main__":
    dirs_to_check = [
        "hugo-sites/hugo-tobias-weiss-org/myhugoapp/content",
        "hugo-sites/hugo-graphwiz-ai/myhugoapp/content"
    ]
    
    found_issues = False
    for d in dirs_to_check:
        full_path = os.path.join(os.getcwd(), d)
        if not os.path.exists(full_path):
            print(f"Directory not found: {full_path}")
            continue
            
        print(f"Scanning {d}...")
        results = scan_directory(full_path)
        if results:
            found_issues = True
            for path, fm_title, h1_title in results:
                print(f"DOUBLE TITLE FOUND: {path}")
                print(f"  Front Matter: {fm_title}")
                print(f"  Body H1:      {h1_title}")
                print("-" * 20)
        else:
            print("No double titles found.")
            
    if found_issues:
        exit(1)
