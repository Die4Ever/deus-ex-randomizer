//=============================================================================
// NSFCloneAugStealth1.
//=============================================================================
class NSFCloneAugStealth1 extends NSFClone2;

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
    MultiSkins[2]=Texture'NSFCloneAugStealth1BodyNametag';
    CarcassType=Class'NSFCloneAugStealth1NametagCarcass';
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
		//Negative values like -0.4 look good on DirectX 10, but weird on Software/OpenGL.  Stick with positive values.
		SetSkinStyle(STY_Translucent, Texture'WhiteStatic', 0.01);
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
#ifdef injections
    if(EmpHealth <= 0) return False;
#endif

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
    bHasCloak=False
    CloakThreshold=9999;

    CarcassType=Class'DeusEx.NSFCloneAugStealth1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.TerroristTex0'
    MultiSkins(1)=Texture'NSFCloneAugStealth1Legs'
    MultiSkins(2)=Texture'NSFCloneAugStealth1Body'
    MultiSkins(3)=Texture'NSFCloneAugStealth1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'NSFCloneAugStealth1Goggles'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented Terrorist"
    UnfamiliarName="Augmented Terrorist"
}
