//=============================================================================
// MJ12CloneAugTough1.
//=============================================================================
class MJ12CloneAugTough1 extends MJ12Clone4;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to MJ12CloneAugTough1NametagCarcass
    if (Rand(100) < 5){
        MultiSkins[2]=Texture'MJ12CloneAugTough1BodyNametag';
        CarcassType=Class'MJ12CloneAugTough1NametagCarcass';
    }
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

//This guy has a metal head, always count as a helmet
function int HeadDamageMult()
{
    return 4;
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
    local Sound hitSound;
    local float volume;

    if (Level.TimeSeconds - LastPainSound < 0.25)
        return;
    if (Damage <= 0)
        return;

    LastPainSound = Level.TimeSeconds;

    if (damageType=='shot')
        hitSound = Sound'ArmorRicochet';
    else if (Damage <= 30)
        hitSound = HitSound1;
    else
        hitSound = HitSound2;
    volume = FMax(Mult*TransientSoundVolume, Mult*2.0);

    SetDistressTimer();
    PlaySound(hitSound, SLOT_Pain, volume,,, RandomPitch());
    if ((hitSound != None) && bEmitDistress)
        AISendEvent('Distress', EAITYPE_Audio, volume);
}


function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType
#ifdef revision
                            , optional bool bTestOnly
#endif
                            )
{
    local float actualDamage;

#ifdef revision
    actualDamage = Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType, bTestOnly);
#else
    actualDamage = Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
#endif

    if (damageType == 'Shot') {
        actualDamage *= 0.5;
    }
    return actualDamage;
}

defaultproperties
{
    Mesh2=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB'
    Mesh3=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass'
    MultiSkins(0)=Texture'Textures\MJ12CloneAugTough1Head.pcx'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(2)=Texture'Textures\MJ12CloneAugTough1Body.pcx'
    MultiSkins(3)=Texture'Textures\MJ12CloneAugTough1Head.pcx' //this is where you put the face texture
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'Textures\MJ12CloneAugStealth1Goggles.pcx'
    MultiSkins(6)=Texture'Textures\MJ12CloneAugStealth1GogglesDark.pcx'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented MJ12 Troop"
    UnfamiliarName="Augmented MJ12 Troop"
}
