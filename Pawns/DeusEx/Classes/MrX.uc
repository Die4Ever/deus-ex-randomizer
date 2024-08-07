class MrX extends GuntherHermann;

var float healthRegen;
var NavigationPoint nextTarget, farthestStart, closestStart, midStart;
var float lastMoveTime, lastCheckMoveTime;
var vector targetDirection;
var #var(PlayerPawn) player;

static function MrX Create(DXRActorsBase a)
{
    local vector loc;
    local MrX x;
    local int i;

    // Mr. X is a singleton
    foreach a.AllActors(class'MrX', x) {
        x.Destroy();
    }

    a.SetSeed("Mr. X");// should this be seeded or not?

    x = None;
    for(i=0; i<100 && x == None; i++) {
        loc = a.GetRandomPosition(a.player().Location, 16*150, 999999);
        x = a.Spawn(class'MrX',,, loc);
    }
    if(x != None) {
        x.player = a.player();
        x.SetLocation(loc);
        x.HomeLoc = loc;
        x.bUseHome = true;
        x.InitTargetDirection();
    }

    return x;
}


function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    //class'DXRAnimTracker'.static.Create(self, "hat");

    GetTarget(Location, HomeExtent);
}

function InitTargetDirection()
{
    local NavigationPoint p;
    local vector total;
    local float dist, maxDist, minDist;
    local int num;

    minDist = 999999;
    foreach AllActors(class'NavigationPoint', p) {
        if(p.bPlayerOnly) continue;
        total += p.Location;
        num++;
        dist = VSize(Location - p.Location);
        if(dist > maxDist) {
            maxDist = dist;
            farthestStart = p;
        }
        if(dist < minDist) {
            minDist = dist;
            closestStart = p;
        }
    }
    targetDirection = total / num;
    midStart = GetClosestPoint(targetDirection, HomeExtent);
    targetDirection = Normal(targetDirection-Location);
    //player.ClientMessage("InitTargetDirection() " $ targetDirection);
    //player.ClientMessage("InitTargetDirection() " $ closestStart @ midStart @ farthestStart);
}

function NavigationPoint GetClosestPoint(vector loc, float radius)
{
    local float dist, minDist;
    local NavigationPoint closest, p;

    minDist = 999999;
    foreach RadiusActors(class'NavigationPoint', p, radius, loc) {
        if(p.bPlayerOnly) continue;
        dist = VSize(loc - p.Location);
        if(dist < minDist) {
            minDist = dist;
            closest = p;
        }
    }
    return closest;
}

function NavigationPoint GetClosestReachablePoint(Actor from, float radius)
{
    local float dist, minDist;
    local NavigationPoint closest, p;

    minDist = 999999;
    foreach ReachablePathnodes(class'NavigationPoint', p, from, dist) {
        if(p.bPlayerOnly) continue;
        if(dist > radius) continue;
        if(dist < minDist) {
            minDist = dist;
            closest = p;
        }
    }
    return closest;
}

function GetTarget(vector loc, float radius)
{
    local NavigationPoint closest;

    closest = GetClosestPoint(loc, radius);
    if(nextTarget != closest && closest != None) {
        HomeLoc = closest.Location;
        bUseHome = true;
        lastMoveTime = Level.TimeSeconds;
        nextTarget = closest;
    }
}

function UpdateTarget()
{
    local float delta, radius;
    local NavigationPoint p;
    local vector loc;

    lastCheckMoveTime = Level.TimeSeconds;
    delta = Level.TimeSeconds - lastMoveTime;
    loc = HomeLoc + targetDirection * delta * 16;// 1 foot per second?
    radius = HomeExtent * delta * 0.1;

    //player.ClientMessage("UpdateTarget() HomeLoc: " $ HomeLoc );
    //player.ClientMessage("UpdateTarget() goal loc: " $ loc );
    //player.ClientMessage("UpdateTarget() delta: " $ delta );

    GetTarget(loc, radius);

    /*if(VSize(HomeLoc - Location) > HomeExtent && GetStateName()=='Wandering') {
        p = GetClosestPoint((HomeLoc+Location)/2, HomeExtent);
        if(p != None) {
            HomeLoc = p.Location;
            bUseHome = true;
        }
        SetLocation(HomeLoc);
    }*/
}

function Tick(float delta)
{
    Super.Tick(delta);

    LastRenderTime = Level.TimeSeconds;
    bStasis = false;

    healthRegen += delta;
    if(healthRegen > 1) {
        healthRegen = 0;
        HealthHead += 10;
        HealthTorso += 10;
        HealthArmLeft += 10;
        HealthArmRight += 10;
        HealthLegLeft += 10;
        HealthLegRight += 10;
#ifdef injections
        EmpHealth = FClamp(EmpHealth + 10, 0, default.EmpHealth);
#endif
        GenerateTotalHealth();
    }

    if(Level.TimeSeconds - lastCheckMoveTime > 5) {
        UpdateTarget();
    }
}

// only walking animation
function TweenToRunning(float tweentime)
{
//	ClientMessage("TweenToRunning()");
    bIsWalking = False;
    if (Region.Zone.bWaterZone)
        LoopAnimPivot('Tread',, tweentime,, GetSwimPivot());
    else
    {
        if (HasTwoHandedWeapon())
            LoopAnimPivot('Walk2H', runAnimMult, tweentime);
        else
            LoopAnimPivot('Walk', runAnimMult, tweentime);
    }
}


function PlayRunning()
{
//	ClientMessage("PlayRunning()");
    bIsWalking = False;
    if (Region.Zone.bWaterZone)
        LoopAnimPivot('Tread',,,,GetSwimPivot());
    else
    {
        if (HasTwoHandedWeapon())
            LoopAnimPivot('Walk2H', runAnimMult);
        else
            LoopAnimPivot('Walk', runAnimMult);
    }
}


function GenerateTotalHealth()
{
    // you can hurt him but you can't kill him
    HealthHead     = FClamp(HealthHead, MinHealth/2, default.HealthHead);
    HealthTorso    = FClamp(HealthTorso, MinHealth/2, default.HealthTorso);
    HealthArmLeft  = FClamp(HealthArmLeft, MinHealth/2, default.HealthArmLeft);
    HealthArmRight = FClamp(HealthArmRight, MinHealth/2, default.HealthArmRight);
    HealthLegLeft  = FClamp(HealthLegLeft, MinHealth/2, default.HealthLegLeft);
    HealthLegRight = FClamp(HealthLegRight, MinHealth/2, default.HealthLegRight);
    Super.GenerateTotalHealth();
    Health = FClamp(Health, MinHealth/2, default.Health);
}


function PlayFootStep()
{
    local CCResidentEvilCam cam;

    Super.PlayFootStep();

    foreach AllActors(class'CCResidentEvilCam', cam) {
        cam.JoltView();// TODO: also make this work for 3rd person
    }
}

defaultproperties
{
    DrawScale=1.3
    CollisionRadius=28.6
    CollisionHeight=65.78
    Mass=1000
    WalkSound=Sound'DeusExSounds.Robot.MilitaryBotWalk'
    Health=2000
    HealthHead=2000
    HealthTorso=2000
    HealthLegLeft=2000
    HealthLegRight=2000
    HealthArmLeft=2000
    HealthArmRight=2000
    bShowPain=False
    BindName="MrX"
    MinHealth=100
    bImportant=false
    bInvincible=false
    FamiliarName="Mr. X"
    UnfamiliarName="Mr. X"

    InitialInventory(0)=(Inventory=class'WeaponMrXPunch')
    InitialInventory(1)=(Inventory=None)
    InitialInventory(2)=(Inventory=None)
    InitialInventory(3)=(Inventory=None)
    InitialInventory(4)=(Inventory=None)

    Alliance=MrX
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1,bPermanent=True)

    HearingThreshold=0
    RandomWandering=1
    Wanderlust=0.01
    HomeExtent=5000
    bUseHome=true
    bStasis=false

    walkAnimMult=0.75
    runAnimMult=0.9
    bCanStrafe=false
    bEmitDistress=false
    bLookingForLoudNoise=true
    bReactLoudNoise=true
}
