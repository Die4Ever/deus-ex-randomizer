class FillCollisionHole extends DeusExDecoration;

simulated function BaseChange()
{
    Super.BaseChange();
    if (Base == None)
        Destroy();
}

// use vectm to pass to this function
static function CreateLine(Actor a, vector start, vector end, float radius, float height, optional Actor base)
{
    local FillCollisionHole f;
    local vector v, toofar;
    local float dist;

    v = end - start;
    v = Normal(v) * radius * 1.5;
    toofar = end + v*0.1;
    dist = VSize(start-end);

    // while the distance isn't too close to the end piece that we will spawn exactly
    // and while we're closer to the end than toofar, to avoid overshoot
    while(dist > radius/2 && dist < VSize(start-toofar)) {
        f = a.Spawn(class'FillCollisionHole',,, start);
        f.SetCollisionSize(radius, height);
        f.SetBase(base);
        start += v;
        dist = VSize(start-end);
    }

    // spawn the end piece specifically
    f = a.Spawn(class'FillCollisionHole',,, end);
    f.SetCollisionSize(radius, height);
    f.SetBase(base);
}

defaultproperties
{
    bStatic=false
    bCollideWorld=false
    bBlockSight=True
    bHidden=False
    Mesh=None
    Texture=None
    bPushable=false
    bHighlight=false
    Physics=PHYS_None
    bInvincible=true
    ItemName="Wall"
}
