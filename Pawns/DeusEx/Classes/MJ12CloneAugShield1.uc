//=============================================================================
// MJ12CloneAugShield1.
//=============================================================================
class MJ12CloneAugShield1 extends MJ12Clone3;

var bool nametag;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to MJ12CloneAugShield1NametagCarcass
    if (Rand(100) < 5){
        nametag=True;
        GiveNametag();
    }
}

function GiveNametag()
{
    MultiSkins[2]=Texture'MJ12CloneAugShield1BodyNametag';
    CarcassType=Class'MJ12CloneAugShield1NametagCarcass';
}

function Carcass SpawnCarcass()
{
    if (bStunned)
        return Super.SpawnCarcass();

    Explode();

    return None;
}

function Explode()
{
    local SphereEffect sphere;
    local ScorchMark s;
    local ExplosionLight light;
    local int i;
    local float explosionDamage;
    local float explosionRadius;

    explosionDamage = 100;
    explosionRadius = 256;

    // alert NPCs that I'm exploding
    AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
    PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

    // draw a pretty explosion
    light = Spawn(class'ExplosionLight',,, Location);
    if (light != None)
        light.size = 4;

    Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);

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

    // spawn some rocks and flesh fragments
    for (i=0; i<explosionDamage/6; i++)
    {
        if (FRand() < 0.3)
            spawn(class'Rockchip',,,Location);
        else
            spawn(class'FleshFragment',,,Location);
    }

    HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
}

function float ShieldDamage(name damageType)
{
	// handle special damage types
	if ((damageType == 'Flamed') || (damageType == 'Burned') || (damageType == 'Stunned'))
		return 0.0;
	else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas') ||
			(damageType == 'Radiation') || (damageType == 'Shocked') || (damageType == 'Poison') ||
	        (damageType == 'PoisonEffect'))
		return 0.5;
	else
		return Super.ShieldDamage(damageType);
}

defaultproperties
{
    MinHealth=0
    CarcassType=Class'DeusEx.MJ12CloneAugShield1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
    MultiSkins(2)=Texture'MJ12CloneAugShield1Body'
    MultiSkins(3)=Texture'MJ12CloneAugShield1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented MJ12 Troop"
    UnfamiliarName="Augmented MJ12 Troop"
}
