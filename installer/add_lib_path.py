import sys
from pathlib import Path

p = Path(__file__).resolve()
p = p.parent / 'lib'
sys.path.append(str(p))
