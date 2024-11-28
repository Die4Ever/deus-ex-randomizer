class DXRSetFrobbableTrigger extends Trigger;

var name moverTag;
var bool value;

static function DXRSetFrobbableTrigger Create(Actor a, name moverTag, name tag, bool value)
{
    local DXRSetFrobbableTrigger sft;

    sft = a.Spawn(class'DXRSetFrobbableTrigger',, tag);
    sft.moverTag = moverTag;
    sft.value = value;
    sft.SetCollision(false, false, false);

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
