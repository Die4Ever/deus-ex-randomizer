class HECannisterFixTicks extends #var(prefix)HECannister20mm;

state Exploding
{
    ignores ProcessTouch, HitWall, Explode;
Begin:
    // stagger the HurtRadius outward using Timer()
    // do five separate blast rings increasing in size
    gradualHurtCounter = 1;
    gradualHurtSteps = 3;// DXRando: 3 ticks instead of 5, that way a 75 damage HE still deals 50 damage per tick which is enough to break most doors
    Velocity = vect(0,0,0);
    bHidden = True;
    LightType = LT_None;
    SetCollision(False, False, False);
    DamageRing();
    SetTimer(0.25/float(gradualHurtSteps), True);
}

// MomentumTransfer vanilla is 40000 for some reason
defaultproperties
{
    MomentumTransfer=10000
}
