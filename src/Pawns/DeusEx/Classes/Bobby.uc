class Bobby extends DXRStalker;

var float seenCounter;
var float unSeenCounter;
const MaxDist=800;

//TODO Ideas
//
// - Maybe it would be interesting/creepy/spooky if he was really fast when he runs away?
// - He should maybe have a special knife that's more effective?
// - Maybe rather than wandering (like Mr. H), he should be sitting around and stand up when you approach
//   - Maybe he could even only start chasing you after you've seen him, then let him go out of LoS
//   - if this is the case, we might want to make sure his alliance is neutral until he becomes "active",
//     so that you can't easily differentiate him from a "doll" version that won't chase

function InitializePawn()
{
    Super.InitializePawn();
    SetOrders('Sleeping');
}

state Sleeping
{ // TODO: TakeDamage wakes up, into Wandering orders? also when the player is nearby, sees the Bobby, and then no longer sees the Bobby
    ignores bump, frob, reacttoinjury;
    function BeginState()
    {
        StandUp();
        BlockReactions(true);
        bCanConverse = False;
        SeekPawn = None;
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
        bDetectable=false; // HACK: idk why these need to be set again
        bIgnore=true;
        Global.Tick(deltaSeconds);
        CheckWakeup(deltaSeconds);
    }

Begin:
    Acceleration=vect(0,0,0);
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
    SetOrders('Wandering');
    if(Enemy!=None) HandleSighting(Enemy);
    else GotoState('Seeking');
}

function CheckWakeup(float deltaSeconds)
{
    local bool bSeen;

    bSeen = AnyPlayerCanSeeMe();

    if(bSeen)
    {
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

function bool APlayerCanSeeMe(#var(PlayerPawn) p)
{
    local Actor hit;
    local Vector HitLocation, HitNormal;
    local rotator rot;
    local float yaw, pitch, dist;

    if (!p.bDetectable || player.bIgnore) return false;
    if(p.CalculatePlayerVisibility(self) < 0.1) return false; // this only returns 1 or 0

    hit = Trace(HitLocation, HitNormal, p.Location, Location, True);
    p = #var(PlayerPawn)(hit); // we don't actually care if this is THE player, just if it is A player (could be a player standing in front of another)
    if(p == None) return false;

    // figure out if the player can see us
    rot = Rotator(Location - p.Location);
    rot.Roll = 0;
    // diff between player's view rotation and the needed rotation to see
    yaw = (Abs(p.ViewRotation.Yaw - rot.Yaw)) % 65536;
    pitch = (Abs(p.ViewRotation.Pitch - rot.Pitch)) % 65536;

    // center the angles around zero
    if (yaw > 32767)
        yaw -= 65536;
    if (pitch > 32767)
        pitch -= 65536;

    // return if we are not in the player's FOV (don't use their real FOV? every player should be the same? needs to be extra wide then, I guess 180 degrees would be 16384)
    if (Abs(yaw) > 15000 || Abs(pitch) > 15000) {
        return false;
    }

    SetEnemy(p, Level.TimeSeconds);
    return true;
}

function bool AnyPlayerCanSeeMe()
{
    local #var(PlayerPawn) p;
    foreach RadiusActors(class'#var(PlayerPawn)', p, MaxDist) {
        if(APlayerCanSeeMe(p)) return true;
    }
    return false;
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
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1,bPermanent=True)
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
    bKeepWeaponDrawn=True
    // faster jump scares
    SurprisePeriod=0.1
}
