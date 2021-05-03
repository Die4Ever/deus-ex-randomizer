class HXRandoGameInfo extends HXGameInfo;

event InitGame( String Options, out String Error )
{
    local DXRando dxr;

    Super.InitGame(Options, Error);

    if( DeusExLevelInfo == None ) return;
    foreach AllActors(class'DXRando', dxr) return;
    
    dxr = Spawn(class'DXRando');
    dxr.SetdxInfo(DeusExLevelInfo);
}
