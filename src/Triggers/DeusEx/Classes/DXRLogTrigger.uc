class DXRLogTrigger extends Trigger;

function Trigger(Actor Other, Pawn Instigator)
{
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (dxr==None){
        log(Tag$" triggered by Other: "$Other$"   Instigator: "$Instigator);
    } else {
        dxr.Player.ClientMessage(Tag$" triggered by Other: "$Other$"   Instigator: "$Instigator);
    }

}

defaultproperties
{
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bProjTarget=false
    bTriggerOnceOnly=false
}
