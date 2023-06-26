//=============================================================================
// NSFCloneAugStealth1.
//=============================================================================
class NSFCloneAugStealth1 extends Terrorist;

var bool nametag;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to NSFCloneAugTough1Carcass2
    if (Rand(100) < 5){
        nametag=True;
        GiveNametag();
    }

    SetTimer(2.0,True);
}

function Carcass SpawnCarcass()
{
    ResetSkinStyle();
    return Super.SpawnCarcass();
}

function GiveNametag()
{
    MultiSkins[2]=Texture'NSFCloneAugTough1Body2';
    CarcassType=Class'DeusEx.NSFCloneAugTough1Carcass2';
}

function ResetSkinStyle()
{
    Super.ResetSkinStyle();
    if (nametag){
        GiveNametag();
    }
}

function EnableCloak(bool bEnable)  // beware! called from C++
{
	if (!bHasCloak || (CloakEMPTimer > 0) || (Health <= 0) || bOnFire)
		bEnable = false;

	if (bEnable && !bCloakOn)
	{
		SetSkinStyle(STY_Translucent, Texture'WhiteStatic', -0.4); //-0.4 seems to actually be pretty stealthy
		KillShadow();
		bCloakOn = bEnable;
	}
	else if (!bEnable && bCloakOn)
	{
		ResetSkinStyle();
		CreateShadow();
		bCloakOn = bEnable;
	}
}

function bool ShouldBeCloaked()
{
    switch(GetStateName()){
        case 'Seeking':
        case 'Alerting':
        case 'Attacking':
        case 'Fleeing':
            return True;
            break;
        default:
            return False;
            break;
    }
    return False;
}

function Timer()
{
    local bool cloak;
    //Kludge to force our own cloak logic while keeping the performance (I guess) of the native C++ code

    cloak=ShouldBeCloaked();

    bHasCloak=cloak;
    EnableCloak(cloak);  //Needed to disable cloak again afterwards
}

defaultproperties
{
    MinHealth=0
    bHasCloak=False
    CloakThreshold=9999;
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
