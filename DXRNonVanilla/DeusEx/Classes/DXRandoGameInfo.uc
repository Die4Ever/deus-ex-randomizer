#ifdef revision
class DXRandoGameInfo extends RevGameInfo config;
#else
class DXRandoGameInfo extends DeusExGameInfo config;
#endif
// unused in vanilla since we just hook in DeusExLevelInfo instead
// HXRando has its own custom GameInfo

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
