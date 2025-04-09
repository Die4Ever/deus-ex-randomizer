import sys
from pathlib import Path

p = Path(__file__).resolve()
p = p.parent / 'lib'
if p.is_dir():
    sys.path.append(str(p))
