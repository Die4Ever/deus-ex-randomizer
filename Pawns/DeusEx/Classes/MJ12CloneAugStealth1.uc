//=============================================================================
// MJ12CloneAugStealth1.
//=============================================================================
class MJ12CloneAugStealth1 extends MJ12Clone2;

var bool nametag;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to MJ12CloneAugStealth1NametagCarcass
    if (Rand(100) < 5){
        nametag=True;
        GiveNametag();
    }

    SetTimer(2.0,True);
}

function Carcass SpawnCarcass()
{
    ResetSkinStyle();
    if (bStunned)
        return Super.SpawnCarcass();

    Explode();
    return None;
}

function GiveNametag()
{
    MultiSkins[2]=Texture'MJ12CloneAugStealth1BodyNametag';
    CarcassType=Class'MJ12CloneAugStealth1NametagCarcass';
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

    CarcassType=Class'DeusEx.MJ12CloneAugStealth1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'MJ12CloneAugStealth1Head'
    MultiSkins(1)=Texture'MJ12CloneAugStealth1Legs'
    MultiSkins(2)=Texture'MJ12CloneAugStealth1Body'
    MultiSkins(3)=Texture'MJ12CloneAugStealth1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'MJ12CloneAugStealth1Goggles'
    MultiSkins(6)=Texture'MJ12CloneAugStealth1Goggles'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented MJ12 Troop"
    UnfamiliarName="Augmented MJ12 Troop"
}
