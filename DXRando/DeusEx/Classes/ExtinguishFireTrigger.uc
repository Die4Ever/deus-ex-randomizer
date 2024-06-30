class ExtinguishFireTrigger extends Trigger;

function Touch(Actor other)
{
    Super.Touch(other);

    if (Pawn(other) != None && Pawn(other).bOnFire) {
        if (DeusExPlayer(other) != None) {
            DeusExPlayer(other).ExtinguishFire();
        }
        if (ScriptedPawn(other) != None) {
            ScriptedPawn(other).ExtinguishFire();
        }
        return;
    }
    if (DeusExDecoration(other) != None) {
        DeusExDecoration(other).ExtinguishFire();
        return;
    }
}

defaultproperties
{
    bTriggerOnceOnly=false
}
