try:
    from Install import GetDryrun
    from GUI import *
    from pathlib import Path
    from Install import CopyTo, IsWindows
    import subprocess
except Exception as e:
    info('ERROR: importing', e)
    raise


def CopyExeTo(source:Path, dest:Path):
    try:
        CopyTo(source, dest)
    except PermissionError as e:
        if not AskKillGame(source, dest):
            raise


def AskKillGame(source:Path, dest:Path):
    if not IsWindows():
        return False
    self = Path(sys.argv[0]).resolve()
    if self == dest.resolve():
        info('Cannot overwrite self', dest)
        messagebox.showerror('Cannot overwrite installer', 'Rename the installer file and run it again.')
        sys.exit(1)

    cmd = ['TASKLIST', '/FI', 'imagename eq ' + dest.name]
    info('running', cmd)
    ret = subprocess.run(cmd, text=True, capture_output=True, check=True, timeout=30, creationflags=subprocess.CREATE_NO_WINDOW)
    if 'INFO: No tasks are running which match the specified criteria.' in ret.stdout:
        return False

    info('Ask kill game', dest)
    resp = messagebox.askyesno('Close game?', dest.name + ' is currently running and must be closed in order to install. Would you like to close it now?\n\nYou will lose any unsaved progress.')
    if resp:
        cmd = ['taskkill', '/F', '/IM', dest.name]
        info('Killing game', dest, cmd)
        subprocess.run(cmd, text=True, capture_output=True, check=True, timeout=30, creationflags=subprocess.CREATE_NO_WINDOW)
        time.sleep(1)
    # now try again, even if the user declines because maybe they closed the game manually
    CopyTo(source, dest)
    return True
