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

function EndAlarm()
{
    super.EndAlarm();
    LightType = LT_None;
}

function Tick(float deltaTime)
{
    Super.Tick(deltaTime);

    if (AmbientSound != None){ //Alarm is happening
        // flash the light and texture
        if ((Level.TimeSeconds % 0.5) > 0.25)
        {
            LightType = LT_Steady;
        }
        else
        {
            LightType = LT_None;
        }
    }
}

defaultproperties
{
    bProjTarget=true
    LightBrightness=255
    LightRadius=1
    LightType=LT_None
}
