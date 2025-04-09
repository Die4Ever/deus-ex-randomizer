# -*- mode: python ; coding: utf-8 -*-
from pathlib import Path
import re
import os

block_cipher = None
console = False
onefile = True


def IsWindows() -> bool:
    return os.name == 'nt'

# unfortunately runtime_hooks is not relative to the location of the spec file, but everything else is
runtime_hooks = []
if IsWindows() and not onefile:
    if Path('add_lib_path.py').exists():
        runtime_hooks=['add_lib_path.py']
    elif Path('installer/add_lib_path.py').exists():
        runtime_hooks=['installer/add_lib_path.py']
    else:
        raise Exception('failed to find add_lib_path.py')

# we can also create an exe for bingo in the same folder
a_installer = Analysis(
    ['installer.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('../*.u', 'System'),
        ('../*.int', 'System'),
        ('../README.md', '.'),
        ('../LICENSE', '.'),
        ('Configs/*', 'Configs'),
        ('3rdParty/*.*', '3rdParty'),
        ('3rdParty/d3d10drv/*', '3rdParty/d3d10drv'),
        ('3rdParty/d3d10drv_deus_nsf/*', '3rdParty/d3d10drv_deus_nsf'),
        ('3rdParty/dxvk/*', '3rdParty/dxvk')
    ],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=runtime_hooks,
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

a_bingo = Analysis(
    ['../BingoDisplay.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=runtime_hooks,
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

#MERGE( (a_installer, 'DXRandoInstaller', 'DXRandoInstaller'), (a_bingo, 'BingoViewer', 'BingoViewer') )

pyz_installer = PYZ(a_installer.pure, a_installer.zipped_data, cipher=block_cipher)

installer_includes = [a_installer.scripts]
if onefile:
    installer_includes = [a_installer.scripts,a_installer.binaries,a_installer.zipfiles,a_installer.datas,]

exe_installer = EXE(
    pyz_installer,
    *installer_includes,
    [],
    name='DXRandoInstaller',
    debug=True,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=console,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    exclude_binaries=(not onefile),
)

pyz_bingo = PYZ(a_bingo.pure, a_bingo.zipped_data, cipher=block_cipher)

bingo_includes = [a_bingo.scripts]
if onefile:
    bingo_includes = [a_bingo.scripts,a_bingo.binaries,a_bingo.zipfiles,a_bingo.datas,]

exe_bingo = EXE(
    pyz_bingo,
    *bingo_includes,
    [],
    name='BingoViewer',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=console,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    exclude_binaries=(not onefile),
)

if not onefile:
    coll1 = COLLECT(
        exe_installer,
        a_installer.binaries,
        a_installer.zipfiles,
        a_installer.datas,

        strip=False,
        upx=True,
        upx_exclude=[],
        name='DXRando',
    )

    coll2 = COLLECT(
        exe_bingo,
        a_bingo.binaries,
        a_bingo.zipfiles,
        a_bingo.datas,

        strip=False,
        upx=True,
        upx_exclude=[],
        name='BingoViewer',
    )

def DoCleanup(folder):
    print('tidying up', folder)
    is_lib = re.compile(r'(\.dll$)|(\.so(\..+)?$)|(\.pyd$)')

    for f in folder.glob('*.app'):
        if f.is_file():
            f.unlink()

    (folder / 'lib').mkdir(exist_ok=True)
    for f in folder.glob('*'):
        name = f.name.lower()
        if not is_lib.search(name):
            continue
        if name.startswith('python') or name.startswith('libpython'):
            continue# we need the main python library
        dest = f.parent / 'lib' / f.name
        print('renaming', f, 'to', dest)
        f.rename(dest)

    print('done tidying up', folder)

# tidy up
if IsWindows() and not onefile:
    print('tidying up')
    is_lib = re.compile(r'(\.dll$)|(\.so(\..+)?$)|(\.pyd$)')

    dxr = Path('dist') / 'DXRando'
    if not dxr.exists():
        dxr = Path('installer') / 'dist' / 'DXRando'
    DoCleanup(dxr)

    bingo = Path('dist') / 'BingoViewer'
    if not bingo.exists():
        bingo = Path('installer') / 'dist' / 'BingoViewer'
    DoCleanup(bingo)

    print('done tidying up')
