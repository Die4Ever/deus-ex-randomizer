//Class to store original ZoneInfo values for Rando purposes
class DXRStoredZoneInfo extends Info;

var int VersionNum; //To theoretically help with upgrades if more information is added in this class

var bool bLevelInfo;
var bool bSkyZone;

//Properties
var() name   ZoneTag;
var() vector ZoneGravity;
var() vector ZoneVelocity;
var() float  ZoneGroundFriction;
var() float  ZoneFluidFriction;
var() float	 ZoneTerminalVelocity;
var() name   ZonePlayerEvent;
var() int	 DamagePerSec;
var() name	 DamageType;
var() string DamageString;
var() int	 MaxCarcasses;
var() sound  EntrySound;	//only if waterzone
var() sound  ExitSound;		// only if waterzone
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)

//Flags
var()		bool   bWaterZone;   // Zone is water-filled.
var()       bool   bFogZone;     // Zone is fog-filled.
var()       bool   bKillZone;    // Zone instantly kills those who enter.
var()		bool   bNeutralZone; // Players can't take damage in this zone.
var()		bool   bGravityZone; // Use ZoneGravity.
var()		bool   bPainZone;	 // Zone causes pain.
var()		bool   bDestructive; // Destroys carcasses.
var()		bool   bNoInventory;
var()		bool   bMoveProjectiles;	// this velocity zone should impart velocity to projectiles and effects
var()		bool   bBounceVelocity;		// this velocity zone should bounce actors that land in it


//Lighting
var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;
var(ZoneLight) color FogColor;
var(ZoneLight) float FogDistance;

var(ZoneLight) texture EnvironmentMap;
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;
var(ZoneLight) vector ViewFlash, ViewFog;


//Reverb
var(Reverb) bool bReverbZone;
var(Reverb) bool bRaytraceReverb;
var(Reverb) float SpeedOfSound;
var(Reverb) byte MasterGain;
var(Reverb) int  CutoffHz;
var(Reverb) byte Delay[6];
var(Reverb) byte Gain[6];


static function DXRStoredZoneInfo Init(ZoneInfo z)
{
    local int i;
    local DXRStoredZoneInfo szi;

    //Don't create a second stored zone info if one already exists
    szi=Find(z);
    if (szi!=None) return szi;

    szi = z.Spawn(class'DXRStoredZoneInfo',,,z.Location);

    szi.bLevelInfo = (LevelInfo(z)!=None);
    szi.bSkyZone = (SkyZoneInfo(z)!=None);

    szi.Tag = z.Tag;
    szi.Event = z.Event;
    szi.SetOwner(z);

    szi.ZoneTag = z.ZoneTag;
    szi.ZoneGravity = z.ZoneGravity;
    szi.ZoneVelocity = z.ZoneVelocity;
    szi.ZoneGroundFriction = z.ZoneGroundFriction;
    szi.ZoneFluidFriction = z.ZoneFluidFriction;
    szi.ZoneTerminalVelocity = z.ZoneTerminalVelocity;
    szi.ZonePlayerEvent = z.ZonePlayerEvent;
    szi.DamagePerSec = z.DamagePerSec;
    szi.DamageType = z.DamageType;
    szi.DamageString = z.DamageString;
    szi.MaxCarcasses = z.MaxCarcasses;
    szi.EntrySound = z.EntrySound;
    szi.ExitSound = z.ExitSound;
    szi.EntryActor = z.EntryActor;
    szi.ExitActor = z.ExitActor;

    szi.bWaterZone = z.bWaterZone;
    szi.bFogZone = z.bFogZone;
    szi.bKillZone = z.bKillZone;
    szi.bNeutralZone = z.bNeutralZone;
    szi.bGravityZone = z.bGravityZone;
    szi.bPainZone = z.bPainZone;
    szi.bDestructive = z.bDestructive;
    szi.bNoInventory = z.bNoInventory;
    szi.bMoveProjectiles = z.bMoveProjectiles;
    szi.bBounceVelocity = z.bBounceVelocity;

    szi.AmbientBrightness = z.AmbientBrightness;
    szi.AmbientHue = z.AmbientHue;
    szi.AmbientSaturation = z.AmbientSaturation;
    szi.FogColor = z.FogColor;
    szi.FogDistance = z.FogDistance;

    szi.EnvironmentMap = z.EnvironmentMap;
    szi.TexUPanSpeed = z.TexUPanSpeed;
    szi.TexVPanSpeed = z.TexVPanSpeed;
    szi.ViewFlash = z.ViewFlash;
    szi.ViewFog = z.ViewFog;

    szi.bReverbZone = z.bReverbZone;
    szi.bRaytraceReverb = z.bRaytraceReverb;
    szi.SpeedOfSound = z.SpeedOfSound;
    szi.MasterGain = z.MasterGain;
    szi.CutoffHz = z.CutoffHz;
    for (i=0;i<ArrayCount(szi.Delay);i++){
        szi.Delay[i]=z.Delay[i];
    }
    for (i=0;i<ArrayCount(szi.Gain);i++){
        szi.Gain[i]=z.Gain[i];
    }


    return szi;
}

static function bool IsFogZone(ZoneInfo z)
{
    local DXRStoredZoneInfo szi;

    if (z.bFogZone) return True;

    foreach z.ZoneActors(class'DXRStoredZoneInfo',szi){
        if (szi.bFogZone) return True;
    }

    return False;
}

static function DXRStoredZoneInfo Find(ZoneInfo z)
{
    local DXRStoredZoneInfo szi;
    local bool isLevelInfo;

    isLevelInfo = (LevelInfo(z)!=None);

    foreach z.ZoneActors(class'DXRStoredZoneInfo',szi){
        if (isLevelInfo){
            if (szi.bLevelInfo){
                return szi;
            }
        } else {
            if (!szi.bLevelInfo){
                return szi;
            }
        }
    }

    return None;
}

defaultproperties
{
    VersionNum=1
    bAlwaysRelevant=True
}
