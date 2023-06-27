//=============================================================================
// NSFCloneAugShield1.
//=============================================================================
class NSFCloneAugShield1 extends Terrorist;

var bool nametag;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to NSFCloneAugTough1Carcass2
    if (Rand(100) < 5){
        nametag=True;
        GiveNametag();
    }
}

function GiveNametag()
{
    MultiSkins[2]=Texture'NSFCloneAugTough1Body2';
    CarcassType=Class'DeusEx.NSFCloneAugTough1Carcass2';
}

//Copied straight from Walton - values definitely need to be changed
function float ShieldDamage(name damageType)
{
	// handle special damage types
	if ((damageType == 'Flamed') || (damageType == 'Burned') || (damageType == 'Stunned') ||
	    (damageType == 'KnockedOut'))
		return 0.0;
	else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas') ||
			(damageType == 'Radiation') || (damageType == 'Shocked') || (damageType == 'Poison') ||
	        (damageType == 'PoisonEffect'))
		return 0.1;
	else
		return Super.ShieldDamage(damageType);
}

defaultproperties
{
    MinHealth=0
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
