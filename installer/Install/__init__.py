
try:
    outfile = open('log.txt', 'w', encoding="utf-8")
    print('starting', file=outfile, flush=True)
except Exception as e:
    print('ERROR writing to log.txt file', e)
    outfile = None

def debug(*args):
    global outfile
    if GetVerbose():
        print(*args)
        if outfile:
            print(*args, file=outfile, flush=True)

def info(*args):
    global outfile
    print(*args)
    if outfile:
        print(*args, file=outfile, flush=True)




try:
    import sys
    import hashlib
    import os
    from pathlib import Path
    import urllib.request
    import certifi
    import ssl
    import subprocess
    import re
except Exception as e:
    info('ERROR: importing', e)
    raise

verbose = False
dryrun = False
def SetVerbose(val:bool):
    global verbose
    verbose = val

def GetVerbose() -> bool:
    global verbose
    return verbose

def SetDryrun(val:bool):
    global dryrun
    dryrun = val

def GetDryrun() -> bool:
    global dryrun
    return dryrun

VanillaFixer = None
def IsVanillaFixer() -> bool:
    global VanillaFixer
    if VanillaFixer is not None:
        return VanillaFixer
    p = Path(sys.argv[0])
    return 'dxrvanillafixer' in p.name.lower()

def SetVanillaFixer(val):
    global VanillaFixer
    VanillaFixer = val

def IsWindows() -> bool:
    return os.name == 'nt'

version = None
def GetVersion():
    global version
    if version:
        return version

    p = GetPackagesPath('vanilla') / 'DeusEx.u'
    assert p.exists()
    data = p.read_bytes()

    i = data.find(b'class DXRVersion extends Info;')
    data = data[i:]
    i = data.find(b'////// you probably don\'t need to touch the stuff below')
    data = data[:i]

    i = data.find(b'static function CurrentVersion(')
    CurrentVersion = data[i:]
    i = CurrentVersion.find(b'}')
    CurrentVersion = CurrentVersion[:i].decode('iso_8859_1')
    v = re.search(r'major=(\d+);\s+minor=(\d+);\s+patch=(\d+);\s+build=(\d+);', CurrentVersion, flags=re.MULTILINE)
    fullversion = 'v' + v.group(1) + '.' + v.group(2) + '.' + v.group(3) + '.' + v.group(4)
    version = 'v' + v.group(1) + '.' + v.group(2)
    if v.group(3) != '0':
        version += '.' + v.group(3)

    i = data.find(b'static function string VersionString(')
    VersionString = data[i:]
    i = VersionString.find(b'}')
    VersionString = VersionString[:i].decode('iso_8859_1')

    m = re.search(r'status = "(.*)";', VersionString, flags=re.MULTILINE)
    if m and m.group(1):
        version = fullversion + ' ' + m.group(1)

    return version

def CheckVulkan() -> bool:
    if not IsWindows():
        return False # no easy way to detect Vulkan on Linux, they don't need DXVK anyways
    try:
        info('CheckVulkan')
        ret = subprocess.run(['vulkaninfo', '--summary'], text=True, capture_output=True, timeout=30, creationflags=subprocess.CREATE_NO_WINDOW)
        debug(ret.stdout)
        debug(ret.stderr)
        info('CheckVulkan got:', not ret.returncode)
        return not ret.returncode
    except Exception as e:
        info(e)
        return False


def GetConfChanges(modname):
    changes = {
        'Engine.Engine': {
            'DefaultGame': modname+'Randomizer.DXRandoGameInfo',
            'Root': modname+'Randomizer.DXRandoRootWindow'
        },
        'Core.System': {
            'SavePath': '..\\Save' + modname + 'Rando'
        }
    }
    syspath = '..\\' + modname + 'Randomizer\\System\\*.u'
    mapspath = '..\\' + modname + 'Randomizer\\Maps\\*.dx'
    newpaths = [syspath, mapspath]
    additions = {'Core.System': {'Paths': newpaths}}
    if modname == 'Rev':
        additions['RevisionInternal.LaunchSystem'] = {'Paths': newpaths}
    if modname == 'HX':
        changes = {}
    #if modname == 'VMD' and not IsWindows():
        #changes['WinDrv.WindowsClient'] = {'StartupFullscreen': 'False', 'WindowedViewportX': '1280', 'WindowedViewportY': '720'}
    return (changes, additions)


def GetSourcePath() -> Path:
    p = Path(__file__).resolve()
    p = p.parent
    if (p / 'Configs').is_dir():
        return p
    p = p.parent
    if (p / 'Configs').is_dir():
        return p
    raise RuntimeError('failed to GetSourcePath()', p)


def GetSteamPlayDocuments(system:Path) -> Path:
    if 'Steam' in system.parts:
        idx = system.parts.index('Steam')
        idx = len(system.parents) - idx - 1 # parents array is backwards
        p = system.parents[idx]
        info('GetSteamPlayDocuments() == ', p)
        p = p /'steamapps'/'compatdata'/'6910'/'pfx'/'drive_c'/'users'/'steamuser'/'Documents'
        info('GetSteamPlayDocuments() == ', p)
        return p

def GetDocumentsDir(system:Path) -> Path:
    if not IsWindows():
        if 'Steam' in system.parts:
            p = GetSteamPlayDocuments(system)
            Mkdir(p, True, True)
        else:
            p = Path.home()
        assert p.exists(), str(p)
        return p
    try:
        import ctypes.wintypes
        CSIDL_PERSONAL = 5       # My Documents
        SHGFP_TYPE_CURRENT = 0   # Get current, not default value
        buf = ctypes.create_unicode_buffer(ctypes.wintypes.MAX_PATH)
        ctypes.windll.shell32.SHGetFolderPathW(None, CSIDL_PERSONAL, None, SHGFP_TYPE_CURRENT, buf)
        p = Path(buf.value)
        info('GetDocumentsDir() == ', p)
        assert p.exists()
        return p
    except Exception as e:
        info('ERROR: in GetDocumentsDir():', e)
    p = Path.home() / 'Documents'
    info('GetDocumentsDir() == ', p)
    assert p.exists()
    return p


def getDefaultPath():
    checks = [
        Path("C:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
        Path("D:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
        Path.home() /'snap'/'steam'/'common'/'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
        Path.home() /'.steam'/'steam'/'SteamApps'/'common'/'Deus Ex'/'System',
        Path.home() /'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
    ]
    p:Path
    for p in checks:
        f:Path = p / "DeusEx.exe"
        if f.exists():
            return p
    return None


def GetPackagesPath(modname:str) -> Path:
    # TODO: these source files will be split up into a separate folder for each modname when we start using consistent filenames
    p = GetSourcePath()
    # check if compiled python
    if ( p / 'System' / 'DeusEx.u').exists():
        return p / 'System'

    # else, uncompiled, our builds are in the root of the repo, so navigate out of the installer folder
    p = p.parent
    if (p / 'DeusEx.u').exists():
        return p
    raise RuntimeError('failed to GetPackagesPath()', p)


def _DetectFlavors(system:Path):
    flavors = []
    game = system.parent
    vanilla_md5 = None
    is_vanilla = False

    deusexu_md5s = {
        'd343da03a6d311ee412dfae4b52ff975': 'vanilla',
        '5964bd1dcea8edb20cb1bc89881b0556': 'DXRando v2.5',
    }

    if (system / 'DeusEx.u').exists():
        flavors.append('Vanilla')
        vanilla_md5 = MD5((system / 'DeusEx.u').read_bytes())
        md5_name = deusexu_md5s.get(vanilla_md5)
        if md5_name == 'vanilla':
            is_vanilla = True
        elif md5_name:
            info("found DeusEx.u", md5_name, vanilla_md5)
        else:
            info('unknown MD5 for DeusEx.u', vanilla_md5)

    if (game / 'GMDXv9').is_dir():
        flavors.append('GMDX v9')
    if (game / 'GMDXvRSD').is_dir():
        flavors.append('GMDX RSD')
    if (game / 'GMDXv10').is_dir():
        flavors.append('GMDX v10')
    if (system / 'HX.u').exists():
        if not is_vanilla:
            info('WARNING: DeusEx.u file is not vanilla! This can cause issues with HX')
        flavors.append('HX')
    if (game / 'Revision').is_dir():
        flavors.append('Revision')

    if (game / 'VMDSim').is_dir():
        flavors.append('Vanilla? Madder.')
        # VMD uses the vanilla DeusEx.u path, TODO: for non-windows, force in_place=False
        if not IsWindows() and 'Vanilla' in flavors:
            flavors.remove('Vanilla')

    debug("_DetectFlavors", flavors)
    return flavors


def CopyPackageFiles(modname:str, gameroot:Path, packages:list):
    assert (gameroot / 'System').is_dir()
    if modname == 'vanilla':
        dxrandoroot = gameroot / 'DXRando'
    elif modname:
        dxrandoroot = gameroot / (modname+'Randomizer')
    else:
        dxrandoroot = gameroot

    packages_path = GetPackagesPath(modname)

    Mkdir(dxrandoroot, exist_ok=True)
    dxrandosystem = dxrandoroot / 'System'
    Mkdir(dxrandosystem, exist_ok=True)

    # need to split our package files and organize them into different folders since these always have the same names
    #packages.append('DXRandoCore.u')
    #packages.append('DXRandoModules.u')

    for package in packages:
        package_source = packages_path / package
        package_dest = dxrandosystem / package
        CopyTo(package_source, package_dest)


def EngineDllFix(p:Path) -> bool:
    dll = p / 'Engine.dll'
    bytes = dll.read_bytes()
    hex = MD5(bytes)
    if hex == '1f23c5a7e63c79457bd4c24cd14641b0':
        info('Engine.dll speedup fix already applied')
        return True
    if hex != '0af95a7328719b1d4eb26374aad8ae9a':
        info('skipping Engine.dll speedup fix, unrecognized md5 sum:', hex)
        return False
    dllbak = p / 'Engine.dll.bak'
    WriteBytes(dllbak, bytes)
    bytes = bytearray(bytes)
    for i in range(0x12ADCC, 0x12ADCF + 1):
        bytes[i] = 0
    WriteBytes(dll, bytes)
    return True



def CopyD3DRenderers(system:Path, deus_nsf_lighting:bool, deus_nsf_retro_textures:bool):
    source = GetSourcePath()
    thirdparty = source / '3rdParty'
    info('CopyD3DRenderers from', thirdparty, ' to ', system)

    CopyTo(thirdparty/'D3D9Drv.dll', system/'D3D9Drv.dll', True)
    #CopyTo(thirdparty/'D3D9Drv.hut', system/'D3D9Drv.hut', True)
    (system/'D3D9Drv.hut').unlink(True)# this file seems to slow down opening the kentie config page?
    CopyTo(source/'Configs'/'D3D9Drv.int', system/'D3D9Drv.int', True)

    CopyTo(thirdparty/'d3d10drv.dll', system/'d3d10drv.dll', True)
    CopyTo(thirdparty/'D3D10Drv.int', system/'D3D10Drv.int', True)

    if deus_nsf_lighting or deus_nsf_retro_textures:
        deus_nsf = system / 'd3d10drv'
        Copyd3d10drv(thirdparty / 'd3d10drv_deus_nsf', system / 'd3d10drv')
        Copyd3d10drv(thirdparty / 'd3d10drv', system / 'd3d10drv_kentie')
    else:
        deus_nsf = system / 'd3d10drv_deus_nsf'
        Copyd3d10drv(thirdparty / 'd3d10drv_deus_nsf', system / 'd3d10drv_deus_nsf')
        Copyd3d10drv(thirdparty / 'd3d10drv', system / 'd3d10drv')

    if deus_nsf_retro_textures:
        CopyTo(deus_nsf/'unrealpool_retro_textures.fxh', deus_nsf/'unrealpool.fxh')
    else:
        CopyTo(deus_nsf/'unrealpool_smooth_textures.fxh', deus_nsf/'unrealpool.fxh')


def Copyd3d10drv(source, dest):
    info('Copyd3d10drv from', source, 'to', dest)
    Mkdir(dest, exist_ok=True)
    num = 0
    for f in source.glob('*'):
        CopyTo(f, dest / f.name, True)
        num += 1
    assert num > 0, 'Found '+str(num)+' d3d10drv files in '+str(source)


def CopyDXVK(system:Path, install:bool):
    dir = GetSourcePath() / '3rdParty' / 'dxvk'
    info('CopyDXVK from', dir, ' to ', system)
    num = 0
    # doesn't hurt to always have the dxvk.conf file?
    CopyTo(GetSourcePath()/'Configs'/'dxvk.conf', system/'dxvk.conf')
    # loop through all dxvk files and conditionally add or delete them
    for f in dir.glob('*'):
        dest = system / f.name
        if install:
            CopyTo(f, dest)
        elif dest.exists():
            debug('DXVK deleting', dest)
            dest.unlink(True)
        num += 1
    assert num > 0, 'Found '+str(num)+' DXVK files'

def InstallOGL2(system:Path, install:bool):
    Ogl = system/'OpenGLDrv.dll'
    backupOgl = system/'OpenGLDrv.orig.dll'
    if install:
        if Ogl.exists() and not backupOgl.exists():
            Ogl.rename(backupOgl)
        CopyTo(GetSourcePath() / '3rdParty' /'OpenGLDrv.dll', Ogl)
    elif backupOgl.exists():
        currMd5 = ''
        if Ogl.exists():
            currMd5 = MD5(Ogl.read_bytes())
        backupMd5 = MD5(backupOgl.read_bytes())
        info('reverting', Ogl, currMd5, 'to', backupOgl, backupMd5)
        CopyTo(backupOgl, Ogl)


def Mkdir(dir:Path, parents=False, exist_ok=False):
    if GetDryrun():
        info("dryrun would've created folder", dir)
    else:
        debug("creating folder", dir)
        dir.mkdir(parents=parents, exist_ok=exist_ok)

def WriteBytes(out:Path, data:bytes):
    if GetDryrun():
        info("dryrun would've written", len(data), "bytes to", out)
    else:
        debug("writing", len(data), "bytes to", out)
        out.write_bytes(data)


def CopyTo(source:Path, dest:Path, silent:bool=False):
    if GetVerbose() or not silent:
        info('Copying', source, 'to', dest)
    bytes = source.read_bytes()
    WriteBytes(dest, bytes)


def MD5(bytes:bytes) -> str:
    ret = hashlib.md5(bytes).hexdigest()
    debug("MD5 of", len(bytes), " bytes is", ret)
    return ret


def DownloadFile(url, dest, callback=None):
    # still do this on dryrun because it writes to temp?
    sslcontext = ssl.create_default_context(cafile=certifi.where())
    old_func = ssl._create_default_https_context
    ssl._create_default_https_context = lambda : sslcontext # HACK

    info('\n\ndownloading', url, 'to', dest)
    urllib.request.urlretrieve(url, dest, callback) # "legacy interface"
    info('done downloading ', url, 'to', dest)

    ssl._create_default_https_context = old_func
