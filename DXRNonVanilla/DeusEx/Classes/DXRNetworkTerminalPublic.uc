class DXRNetworkTerminalPublic extends NetworkTerminalPublic;

function ShowScreen(Class<ComputerUIWindow> newScreen)
{
    newScreen = class'DXRNetworkTerminal'.static.ShowScreen(newScreen);
    Super.ShowScreen(newScreen);
}
