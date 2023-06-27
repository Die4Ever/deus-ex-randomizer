//=============================================================================
// NSFCloneAugTough1.
//=============================================================================
class NSFCloneAugTough1 extends Terrorist;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to NSFCloneAugTough1Carcass2
    if (Rand(100) < 5){
        MultiSkins[2]=Texture'NSFCloneAugTough1BodyNametag';
        CarcassType=Class'DeusEx.NSFCloneAugTough1NametagCarcass';
    }
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
    MinHealth=0
    GroundSpeed=170
    Fatness=130
    Health=125
    CarcassType=Class'DeusEx.NSFCloneAugTough1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.TerroristTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.TerroristTex2'
    MultiSkins(2)=Texture'NSFCloneAugTough1Body'
    MultiSkins(3)=Texture'NSFCloneAugTough1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.GogglesTex1'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented Terrorist"
    UnfamiliarName="Augmented Terrorist"
}
