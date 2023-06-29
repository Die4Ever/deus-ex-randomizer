class DXRNetworkTerminal extends DXRInfo abstract;

static function bool GetNoPause(NetworkTerminal terminal) {
    local DXRFlags flags;

    foreach terminal.Player.AllActors(class'DXRFlags', flags) {
        if(flags.settings.menus_pause == 0)
            return true;
    }

    return false;
}

static function InitWindow(NetworkTerminal terminal)
{
    if(GetNoPause(terminal)) {
        terminal.SetBackgroundStyle(DSTY_Modulated);
        terminal.SetBackground(Texture'MaskTexture');
        if(terminal.Player != None)
            terminal.Player.MakePlayerIgnored(false);
    }
}

static function Class<#var(prefix)ComputerUIWindow> ShowScreen(Class<#var(prefix)ComputerUIWindow> newScreen)
{
    switch(newScreen) {
        case class'#var(prefix)ComputerScreenEmail':
            newScreen = class'DXRComputerScreenEmail';
            break;
        case class'#var(prefix)ComputerScreenBulletins':
            newScreen = class'DXRComputerScreenBulletins';
            break;
        case class'#var(prefix)ComputerScreenSpecialOptions':
            newScreen = class'DXRComputerScreenSpecialOptions';
            break;
    }
    return newScreen;
}
