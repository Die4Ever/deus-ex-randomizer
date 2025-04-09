class DestroyTrigger extends Trigger;

function Trigger(Actor Other, Pawn Instigator)
{
    local Actor a;

    Super.Trigger(Other, Instigator);

    foreach AllActors(class'Actor', a, Event) {
        a.Destroy();
    }
}
