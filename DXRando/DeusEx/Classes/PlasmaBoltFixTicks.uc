class PlasmaBoltFixTicks extends #var(prefix)PlasmaBolt;

state Exploding
{
    ignores ProcessTouch, HitWall, Explode;
Begin:
    // stagger the HurtRadius outward using Timer()
    // do five separate blast rings increasing in size
    gradualHurtCounter = 1;
    gradualHurtSteps = 3;// DXRando: 3 ticks instead of 5, so plasma rifles are slightly less terrible at breaking doors
    Velocity = vect(0,0,0);
    bHidden = True;
    LightType = LT_None;
    SetCollision(False, False, False);
    DamageRing();
    SetTimer(0.25/float(gradualHurtSteps), True);
}

// vanilla MomentumTransfer is 5000
defaultproperties
{
    blastRadius=128
    Damage=18
    MomentumTransfer=6000
#ifndef hx
    mpDamage=18
    mpBlastRadius=128
#endif
}
