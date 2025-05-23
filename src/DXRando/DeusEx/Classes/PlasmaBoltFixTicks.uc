class PlasmaBoltFixTicks extends #var(prefix)PlasmaBolt;

state Exploding
{
    ignores ProcessTouch, HitWall, Explode;
Begin:
    // stagger the HurtRadius outward using Timer()
    // do five separate blast rings increasing in size
    gradualHurtCounter = 1;
    gradualHurtSteps = 2;// DXRando: 2 ticks instead of 5, so plasma rifles are slightly less terrible at breaking doors
    Velocity = vect(0,0,0);
    bHidden = True;
    LightType = LT_None;
    SetCollision(False, False, False);
    DamageRing();
    SetTimer(0.25/float(gradualHurtSteps), True);
}

function PlayImpactSound()
{// less clipping, half volume
    local float rad;

    if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer) || (Level.NetMode == NM_DedicatedServer))
    {
        rad = Max(blastRadius*4, 1024);
        PlaySound(ImpactSound, SLOT_None, 1,, rad);
    }
}

defaultproperties
{
    blastRadius=128
    Damage=18
#ifndef hx
    mpDamage=18
    mpBlastRadius=128
#endif
}
