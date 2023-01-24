class RocketFixTicks extends #var(prefix)Rocket;

state Exploding
{
    ignores ProcessTouch, HitWall, Explode;
Begin:
    // stagger the HurtRadius outward using Timer()
    // do five separate blast rings increasing in size
    gradualHurtCounter = 1;
    gradualHurtSteps = 4;// DXRando: 4 ticks instead of 5, that way a 150 damage gep gun still deals 75 damage per tick which is enough to break any door
    Velocity = vect(0,0,0);
    bHidden = True;
    LightType = LT_None;
    SetCollision(False, False, False);
    DamageRing();
    SetTimer(0.25/float(gradualHurtSteps), True);
}
