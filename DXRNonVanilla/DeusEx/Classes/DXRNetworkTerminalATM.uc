class DXRNetworkTerminalATM extends NetworkTerminalATM;

event InitWindow()
{
    Super.InitWindow();
    class'DXRNetworkTerminal'.static.InitWindow(self);
}
