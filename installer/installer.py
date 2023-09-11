from Install import GetSourcePath, SetDryrun, SetVerbose, info, debug
try:
    import argparse
    import sys
    import traceback

    import GUI.InstallerWindow
    from Install.Install import UnattendedInstall
except Exception as e:
    info('ERROR: importing', e)
    raise

parser = argparse.ArgumentParser(description='Deus Ex Randomizer')
parser.add_argument('--version', action="store_true", help='Output version')
parser.add_argument('--dryrun', action="store_true", help="Dry run, don't actually change anything")
parser.add_argument('--unattended', action="store_true", help='Unattended installation')
parser.add_argument('--path', help='Path to DeusEx.exe for installation')
parser.add_argument('--downloadmirrors', action="store_true", help='Default to download mirrored maps for unattended installations')
parser.add_argument('--verbose', action="store_true", help="Output way more to the console")
args = parser.parse_args()

def GetVersion():
    return 'v0.4'

if args.verbose:
    SetVerbose(True)

if args.dryrun:
    SetDryrun(True)

if args.version:
    thirdparty = GetSourcePath() / '3rdParty'
    for f in thirdparty.rglob('*'):
        debug(f)
    info('DXRando Installer version:', GetVersion())
    info('Python version:', sys.version_info)
    sys.exit(0)

if args.unattended:
    try:
        UnattendedInstall(args.path, args.downloadmirrors)
        sys.exit(0)
    except Exception as e:
        info('\n\nError!')
        info(e, '\n')
        info(traceback.format_exc())
        info('falling back to manual install')

GUI.InstallerWindow.main()
