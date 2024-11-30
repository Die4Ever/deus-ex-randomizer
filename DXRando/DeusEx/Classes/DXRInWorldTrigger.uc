class DXRInWorldTrigger extends Trigger;

var name targetTag;
var bool enter;

static function DXRInWorldTrigger Create(Actor a, name targetTag, name tag, bool enter)
{
    local DXRInWorldTrigger iwt;

    iwt = a.Spawn(class'DXRInWorldTrigger',, tag);
    iwt.targetTag = targetTag;
    iwt.enter = enter;

    return iwt;
}

function Trigger(Actor other, Pawn instigator)
{
    local Actor a;

    Super.Trigger(other, instigator);
    
    foreach AllActors(class'Actor', a, targetTag) {
        if (ScriptedPawn(a) != None) {
            if (enter) {
                ScriptedPawn(a).EnterWorld();
            } else {
                ScriptedPawn(a).LeaveWorld();
            }
        } else if (Vehicles(a) != None) {
            if (enter) {
                Vehicles(a).EnterWorld();
            } else {
                Vehicles(a).LeaveWorld();
            }
        }
    }
}

defaultproperties
{
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
}
