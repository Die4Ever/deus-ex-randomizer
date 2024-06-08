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

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
    local MetalFragment frag;

    if (DamageType == 'EMP')
    {
        confusionTimer = 0;
        if (!bConfused)
        {
            bConfused = True;
            PlaySound(sound'EMPZap', SLOT_None,,, 1280);
        }
    }
    else if ((DamageType == 'Exploded') || (DamageType == 'Shot') || (DamageType == 'Sabot'))
    {
        if (Damage >= minDamageThreshold) {
            HitPoints -= Damage;
        } else {
            //Damage doesn't meet minimum damage threshold
            //Logic from DeusExDecoration - sabot does 50% damage, explosions 25%
            if (DamageType == 'Exploded'){
                HitPoints -= Damage * 0.25;
            } else if  (DamageType == 'Sabot'){
                HitPoints -= Damage * 0.5;
            }
        }

    }

    if (HitPoints <= 0)
    {
        frag = Spawn(class'MetalFragment', Owner);
        if (frag != None)
        {
            frag.Instigator = EventInstigator;
            frag.CalcVelocity(Momentum,0);
            frag.DrawScale = 0.5*FRand();
            frag.Skin = GetMeshTexture();
        }

        Destroy();
    }
}

defaultproperties
{
    bProjTarget=true
    LightBrightness=255
    LightRadius=1
    LightType=LT_None
}
