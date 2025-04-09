class DXRSimpleTrigger extends Triggers;

var bool bTriggerOnceOnly;

event Trigger( Actor Other, Pawn EventInstigator )
{
    local Actor A;
    if (Event != '')
        foreach AllActors(class 'Actor', A, Event)
            A.Trigger(Self, EventInstigator);

    if(bTriggerOnceOnly) Destroy();
}

defaultproperties
{
    bTriggerOnceOnly=true
}
