#ifdef revision
class DXRandoRootWindow extends RevRootWindow;
#else
class DXRandoRootWindow extends DeusExRootWindow;
#endif

event InitWindow()
{
    Super.InitWindow();

    hud.Destroy();
    hud = DeusExHUD(NewChild(Class'DXRandoHUD'));
    hud.UpdateSettings(DeusExPlayer(parentPawn));
    hud.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
}

function bool GetNoPause(bool bNoPause) {
    local DXRFlags flags;
    local SkilledTool tool;
    local bool ret;

    ret = bNoPause;

    foreach parentPawn.AllActors(class'DXRFlags', flags) {
        if(flags.settings.menus_pause == 0)
            ret = true;
    }

    if(!ret && #defined(gmdx)) {
        // check for using tools during paused menus
        foreach parentPawn.AllActors(class'SkilledTool', tool) {
            if(!tool.IsInState('UseIt')) continue;
            if(NanoKeyRing(tool) != None) continue;
            DeusExPlayer(parentPawn).ClientMessage("TOOL PAUSE GLITCH DETECTED!");
            class'DXRStats'.static.AddGlitchOffense(DeusExPlayer(parentPawn));
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
        class'DXRStats'.static.AddGlitchOffense(DeusExPlayer(parentPawn));
    }

    Super.PopWindow(bNoUnpause);
}

function DeusExBaseWindow InvokeMenuScreen(Class<DeusExBaseWindow> newScreen, optional bool bNoPause)
{
    log("DXRandoRootWindow InvokeMenuScreen "$newScreen);
    switch(newScreen) {
#ifdef vmd
        case class'VMDMenuSelectAppearance':
            newScreen = class'DXRVMDMenuSelectAppearance';
            break;

        case class'VMDMenuSelectSkills':
            newScreen = class'DXRVMDMenuSelectSkills';
            break;
#else
        case class'MenuScreenNewGame':
            newScreen = class'DXRMenuScreenNewGame';
            break;

        case class'MenuSelectDifficulty':
            newScreen = class'DXRMenuSelectDifficulty';
            break;
#endif

        case class'CreditsWindow':
            newScreen = class'NewGamePlusCreditsWindow';
            break;
    }
    return Super.InvokeMenuScreen(newScreen, GetNoPause(bNoPause));
}

function InvokeMenu(Class<DeusExBaseWindow> newMenu)
{
    log("DXRandoRootWindow InvokeMenu "$newMenu);
    switch(newMenu) {
        case class'MenuMain':
            newMenu = class'DXRMenuMain';
            break;

#ifdef vmd
        // VMD 1.56 or any version
        case class'MenuSelectDifficulty':
            newMenu = class'VMDR156MenuSelectDifficulty';
            break;

        case class'MenuMainInGame':
            newMenu = class'DXRMenuMainInGame';
            break;
#endif
#ifdef vmd175
        // VMD 1.75
        case class'VMDMenuSelectCustomDifficulty':
            newMenu = class'VMDR175MenuSelectDifficulty';
            break;
#endif
    }
    Super.InvokeMenu(newMenu);
}

function DeusExBaseWindow InvokeUIScreen(Class<DeusExBaseWindow> newScreen, optional Bool bNoPause)
{
    log("DXRandoRootWindow InvokeUIScreen "$newScreen);
    switch(newScreen) {
        /*case class'ATMWindow':
            newScreen = class'DXRATMWindow';
            break;*/
        case class'NetworkTerminalATM':
            newScreen = class'DXRNetworkTerminalATM';
            break;

#ifndef vmd
        case class'HUDMedBotHealthScreen':
            newScreen = class'DXRHUDMedBotHealthScreen';
            break;
        case class'HUDRechargeWindow':
            newScreen = class'DXRHUDRechargeWindow';
            break;
#endif

        case class'HUDMedBotAddAugsScreen':
            newScreen = class'DXRHUDMedBotAddAugsScreen';
            break;

        case class'NetworkTerminalPersonal':
            newScreen = class'DXRNetworkTerminalPersonal';
            break;
        case class'NetworkTerminalPublic':
            newScreen = class'DXRNetworkTerminalPublic';
            break;
        case class'NetworkTerminalSecurity':
            newScreen = class'DXRNetworkTerminalSecurity';
            break;
        case class'PersonaScreenSkills':
            newScreen = class'DXRPersonaScreenSkills';
            break;
        case class'PersonaScreenGoals':
            newScreen = class'DXRPersonaScreenGoals';
            break;
        default:
            if(class<NetworkTerminal>(newScreen) != None) {
                log("WARNING: InvokeUIScreen "$newScreen);
            }
            break;
    }
    return Super.InvokeUIScreen(newScreen, GetNoPause(bNoPause));
}
