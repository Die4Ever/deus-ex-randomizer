# -*- mode: python ; coding: utf-8 -*-
from pathlib import Path
import re
import os

def IsWindows() -> bool:
    return os.name == 'nt'

block_cipher = None
console = False

# unfortunately runtime_hooks is not relative to the location of the spec file, but everything else is
runtime_hooks = []
if IsWindows():
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
        ('3rdParty/d3d10drv/*', '3rdParty/d3d10drv')
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

MERGE( (a_installer, 'DXRandoInstaller', 'DXRandoInstaller'), (a_bingo, 'BingoViewer', 'BingoViewer') )

pyz_installer = PYZ(a_installer.pure, a_installer.zipped_data, cipher=block_cipher)

exe_installer = EXE(
    pyz_installer,
    a_installer.scripts,
    [],
    exclude_binaries=True,
    name='DXRandoInstaller',
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
)

pyz_bingo = PYZ(a_bingo.pure, a_bingo.zipped_data, cipher=block_cipher)

exe_bingo = EXE(
    pyz_bingo,
    a_bingo.scripts,
    [],
    exclude_binaries=True,
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
)

coll = COLLECT(
    exe_installer,
    a_installer.binaries,
    a_installer.zipfiles,
    a_installer.datas,

    exe_bingo,
    a_bingo.binaries,
    a_bingo.zipfiles,
    a_bingo.datas,

    strip=False,
    upx=True,
    upx_exclude=[],
    name='DXRando',
)

# tidy up
if IsWindows():
    print('tidying up')
    is_lib = re.compile(r'(\.dll$)|(\.so(\..+)?$)|(\.pyd$)')

    dxr = Path('dist') / 'DXRando'
    if not dxr.exists():
        dxr = Path('installer') / 'dist' / 'DXRando'

    if (dxr / 'installer.app').exists():
        (dxr / 'installer.app').unlink()

    (dxr / 'lib').mkdir(exist_ok=True)
    for f in dxr.glob('*'):
        name = f.name.lower()
        if not is_lib.search(name):
            continue
        if name.startswith('python') or name.startswith('libpython'):
            continue# we need the main python library
        dest = f.parent / 'lib' / f.name
        print('renaming', f, 'to', dest)
        f.rename(dest)

    print('done tidying up')
