import argparse
import sys
import traceback

import GUI.InstallerWindow
from Install import SetDryrun, SetVerbose
from Install.Install import UnattendedInstall

parser = argparse.ArgumentParser(description='Deus Ex Randomizer')
parser.add_argument('--version', action="store_true", help='Output version')
parser.add_argument('--dryrun', action="store_true", help="Dry run, don't actually change anything")
parser.add_argument('--unattended', action="store_true", help='Unattended installation')
parser.add_argument('--path', help='Path to DeusEx.exe for installation')
parser.add_argument('--downloadmirrors', action="store_true", help='Default to download mirrored maps for unattended installations')
parser.add_argument('--verbose', action="store_true", help="Output way more to the console")
args = parser.parse_args()

def GetVersion():
    return 'v0.3'

if args.version:
    print('DXRando Installer version:', GetVersion(), file=sys.stderr)
    print('Python version:', sys.version_info, file=sys.stderr)
    sys.exit(0)

if args.verbose:
    SetVerbose(True)

if args.dryrun:
    SetDryrun(True)

if args.unattended:
    try:
        UnattendedInstall(args.path, args.downloadmirrors)
        sys.exit(0)
    except Exception as e:
        print('\n\nError!')
        print(e, '\n')
        print(traceback.format_exc())
        print('falling back to manual install')

GUI.InstallerWindow.main()
