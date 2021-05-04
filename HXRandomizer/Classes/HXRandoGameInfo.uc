class HXRandoGameInfo extends HXGameInfo;

var DXRando dxr;

replication
{
    reliable if( Role==ROLE_Authority )
        dxr;
}

event InitGame( String Options, out String Error )
{
    Super.InitGame(Options, Error);

    log("InitGame", self.name);
    if( DeusExLevelInfo == None ) return;
    foreach AllActors(class'DXRando', dxr) return;
    
    dxr = Spawn(class'DXRando');
    dxr.SetdxInfo(DeusExLevelInfo);
    log("InitGame, dxr: "$dxr, self.name);
}

event PostLogin(playerpawn NewPlayer)
{
    Super.PostLogin(NewPlayer);
    if( Role != ROLE_Authority ) return;

    foreach AllActors(class'DXRando', dxr) break;
    log("PostLogin("$NewPlayer$") server, dxr: "$dxr, self.name);
    dxr.Login(NewPlayer);
}
