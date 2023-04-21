class DXRandoRootWindow merges DeusExRootWindow;
// merges because DeusExRootWindow depends on int entries

function bool GetNoPause(bool bNoPause) {
    local DXRFlags flags;
    local SkilledTool tool;
    local bool ret;

    ret = bNoPause;

    foreach parentPawn.AllActors(class'DXRFlags', flags) {
        if(flags.settings.menus_pause == 0)
            ret = true;
    }

    if(!ret) {
        // check for using tools during paused menus
        foreach parentPawn.AllActors(class'SkilledTool', tool) {
            if(!tool.IsInState('UseIt')) continue;
            if(NanoKeyRing(tool) != None) continue;
            DeusExPlayer(parentPawn).ClientMessage("TOOL PAUSE GLITCH DETECTED!");
            class'DXRStats'.static.AddCheatOffense(DeusExPlayer(parentPawn));
            break;
        }
    }

    return ret;
}

function DeusExBaseWindow PopWindow(optional Bool bNoUnpause)
{
    local float f;

    // check for super jumps
    f = DeusExPlayer(parentPawn).AugmentationSystem.GetAugLevelValue(class'AugSpeed');
    f *= 1.3;// some leniency
    if(f > 0 && parentPawn.JumpZ > parentPawn.default.JumpZ * f) {
        DeusExPlayer(parentPawn).ClientMessage("SUPER JUMP GLITCH DETECTED!");
        class'DXRStats'.static.AddCheatOffense(DeusExPlayer(parentPawn));
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
