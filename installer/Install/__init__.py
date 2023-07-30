import hashlib
import os
from pathlib import Path
import Install.Config as Config
import urllib.request
import certifi
import ssl

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

def IsWindows() -> bool:
    return os.name == 'nt'

try:
    outfile = open('log.txt', 'w')
except Exception as e:
    print('ERROR writing to log.txt file', e)
    outfile = None

def debug(*args):
    global outfile
    if GetDryrun():
        print(*args)
        if outfile:
            print(*args, file=outfile)

def info(*args):
    global outfile
    print(*args)
    if outfile:
        print(*args, file=outfile)


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


def GetDocumentsDir() -> Path:
    if not IsWindows():
        p = Path.home()
        info('GetDocumentsDir() == ', p)
        assert p.exists()
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
    else:
        dxrandoroot = gameroot / (modname+'Randomizer')

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


def ModifyConfig(defconfig:Path, config:Path, outdefconfig:Path, outconfig:Path, changes:dict):
    info('ModifyConfig', defconfig, config, outdefconfig, outconfig)
    bytes = defconfig.read_bytes()
    bytes = Config.ModifyConfig(bytes, changes)
    WriteBytes(outdefconfig, bytes)

    if config.exists():
        bytes = defconfig.read_bytes()
        bytes = Config.ModifyConfig(bytes, changes)
        WriteBytes(outconfig, bytes)


def CopyD3D10Renderer(system:Path):
    thirdparty = GetSourcePath() / '3rdParty'
    info('CopyD3D10Renderer from', thirdparty, ' to ', system)

    CopyTo(thirdparty/'d3d10drv.dll', system/'d3d10drv.dll', True)
    CopyTo(thirdparty/'D3D10Drv.int', system/'D3D10Drv.int', True)

    drvdir_source = thirdparty / 'd3d10drv'
    drvdir_dest = system / 'd3d10drv'
    Mkdir(drvdir_dest, exist_ok=True)
    for f in drvdir_source.glob('*'):
        CopyTo(f, drvdir_dest / f.name, True)


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


def DownloadFile(url, dest, callback):
    # still do this on dryrun because it writes to temp?
    sslcontext = ssl.create_default_context(cafile=certifi.where())
    old_func = ssl._create_default_https_context
    ssl._create_default_https_context = lambda : sslcontext # HACK

    info('\n\ndownloading', url, 'to', dest)
    urllib.request.urlretrieve(url, dest, callback) # "legacy interface"
    info('done downloading ', url, 'to', dest)

    ssl._create_default_https_context = old_func
