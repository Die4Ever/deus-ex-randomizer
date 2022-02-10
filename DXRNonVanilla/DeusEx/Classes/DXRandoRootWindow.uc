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
    if(class<NetworkTerminal>(newScreen) != None) {
        log("InvokeUIScreen "$newScreen);
        /*
        class ATMWindow extends NetworkTerminalATM;
        class NetworkTerminalATM extends NetworkTerminal;
        class NetworkTerminalPersonal extends NetworkTerminal;
        class NetworkTerminalPublic extends NetworkTerminal;
        class NetworkTerminalSecurity extends NetworkTerminal;
        */
    }
    switch(newScreen) {
        case class'NetworkTerminal':
            newScreen = class'NetworkTerminal';
            break;
    }
    return Super.InvokeUIScreen(newScreen, bNoPause);
}
