class MrX extends GuntherHermann;

var float healthRegenTimer;
var #var(PlayerPawn) player;
var int FleeHealth;// like MinHealth, but we need more control

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
    if(x == None) return None;

    x.player = a.player();
    x.HomeLoc = loc;
    x.bUseHome = true;

    return x;
}

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    //class'DXRAnimTracker'.static.Create(self, "hat");
}

function InitializePawn()
{
    local NavigationPoint p, farthest, closest;
    local float dist, maxDist, minDist;
    local int i;
    local DXREnemiesPatrols patrols;

    Super.InitializePawn();

    minDist = 999999;
    foreach AllActors(class'NavigationPoint', p) {
        if(p.bPlayerOnly) continue;
        dist = VSize(Location - p.Location);
        if(dist > maxDist) {
            maxDist = dist;
            farthest = p;
        }
        if(dist < minDist) {
            minDist = dist;
            closest = p;
        }
    }

    foreach AllActors(class'DXREnemiesPatrols', patrols) { break; }

    dist = VSize(closest.Location - farthest.Location);
    for(i=0; i<10; i++) {
        if(patrols._GivePatrol(self, dist, 0.5, 1.5, 1600, 0, true)) return;
    }
}

function Tick(float delta)
{
    Super.Tick(delta);

    LastRenderTime = Level.TimeSeconds;
    bStasis = false;

    healthRegenTimer += delta;
    if(healthRegenTimer > 1) {
        healthRegenTimer = 0;

        if(health < FleeHealth) {
            MinHealth = default.health/2;
            bDetectable=false;
            bIgnore=true;
            Visibility=0;
        } else if(health > MinHealth) {
            MinHealth = default.MinHealth;
            bDetectable=true;
            bIgnore=false;
            Visibility=default.Visibility;
        }

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
    HealthHead     = FClamp(HealthHead, FleeHealth/2, default.HealthHead);
    HealthTorso    = FClamp(HealthTorso, FleeHealth/2, default.HealthTorso);
    HealthArmLeft  = FClamp(HealthArmLeft, FleeHealth/2, default.HealthArmLeft);
    HealthArmRight = FClamp(HealthArmRight, FleeHealth/2, default.HealthArmRight);
    HealthLegLeft  = FClamp(HealthLegLeft, FleeHealth/2, default.HealthLegLeft);
    HealthLegRight = FClamp(HealthLegRight, FleeHealth/2, default.HealthLegRight);
    Super.GenerateTotalHealth();
    Health = FClamp(Health, FleeHealth/2, default.Health);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    if(health < MinHealth) return;
    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function bool ShouldDropWeapon()
{
    return false;
}

function PlayFootStep()
{
    local CCResidentEvilCam cam;

    Super.PlayFootStep();

    foreach AllActors(class'CCResidentEvilCam', cam) {
        cam.JoltView();// TODO: also make this work for 3rd person
    }
}

// collision radius 1.0 is 22, height is 50.6
defaultproperties
{
    DrawScale=1.3
    CollisionRadius=25
    CollisionHeight=58
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
    FleeHealth=100
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
    RandomWandering=0.3
    Wanderlust=0.01
    HomeExtent=2000
    bUseHome=true
    bStasis=false
    walkAnimMult=0.75
    runAnimMult=0.9
    bCanStrafe=false
    bEmitDistress=false
    bLookingForLoudNoise=true
    bReactLoudNoise=true
}
