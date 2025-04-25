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

    if (damageType=='shot' || damageType=='AutoShot')
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

    if (damageType == 'Shot' || damageType == 'AutoShot') {
        actualDamage *= 0.5;
    }
    return actualDamage;
}

defaultproperties
{
    CarcassType=Class'DeusEx.MJ12CloneAugTough1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'MJ12CloneAugTough1Head'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(2)=Texture'MJ12CloneAugTough1Body'
    MultiSkins(3)=Texture'MJ12CloneAugTough1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented MJ12 Troop"
    UnfamiliarName="Augmented MJ12 Troop"
}
