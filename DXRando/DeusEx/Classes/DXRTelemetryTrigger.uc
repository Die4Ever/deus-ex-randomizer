class DXRTelemetryTrigger extends Trigger;

var string telemMsg;

function string GetTelemMessage()
{
    return telemMsg;
}

function Trigger(Actor Other, Pawn Instigator)
{
    local Actor a;
    local DXRando dxr;

    Super.Trigger(Other, Instigator);

    dxr = class'DXRando'.default.dxr;

    if (dxr!=None){
        class'DXRTelemetry'.static.SendEvent(dxr, Instigator, GetTelemMessage());
    }

}

defaultproperties
{
     bCollideActors=False
     bCollideWorld=False
}
