//For all those spots where you just don't want it to be possible to trigger something more than once...
//Stick one of these in the middle.
class OnceOnlyTrigger extends Trigger;

function Trigger(Actor Other, Pawn Instigator)
{
	local Actor A;

    if (Event != '')
        foreach AllActors(class 'Actor', A, Event)
            A.Trigger(Other, Instigator);

    Super.Trigger(Other, Instigator);

    Destroy();
}

defaultproperties
{
     bCollideActors=False
     bCollideWorld=False
     bTriggerOnceOnly=True
}
