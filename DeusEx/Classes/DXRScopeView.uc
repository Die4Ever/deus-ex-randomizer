class DXRScopeView extends DeusExScopeView;

event InitWindowWithPlayer(DeusExPlayer p)
{
    Super.InitWindow();
    player = p;
    StyleChanged();
}

event DrawWindow(GC gc)
{
    local bool was_standalone;
    if ( Player.Level.NetMode == NM_Standalone ) {
        was_standalone = true;
        Player.Level.NetMode = NM_Client;
    }
    bBinocs = false;
    Super.DrawWindow(gc);
    if ( was_standalone )
        Player.Level.NetMode = NM_Standalone;
}

event StyleChanged()
{
    //prevent Accessed None warnings
    if ( player == None ) return;
    Super.StyleChanged();
}
