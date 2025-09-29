class MrH extends DXRStalker;

var float proxyHeight;

// for bumping pawns
var Actor lastBumpActor;
var float lastBumpTime;

static function DXRStalker Create(DXRActorsBase a)
{
    local MrH h;

    h = MrH(Super.Create(a));
    if(h==None) return None;

    class'DamageProxy'.static.Create(h, h.proxyHeight);
    h.ResetBasedPawnSize();
    return h;
}

state Wandering
{
    // HACK: for save game compatibility
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

event Bump( Actor Other )
{
    if(Teleporter(Other) != None || #var(prefix)MapExit(Other) != None) {
        Other.SetCollision( Other.bCollideActors, false, Other.bBlockPlayers );
    } else if(Decoration(Other) != None) {
        BumpDamage(Other, 55, 1000);
    } else if(ScriptedPawn(Other) != None) {
        BumpDamage(Other, 1, 70000);
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
    Buoyancy=1005
    WalkSound=Sound'DeusExSounds.Robot.MilitaryBotWalk'
    Health=1000
    HealthHead=1000
    HealthTorso=1000
    HealthLegLeft=1000
    HealthLegRight=1000
    HealthArmLeft=1000
    HealthArmRight=1000
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
    bKeepWeaponDrawn=True // maybe faster response?
    Alliance=MrH
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1,bPermanent=True)
    HearingThreshold=0
    walkAnimMult=0.75
    runAnimMult=0.9
    bCanStrafe=false
    CarcassType=Class'MrHCarcass'
    WalkingSpeed=0.350000
    BurnPeriod=0.000000
    GroundSpeed=210.000000
    BaseEyeHeight=44.000000
}
