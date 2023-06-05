import argparse
import sys

import GUI.InstallerWindow

parser = argparse.ArgumentParser(description='Deus Ex Randomizer')
parser.add_argument('--version', action="store_true", help='Output version')
#parser.add_argument('--verbose', action="store_true", help="Output way more to the console")
args = parser.parse_args()

def GetVersion():
    return 'v0.1'

if args.version:
    print('DXRando Installer version:', GetVersion(), file=sys.stderr)
    print('Python version:', sys.version_info, file=sys.stderr)
    sys.exit(0)

GUI.InstallerWindow.main()
