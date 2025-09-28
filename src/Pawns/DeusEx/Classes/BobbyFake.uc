class BobbyFake extends #var(prefix)Robot; // robots don't bleed

function InitializePawn()
{
    Super.InitializePawn();
    SetOrders('Paralyzed');
}

function Tick(float deltaSeconds)
{
    Super.Tick(deltaSeconds);
    bDetectable=false; // HACK: idk why these need to be set again
    bIgnore=true;
    CheckWakeup(deltaSeconds);
    LipSynch(deltaSeconds); // blink
}

function CheckWakeup(float deltaSeconds)
{
    local #var(PlayerPawn) seer;

    seer = class'DXRStalker'.static.AnyPlayerCanSeeMe(self, 800, true); // respect camo, this is Bobby trying to be sneaky

    if(seer!=None)
    {
        LookAtActor(seer,true,true,true);
    }
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
    return;
}

//GMK_DressShirt doesn't actually have a sitting animation ¯\_(ツ)_/¯
function PlaySitting()
{
    //ClientMessage("PlaySitting()");
    //LoopAnimPivot('SitBreathe', , 0.15);
    LoopAnimPivot('SitStill', , 0.15); //Have fun T-Posing
}

defaultproperties
{
    DrawScale=0.6
    CollisionRadius=10.000000
    CollisionHeight=21.000000
    Mass=45
    Buoyancy=50
    WalkSound=Sound'DeusExSounds.Robot.SpiderBot2Walk'
    Health=50
    HealthHead=50
    HealthTorso=50
    HealthLegLeft=50
    HealthLegRight=50
    HealthArmLeft=50
    HealthArmRight=50
    bShowPain=False
    UnderWaterTime=-1.000000
    BindName="Bobby"
    MinHealth=0
    bDetectable=false
    bIgnore=true
    FamiliarName="Bobby"
    UnfamiliarName="Bobby"
    Texture=Texture'DeusExItems.Skins.BlackMaskTex'
    Mesh=LodMesh'DeusExCharacters.GMK_DressShirt'
    MultiSkins(0)=Texture'BobbyFace'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.BobPageTex1'
    MultiSkins(2)=Texture'BobbyPants'
    MultiSkins(3)=Texture'BobbyFace'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
    InitialInventory(0)=(Inventory=None)
    InitialInventory(1)=(Inventory=None)
    InitialInventory(2)=(Inventory=None)
    InitialInventory(3)=(Inventory=None)
    InitialInventory(4)=(Inventory=None)
    Alliance=Stalkers
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=0,bPermanent=True)
    HearingThreshold=0
    walkAnimMult=1.572265625
    runAnimMult=0.9
    bCanStrafe=false
    CarcassType=Class'BobbyCarcass'
    WalkingSpeed=0.350000
    BurnPeriod=0.000000
    GroundSpeed=210.000000
    BaseEyeHeight=15.6
    HitSound1=None;
    HitSound2=None;
    Die=None;
    bKeepWeaponDrawn=False
    DrawType=DT_Mesh
}
