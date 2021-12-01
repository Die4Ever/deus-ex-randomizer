class RevRandoRootWindow extends RevRootWindow;

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
            newMenu = class'RevRandoMenuMain';
            break;
    }
    Super.InvokeMenu(newMenu);
}
