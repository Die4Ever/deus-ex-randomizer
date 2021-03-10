class MissionScript injects MissionScript transient abstract;

function Timer()
{
    // ensure DXRFlags can load flags before we start
    local DXRando dxr;
    foreach AllActors(class'DXRando', dxr) { break; }
    if( dxr == None ) return;
    if( dxr.Player == None ) dxr.Init();
    if( dxr.Player == None ) return;

    Super.Timer();
}
