
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
    VanillaFixer = 'vanillafixer' in p.name.lower()
    return VanillaFixer

ZeroRando = None
def IsZeroRando() -> bool:
    global ZeroRando
    if ZeroRando is not None:
        return ZeroRando
    p = Path(sys.argv[0])
    ZeroRando = 'zerorando' in p.name.lower()
    return ZeroRando


def SetVanillaFixer(val):
    global VanillaFixer
    VanillaFixer = val

def SetZeroRando(val):
    global ZeroRando
    ZeroRando = val

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
        out = ret.stdout
        debug(out)
        debug(ret.stderr)
        info('CheckVulkan got:', not ret.returncode)
        if ret.returncode:
            return False
        found_nvidia = False
        found_amd = False
        found_intel = False
        try: # try to detect GPU brands
            for m in re.finditer(r'deviceName\s*=\s*(.*)\n', out):
                deviceName = m.group(1)
                info(deviceName)
                if 'NVIDIA' in deviceName:
                    found_nvidia = True
                elif 'Intel' in deviceName:
                    found_intel = True
                elif 'AMD' in deviceName:
                    found_amd = True
            if not found_nvidia and not found_amd:
                info("did not find Nvidia or AMD GPU, defaulting to no DXVK")
                return False # https://github.com/Die4Ever/deus-ex-randomizer/issues/898
        except Exception as e:
            info(e)
        return True
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


def GetSteamPlayDocuments(system:Path):
    if 'Steam' in system.parts:
        idx = system.parts.index('Steam')
        idx = len(system.parents) - idx - 1 # parents array is backwards
        p = system.parents[idx]
        info('GetSteamPlayDocuments() == ', p)
        if not (p/'steamapps'/'compatdata').exists():
            return None
        p = p /'steamapps'/'compatdata'/'6910'/'pfx'/'drive_c'/'users'/'steamuser'/'Documents'
        info('GetSteamPlayDocuments() == ', p)
        return p
    return None


def GetAltSteamPlayDocuments(): # game and steam are in different folders or drives, just make a guess for now...
    checks = [
        Path.home() /'snap'/'steam'/'common'/'.local'/'share'/'Steam',
        Path.home() /'.steam'/'steam',
        Path.home() /'.steam',
        Path.home() /'.local'/'share'/'Steam'
    ]
    for p in checks:
        docs = _GetAltSteamPlayDocuments(p)
        if docs:
            return docs
    return Path.home()


def _GetAltSteamPlayDocuments(p):
    if not p.exists():
        return None
    if not (p/'steam.sh').exists():
        return None
    compatdata = p/'steamapps'/'compatdata'
    if not compatdata.exists():
        return None
    docs = compatdata/'6910'/'pfx'/'drive_c'/'users'/'steamuser'/'Documents'
    info('_GetAltSteamPlayDocuments == ', docs)
    return docs


def GetDocumentsDir(system:Path) -> Path:
    if not IsWindows():
        p = None
        if 'Steam' in system.parts:
            p = GetSteamPlayDocuments(system)
            Mkdir(p, True, True)
        if (not p) and 'steamapps' in system.parts:
            p = GetAltSteamPlayDocuments()
            Mkdir(p, True, True)
        if not p:
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
    try:
        checks = [
            Path("C:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
            Path("D:\\") / "Program Files (x86)" / "Steam" / "steamapps" / "common" / "Deus Ex" / "System",
            Path.home() /'snap'/'steam'/'common'/'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
            Path.home() /'.steam'/'steam'/'SteamApps'/'common'/'Deus Ex'/'System',
            Path.home() /'.steam'/'steam'/'steamapps'/'common'/'Deus Ex'/'System', # not sure if this ever happens but the one above with different capitalization had me suspicious
            Path.home() /'.local'/'share'/'Steam'/'steamapps'/'common'/'Deus Ex'/'System',
        ]
        p:Path
        for p in checks:
            try:
                f:Path = p / "DeusEx.exe"
                if f.exists():
                    return p
            except Exception as e:
                info(e)
    except Exception as e:
        info(e)
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

    if (game / 'Revision').is_dir() and (game/'Revision'/'System'/'RevisionDefault.ini').exists():
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


# thanks to https://steamcommunity.com/sharedfiles/filedetails/?id=2048525175
def EngineDllFix(p:Path, speedupfix:bool) -> bool:
    dll = p / 'Engine.dll'
    bytes = dll.read_bytes()
    hex = MD5(bytes)
    if hex not in ('0af95a7328719b1d4eb26374aad8ae9a', '1f23c5a7e63c79457bd4c24cd14641b0'): # vanilla, fixed
        info('skipping Engine.dll speedup fix, unrecognized md5 sum:', hex)
        return False

    if speedupfix and hex == '1f23c5a7e63c79457bd4c24cd14641b0':
        info('Engine.dll speedup fix already applied')
        return True
    if speedupfix==False and hex == '0af95a7328719b1d4eb26374aad8ae9a':
        info('Engine.dll already vanilla')
        return True

    if speedupfix:
        dllbak = p / 'Engine.dll.bak'
        WriteBytes(dllbak, bytes)

    bytes = bytearray(bytes)
    if speedupfix:
        bytes[0x12ADCC:0x12ADD0] = (0,0,0,0)
    else:
        bytes[0x12ADCC:0x12ADD0] = (10, 215, 163, 59)
    WriteBytes(dll, bytes)
    return True



def CopyD3DRenderers(system:Path, deus_nsf_lighting:bool, d3d10_textures:str):
    source = GetSourcePath()
    thirdparty = source / '3rdParty'
    info('CopyD3DRenderers from', thirdparty, ' to ', system)

    CopyTo(thirdparty/'D3D9Drv.dll', system/'D3D9Drv.dll', True)
    #CopyTo(thirdparty/'D3D9Drv.hut', system/'D3D9Drv.hut', True)
    (system/'D3D9Drv.hut').unlink(True)# this file seems to slow down opening the kentie config page?
    CopyTo(source/'Configs'/'D3D9Drv.int', system/'D3D9Drv.int', True)

    CopyTo(thirdparty/'d3d10drv.dll', system/'d3d10drv.dll', True)
    CopyTo(thirdparty/'D3D10Drv.int', system/'D3D10Drv.int', True)

    if deus_nsf_lighting or d3d10_textures != 'Smooth':
        deus_nsf = system / 'd3d10drv'
        Copyd3d10drv(thirdparty / 'd3d10drv_deus_nsf', system / 'd3d10drv')
        Copyd3d10drv(thirdparty / 'd3d10drv', system / 'd3d10drv_kentie')
    else:
        deus_nsf = system / 'd3d10drv_deus_nsf'
        Copyd3d10drv(thirdparty / 'd3d10drv_deus_nsf', system / 'd3d10drv_deus_nsf')
        Copyd3d10drv(thirdparty / 'd3d10drv', system / 'd3d10drv')

    if d3d10_textures=='Retro':
        CopyTo(deus_nsf/'unrealpool_retro_textures.fxh', deus_nsf/'unrealpool.fxh')
    elif d3d10_textures=='Balanced':
        CopyTo(deus_nsf/'unrealpool_balanced_textures.fxh', deus_nsf/'unrealpool.fxh')
    elif d3d10_textures=='Smooth':
        CopyTo(deus_nsf/'unrealpool_smooth_textures.fxh', deus_nsf/'unrealpool.fxh')


def Copyd3d10drv(source, dest):
    info('Copyd3d10drv from', source, 'to', dest)
    Mkdir(dest, exist_ok=True)
    num = 0
    for f in source.glob('*'):
        CopyTo(f, dest / f.name, True)
        num += 1
    assert num > 0, 'Found '+str(num)+' d3d10drv files in '+str(source)


def CopyDXVK(system:Path, install:bool, maxfps=500):
    dir = GetSourcePath() / '3rdParty' / 'dxvk'
    info('CopyDXVK with install=', install, 'maxfps=', maxfps, 'from', dir, ' to ', system)
    num = 0
    # doesn't hurt to always have the dxvk.conf file?
    dxvkconf = (GetSourcePath()/'Configs'/'dxvk.conf').read_text()
    if maxfps:
        maxfps = str(int(maxfps))
        dxvkconf = dxvkconf.replace('dxgi.maxFrameRate = 500', 'dxgi.maxFrameRate = ' + maxfps)
        dxvkconf = dxvkconf.replace('d3d9.maxFrameRate = 500', 'd3d9.maxFrameRate = ' + maxfps)
    WriteBytes(system/'dxvk.conf', dxvkconf.encode())
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
