from Install import *
try:
    import os
    import tempfile
    from zipfile import ZipFile
    from Install import _DetectFlavors
    from Install import MapVariants
    from Install import Config
    from GUI.SaveMigration import SaveMigration
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

    globalsettings = dict(speedupfix=True, dxvk=dxvk_default, deus_nsf_d3d10_lighting=False, deus_nsf_d3d10_retro_textures=False, ogl2=dxvk_default)

    ret = Install(p, settings, globalsettings)


def DetectFlavors(exe:Path) -> list:
    assert exe.exists(), str(exe)
    assert exe.name.lower() == 'deusex.exe'
    system:Path = exe.parent
    assert system.name.lower() == 'system'

    return _DetectFlavors(system)


def Install(exe:Path, flavors:dict, globalsettings:dict) -> dict:
    assert exe.exists(), str(exe)
    assert exe.name.lower() == 'deusex.exe'
    system:Path = exe.parent
    assert system.name.lower() == 'system'

    info('Installing flavors:', flavors, globalsettings, exe)

    for(f, settings) in flavors.items():
        ret={}
        if not settings.get('install') and f != 'Vanilla':
            # vanilla handles its own skipping logic
            info('skipping installation of', f)
            continue

        if 'Vanilla'==f:
            ret = InstallVanilla(system, settings, globalsettings)
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

    if globalsettings['speedupfix']:
        EngineDllFix(system)

    CopyDXVK(system, globalsettings['dxvk'])
    CopyD3DRenderers(system, globalsettings['deus_nsf_d3d10_lighting'], globalsettings['d3d10_textures'])
    InstallOGL2(system, globalsettings['ogl2'])

    debug("Install returning", flavors)

    return flavors


def InstallVanilla(system:Path, settings:dict, globalsettings:dict):
    gameroot = system.parent

    if not settings.get('install') and not settings.get('LDDP') and not settings.get('FixVanilla'):
        return

    if settings.get('LDDP'):
        InstallLDDP(system, settings)

    # always install FemJCu because it doesn't hurt to have
    FemJCu = GetSourcePath() / '3rdParty' / "FemJC.u"
    CopyTo(FemJCu, system / 'FemJC.u')

    exe_source = GetSourcePath() / '3rdParty' / "KentieDeusExe.exe"
    exetype = settings.get('exetype')
    kentie = True
    if exetype == 'Launch':
        exe_source = GetSourcePath() / '3rdParty' / "Launch.exe"
        kentie = False

    exename = 'DXRando'
    # or should we not create a separate DXRando.exe file? Linux defaults to DeusEx.exe because of Steam
    if settings.get('install') and not settings.get('DXRando.exe', IsWindows()):
        exename = 'DeusEx'

    # also fix vanilla stuff
    if exename != 'DeusEx' and settings.get('FixVanilla'):
        exedest:Path = system / 'DeusEx.exe'
        CopyTo(exe_source, exedest)
        ini = GetSourcePath() / 'Configs' / "DeusExDefault.ini"
        VanillaFixConfigs(system=system, exename='DeusEx', kentie=kentie,
                          globalsettings=globalsettings, sourceINI=ini)
    else:
        info('skipping fixing of vanilla')

    if kentie: # kentie needs this, copy it into the regular System folder, doesn't hurt if you don't need it
        deusexeu = GetSourcePath() / '3rdParty' / "DeusExe.u"
        CopyTo(deusexeu, system / 'DeusExe.u')

    if not settings.get('install'):
        info('skipping installation of vanilla DXRando')
        return

    exedest:Path = system / (exename+'.exe')
    CopyTo(exe_source, exedest)

    intfile = GetSourcePath() / 'Configs' / 'DXRando.int'
    intdest = system / (exename+'.int')
    CopyTo(intfile, intdest)

    ini = GetSourcePath() / 'Configs' / "DXRandoDefault.ini"
    VanillaFixConfigs(system=system, exename=exename, kentie=kentie,
                      globalsettings=globalsettings, sourceINI=ini, ZeroRando=settings.get('ZeroRando', False))

    dxrroot = gameroot / 'DXRando'
    Mkdir((dxrroot / 'Maps'), exist_ok=True, parents=True)
    Mkdir((dxrroot / 'System'), exist_ok=True, parents=True)
    CopyPackageFiles('vanilla', gameroot, ['DeusEx.u'])

    if settings.get('mirrors'):
        MapVariants.InstallMirrors(dxrroot / 'Maps', settings.get('downloadcallback'), 'Vanilla')


def GetSaveAndConfigPaths(system: Path, dxdocs: Path, kentie:bool, SaveDXRando:bool):
    if kentie:
        configs_dest = dxdocs / 'System'
        if SaveDXRando:
            savepath = dxdocs /'SaveDXRando'
        else:
            savepath = dxdocs /'Save'
    else:
        configs_dest = system
        if SaveDXRando:
            savepath = system.parent /'SaveDXRando'
        else:
            savepath = system.parent /'Save'
    return (savepath, configs_dest)


def VanillaFixConfigs(system, exename, kentie, globalsettings:dict, sourceINI: Path, ZeroRando=False):
    c = Config.Config(sourceINI.read_bytes())
    SaveDXRando = ('..\SaveDXRando' == c.get('Core.System', 'SavePath'))

    dxdocs = GetDocumentsDir(system)/'Deus Ex'
    (savepath, configs_dest) = GetSaveAndConfigPaths(system, dxdocs, kentie, SaveDXRando)
    (othersavepath, other_configs_dest) = GetSaveAndConfigPaths(system, dxdocs, not kentie, SaveDXRando)
    Mkdir(savepath, exist_ok=True, parents=True)
    if othersavepath.exists():
        SaveMigration(othersavepath, savepath)

    changes = {}

    if not globalsettings['dxvk'] and IsWindows():
        changes['Galaxy.GalaxyAudioSubsystem'] = {'Latency': '80'}

    if 'D3D10Drv.D3D10RenderDevice' not in changes:
        changes['D3D10Drv.D3D10RenderDevice'] = {}
    if not globalsettings['speedupfix']:
        if 'DeusExe' not in changes:
            changes['DeusExe'] = {}
        changes['DeusExe'].update({'FPSLimit': '120'})
        changes['D3D10Drv.D3D10RenderDevice'].update({'FPSLimit': '120', 'VSync': 'True'})
    elif exename == 'DeusEx': # ensure we don't retain bad settings from old vanilla configs since we use the same exe file name?
        if 'DeusExe' not in changes:
            changes['DeusExe'] = {}
        changes['DeusExe'].update({'FPSLimit': '0'})
        changes['D3D10Drv.D3D10RenderDevice'].update({'FPSLimit': '0', 'VSync': 'False'})

    if globalsettings['deus_nsf_d3d10_lighting']:
        changes['D3D10Drv.D3D10RenderDevice'].update({'ClassicLighting': 'False'})
    else:
        changes['D3D10Drv.D3D10RenderDevice'].update({'ClassicLighting': 'True'})

    info('ZeroRando:', ZeroRando, exename)
    # if doing an in-place installation like on Linux, we use DeusEx.ini for most things, but this will still be in DXRando.ini
    if ZeroRando and exename == 'DeusEx':
        ZeroRandoIni: Path = configs_dest / ('DXRando.ini')
        if ZeroRandoIni.exists():
            oldconfig = ZeroRandoIni.read_bytes()
            c = Config.Config(oldconfig)
        else:
            c = Config.Config(b'')
        c.ModifyConfig(changes={'DeusEx.DXRFlags': {'gamemode': '4'}}, additions={})
        c.WriteFile(ZeroRandoIni)
    elif ZeroRando:
        if 'DeusEx.DXRFlags' not in changes:
            changes['DeusEx.DXRFlags'] = {}
        changes['DeusEx.DXRFlags'].update({'gamemode': '4'})

    if globalsettings['deus_nsf_d3d10_lighting'] or globalsettings['d3d10_textures'] != 'Smooth':
        # keep D3D10 because obviously they wanted it
        changes['Engine.Engine'] = {'GameRenderDevice': 'D3D10Drv.D3D10RenderDevice'}
    elif IsWindows() and not globalsettings['dxvk']:
        changes['Engine.Engine'] = {'GameRenderDevice': 'D3D9Drv.D3D9RenderDevice'}
    elif not IsWindows():
        if globalsettings['ogl2']:
            changes['Engine.Engine'] = {'GameRenderDevice': 'OpenGLDrv.OpenGLRenderDevice'}
        else:
            changes['Engine.Engine'] = {'GameRenderDevice': 'D3D9Drv.D3D9RenderDevice'}
        if 'WinDrv.WindowsClient' not in changes:
            changes['WinDrv.WindowsClient'] = {'StartupFullscreen': 'True'}

    # write default config
    if changes:
        defini_dest:Path = system / (exename+'Default.ini') # I don't think Kentie cares about this file, but Han's Launchbox does
        info('\n\n\n\n', defini_dest)
        b = sourceINI.read_bytes()
        c = Config.Config(b)
        c.ModifyConfig(changes, additions={})
        c.WriteFile(defini_dest)

    # write non default config
    DXRandoini: Path = configs_dest / (exename+'.ini')
    Mkdir(DXRandoini.parent, parents=True, exist_ok=True)
    if DXRandoini.exists():
        oldconfig = DXRandoini.read_bytes()
        c = Config.Config(oldconfig)
        changes = c.RetainConfigSections(
            set(('WinDrv.WindowsClient', 'Galaxy.GalaxyAudioSubsystem', 'DeusExe',
                 'DeusEx.DXRando', 'DeusEx.DXRFlags', 'DeusEx.DXRTelemetry', 'DeusEx.DXRMenuScreenNewGame')),
            changes
        )
    if changes:
        c = Config.Config(b)
        c.ModifyConfig(changes, additions={})
        c.WriteFile(DXRandoini)

    Config.BackupSplits(configs_dest/'DXRSplits.ini')


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
        c = Config.Config(b)
        c.ModifyConfig(changes, additions)
        c.WriteFile(confpath)

    confpath = game / exename / 'System' / 'gmdx.ini'
    if confpath.exists():
        b = confpath.read_bytes()
        c = Config.Config(b)
        c.ModifyConfig(changes, additions)
        c.WriteFile(confpath)

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
    c = Config.Config(b)
    c.ModifyConfig(changes, additions)
    if in_place:
        newexename = exename
    outconf = system / (newexename + 'Default.ini')
    c.WriteFile(outconf)

    confpath = system / (exename + '.ini')
    if confpath.exists():
        b = confpath.read_bytes()
        c = Config.Config(b)
        c.ModifyConfig(changes, additions)
        outconf = system / (newexename + '.ini')
        if in_place:
            outconf = confpath
        c.WriteFile(outconf)

    # User inis
    if in_place:
        return
    confpath = system / (exename + 'DefUser.ini')
    b = confpath.read_bytes()
    c = Config.Config(b)
    c.ModifyConfig(changes, additions)
    outconf = system / (newexename + 'DefUser.ini')
    if in_place:
        outconf = confpath
    c.WriteFile(outconf)

    confpath = system / (exename + 'User.ini')
    if confpath.exists():
        b = confpath.read_bytes()
        c = Config.Config(b)
        c.ModifyConfig(changes, additions)
        outconf = system / (newexename + 'User.ini')
        if in_place:
            outconf = confpath
        c.WriteFile(outconf)
