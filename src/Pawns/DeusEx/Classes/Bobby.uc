class Bobby extends DXRStalker;

// once seen they are ready to wakeup, and then will wakeup when unseen

var float seenCounter;
var float unSeenCounter;

function InitializePawn()
{
    Super.InitializePawn();
    SetOrders('Sleeping');
}

state Sleeping
{
    ignores bump, frob, reacttoinjury;
    function BeginState()
    {
        BlockReactions(true);
        bCanConverse = False;
        EnableCheckDestLoc(false);
    }
    function EndState()
    {
        ResetReactions();
        bCanConverse = True;
    }

    function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
    {
        Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
        GotoState('Wakeup');
    }

    function Tick(float deltaSeconds)
    {
        Global.Tick(deltaSeconds);
        CheckWakeup(deltaSeconds);
        LipSynch(deltaSeconds); // blink
        bDetectable=false; // HACK: idk why these need to be set again
        bIgnore=true;
    }

Begin:
    Acceleration=vect(0,0,0);
    DesiredRotation=Rotation;
    PlayAnimPivot('Still');
}

state Wakeup
{
Begin:
    if(Enemy!=None) {
        LookAtActor(Enemy,true,true,true);
        Sleep(0.1);
    }
    bDetectable=true;
    bIgnore=false;
    ChangeAlly('Player', -1, false);
    bKeepWeaponDrawn=true;
    SetOrders('Wandering');
    if(Enemy!=None) HandleSighting(Enemy);
    else GotoState('Seeking');
}

function CheckWakeup(float deltaSeconds)
{
    local #var(PlayerPawn) seer;

    seer = AnyPlayerCanSeeMe(self, 800, true); // respect camo, this is Bobby trying to be sneaky

    if(seer!=None)
    {
        SetEnemy(seer, Level.TimeSeconds, true);
        LookAtActor(seer,true,true,true);
        seenCounter += deltaSeconds;
        unSeenCounter = 0;
    }
    else if(seenCounter > 0.5)
    {
        unSeenCounter += deltaSeconds;
        if(unSeenCounter > 0.5)
        {
            GotoState('Wakeup');
        }
    }
    else
    {
        seenCounter = FMax(seenCounter-deltaSeconds, 0);
    }
}

//Mostly from Robot - he's a doll, so these things don't work on him
function bool IgnoreDamageType(Name damageType)
{
    if ((damageType == 'TearGas') || (damageType == 'HalonGas') || (damageType == 'PoisonGas') || (damageType == 'Radiation'))
        return True;
    else if ((damageType == 'Poison') || (damageType == 'PoisonEffect'))
        return True;
    else
        return False;
}

function bool ShouldDropWeapon()
{
    //Bobby has a firm kung fu grip
    return false;
}

function MakePawnIgnored(bool bNewIgnore)
{
    // do nothing
}

////////////////////////////////
// #region Animation Hacks
////////////////////////////////

//Don't play breathing animations
function TweenToWaiting(float tweentime)
{
//    ClientMessage("TweenToWaiting()");
    if (Region.Zone.bWaterZone)
        TweenAnimPivot('Tread', tweentime, GetSwimPivot());
    else
    {
        TweenAnimPivot('BreatheLight', tweentime);
        //if (HasTwoHandedWeapon())
        //    TweenAnimPivot('BreatheLight2H', tweentime);
        //else
        //    TweenAnimPivot('BreatheLight', tweentime);
    }
}

function PlayWaiting()
{
//    ClientMessage("PlayWaiting()");
    if (Region.Zone.bWaterZone)
        LoopAnimPivot('Tread', , 0.3, , GetSwimPivot());
    else
    {
        TweenAnimPivot('BreatheLight',0); //Tween to the breathing animation, but don't actually play it
        //if (HasTwoHandedWeapon())
        //    LoopAnimPivot('BreatheLight2H', , 0.3);
        //else
        //    LoopAnimPivot('BreatheLight', , 0.3);
    }
}

//GMK_DressShirt doesn't actually have a sitting animation ¯\_(ツ)_/¯
function PlaySitting()
{
    //ClientMessage("PlaySitting()");
    //LoopAnimPivot('SitBreathe', , 0.15);
    LoopAnimPivot('SitStill', , 0.15); //Have fun T-Posing
}

// #endregion

defaultproperties
{
    DrawScale=0.6
    CollisionRadius=10.000000
    CollisionHeight=19.000000
    Mass=45
    Buoyancy=50
    WalkSound=Sound'DeusExSounds.Robot.SpiderBot2Walk'
    Health=100
    HealthHead=100
    HealthTorso=100
    HealthLegLeft=100
    HealthLegRight=100
    HealthArmLeft=100
    HealthArmRight=100
    bShowPain=False
    UnderWaterTime=-1.000000
    BindName="Bobby"
    MinHealth=10
    FleeHealth=10
    bInvincible=false

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
    InitialInventory(0)=(Inventory=class'WeaponBobbysKnife')
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
    RotationRate=(Yaw=100000)
    BaseEyeHeight=15.6
    HitSound1=Sound'ChildPainMedium';
    HitSound2=Sound'ChildPainLarge';
    Die=Sound'ChildDeath';
    bKeepWeaponDrawn=False
    // faster jump scares
    SurprisePeriod=0.1
}
