# -*- mode: python ; coding: utf-8 -*-
from pathlib import Path
import re
import os
from Install import DownloadFile, WriteBytes
from zipfile import ZipFile
import tarfile
import PyInstaller.__main__

Community_Update_url = "https://github.com/Defaultplayer001/Deus-Ex-Universe-Community-Update-/raw/a662f6ed177dba52ad3a0d8141fa2ac72f8af034/%5B1.0%5D%20Deus%20Ex%20-%20Windows-Linux-macOS-Android/"
downloads = {
    # Launchers
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/Alternative%20EXEs/Kentie's%20DeusExe.exe": "KentieDeusExe.exe",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/DeusExe.u": "DeusExe.u",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/Alternative%20EXEs/Launch.exe": "Launch.exe",

    # Renderers
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/D3D9Drv.dll": "D3D9Drv.dll",
    # "DXCU%20Installer%20Source/Mods/Community%20Update/System/D3D9Drv.hut": "D3D9Drv.hut",
    # "DXCU%20Installer%20Source/Mods/Community%20Update/System/D3D9Drv.int": "D3D9Drv.int",

    "CommunityUpdateFileArchiveDXPC/OpenGL/dxglr21.zip": "dxglr21.zip",

    # D3D10
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/D3D10Drv.int": "D3D10Drv.int",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv.dll": "d3d10drv.dll",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/common.fxh": "d3d10drv/common.fxh",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/complexsurface.fx": "d3d10drv/complexsurface.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/finalpass.fx": "d3d10drv/finalpass.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/firstpass.fx": "d3d10drv/firstpass.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/fogsurface.fx": "d3d10drv/fogsurface.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/gouraudpolygon.fx": "d3d10drv/gouraudpolygon.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/hdr%20(original).fx": "d3d10drv/hdr.original.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/hdr.fx": "d3d10drv/hdr.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/polyflags.fxh": "d3d10drv/polyflags.fxh",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/postprocessing.fxh": "d3d10drv/postprocessing.fxh",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/states.fxh": "d3d10drv/states.fxh",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/tile.fx": "d3d10drv/tile.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/unreal_pom.fx": "d3d10drv/unreal_pom.fx",
    "DXCU%20Installer%20Source/Mods/Community%20Update/System/d3d10drv/unrealpool.fxh": "d3d10drv/unrealpool.fxh",
}

basedest = ''
base = Path()

if Path('installer/add_lib_path.py').exists():
    base = Path('installer')
    basedest = 'installer/3rdParty/'
elif Path('add_lib_path.py').exists():
    basedest = '3rdParty/'
else:
    raise RuntimeError("Can't find root folder for installer")

basedest = base / '3rdParty'

basedest.mkdir(exist_ok=True)
(basedest/'d3d10drv').mkdir(exist_ok=True)
(basedest/'dxvk').mkdir(exist_ok=True)

for (url, dest) in downloads.items():
    p = basedest/dest
    if not p.exists():
        DownloadFile(Community_Update_url + url, basedest/dest)

# TODO: unzip dxglr21.zip
zip = ZipFile(basedest/'dxglr21.zip', 'r')
zip.extractall(basedest)
zip.close()
(basedest/'dxglr21.zip').unlink()


# # LDDP minimal install
if not (basedest/'FemJC.u').exists():
    DownloadFile('https://github.com/LayDDentonProject/Lay-D-Denton-Project/releases/download/v1.1/FemJC.u', basedest/'FemJC.u')

# DXVK 32bit
if not (basedest/'dxvk.tar.gz').exists():
    DownloadFile('https://github.com/doitsujin/dxvk/releases/download/v2.3/dxvk-2.3.tar.gz', basedest/'dxvk.tar.gz')
tar = tarfile.open(basedest/'dxvk.tar.gz')
for f in tar.getmembers():
    if '/x32/' in f.path and f.isfile():
        p = Path(f.name).name
        p = basedest/'dxvk'/p
        data = tar.extractfile(f).read()
        WriteBytes(p, data)
tar.close()
(basedest/'dxvk.tar.gz').unlink()

spec = base/'installer.spec'
print("building spec file:", spec)
(base/'dist').mkdir(exist_ok=True)
(base/'build').mkdir(exist_ok=True)
PyInstaller.__main__.run([
    #'--clean',
    '--distpath=' + str(base/'dist'),
    '--workpath=' + str(base/'build'),
    str(spec),
])
