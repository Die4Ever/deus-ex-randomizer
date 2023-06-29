//=============================================================================
// UNATCOCloneAugTough1.
//=============================================================================
class UNATCOCloneAugTough1 extends UNATCOClone4;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to UNATCOCloneAugTough1NametagCarcass
    if (Rand(100) < 5){
        MultiSkins[2]=Texture'UNATCOCloneAugTough1BodyNametag';
        CarcassType=Class'UNATCOCloneAugTough1NametagCarcass';
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
    Mesh2=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB'
    Mesh3=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass'
    MultiSkins(0)=Texture'Textures\NSFCloneAugTough1Head.pcx'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.UNATCOTroopTex1'
    MultiSkins(2)=Texture'Textures\NSFCloneAugTough1Body.pcx'
    MultiSkins(3)=Texture'Textures\NSFCloneAugTough1Head.pcx' //this is where you put the face texture
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.UNATCOTroopTex3'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
