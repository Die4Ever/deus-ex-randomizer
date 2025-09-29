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

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
    Super(ScriptedPawn).TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bPlayAnim);
}

function ImpartMomentum(Vector momentum, Pawn instigatedBy)
{
    Super(ScriptedPawn).ImpartMomentum(momentum, instigatedBy);
}


function Explode(vector HitLocation)
{
    local int i;
    local Vector loc;
    local DeusExFragment s;
    local ExplosionLight light;
    local ExplosionSmall exp;

    PlaySound(explosionSound, SLOT_None, 2.0,, 32);

    PlaySound(sound'SmallExplosion1', SLOT_None,,, 32);
    AISendEvent('LoudNoise', EAITYPE_Audio, , 32);

    // draw a pretty explosion
    light = Spawn(class'ExplosionLight',,, HitLocation);
    light.size = 2;
    exp = Spawn(class'ExplosionSmall',,, Location);
    exp.DrawScale = 0.5;

    // spawn some metal fragments
    for (i=0; i<6; i++)
    {
        s = Spawn(class'MetalFragment', Owner);
        if (s != None)
        {
            s.Instigator = Instigator;
            s.CalcVelocity(Velocity, 16);
            s.DrawScale = 0.7*FRand();
            s.Skin = GetMeshTexture();
            if (FRand() < 0.75)
                s.bSmoking = True;
        }
    }

    // cause the damage
    HurtRadius(1, 16, 'Exploded', 16, Location);
}

defaultproperties
{
    DrawScale=0.6
    CollisionRadius=10.000000
    CollisionHeight=21.000000
    Mass=80
    Buoyancy=0
    WalkSound=Sound'DeusExSounds.Robot.SpiderBot2Walk'
    Health=5
    HealthHead=5
    HealthTorso=5
    HealthLegLeft=5
    HealthLegRight=5
    HealthArmLeft=5
    HealthArmRight=5
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
