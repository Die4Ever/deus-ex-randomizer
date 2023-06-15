class DXRandoRootWindow merges DeusExRootWindow;
// merges because DeusExRootWindow depends on int entries

function bool GetNoPause(bool bNoPause) {
    local DXRFlags flags;

    foreach parentPawn.AllActors(class'DXRFlags', flags) {
        if(flags.settings.menus_pause == 0)
            bNoPause = true;
    }

    return bNoPause;
}

function DeusExBaseWindow PopWindow(optional Bool bNoUnpause)
{
    local float f;
    local DeusExMover m;
    local HackableDevices h;
    local SkilledTool tool;
    local bool bFixGlitches;

    bFixGlitches = bool(parentPawn.ConsoleCommand("get #var(package).MenuChoice_FixGlitches enabled"));

    // check for super jumps
    f = DeusExPlayer(parentPawn).AugmentationSystem.GetAugLevelValue(class'AugSpeed');
    if(bFixGlitches && f > 0 && parentPawn.JumpZ > parentPawn.default.JumpZ * f) {
        parentPawn.JumpZ = parentPawn.default.JumpZ * f;
    }
    else if(f > 0 && parentPawn.JumpZ > parentPawn.default.JumpZ * f*1.3) {
        class'DXRStats'.static.AddCheatOffense(DeusExPlayer(parentPawn));
    }

    if(bFixGlitches && !bNoUnPause) {
        foreach parentPawn.AllActors(class'DeusExMover', m) {
            if(!m.bPicking) continue;
            m.LastTickTime = m.Level.TimeSeconds;
        }
        foreach parentPawn.AllActors(class'HackableDevices', h) {
            if(!h.bHacking) continue;
            h.LastTickTime = h.Level.TimeSeconds;
        }
    }
    else if(!bFixGlitches && !bNoUnPause) {
        // check for using tools during paused menus, the issue is in DeusExMover::Timer and HackableDevices::Timer
        foreach parentPawn.AllActors(class'SkilledTool', tool) {
            if(!tool.IsInState('UseIt')) continue;
            if(NanoKeyRing(tool) != None) continue;
            class'DXRStats'.static.AddCheatOffense(DeusExPlayer(parentPawn));
            break;
        }
    }

    _PopWindow(bNoUnpause);
}

function DeusExBaseWindow InvokeMenuScreen(Class<DeusExBaseWindow> newScreen, optional bool bNoPause)
{
    log("DXRandoRootWindow InvokeMenuScreen "$newScreen);
    return _InvokeMenuScreen(newScreen, GetNoPause(bNoPause));
}

function InvokeMenu(Class<DeusExBaseWindow> newMenu)
{
    log("DXRandoRootWindow InvokeMenu "$newMenu);
    _InvokeMenu(newMenu);
}

function DeusExBaseWindow InvokeUIScreen(Class<DeusExBaseWindow> newScreen, optional Bool bNoPause)
{
    log("DXRandoRootWindow InvokeUIScreen "$newScreen);
    return _InvokeUIScreen(newScreen, GetNoPause(bNoPause));
}
