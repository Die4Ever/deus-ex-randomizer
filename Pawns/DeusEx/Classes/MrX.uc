class MrX extends HumanMilitary;

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

//
// Damage type table for Mr X (Copied from Gunther):
//
// Shot			- 100%
// Sabot		- 100%
// Exploded		- 100%
// TearGas		- 10%
// PoisonGas	- 10%
// Poison		- 10%
// HalonGas		- 10%
// Radiation	- 10%
// Shocked		- 10%
// Stunned		- 0%
// KnockedOut   - 0%
// Flamed		- 0%
// Burned		- 0%
// NanoVirus	- 0%
// EMP			- 0%
//

//Copied from GuntherHermann
function float ShieldDamage(name damageType)
{
    // handle special damage types
    if ((damageType == 'Flamed') || (damageType == 'Burned') || (damageType == 'Stunned') ||
        (damageType == 'KnockedOut'))
        return 0.0;
    else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas') ||
            (damageType == 'Radiation') || (damageType == 'Shocked') || (damageType == 'Poison') ||
            (damageType == 'PoisonEffect'))
        return 0.1;
    else
        return Super.ShieldDamage(damageType);
}

//Copied from GuntherHermann
function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    if (!bCollideActors && !bBlockActors && !bBlockPlayers)
        return;
    if (CanShowPain())
        TakeHit(hitPos);
    else
        GotoNextState();
}

//Copied from GuntherHermann, only to demonstrate that Mr X doesn't explode
//(also he shouldn't really die, but...)
/*
function Carcass SpawnCarcass()
{
    if (bStunned)
        return Super.SpawnCarcass();

    Explode();

    return None;
}
*/

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
    Texture=Texture'DeusExItems.Skins.BlackMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_DressShirt_B'
    MultiSkins(0)=Texture'MrXShirt'
    MultiSkins(1)=Texture'MrXPants'
    MultiSkins(2)=Texture'MrXFace'
    MultiSkins(3)=Texture'MrXFace'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExItems.Skins.BlackMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
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
    CarcassType=Class'MrXCarcass'
    WalkingSpeed=0.350000
    bImportant=True
    BurnPeriod=0.000000
    GroundSpeed=210.000000
    BaseEyeHeight=44.000000
}
