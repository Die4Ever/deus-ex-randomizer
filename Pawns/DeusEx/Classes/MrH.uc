class MrH extends HumanMilitary;

var float healthRegenTimer, empRegenTimer;
var #var(PlayerPawn) player;
var int FleeHealth;// like MinHealth, but we need more control
var Actor closestDestPoint, farthestDestPoint;
var float maxDist; // for iterative farthestDestPoint
var float proxyHeight;

// for bumping pawns
var Actor lastBumpActor;
var float lastBumpTime;

static function MrH Create(DXRActorsBase a)
{
    local vector loc;
    local MrH h;
    local int i;

    // Mr. H is a singleton
    foreach a.AllActors(class'MrH', h) {
        h.Destroy();
    }

    a.SetSeed("Mr. H");// should this be seeded or not?

    h = None;
    for(i=0; i<100 && h == None; i++) {
        loc = a.GetRandomPosition(a.player().Location, 16*100, 999999);
        h = a.Spawn(class'MrH',,, loc);
    }
    if(h == None) return None;

    h.player = a.player();
    h.HomeLoc = loc;
    h.bUseHome = true;

    class'DamageProxy'.static.Create(h, h.proxyHeight);
    h.ResetBasedPawnSize();
    return h;
}

//
// Damage type table for Mr H (Copied from Gunther):
//
// Shot			- 100%
// Sabot		- 100%
// Exploded		- 100%
// TearGas		- 10%
// PoisonGas	- 10%
// HalonGas		- 10%
// Radiation	- 10%
// Shocked		- 10%
// Stunned		- 0%
// KnockedOut   - 0%
// Flamed		- 0%
// Burned		- 0%
// NanoVirus	- 0%
// EMP			- 0%
// delted: Poison 10%
//

//Copied from GuntherHermann
function float ShieldDamage(name damageType)
{
    // handle special damage types
    if ((damageType == 'Flamed') || (damageType == 'Burned') || (damageType == 'Stunned') ||
        (damageType == 'KnockedOut'))
        return 0.0;
    else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas') ||
            (damageType == 'Radiation') || (damageType == 'Shocked'))
        return 0.1;
    else
        return Super.ShieldDamage(damageType);
}

// Exploded damage reduced here so no shield graphic, so players don't think he's immune
#ifdef revision
function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType, optional bool bTestOnly)
{
    if (damageType == 'Exploded')
        Damage *= 0.7;
    return Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType, bTestOnly);
}
#else
function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
{
    if (damageType == 'Exploded')
        Damage *= 0.7;
    return Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
}
#endif

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

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    //class'DXRAnimTracker'.static.Create(self, "hat");
}

function Actor GetFarthestNavPoint(Actor from, optional int iters)
{
    local Actor farthest, t;
    local NavigationPoint p;
    local float dist;

    dist = VSize(closestDestPoint.Location-from.Location);
    if(dist > maxDist) {
        maxDist = dist;
        farthest = from;
    }

    if(iters > 3) return farthest;

    foreach ReachablePathnodes(class'NavigationPoint', p, from, dist) {
        t = GetFarthestNavPoint(p, iters+1);
        if(t != None) {
            farthest = t;
        }
    }

    return farthest;
}

function InitializePawn()
{
    local NavigationPoint p, closest;
    local float dist, minDist;
    local int i;

    Super.InitializePawn();

    minDist = 999999;
    foreach RadiusActors(class'NavigationPoint', p, 1600) {
        if(p.bPlayerOnly) continue;
        if(GetNextWaypoint(p)==None) continue;
        dist = VSize(Location - p.Location);
        if(dist < minDist) {
            minDist = dist;
            closest = p;
        }
    }

    closestDestPoint = closest;

    SetOrders('Wandering');
}

function Tick(float delta)
{
    local int i;

    Super.Tick(delta);

    LastRenderTime = Level.TimeSeconds;
    bStasis = false;

    healthRegenTimer += delta;
    if(healthRegenTimer > 2) {
        healthRegenTimer = 0;
        i = 20;

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
            i = 10;
        }

        HealthHead += i;
        HealthTorso += i;
        HealthArmLeft += i;
        HealthArmRight += i;
        HealthLegLeft += i;
        HealthLegRight += i;
        GenerateTotalHealth();
    }

    empRegenTimer += delta;
    if(empRegenTimer > 30) {
        empRegenTimer = 0;
        #ifdef injections
        EmpHealth = FClamp(EmpHealth + 10, 0, default.EmpHealth);
        #endif
    }
}


state Wandering
{
    #ifdef vmd
    function bool PickDestination()
    #else
    function PickDestination()
    #endif
    {
        local Actor   target;
        local int     iterations;
        local float   magnitude, dist1, dist2;
        local rotator rot1;

        if(closestDestPoint != None) {
            target = GetFarthestNavPoint(self);
        }
        if(target != None) {
            farthestDestPoint = target;
        }

        if(farthestDestPoint == None || closestDestPoint == None) {
            #ifdef vmd
            return Super.PickDestination();
            #else
            Super.PickDestination();
            return;
            #endif
        }

        target = farthestDestPoint;
        dist1 = VSize(Location - farthestDestPoint.Location);
        dist2 = VSize(Location - closestDestPoint.Location);

        if(dist1 < dist2*0.1) {
            // swap target
            target = closestDestPoint;
            closestDestPoint = farthestDestPoint;
            farthestDestPoint = target;
            dist1 = dist2;
        }

        if (dist1 > 16)
        {
            target = FindPathToward(farthestDestPoint);
            if(target == None) {
                target = farthestDestPoint;
            }
        }

        if(target == None) {
            #ifdef vmd
            return Super.PickDestination();
            #else
            Super.PickDestination();
            return;
            #endif
        }

        iterations = 5;
        magnitude  = 4000*(FRand()*0.4+0.8);  // 4000, +/-20%
        rot1       = Rotator(Location - target.Location);
        rot1.Yaw  += 32768; // looking towards target

        destLoc = target.Location;

        if (!AIPickRandomDestination(100, magnitude, rot1.Yaw, 0.8, -rot1.Pitch, 0.8, iterations,
                                        FRand()*0.4+0.35, destLoc))
        {
            target = FindPathToward(farthestDestPoint);
            if(target != None) destLoc = target.Location;
            else {
                #ifdef vmd
                return Super.PickDestination();
                #else
                Super.PickDestination();
                return;
                #endif
            }
        }

        #ifdef vmd
        return true;
        #endif
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
    bInvincible    = false;// damageproxy hack, GenerateTotalHealth() sets health to maximum when invincible
    Super.GenerateTotalHealth();
    bInvincible    = true;// damageproxy hack
    Health = FClamp(Health, FleeHealth/2, default.Health);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    if(damageType == 'EMP') empRegenTimer=0;
    else if(health < MinHealth) return;
    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function bool ShouldDropWeapon()
{
    return false;
}

event Bump( Actor Other )
{
    if(Teleporter(Other) != None || #var(prefix)MapExit(Other) != None) {
        Other.SetCollision( Other.bCollideActors, false, Other.bBlockPlayers );
    } else if(Decoration(Other) != None) {
        BumpDamage(Other, 55, 1000);
    } else if(ScriptedPawn(Other) != None) {
        BumpDamage(Other, 1, 20000);
    } else if(DamageProxy(Other) != None) {
        return;
    }

    Super.Bump(Other);
}

function BumpDamage(Actor Other, int damage, float momentum)
{
    if(Other != lastBumpActor || lastBumpTime < Level.TimeSeconds-1) {
        Other.TakeDamage(damage, None, Location, Vect(0,1,0.5)*momentum, 'Shot');
        lastBumpActor = Other;
        lastBumpTime = Level.TimeSeconds;
    }
}

function PlayFootStep()
{
    local CCResidentEvilCam cam;

    Super.PlayFootStep();

    if(!#defined(injections)) { // for injections, we already do this inside our ScriptedPawn.uc
        foreach RadiusActors(class'CCResidentEvilCam', cam, 800) {
            cam.JoltView();// TODO: also make this work for 3rd person
        }
    }
}

function ResetBasedPawnSize()
{
    SetBasedPawnSize(Default.CollisionRadius - 4, GetDefaultCollisionHeight() - proxyHeight);
}

function Timer()
{
    bInvincible=false;// damageproxy hack
    Super.Timer();
    bInvincible=true;
}

#ifdef revision
function EHitLocation HandleDamage(int Damage, Vector hitLocation, Vector offset, name damageType, optional bool bAnimOnly)
{
    if(offset!=vect(0,0,0)) offset.Z -=  proxyHeight/2;
    return Super.HandleDamage(Damage, hitLocation, offset, damageType, bAnimOnly);
}
#elseif gmdx
function EHitLocation HandleDamage(int actualDamage, Vector hitLocation, Vector offset, name damageType, optional Pawn instigatedBy)
{
    if(offset!=vect(0,0,0)) offset.Z -=  proxyHeight/2;
    return Super.HandleDamage(actualDamage, hitLocation, offset, damageType, instigatedBy);
}
#else
function EHitLocation HandleDamage(int actualDamage, Vector hitLocation, Vector offset, name damageType)
{
    if(offset!=vect(0,0,0)) offset.Z -=  proxyHeight/2;
    return Super.HandleDamage(actualDamage, hitLocation, offset, damageType);
}
#endif


// collision radius 1.0 is 22, height is 50.6
defaultproperties
{
    DrawScale=1.3
    CollisionRadius=25
    CollisionHeight=60
    proxyHeight=12
    Mass=1000
    WalkSound=Sound'DeusExSounds.Robot.MilitaryBotWalk'
    Health=1800
    HealthHead=1800
    HealthTorso=1800
    HealthLegLeft=1800
    HealthLegRight=1800
    HealthArmLeft=1800
    HealthArmRight=1800
    bShowPain=False
    UnderWaterTime=-1.000000
    BindName="MrH"
    MinHealth=100
    FleeHealth=100
    bInvincible=false
    FamiliarName="Mr. H"
    UnfamiliarName="Mr. H"
    Texture=Texture'DeusExItems.Skins.BlackMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_DressShirt_B'
    MultiSkins(0)=Texture'MrHShirt'
    MultiSkins(1)=Texture'MrHPants'
    MultiSkins(2)=Texture'MrHFace'
    MultiSkins(3)=Texture'MrHFace'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExItems.Skins.BlackMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
    InitialInventory(0)=(Inventory=class'WeaponMrHPunch')
    InitialInventory(1)=(Inventory=None)
    InitialInventory(2)=(Inventory=None)
    InitialInventory(3)=(Inventory=None)
    InitialInventory(4)=(Inventory=None)
    Alliance=MrH
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1,bPermanent=True)
    HearingThreshold=0
    RandomWandering=0.3
    Wanderlust=0.01
    HomeExtent=20000
    bUseHome=false
    bStasis=false
    walkAnimMult=0.75
    runAnimMult=0.9
    bCanStrafe=false
    bEmitDistress=false
    bLookingForLoudNoise=true
    bReactLoudNoise=true
    CarcassType=Class'MrHCarcass'
    WalkingSpeed=0.350000
    bImportant=True
    BurnPeriod=0.000000
    GroundSpeed=210.000000
    BaseEyeHeight=44.000000
}
