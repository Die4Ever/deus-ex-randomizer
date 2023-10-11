from Install import *
try:
    import os
    import tempfile
    from zipfile import ZipFile
    from Install import _DetectFlavors
    from Install import MapVariants
except Exception as e:
    info('ERROR: importing', e)
    raise

def UnattendedInstall(installpath:str, downloadmirrors):
    if not installpath:
        p:Path = getDefaultPath()
        p = p / 'DeusEx.exe'
    else:
        p:Path = Path(installpath)
        if p.is_dir() and p.name == 'System':
            p = p / 'DeusEx.exe'

    assert p.exists(), str(p)

    callback = lambda a,b,c, status='Downloading' : debug(status, a,b,c)
    flavors = DetectFlavors(p)
    settings = {}
    for f in flavors:
        settings[f] = {'downloadcallback': callback}

    if downloadmirrors and 'Vanilla' in settings:
        settings['Vanilla']['mirrors'] = True

    dxvk_default = IsWindows() and CheckVulkan()

    ret = Install(p, settings, speedupfix=True, dxvk=dxvk_default, ogl2=dxvk_default)


def DetectFlavors(exe:Path) -> list:
    assert exe.exists(), str(exe)
    assert exe.name.lower() == 'deusex.exe'
    system:Path = exe.parent
    assert system.name.lower() == 'system'

    return _DetectFlavors(system)


def Install(exe:Path, flavors:dict, speedupfix:bool, dxvk:bool, OGL2:bool=False) -> dict:
    assert exe.exists(), str(exe)
    assert exe.name.lower() == 'deusex.exe'
    system:Path = exe.parent
    assert system.name.lower() == 'system'

    info('Installing flavors:', flavors, speedupfix, exe)

    for(f, settings) in flavors.items():
        ret={}
        if 'Vanilla'==f:
            ret = InstallVanilla(system, settings, speedupfix, Vulkan=dxvk, OGL2=OGL2)
        if 'Vanilla? Madder.'==f:
            ret = CreateModConfigs(system, settings, 'VMD', 'VMDSim')
        if 'GMDX v9'==f:
            ret = InstallGMDX(system, settings, 'GMDXv9')
        if 'GMDX RSD'==f:
            ret = InstallGMDX(system, settings, 'GMDXvRSD')
        if 'GMDX v10'==f:
            ret = CreateModConfigs(system, settings, 'GMDX', 'GMDXv10')
        if 'Revision'==f:
            ret = InstallRevision(system, settings)
        if 'HX'==f:
            ret = InstallHX(system, settings)
        if ret and settings:
            settings.update(ret)

    if speedupfix:
        EngineDllFix(system)

    CopyDXVK(system, dxvk)
    InstallOGL2(system, OGL2)

    debug("Install returning", flavors)

    return flavors


def InstallVanilla(system:Path, settings:dict, speedupfix:bool, Vulkan:bool, OGL2:bool):
    gameroot = system.parent

    if settings.get('LDDP'):
        InstallLDDP(system, settings)

    exe_source = GetSourcePath() / '3rdParty' / "KentieDeusExe.exe"
    exetype = settings.get('exetype')
    kentie = True
    if exetype == 'Launch':
        exe_source = GetSourcePath() / '3rdParty' / "Launch.exe"
        kentie = False
    exename = 'DXRando'
    # TODO: allow separate exe file for linux, use new in_place boolean setting?
    # maybe I can create the SteamPlay config file needed? I think it's a .desktop file
    if not IsWindows():
        exename = 'DeusEx'
    exedest:Path = system / (exename+'.exe')
    CopyTo(exe_source, exedest)

    intfile = GetSourcePath() / 'Configs' / 'DXRando.int'
    intdest = system / (exename+'.int')
    CopyTo(intfile, intdest)

    ini = GetSourcePath() / 'Configs' / "DXRandoDefault.ini"
    defini_dest = system / (exename+'Default.ini') # I don't think Kentie cares about this file, but Han's Launchbox does
    CopyTo(ini, defini_dest)

    if kentie:
        DeusExeU = GetSourcePath() / '3rdParty' / 'DeusExe.u'
        CopyTo(DeusExeU, system / 'DeusExe.u')
        configs_dest = GetDocumentsDir(system) / 'Deus Ex' / 'System'
        Mkdir(configs_dest.parent /'SaveDXRando', exist_ok=True, parents=True)
    else:
        configs_dest = system
        Mkdir(system.parent /'SaveDXRando', exist_ok=True, parents=True)
    DXRandoini = configs_dest / (exename+'.ini')
    Mkdir(DXRandoini.parent, parents=True, exist_ok=True)

    changes = {}
    if DXRandoini.exists():
        oldconfig = DXRandoini.read_text()
        oldconfig = Config.ReadConfig(oldconfig)
        changes = Config.RetainConfigSections(
            set(('WinDrv.WindowsClient', 'DeusEx.DXRFlags', 'DeusEx.DXRTelemetry', 'Galaxy.GalaxyAudioSubsystem', 'DeusExe')),
            oldconfig, changes
        )
    elif not Vulkan and IsWindows():
        changes['Galaxy.GalaxyAudioSubsystem'] = {'Latency': '80'}

    CopyTo(ini, DXRandoini)

    if not speedupfix:
        if 'DeusExe' not in changes:
            changes['DeusExe'] = {}
        changes['DeusExe'].update({'FPSLimit': '120'})
        if 'D3D10Drv.D3D10RenderDevice' not in changes:
            changes['D3D10Drv.D3D10RenderDevice'] = {}
        changes['D3D10Drv.D3D10RenderDevice'].update({'FPSLimit': '120', 'VSync': 'True'})
    elif exename == 'DeusEx': # ensure we don't retain bad settings from old vanilla configs since we use the same exe file name?
        if 'DeusExe' not in changes:
            changes['DeusExe'] = {}
        changes['DeusExe'].update({'FPSLimit': '0'})
        if 'D3D10Drv.D3D10RenderDevice' not in changes:
            changes['D3D10Drv.D3D10RenderDevice'] = {}
        changes['D3D10Drv.D3D10RenderDevice'].update({'FPSLimit': '0', 'VSync': 'False'})

    if IsWindows() and not Vulkan:
        changes['Engine.Engine'] = {'GameRenderDevice': 'D3D9Drv.D3D9RenderDevice'}
    elif not IsWindows():
        if OGL2:
            changes['Engine.Engine'] = {'GameRenderDevice': 'OpenGLDrv.OpenGLRenderDevice'}
        else:
            changes['Engine.Engine'] = {'GameRenderDevice': 'D3D9Drv.D3D9RenderDevice'}
        if 'WinDrv.WindowsClient' not in changes:
            changes['WinDrv.WindowsClient'] = {'StartupFullscreen': 'True'}

    if changes:
        b = defini_dest.read_bytes()
        b = Config.ModifyConfig(b, changes, additions={})
        WriteBytes(defini_dest, b)

        b = DXRandoini.read_bytes()
        b = Config.ModifyConfig(b, changes, additions={})
        WriteBytes(DXRandoini, b)

    dxrroot = gameroot / 'DXRando'
    Mkdir((dxrroot / 'Maps'), exist_ok=True, parents=True)
    Mkdir((dxrroot / 'System'), exist_ok=True, parents=True)
    CopyPackageFiles('vanilla', gameroot, ['DeusEx.u'])
    CopyD3DRenderers(system)

    FemJCu = GetSourcePath() / '3rdParty' / "FemJC.u"
    CopyTo(FemJCu, dxrroot / 'System' / 'FemJC.u')

    if settings.get('mirrors'):
        MapVariants.InstallMirrors(dxrroot / 'Maps', settings.get('downloadcallback'), 'Vanilla')


def InstallLDDP(system:Path, settings:dict):
    callback = settings.get('downloadcallback')
    tempdir = Path(tempfile.gettempdir()) / 'dxrando'
    Mkdir(tempdir, exist_ok=True)
    name = 'Lay_D_Denton_Project_1.1.zip'
    temp = tempdir / name
    if temp.exists():
        temp.unlink()

    mapsdir = system.parent / 'Maps'

    url = "https://github.com/LayDDentonProject/Lay-D-Denton-Project/releases/download/v1.1/" + name
    downloadcallback = lambda a,b,c : callback(a,b,c, status="Downloading LDDP")
    DownloadFile(url, temp, downloadcallback)

    with ZipFile(temp, 'r') as zip:
        files = list(zip.infolist())
        i=0
        for f in files:
            callback(i, 1, len(files), 'Extracting LDDP')
            i+=1
            if f.is_dir():
                continue
            name = Path(f.filename).name
            data = zip.read(f.filename)
            if name.endswith('.u'):
                dest = system / name
            elif name.endswith('.dx'):
                dest = mapsdir / name
            else:
                continue
            WriteBytes(dest, data)
            debug(Path(f.filename).name, f.file_size)

    info('done Installing LDDP to', system, '\n')
    temp.unlink()


def InstallGMDX(system:Path, settings:dict, exename:str):
    game = system.parent
    (changes, additions) = GetConfChanges('GMDX')
    Mkdir(game/'SaveGMDXRando', exist_ok=True)
    # GMDX uses absolute path shortcuts with ini files in their arguments, so it's not as simple to copy their exe

    confpath = GetDocumentsDir(system) / 'Deus Ex' / exename / 'System' / 'gmdx.ini'
    if confpath.exists():
        b = confpath.read_bytes()
        b = Config.ModifyConfig(b, changes, additions)
        WriteBytes(confpath, b)

    confpath = game / exename / 'System' / 'gmdx.ini'
    if confpath.exists():
        b = confpath.read_bytes()
        b = Config.ModifyConfig(b, changes, additions)
        WriteBytes(confpath, b)

    CopyPackageFiles('GMDX', game, ['GMDXRandomizer.u'])


def InstallRevision(system:Path, settings:dict):
    # Revision's exe is special and calls back to Steam which calls the regular Revision.exe file, so we pass in_place=True
    revsystem = system.parent / 'Revision' / 'System'
    CreateModConfigs(revsystem, settings, 'Rev', 'Revision', in_place=True)


def InstallHX(system:Path, settings:dict):
    CopyPackageFiles('HX', system.parent, ['HXRandomizer.u'])
    (changes, additions) = GetConfChanges('HX')
    Mkdir(system.parent/'SaveHXRando', exist_ok=True)
    ChangeModConfigs(system, settings, 'HX', 'HX', 'HX', changes, additions, True)
    int_source = GetPackagesPath('HX') / 'HXRandomizer.int'
    int_dest = system / 'HXRandomizer.int'
    CopyTo(int_source, int_dest)


def CreateModConfigs(system:Path, settings:dict, modname:str, exename:str, in_place:bool=False):
    exepath = system / (exename+'.exe')
    newexename = modname+'Randomizer'
    newexepath = system / (newexename+'.exe')
    modpath = system.parent / (modname+'Randomizer')
    mapspath = modpath / 'Maps'
    Mkdir(mapspath, exist_ok=True, parents=True)
    if not IsWindows():
        in_place = True
    if not in_place:
        CopyTo(exepath, newexepath)

    intfile = GetSourcePath() / 'Configs' / 'DXRando.int'
    intdest = system / (newexename+'.int')
    CopyTo(intfile, intdest)

    CopyPackageFiles(modname, system.parent, [modname+'Randomizer.u'])

    (changes, additions) = GetConfChanges(modname)
    Mkdir(system.parent/('Save'+modname+'Rando'), exist_ok=True)
    ChangeModConfigs(system, settings, modname, exename, newexename, changes, additions, in_place)

    if settings.get('mirrors'):
        MapVariants.InstallMirrors(mapspath, settings.get('downloadcallback'), modname)


def ChangeModConfigs(system:Path, settings:dict, modname:str, exename:str, newexename:str, changes:dict, additions:dict, in_place:bool=False):
    # inis
    info('ChangeModConfigs', system, modname, exename, newexename, in_place)
    confpath = system / (exename + 'Default.ini')
    b = confpath.read_bytes()
    b = Config.ModifyConfig(b, changes, additions)
    if in_place:
        newexename = exename
    outconf = system / (newexename + 'Default.ini')
    WriteBytes(outconf, b)

    confpath = system / (exename + '.ini')
    if confpath.exists():
        b = confpath.read_bytes()
        b = Config.ModifyConfig(b, changes, additions)
        outconf = system / (newexename + '.ini')
        if in_place:
            outconf = confpath
        WriteBytes(outconf, b)

    # User inis
    if in_place:
        return
    confpath = system / (exename + 'DefUser.ini')
    b = confpath.read_bytes()
    b = Config.ModifyConfig(b, changes, additions)
    outconf = system / (newexename + 'DefUser.ini')
    if in_place:
        outconf = confpath
    WriteBytes(outconf, b)

    confpath = system / (exename + 'User.ini')
    if confpath.exists():
        b = confpath.read_bytes()
        b = Config.ModifyConfig(b, changes, additions)
        outconf = system / (newexename + 'User.ini')
        if in_place:
            outconf = confpath
        WriteBytes(outconf, b)
