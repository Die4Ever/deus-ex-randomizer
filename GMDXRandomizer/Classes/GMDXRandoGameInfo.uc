class GMDXRandoGameInfo extends DeusExGameInfo config;

var DXRando dxr;

event InitGame( String Options, out String Error )
{
    local DeusExLevelInfo DeusExLevelInfo;
    Super.InitGame(Options, Error);

    log("InitGame DXR", self.name);
    foreach AllActors( Class'DeusExLevelInfo', DeusExLevelInfo )
        break;
    if( DeusExLevelInfo == None ) return;
    if( dxr != None ) return;
    foreach AllActors(class'DXRando', dxr) return;
    
    dxr = Spawn(class'DXRando');
    dxr.SetdxInfo(DeusExLevelInfo);
    log("InitGame, dxr: "$dxr, self.name);
}
