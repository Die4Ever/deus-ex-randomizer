class DXRBeamTrigger injects BeamTrigger;

function bool IsRelevant( actor Other )
{
    if (TriggerType==TT_AnyProximity){
        if (ScriptedPawn(Other)!=None){
            return False;
        }
    }
    return Super.IsRelevant(Other);
}

defaultproperties
{
    bProjTarget=true
}
