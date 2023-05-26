from hashlib import md5

from pathlib import Path

def GetSourcePath() -> Path:
    p = Path(__file__).resolve()
    p = p.parent
    if (p / 'Configs').is_dir():
        return p
    p = p.parent
    if (p / 'Configs').is_dir():
        return p
    raise RuntimeError('failed to GetSourcePath()', p)

def GetPackagesPath() -> Path:
    p = GetSourcePath()
    # check if compiled
    if ( p / 'System' / 'DeusEx.u').exists():
        return p / 'System'

    # else, uncompiled, our builds are in the root of the repo, so navigate out of the installer folder
    p = p.parent
    if (p / 'DeusEx.u').exists():
        return p
    raise RuntimeError('failed to GetPackagesPath()', p)

def Install(p:Path):
    assert p.name == 'DeusEx.exe'
    system:Path = p.parent
    # TODO: detect which flavor of Deus Ex this is, based on surrounding filenames
    InstallVanilla(p)
    EngineDllFix(system)


def InstallVanilla(p:Path):
    assert p.name == 'DeusEx.exe'
    system:Path = p.parent
    gameroot = system.parent

    # TODO: option for Kentie's vs Han's
    kentie = GetSourcePath() / '3rdParty' / "KentieDeusExe.exe"
    exedest:Path = system / 'DXRando.exe'
    CopyTo(kentie, exedest)

    intfile = GetSourcePath() / 'Configs' / 'DXRando.int'
    intdest = system / 'DXRando.int'
    CopyTo(intfile, intdest)

    ini = GetSourcePath() / 'Configs' / "DXRandoDefault.ini"
    inidest = system / "DXRandoDefault.ini"# I don't think Kentie cares about this file, but Han's Launchbox does
    CopyTo(ini, inidest)

    # TODO: retain old resolution choices and stuff like that, set FPSLimit and VSync properly if skipping Engine.dll speedup fix
    configsroot = Path.home() / 'Documents' / 'Deus Ex' / 'System'
    DXRandoini = configsroot / 'DXRando.ini'
    if DXRandoini.exists():
        DXRandoini.unlink()
    CopyTo(ini, DXRandoini)

    CopyPackageFiles(gameroot, ['DeusEx.u'])
    CopyD3D10Renderer(system)


def CopyPackageFiles(gameroot:Path, packages:list):
    dxrandoroot = gameroot / 'DXRando'
    packages_path = GetPackagesPath()

    dxrandoroot.mkdir(exist_ok=True)
    dxrandosystem = dxrandoroot / 'System'
    dxrandosystem.mkdir(exist_ok=True)

    for package in packages:
        package_source = packages_path / package
        package_dest = dxrandosystem / package
        CopyTo(package_source, package_dest)


def EngineDllFix(p:Path) -> bool:
    dll = p / 'Engine.dll'
    bytes = dll.read_bytes()
    hex = md5(bytes).hexdigest()
    if hex == '1f23c5a7e63c79457bd4c24cd14641b0':
        print('Engine.dll speedup fix already applied')
        return True
    if hex != '0af95a7328719b1d4eb26374aad8ae9a':
        print('skipping Engine.dll speedup fix, unrecognized md5 sum:', hex)
        return False
    bytes = bytearray(bytes)
    for i in range(0x12ADCC, 0x12ADCF + 1):
        bytes[i] = 0
    dll.write_bytes(bytes)
    return True


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
