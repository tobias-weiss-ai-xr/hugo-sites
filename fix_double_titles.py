import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split front matter and body
    match = re.match(r'^(\+\+\+|---)\n(.*?)\n\1\n(.*)', content, re.DOTALL)
    if not match:
        return False

    delimiter = match.group(1)
    front_matter = match.group(2)
    body = match.group(3) # Not stripped yet to preserve other whitespace if needed, but we'll rebuild it

    # Extract title from front matter
    title_match = re.search(r'^title\s*[:=]\s*["\\]?(.*?)["\\]?$', front_matter, re.MULTILINE | re.IGNORECASE)
    if not title_match:
        return False
    
    fm_title = title_match.group(1).strip()

    # Find the H1 in the body that matches
    # We look for the exact line "# <Title>" or "# <Title>\n" at the start of the body (allowing for some whitespace) 
    
    # We want to remove the specific line that constitutes the double title.
    # It's usually the first non-empty line of the body. 
    
    lines = body.splitlines(keepends=True)
    new_lines = []
    removed = False
    
    # Skip initial empty lines to find the first content
    idx = 0
    while idx < len(lines) and not lines[idx].strip():
        new_lines.append(lines[idx])
        idx += 1
        
    if idx < len(lines):
        first_content_line = lines[idx]
        # Check if it is the H1
        h1_match = re.match(r'^#\s+(.*)', first_content_line.strip())
        if h1_match:
            h1_title = h1_match.group(1).strip()
            # If it matches the front matter title (loosely)
            if h1_title == fm_title:
                # SKIP this line (remove it)
                removed = True
                # also skip following blank lines to avoid huge gap? 
                # Let's just remove the title line for now.
                idx += 1 
            else:
                 pass # Not the same title, keep it
        else:
            pass # Not a header, keep it

    # Add the rest of the lines
    new_lines.extend(lines[idx:])
    
    if removed:
        new_content = f"{delimiter}\n{front_matter}\n{delimiter}\n{''.join(new_lines)}"
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    
    return False

def scan_and_fix_directory(root_dir):
    fixed_count = 0
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith('.md'):
                filepath = os.path.join(dirpath, filename)
                if fix_file(filepath):
                    print(f"Fixed: {filepath}")
                    fixed_count += 1
    return fixed_count

if __name__ == "__main__":
    dirs_to_check = [
        "hugo-sites/hugo-tobias-weiss-org/myhugoapp/content",
        "hugo-sites/hugo-graphwiz-ai/myhugoapp/content"
    ]
    
    total_fixed = 0
    for d in dirs_to_check:
        full_path = os.path.join(os.getcwd(), d)
        if not os.path.exists(full_path):
            print(f"Directory not found: {full_path}")
            continue
            
        print(f"Fixing files in {d}...")
        total_fixed += scan_and_fix_directory(full_path)
            
    print(f"Total files fixed: {total_fixed}")
