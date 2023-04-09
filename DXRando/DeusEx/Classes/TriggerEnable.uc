class DXRTriggerEnable extends Triggers;

// ----------------------------------------------------------------------
// Trigger()
// ----------------------------------------------------------------------

singular function Trigger(Actor Other, Pawn Instigator)
{
    local Actor a;
    foreach AllActors(class'Actor', a, Event) {
        a.SetCollision(true, a.bBlockActors, a.bBlockPlayers);
    }
}

// ----------------------------------------------------------------------
// Touch()
// ----------------------------------------------------------------------

singular function Touch(Actor Other)
{
    // do nothing
}

static function DXRTriggerEnable Create(Actor a, Name tag, Name Event)
{
    local DXRTriggerEnable t;

    t = a.Spawn(class'DXRTriggerEnable', None, tag, a.Location, a.Rotation );
    t.Event = Event;

    foreach t.AllActors(class'Actor', a, Event) {
        a.SetCollision(false, a.bBlockActors, a.bBlockPlayers);
    }
    return t;
}

defaultproperties
{
    bCollideActors=False
}
