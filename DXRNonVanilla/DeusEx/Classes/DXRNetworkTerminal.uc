class DXRNetworkTerminal extends DXRInfo abstract;

static function Class<ComputerUIWindow> ShowScreen(Class<ComputerUIWindow> newScreen)
{
    switch(newScreen) {
        case class'ComputerScreenEmail':
            newScreen = class'DXRComputerScreenEmail';
            break;
        case class'ComputerScreenBulletins':
            newScreen = class'DXRComputerScreenBulletins';
            break;
        case class'ComputerScreenSpecialOptions':
            newScreen = class'DXRComputerScreenSpecialOptions';
            break;
    }
    return newScreen;
}
