class DXRSetFrobbableTrigger extends Trigger;

var name moverTag;
var bool value;

static function DXRSetFrobbableTrigger Create(Actor a, name moverTag, name tag, bool value)
{
    local DXRSetFrobbableTrigger sft;

    sft = a.Spawn(class'DXRSetFrobbableTrigger',, tag);
    sft.moverTag = moverTag;
    sft.value = value;

    return sft;
}

function Trigger(Actor other, Pawn instigator)
{
    local DeusExMover mover;

    Super.Trigger(other, instigator);
    foreach AllActors(class'DeusExMover', mover, moverTag) {
        mover.bFrobbable = value;
    }
}

defaultproperties
{
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
}

