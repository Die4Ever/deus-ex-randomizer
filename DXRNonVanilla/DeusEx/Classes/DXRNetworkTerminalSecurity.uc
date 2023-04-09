class DXRNetworkTerminalSecurity extends NetworkTerminalSecurity;

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
