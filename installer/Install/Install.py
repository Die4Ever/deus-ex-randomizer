from Install import *

def Install(exe:Path):
    assert exe.name == 'DeusEx.exe'
    system:Path = exe.parent
    assert system.name == 'System'

    flavors = DetectFlavors(system)
    print('Found flavors:', flavors)
    if 'vanilla' in flavors:
        InstallVanilla(system)
    if 'vmd' in flavors:
        CreateModConfigs(system, 'VMD', 'VMDSim')
    if 'gmdx v9' in flavors:
        InstallGMDX(system, 'GMDXv9')
    if 'gmdx rsd' in flavors:
        InstallGMDX(system, 'GMDXvRSD')
    if 'gmdx v10' in flavors:
        CreateModConfigs(system, 'GMDX', 'GMDXv10')
    if 'revision' in flavors:
        InstallRevision(system)
    if 'hx' in flavors:
        InstallHX(system)
    EngineDllFix(system)


def InstallVanilla(system:Path):
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

    CopyPackageFiles('vanilla', gameroot, ['DeusEx.u'])
    CopyD3D10Renderer(system)


def InstallGMDX(system:Path, exename:str):
    (changes, additions) = GetConfChanges('GMDX')
    # GMDX uses absolute path shortcuts with ini files in their arguments, so it's not as simple to copy their exe

    confpath = Path.home() / 'Documents' / 'Deus Ex' / exename / 'System' / 'gmdx.ini'
    if confpath.exists():
        b = confpath.read_bytes()
        b = Configs.ModifyConfig(b, changes, additions)
        confpath.write_bytes(b)

    confpath = system / exename / 'System' / 'gmdx.ini'
    if confpath.exists():
        b = confpath.read_bytes()
        b = Configs.ModifyConfig(b, changes, additions)
        confpath.write_bytes(b)

    CopyPackageFiles('GMDX', system.parent, ['GMDXRandomizer.u'])


def InstallRevision(system:Path):
    # Revision's exe is special and calls back to Steam which calls the regular Revision.exe file
    revsystem = system.parent / 'Revision' / 'System'
    CreateModConfigs(revsystem, 'Rev', 'Revision', True)


def InstallHX(system:Path):
    CopyPackageFiles('HX', system.parent, ['HXRandomizer.u'])
    (changes, additions) = GetConfChanges('HX')
    ChangeModConfigs(system, 'HX', 'HX', 'HX', changes, additions, True)
    int_source = GetPackagesPath('HX') / 'HXRandomizer.int'
    int_dest = system / 'HXRandomizer.int'
    CopyTo(int_source, int_dest)


# pretty sure this function is only good for VMD...
def CreateModConfigs(system:Path, modname:str, exename:str, in_place:bool=False):
    exepath = system / (exename+'.exe')
    newexename = modname+'Randomizer'
    newexepath = system / (newexename+'.exe')
    if not in_place:
        CopyTo(exepath, newexepath)

    intfile = GetSourcePath() / 'Configs' / 'DXRando.int'
    intdest = system / (newexename+'.int')
    CopyTo(intfile, intdest)

    CopyPackageFiles(modname, system.parent, [modname+'Randomizer.u'])

    (changes, additions) = GetConfChanges(modname)
    ChangeModConfigs(system, modname, exename, newexename, changes, additions, in_place)


def ChangeModConfigs(system:Path, modname:str, exename:str, newexename:str, changes:dict, additions:dict, in_place:bool=False):
    # inis
    confpath = system / (exename + 'Default.ini')
    b = confpath.read_bytes()
    b = Configs.ModifyConfig(b, changes, additions)
    outconf = system / (newexename + 'Default.ini')
    if in_place:
        outconf = confpath
    outconf.write_bytes(b)

    confpath = system / (exename + '.ini')
    if confpath.exists():
        b = confpath.read_bytes()
        b = Configs.ModifyConfig(b, changes, additions)
        outconf = system / (newexename + '.ini')
        if in_place:
            outconf = confpath
        outconf.write_bytes(b)

    # User inis
    if in_place:
        return
    confpath = system / (exename + 'DefUser.ini')
    b = confpath.read_bytes()
    b = Configs.ModifyConfig(b, changes, additions)
    outconf = system / (newexename + 'DefUser.ini')
    if in_place:
        outconf = confpath
    outconf.write_bytes(b)

    confpath = system / (exename + 'User.ini')
    if confpath.exists():
        b = confpath.read_bytes()
        b = Configs.ModifyConfig(b, changes, additions)
        outconf = system / (newexename + 'User.ini')
        if in_place:
            outconf = confpath
        outconf.write_bytes(b)
