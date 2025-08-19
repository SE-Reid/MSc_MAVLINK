#!/usr/bin/env python3
"""Clean up whitespace issues in heartbeat_monitor.py"""

with open('src/heartbeat_monitor.py', 'r') as f:
    content = f.read()

# Remove trailing whitespace
lines = content.split('\n')
cleaned_lines = [line.rstrip() for line in lines]
content = '\n'.join(cleaned_lines)

with open('src/heartbeat_monitor.py', 'w') as f:
    f.write(content)

print('Cleaned up whitespace in heartbeat_monitor.py')
