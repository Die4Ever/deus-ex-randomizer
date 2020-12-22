class ScopeView injects DeusExScopeView;

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
