try:
    from GUI import *
    from pathlib import Path
    import math
    from Install import CopyTo
except Exception as e:
    info('ERROR: importing', e)
    raise

def PathSize(path: Path):
    size=0
    for f in path.glob('*'):
        size += f.stat().st_size
    return size


def SaveMigration(oldpath:Path, newpath:Path):
    info('SaveMigration old:', oldpath.absolute())
    info('SaveMigration new:', newpath.absolute())
    assert oldpath.exists()
    assert newpath.exists()

    newest = []
    totalsize = 0
    for f in oldpath.glob('*'):
        if not f.is_dir():
            continue
        stat = f.stat()
        mtime = stat.st_mtime
        size = PathSize(f)
        if size < 5000: # a save folder isn't gonna be less than 5k
            continue
        newest.append(dict(mtime=mtime, path=f, size=size))

    # sort by modified date and keep the newest 100
    newest = sorted(newest, key=lambda f: f['mtime'], reverse=True)[:100]

    # remove any that already exist in newpath
    newest = [f for f in newest if not (newpath/f['path'].name).exists()]

    # total up the sizes
    for f in newest:
        out:Path = newpath/f['path'].name
        totalsize += f['size']
    if not newest:
        return
    totalsizestr = str(math.ceil(totalsize/1048576)) + ' MB'

    resp = messagebox.askyesno('Copy saves?', 'Copy ' + str(len(newest)) + ' saves from:\n'
                        + str(oldpath.absolute())
                        + '\n\nto:\n'
                        + str(newpath.absolute())
                        + '\n\n(' + totalsizestr + ')?')

    if not resp:
        return

    for save in newest:
        savefolder:Path = save['path']
        if not savefolder.exists():
            continue # just in case they deleted stuff while looking at the dialog?
        outfolder = newpath/savefolder.name
        if outfolder.exists():
            continue
        outfolder.mkdir()
        for f in savefolder.glob('*'):
            CopyTo(f, outfolder/f.name, silent=True)
