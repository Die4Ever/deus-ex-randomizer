class DXRBeamTrigger injects BeamTrigger;
// the blue one with no alarm

function bool IsRelevant( actor Other )
{
    if (TriggerType==TT_AnyProximity){
        if (ScriptedPawn(Other)!=None){
            return False;
        }
    }
    return Super.IsRelevant(Other);
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
}
