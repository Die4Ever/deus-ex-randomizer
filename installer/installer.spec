# -*- mode: python ; coding: utf-8 -*-


block_cipher = None
console = False

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
    runtime_hooks=[],
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
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

MERGE( (a_installer, 'installer', 'installer'), (a_bingo, 'BingoViewer', 'BingoViewer') )

pyz_installer = PYZ(a_installer.pure, a_installer.zipped_data, cipher=block_cipher)

exe_installer = EXE(
    pyz_installer,
    a_installer.scripts,
    [],
    exclude_binaries=True,
    name='installer',
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
    name='dxrando',
)
