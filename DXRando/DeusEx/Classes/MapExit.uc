class DXRMapExit injects MapExit;

var name destName;

function SetDestination(string destURL, name dest_actor_name, optional string tag)
{
    DestMap = destURL $ "#" $ tag;
    destName = dest_actor_name;
}

function Touch(Actor Other)
{
    if( DeusExPlayer(Other) == None )
        return;// the player isn't the one touching us!
    
    Super.Touch(Other);
}

function LoadMap(Actor Other)
{
    Player = DeusExPlayer(GetPlayerPawn());
    if( Player != None && destName != '' ) {
        class'DynamicTeleporter'.static.SetDestName(Player, destName);
    }
    Super.LoadMap(Other);
}

defaultproperties
{
    bStatic=false
}
