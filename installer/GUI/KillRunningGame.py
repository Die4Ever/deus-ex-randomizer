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
        if not AskKillGame(dest):
            raise
        CopyTo(source, dest)


def AskKillGame(exe:Path):
    if not IsWindows():
        return False
    selfpath = Path(sys.argv[0]).resolve()
    if selfpath == exe.resolve():
        info('Cannot overwrite self', exe)
        messagebox.showerror('Cannot overwrite installer', 'Rename the installer file and run it again.')
        sys.exit(1)

    if not IsGameRunning(exe):
        return False

    info('Ask kill game', exe)
    resp = messagebox.askyesno('Close game?', exe.name + ' is currently running and must be closed in order to install. Would you like to close it now?\n\nYou will lose any unsaved progress.')
    if resp:
        cmd = ['taskkill', '/F', '/IM', exe.name]
        info('Killing game', exe, cmd)
        subprocess.run(cmd, text=True, capture_output=True, check=True, timeout=30, creationflags=subprocess.CREATE_NO_WINDOW)
        time.sleep(1)
    # try again, even if the user declines because maybe they closed the game manually
    return True


def IsGameRunning(exe:Path):
    if not IsWindows():
        return False # we don't care outside of Windows
    cmd = ['TASKLIST', '/FI', 'imagename eq ' + exe.name]
    info('running', cmd)
    ret = subprocess.run(cmd, text=True, capture_output=True, check=True, timeout=30, creationflags=subprocess.CREATE_NO_WINDOW)
    if 'INFO: No tasks are running which match the specified criteria.' in ret.stdout:
        return False
    return True
