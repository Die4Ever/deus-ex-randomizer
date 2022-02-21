class DXRMapExit injects MapExit;

var name destName;
var transient int used;

function SetDestination(string destURL, name dest_actor_name, optional string tag)
{
    DestMap = destURL $ "#" $ tag;
    destName = dest_actor_name;
}

function MarkUsed()
{
    used = class'DXRInfo'.static._SystemTime(Level);
}

function bool bUsed()
{
    return (class'DXRInfo'.static._SystemTime(Level) - used) <3;
}

function Touch(Actor Other)
{
    if( DeusExPlayer(Other) == None )
        return;// the player isn't the one touching us!

    Super.Touch(Other);
}

function LoadMap(Actor Other)
{
    if(bUsed()) {
        return;
    }
    Player = DeusExPlayer(GetPlayerPawn());
    if( Player != None && destName != '' ) {
        class'DynamicTeleporter'.static.SetDestName(Player, destName);
    }
    if( Player != None )
        MarkUsed();
    Super.LoadMap(Other);
}

defaultproperties
{
    bStatic=false
}
