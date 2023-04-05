class DXRTriggerEnable extends Triggers;

// ----------------------------------------------------------------------
// Trigger()
// ----------------------------------------------------------------------

singular function Trigger(Actor Other, Pawn Instigator)
{
    local Actor a;
    foreach AllActors(class'Actor', a, Event) {
        //a.SetCollision(a.bCollideActors, a.bBlockActors, a.bBlockPlayers);
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
    //owner.SetCollision(false, a.bBlockActors, a.bBlockPlayers);
    t.Event = Event;
    //a.Tag = Event;

    foreach t.AllActors(class'Actor', a, Event) {
        a.SetCollision(false, a.bBlockActors, a.bBlockPlayers);
    }
    return t;
}

defaultproperties
{
    bCollideActors=False
}
