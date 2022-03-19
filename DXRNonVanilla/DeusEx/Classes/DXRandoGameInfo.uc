#ifdef revision
class DXRandoGameInfo extends RevGameInfo config;
#else
class DXRandoGameInfo extends DeusExGameInfo config;
#endif
// unused in vanilla since we just hook in DeusExLevelInfo instead
// HXRando has its own custom GameInfo

var DXRando dxr;

function DXRando GetDXR()
{
    local DeusExLevelInfo DeusExLevelInfo;

    if( dxr != None ) return dxr;
    foreach AllActors(class'DXRando', dxr) return dxr;

    foreach AllActors( Class'DeusExLevelInfo', DeusExLevelInfo )
        break;

    dxr = Spawn(class'DXRando');
    dxr.SetdxInfo(DeusExLevelInfo);
    log("GetDXR(), dxr: "$dxr, self.name);
    return dxr;
}

event InitGame( String Options, out String Error )
{
    Super.InitGame(Options, Error);

    log("InitGame DXR", self.name);
    GetDXR();
}

event PostLogin(playerpawn NewPlayer)
{
    local #var PlayerPawn  p;

    Super.PostLogin(NewPlayer);
    if( Role != ROLE_Authority ) return;

    p = #var PlayerPawn (NewPlayer);

    GetDXR();
    log("PostLogin("$NewPlayer$") server, dxr: "$dxr, self.name);
    dxr.PlayerLogin( p );
}

function bool PickupQuery( Pawn Other, Inventory item )
{
    local DXRLoadouts loadouts;
    local #var PlayerPawn  player;

    player = #var PlayerPawn (Other);
    if(player != None) {
        loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
        if( loadouts.ban(player, item) ) {
            item.Destroy();
            return false;
        }
    }

    return Super.PickupQuery(Other, item);
}

function Killed( pawn Killer, pawn Other, name damageType )
{
    Super.Killed(Killer, Other, damageType);
    class'DXREvents'.static.AddDeath(Other, Killer, damageType);
}
