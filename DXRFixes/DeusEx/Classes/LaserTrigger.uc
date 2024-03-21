class DXRLaserTrigger injects LaserTrigger;
// the red one with the alarm built-in

function bool IsRelevant( actor Other )
{
    if (TriggerType==TT_AnyProximity){
        if (ScriptedPawn(Other)!=None){
            return False;
        }
    }
    return Super.IsRelevant(Other);
}

function BeginAlarm()
{
    local Actor A;

    Super.BeginAlarm();

    // Trigger event
    if(Event != '')
        foreach AllActors(class 'Actor', A, Event)
            A.Trigger(Self, Pawn(emitter.HitActor));
}

defaultproperties
{
    bProjTarget=true
}
