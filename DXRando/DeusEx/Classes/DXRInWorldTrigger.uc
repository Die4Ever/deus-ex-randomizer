class DXRInWorldTrigger extends Trigger;

var name pawnTag;
var bool enter;

static function DXRInWorldTrigger Create(Actor a, name pawnTag, name tag, bool enter)
{
    local DXRInWorldTrigger iwt;

    iwt = a.Spawn(class'DXRInWorldTrigger',, tag);
    iwt.pawnTag = pawnTag;
    iwt.enter = enter;
    iwt.SetCollision(false, false, false);

    return iwt;
}

function Trigger(Actor other, Pawn instigator)
{
    local ScriptedPawn pawn;

    Super.Trigger(other, instigator);
    foreach AllActors(class'ScriptedPawn', pawn, pawnTag) {
        if (enter) {
            pawn.EnterWorld();
        } else {
            pawn.LeaveWorld();
        }
    }
}
