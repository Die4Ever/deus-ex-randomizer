class DXRNetworkTerminal extends DXRInfo;

static function Class<ComputerUIWindow> ShowScreen(Class<ComputerUIWindow> newScreen)
{
    switch(newScreen) {
        case class'ComputerScreenEmail':
            newScreen = class'DXRComputerScreenEmail';
            break;
        case class'ComputerScreenBulletins':
            newScreen = class'DXRComputerScreenBulletins';
            break;
    }
    return newScreen;
}
