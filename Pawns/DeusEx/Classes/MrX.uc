class MrX extends GuntherHermann;

var float healthRegen;

static function MrX Create(DXRActorsBase a)
{
    local vector loc;
    local MrX m;

    // Mr. X is a singleton
    foreach a.AllActors(class'MrX', m) {
        m.Destroy();
    }

    a.SetSeed("Mr. X");
    loc = a.GetRandomPosition(a.player().Location, 16*150, 9999999);

    m = a.Spawn(class'MrX',,, loc);

    return m;
}

/*
function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    class'DXRAnimTracker'.static.Create(self, "hat");
}
*/

function Tick(float delta)
{
    Super.Tick(delta);

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
    RandomWandering=0.1
    Wanderlust=3

    walkAnimMult=0.75
    runAnimMult=0.9
    bCanStrafe=false
    bEmitDistress=false
    bLookingForLoudNoise=true
    bReactLoudNoise=true
}
