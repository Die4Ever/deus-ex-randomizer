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
    CarcassType=Class'DeusEx.MJ12CloneAugShield1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(2)=Texture'MJ12CloneAugShield1Body'
    MultiSkins(3)=Texture'MJ12CloneAugShield1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented MJ12 Troop"
    UnfamiliarName="Augmented MJ12 Troop"
}
