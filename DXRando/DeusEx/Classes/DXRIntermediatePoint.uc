//This acts kind of like a half-assed dynamic patrol point
class DXRIntermediatePoint extends Info;

var() name nextPoint;

//Once pawns reach us, move on to the next point
function Touch( actor Other )
{
    local #var(prefix)ScriptedPawn sp;

    sp = #var(prefix)ScriptedPawn(other);

    if (sp==None) return;
    if (sp.OrderTag!=Tag) return;

    sp.ClearNextState();

    if (nextPoint=='') return;

    sp.SetOrders(sp.Orders,nextPoint,True);

}

defaultproperties
{
    bCollideActors=true
    CollisionRadius=50
}
