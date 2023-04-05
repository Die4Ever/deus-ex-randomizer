class DXRNetworkTerminalPersonal extends NetworkTerminalPersonal;

function ShowScreen(Class<ComputerUIWindow> newScreen)
{
    newScreen = class'DXRNetworkTerminal'.static.ShowScreen(newScreen);
    Super.ShowScreen(newScreen);
}

event InitWindow()
{
    Super.InitWindow();
    class'DXRNetworkTerminal'.static.InitWindow(self);
}
