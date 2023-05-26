import hashlib
from pathlib import Path
import Configs

def GetConfChanges(modname):
    changes = {
        'Engine.Engine': {
            'DefaultGame': modname+'Randomizer.DXRandoGameInfo',
            'Root': modname+'Randomizer.DXRandoRootWindow'
        }
    }
    newpath = '..\\' + modname + 'Randomizer\\System\\*.u'
    additions = {'Core.System': {'Paths': newpath}}
    if modname == 'Rev':
        additions['RevisionInternal.LaunchSystem'] = {'Paths': newpath}
    if modname == 'HX':
        changes = {}
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


def DetectFlavors(system:Path):
    flavors = []
    game = system.parent
    vanilla_md5 = None
    is_vanilla = False

    if (game / 'VMDSim').is_dir():
        return ['vmd']# VMD seems like it can only exist by itself

    if (system / 'DeusEx.u').exists():
        flavors.append('vanilla')
        vanilla_md5 = MD5((system / 'DeusEx.u').read_bytes())
        if vanilla_md5 == 'd343da03a6d311ee412dfae4b52ff975':
            is_vanilla = True
        else:
            print('unknown MD5 for DeusEx.u', vanilla_md5)

    if (game / 'GMDXv9').is_dir():
        flavors.append('gmdx v9')
    if (game / 'GMDXvRSD').is_dir():
        flavors.append('gmdx rsd')
    if (game / 'GMDXv10').is_dir():
        flavors.append('gmdx v10')
    if (system / 'HX.u').exists():
        if not is_vanilla:
            print('WARNING: DeusEx.u file is not vanilla! This can cause issues with HX')
        flavors.append('hx')
    if (game / 'Revision').is_dir():
        flavors.append('revision')

    return flavors


def CopyPackageFiles(modname:str, gameroot:Path, packages:list):
    assert (gameroot / 'System').is_dir()
    if modname == 'vanilla':
        dxrandoroot = gameroot / 'DXRando'
    else:
        dxrandoroot = gameroot / (modname+'Randomizer')

    packages_path = GetPackagesPath(modname)

    dxrandoroot.mkdir(exist_ok=True)
    dxrandosystem = dxrandoroot / 'System'
    dxrandosystem.mkdir(exist_ok=True)

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
        print('Engine.dll speedup fix already applied')
        return True
    if hex != '0af95a7328719b1d4eb26374aad8ae9a':
        print('skipping Engine.dll speedup fix, unrecognized md5 sum:', hex)
        return False
    dllbak = p / 'Engine.dll.bak'
    dllbak.write_bytes(bytes)
    bytes = bytearray(bytes)
    for i in range(0x12ADCC, 0x12ADCF + 1):
        bytes[i] = 0
    dll.write_bytes(bytes)
    return True


def ModifyConfig(defconfig:Path, config:Path, outdefconfig:Path, outconfig:Path, changes:dict):
    bytes = defconfig.read_bytes()
    bytes = Configs.ModifyConfig(bytes, changes)
    outdefconfig.write_bytes(bytes)

    if config.exists():
        bytes = defconfig.read_bytes()
        bytes = Configs.ModifyConfig(bytes, changes)
        outconfig.write_bytes(bytes)


def CopyD3D10Renderer(system:Path):
    thirdparty = GetSourcePath() / '3rdParty'

    CopyTo(thirdparty/'d3d10drv.dll', system/'d3d10drv.dll')
    CopyTo(thirdparty/'D3D10Drv.int', system/'D3D10Drv.int')

    drvdir_source = thirdparty / 'd3d10drv'
    drvdir_dest = system / 'd3d10drv'
    drvdir_dest.mkdir(exist_ok=True)
    for f in drvdir_source.glob('*'):
        CopyTo(f, drvdir_dest / f.name)


def CopyTo(source:Path, dest:Path):
    bytes = source.read_bytes()
    dest.write_bytes(bytes)

def MD5(bytes:bytes) -> str:
    return hashlib.md5(bytes).hexdigest()
