//Birds aren't real
class DXRBird injects #var(prefix)Bird;

var bool bIsReal;
var bool bZapped; //To track through whether or not fake birds should explode or not

function BeginPlay()
{
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (dxr==None) return;

    // 1% odds of a bird being fake normally, always fake on April Fools
    if ((class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags) && Rand(100)==0) || dxr.IsAprilFools()) {
        bIsReal = False;
    }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation,
                    Vector momentum, name damageType)
{
    bZapped = ((DamageType == 'EMP') || (DamageType == 'NanoVirus'));
    if (bZapped && !bIsReal){ //Zapping only works on fake birds
        DamageType = 'Shot'; //This bypasses stupid checks for EMP/NanoVirus damage in other state TakeDamage functions
    }

    Super.TakeDamage(Damage,instigatedBy,hitLocation,momentum,damageType);
}

function Carcass SpawnCarcass()
{
    if (bIsReal || bZapped){
        return Super.SpawnCarcass();
    }

    class'DXREvents'.static.MarkBingo("BirdsArentReal");

    Explode();

    return None;
}

function Explode(optional vector HitLocation) // argument for compatibility with Revision and VMD
{
    local SphereEffect sphere;
    local ScorchMark s;
    local ExplosionLight light;
    local int i;
    local float explosionDamage;
    local float explosionRadius;

    explosionDamage = 10; //Low Damage
    explosionRadius = 64; //Small radius

    // alert NPCs that I'm exploding
    AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
    PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

    // draw a pretty explosion
    light = Spawn(class'ExplosionLight',,, Location);
    if (light != None)
        light.size = 4;

    Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
    //Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
    //Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
    //Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);

    sphere = Spawn(class'SphereEffect',,, Location);
    if (sphere != None)
        sphere.size = explosionRadius / 32.0;

    // spawn a mark
    s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
    if (s != None)
    {
        s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
        s.ReattachDecal();
    }

    // spawn some rocks
    for (i=0; i<3; i++)
    {
        spawn(class'Rockchip',,,Location);
    }

    HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
}

//Stubbed for save compatibility
state Wandering
{
}

state Flying
{
}

defaultproperties
{
    bIsReal=true
}
