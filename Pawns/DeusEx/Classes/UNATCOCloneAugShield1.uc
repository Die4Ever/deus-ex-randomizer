//=============================================================================
// UNATCOCloneAugShield1.
//=============================================================================
class UNATCOCloneAugShield1 extends UNATCOClone3;

var bool nametag;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to UNATCOCloneAugShield1NametagCarcass
    if (Rand(100) < 5){
        nametag=True;
        GiveNametag();
    }
}

function GiveNametag()
{
    MultiSkins[2]=Texture'UNATCOCloneAugShield1BodyNametag';
    CarcassType=Class'UNATCOCloneAugShield1NametagCarcass';
}

function Carcass SpawnCarcass()
{
    if (bStunned)
        return Super.SpawnCarcass();

    Explode();

    return None;
}

function float ShieldDamage(name damageType)
{
	// handle special damage types
	if ((damageType == 'Flamed') || (damageType == 'Burned') || (damageType == 'Stunned'))
		return 0.1;
	else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas') ||
			(damageType == 'Radiation') || (damageType == 'Shocked') || (damageType == 'Poison') ||
	        (damageType == 'PoisonEffect'))
		return 0.5;
	else
		return Super.ShieldDamage(damageType);
}

defaultproperties
{
    CarcassType=Class'DeusEx.UNATCOCloneAugShield1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.UNATCOTroopTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.UNATCOTroopTex1'
    MultiSkins(2)=Texture'UNATCOCloneAugShield1Body'
    MultiSkins(3)=Texture'UNATCOCloneAugShield1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.UNATCOTroopTex3'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented UNATCO Troop"
    UnfamiliarName="Augmented UNATCO Troop"
}
