class GMDXRandoRootWindow extends DeusExRootWindow;

function DeusExBaseWindow InvokeMenuScreen(Class<DeusExBaseWindow> newScreen, optional bool bNoPause)
{
    switch(newScreen) {
        case class'MenuScreenNewGame':
            newScreen = class'DXRMenuScreenNewGame';
            break;
        case class'MenuSelectDifficulty':
            newScreen = class'DXRMenuSelectDifficulty';
            break;
    }
    return Super.InvokeMenuScreen(newScreen, bNoPause);
}

function InvokeMenu(Class<DeusExBaseWindow> newMenu)
{
    switch(newMenu) {
        case class'MenuMain':
            newMenu = class'GMDXRMenuMain';
            break;
    }
    Super.InvokeMenu(newMenu);
}
