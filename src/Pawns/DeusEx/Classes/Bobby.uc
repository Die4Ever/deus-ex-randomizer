class Bobby extends DXRStalker;

// once seen they are ready to wakeup, and then will wakeup when unseen
var float seenCounter;
var float unSeenCounter;
var int pathingFails;

// for being bumped by pawns
var Actor lastBumpActor;
var float lastBumpTime;

const SpreadDistance = 160;

//#region destroying
simulated function PreTravel()
{
    bTransient = false;
}

simulated function Destroyed()
{
    local DXRHalloween h;
    local BobbyFake faker;

    if(bTransient) {
        // destroyed by leaving
        bTransient=false;
        h = DXRHalloween(class'DXRHalloween'.static.Find());
        faker = ChooseFake();
        if(h!=None && h.dxr!=None && faker!=None) {
            class'BobbyPossessionEffect'.static.Create(self, faker, h);
        }
    }
    Super.Destroyed();
}
//#endregion

//#region spawning
function BobbyFake ChooseFake(optional BobbyFake except)
{
    local BobbyFake faker, closestFaker;
    local float dist, closestDist, minDist;

    closestDist = 999999;
    minDist = -1;
    if(except!=None) {
        minDist = VSize(Location-except.Location);
    }

    foreach AllActors(class'BobbyFake', faker) {
        if(faker.health <= 0) continue;

        dist = VSize(Location-faker.Location);

        if(faker.Owner==self && dist > minDist) return faker;
        if(Bobby(faker.Owner)!=None) continue;

        if(dist < closestDist && dist > minDist) {
            closestDist = dist;
            closestFaker = faker;
        }
    }

    if(closestFaker!=None) closestFaker.SetOwner(self);
    return closestFaker;
}

static function ScriptedPawn SpawnOne(DXRActorsBase a, class<ScriptedPawn> type, vector baseloc)
{
    local ScriptedPawn s;
    local vector loc;
    local int i;

    for(i=0; i<10; i++) {
        loc = a.GetRandomPositionNear(baseloc, SpreadDistance);
        s = a.Spawn(type,,, loc);
        if(s != None) {
            if(DXRStalker(s)!=None) {
                DXRStalker(s).InitStalker(a);
            }
            return s;
        }
    }
    return None;
}

static function ScriptedPawn SpawnPack(DXRActorsBase a, class<ScriptedPawn> type)
{
    local ScriptedPawn leader, s;
    local vector loc;
    local int i;

    for(i=0; i<10; i++) {
        loc = a.GetRandomPosition(a.player().Location, 16*100, 999999);
        leader = SpawnOne(a, type, loc);
        if(leader!=None) break;
    }
    if(leader == None) return None;

    for(i=1; i<3; i++) {
        s = SpawnOne(a, type, loc);
        if(DXRStalker(s)!=None) {
            DXRStalker(s).InitStalker(a);
        }
    }

    return leader;
}

function InitializePawn()
{
    Super.InitializePawn();
    SetOrders('Sleeping');
}
//#endregion

//#region states
state Sleeping
{
    ignores frob, reacttoinjury;
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
    PlayWaiting();
}

state Wakeup
{
Begin:
    WakeupFriends();
    if(Enemy!=None) {
        LookAtActor(Enemy,true,true,true);
    }
    bDetectable=true;
    bIgnore=false;
    ChangeAlly('Player', -1, true);
    bKeepWeaponDrawn=true;
    SetOrders('Wandering');
    OrderActor=Enemy;
    if(!PlayerCloaked(#var(PlayerPawn)(Enemy), self)) SetOrders('Attacking');
    else if(OrderActor!=None) GotoState('RunningTo');
    else GotoState('Seeking');
}


state Fleeing
{
    function BeginState()
    {
        if (bLeaveAfterFleeing)
        {
            RunToFaker();
        }
        Super.BeginState();
    }
}

state RunningTo
{
    ignores frob, reacttoinjury;
    function BeginState()
    {
        BlockReactions(true);
        bCanConverse = False;
        EnableCheckDestLoc(false);
    }

    function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
    {
        // can't be damaged here
    }

    function EndState()
    {
        local DXRHalloween halloween;
        local BobbyFake faker;
        faker = BobbyFake(orderActor);
        if (faker!=None && VSize(Location-faker.Location) < 160) {
            halloween = DXRHalloween(class'DXRHalloween'.static.Find());
            class'BobbyPossessionEffect'.static.Create(self, faker, halloween);
            GotoState('Possessing');
        } else {
            RunToFaker();
        }
    }

    function Tick(float deltaSeconds)
    {
        local BobbyFake faker;
        Global.Tick(deltaSeconds);
        faker = BobbyFake(orderActor);
        if(faker == None || faker.health <= 0) {
            RunToFaker();
        }
    }

    function Actor GetNextWaypoint(Actor destination)
    {
        local Actor a;
        a = Global.GetNextWaypoint(destination);
        if(a==None) {
            pathingFails++;
            if(pathingFails>3) {
                RunToFaker(BobbyFake(orderActor));
                return None;
            }
        }
        else pathingFails = 0;
        return a;
    }
}

state Possessing
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
        // can't be damaged here
    }

    function Tick(float deltaSeconds)
    {
        Global.Tick(deltaSeconds);
        if(BobbyFake(orderActor) == None || BobbyFake(orderActor).health <= 0) {
            RunToFaker();
        }
    }

Begin:
    bTransient = false;
    bDisappear = false;
    Acceleration=vect(0,0,0);
    Velocity=vect(0,0,0);
    LoopAnim('Shocked',2.5); //He's BUZZING with excitement!
    if(orderActor!=None) LookAtActor(orderActor,true,true,true);
}
//#endregion

//#region util

function RunToFaker(optional BobbyFake except)
{
    local BobbyFake faker;
    bTransient = true; // we can possess early if out of sight
    bDisappear = true;
    bLeaveAfterFleeing = false; // only do this once
    faker = ChooseFake(except);
    OrderActor = faker;
    if(faker!=None) {
        GotoState('RunningTo');
        return;
    }
    GotoState('Fleeing');
}

function WakeupFriends()
{
    local Bobby friend;
    foreach RadiusActors(class'Bobby', friend, SpreadDistance+32) {
        if(friend.IsInState('Sleeping')) {
            friend.GotoState('Wakeup');
        }
    }
}

function CheckWakeup(float deltaSeconds)
{
    local #var(PlayerPawn) seer;

    seer = AnyPlayerCanSeeMe(self, 1200, true); // respect camo, this is Bobby trying to be sneaky

    if(seer!=None)
    {
        SetSeekLocation(seer, seer.Location, SEEKTYPE_Sight, true);
        SetEnemy(seer, Level.TimeSeconds, true);
        LookAtActor(seer,true,true,true);
        seenCounter += deltaSeconds;
        unSeenCounter = 0;
    }
    else if(seenCounter > 0.3)
    {
        unSeenCounter += deltaSeconds;
        if(unSeenCounter > 0.3)
        {
            GotoState('Wakeup');
        }
    }
    else
    {
        seenCounter = FMax(seenCounter-deltaSeconds, 0);
    }
}

// friends till the end
function bool SetEnemy(Pawn newEnemy, optional float newSeenTime,
                       optional bool bForce)
{
    local Bobby friend;
    foreach RadiusActors(class'Bobby', friend, SpreadDistance+16) {
        friend._SetEnemy(newEnemy, newSeenTime, bForce);
    }
    return Super.SetEnemy(newEnemy, newSeenTime, bForce);
}

function bool _SetEnemy(Pawn newEnemy, optional float newSeenTime,
                       optional bool bForce)
{
    return Super.SetEnemy(newEnemy, newSeenTime, bForce);
}


event Bump( Actor Other )
{
    local vector momentum;
    local float scale;

    if(Other == lastBumpActor && lastBumpTime > Level.TimeSeconds-1) return;
    if(Other.Mass <= Mass) return;
    if(ScriptedPawn(Other) == None) return;

    lastBumpActor = Other;
    lastBumpTime = Level.TimeSeconds;

    scale = 10 * Loge(Other.Mass) * Loge(VSize(Other.Velocity));
    scale = FClamp(scale, 1000, 2000);
    momentum = Normal(Location - Other.Location) * scale;
    momentum.Z *= -2;
    ImpartMomentum(momentum, Pawn(Other));
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
    Mass=90
    Buoyancy=50
    WalkSound=Sound'DeusExSounds.Robot.SpiderBot2Walk'
    Health=150
    HealthHead=150
    HealthTorso=150
    HealthLegLeft=150
    HealthLegRight=150
    HealthArmLeft=150
    HealthArmRight=150
    bShowPain=False
    UnderWaterTime=-1.000000
    BindName="Bobby"
    MinHealth=10
    FleeHealth=10
    bInvincible=false
    bLeaveAfterFleeing=true
    bRegenHealth=False

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
    GroundSpeed=230.000000
    RotationRate=(Yaw=100000)
    BaseEyeHeight=15.6
    HitSound1=Sound'ChildPainMedium';
    HitSound2=Sound'ChildPainLarge';
    Die=Sound'ChildDeath';
    bKeepWeaponDrawn=False
    // faster jump scares
    SurprisePeriod=0.1
}
