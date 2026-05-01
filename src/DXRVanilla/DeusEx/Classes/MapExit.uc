class DXRMapExit injects MapExit;

var name destName;
var travel float used;

function SetDestination(string destURL, name dest_actor_name, optional string tag)
{
    DestMap = destURL $ "#" $ tag;
    destName = dest_actor_name;
}

function MarkUsed()
{
    used = Level.TimeSeconds;
}

function bool bUsed()
{
    return (Level.TimeSeconds - used) <3;
}

function Touch(Actor Other)
{
    log(self$".Touch("$Other$")");
    if (Level.LevelAction == LEVACT_Loading){
        log(self$".Touch("$Other$") during LevelAction "$Level.LevelAction$", ignoring");
        return; //you aren't actually playing, maybe randomization is still happening?
    }
    if( class'MenuChoice_FixGlitches'.default.enabled && DeusExPlayer(Other) == None )
        return;// the player isn't the one touching us!

    Super.Touch(Other);
}

function Trigger(Actor Other, Pawn Instigator)
{
    log(self$".Trigger("$Other$", "$Instigator$")");
	Super.Trigger(Other, Instigator);
}

function LoadMap(Actor Other)
{
    // HACKS
    log(self$".LoadMap("$Other$")");
    if(bUsed()) {
        log(self$".LoadMap, bUsed");
        return;
    }
    Player = DeusExPlayer(GetPlayerPawn());
    if( Player != None && destName != '' ) {
        class'DynamicTeleporter'.static.SetDestName(Player, destName);
    }
    if( Player != None ) {
        Player.FrobTarget = None;
        MarkUsed();
    }
    Super.LoadMap(Other);
}

defaultproperties
{
    used=-999
}
