class SpawnItemTrigger extends #var(prefix)Trigger;

var() class<Actor> spawnClass;
var() vector       spawnLoc;
var() rotator      spawnRot;

function Trigger(Actor Other, Pawn Instigator)
{
    local Actor a;

    Super.Trigger(Other, Instigator);

    a = Spawn(spawnClass,,,spawnLoc,spawnRot);

    log(self @ "spawned" @ a);
}

defaultproperties
{
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
}
