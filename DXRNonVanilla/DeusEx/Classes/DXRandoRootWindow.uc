class DXRandoRootWindow extends DeusExRootWindow;

function DeusExBaseWindow InvokeMenuScreen(Class<DeusExBaseWindow> newScreen, optional bool bNoPause)
{
    switch(newScreen) {
#ifndef vmd
        case class'MenuScreenNewGame':
            newScreen = class'DXRMenuScreenNewGame';
            break;
#endif
        case class'MenuSelectDifficulty':
            newScreen = class'DXRMenuSelectDifficulty';
            break;

        case class'CreditsWindow':
            newScreen = class'NewGamePlusCreditsWindow';
            break;
    }
    return Super.InvokeMenuScreen(newScreen, bNoPause);
}

function InvokeMenu(Class<DeusExBaseWindow> newMenu)
{
    switch(newMenu) {
#ifndef vmd
        case class'MenuMain':
            newMenu = class'DXRMenuMain';
            break;
#endif
    }
    Super.InvokeMenu(newMenu);
}

function DeusExBaseWindow InvokeUIScreen(Class<DeusExBaseWindow> newScreen, optional Bool bNoPause)
{
    switch(newScreen) {
        /*case class'ATMWindow':
            newScreen = class'DXRATMWindow';
            break;
        case class'NetworkTerminalATM':
            newScreen = class'DXRNetworkTerminalATM';
            break;*/

        case class'HUDMedBotAddAugsScreen':
            newScreen = class'DXRHUDMedBotAddAugsScreen';
            break;
        case class'HUDMedBotHealthScreen':
            newScreen = class'DXRHUDMedBotHealthScreen';
            break;
        case class'HUDRechargeWindow':
            newScreen = class'DXRHUDRechargeWindow';
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
        default:
            if(class<NetworkTerminal>(newScreen) != None) {
                log("WARNING: InvokeUIScreen "$newScreen);
            }
            break;
    }
    return Super.InvokeUIScreen(newScreen, bNoPause);
}
