#!/usr/bin/env python3
"""Phase A: Replace Post-Completion Learning Capture boilerplate with wk:learn pointer."""
import os
import re

VERSION = '2026.05.01-073751'
skills_dir = os.path.join(os.path.dirname(__file__), '..', 'skills')

updated = []

for skill_name in sorted(os.listdir(skills_dir)):
    skill_file = os.path.join(skills_dir, skill_name, 'SKILL.md')
    if not os.path.isfile(skill_file):
        continue

    content = open(skill_file).read()

    marker = '\n## Post-Completion: Learning Capture\n'
    idx = content.find(marker)
    if idx == -1:
        continue

    replacement = (
        f'\n## Post-Completion\n\n'
        f"Invoke `wk:learn` with this skill's short name as the argument "
        f'(e.g., `wk:learn {skill_name}`).\n'
    )

    new_content = content[:idx] + replacement

    new_content = re.sub(
        r"(version:\s*')[^']+(')",
        rf"\g<1>{VERSION}\g<2>",
        new_content,
        count=1
    )

    open(skill_file, 'w').write(new_content)
    updated.append(skill_name)

print('\n'.join(updated))
print(f'\nTotal updated: {len(updated)}')
