class DXRReplaceActors extends DXRActorsBase;

function PostFirstEntry()
{
    Super.PostFirstEntry();
    ReplaceActors();
}

function ReplaceActors()
{
    local Actor a;
    foreach AllActors(class'Actor', a) {
        if( #var prefix InformationDevices(a) != None ) {
            ReplaceInformationDevice(#var prefix InformationDevices(a));
        }
#ifdef gmdx
        if( WeaponGEPGun(a) != None ) {
            ReplaceGepGun(WeaponGEPGun(a));
        }
#endif
    }
}

function ReplaceInformationDevice(#var prefix InformationDevices a)
{
    local DXRInformationDevices n;

    if( DXRInformationDevices(a) != None )
        return;

    n = DXRInformationDevices(SpawnReplacement(a, class'DXRInformationDevices'));
    if(n == None)
        return;

    n.bAddToVault = a.bAddToVault;
    n.TextPackage = a.TextPackage;
    n.textTag = a.textTag;
    n.imageClass = a.imageClass;
    n.msgNoText = a.msgNoText;
    n.ImageLabel = a.ImageLabel;
    n.AddedToDatavaultLabel = a.AddedToDatavaultLabel;
    ReplaceDeusExDecoration(a, n);

    a.Destroy();
}

function ReplaceGEPGun(WeaponGEPGUN a)
{
    local GMDXGepGun n;

    if(GMDXGepGun(a) != None)
        return;

    n = GMDXGepGun(SpawnReplacement(a, class'GMDXGepGun'));
    if(n == None)
        return;

    ReplaceWeapon(a, n);
}

function DeusExWeapon ReplaceWeapon(DeusExWeapon a, DeusExWeapon n)
{
    local ScriptedPawn owner;
    local bool bWasDrawn;
    owner = ScriptedPawn(a.Owner);
    if(owner != None && owner.Weapon == a) {
        bWasDrawn = true;
    }
    a.Destroy();
    if(owner != None) {
        GiveExistingItem(owner, n);
        if(bWasDrawn) {
            owner.SetupWeapon(true, true);
            owner.SetWeapon(n);
        }
    }
}

#ifdef hx
function ReplaceDeusExDecoration(HXDecoration a, HXDecoration n)
#else
function ReplaceDeusExDecoration(DeusExDecoration a, DeusExDecoration n)
#endif
{
#ifdef hx
    n.PrecessorName = a.PrecessorName;
    n.bClientHighlight = a.bClientHighlight;
#endif
    n.bInvincible = a.bInvincible;
    n.HitPoints = a.HitPoints;
    n.minDamageThreshold = a.minDamageThreshold;
    n.FragType = a.FragType;
    n.bFlammable = a.bFlammable;
    n.Flammability = a.Flammability;
    n.explosionDamage = a.explosionDamage;
    n.explosionRadius = a.explosionRadius;
    n.bHighlight = a.bHighlight;
    n.ItemArticle = a.ItemArticle;
    n.ItemName = a.ItemName;
    n.bTravel = a.bTravel;
    n.bFloating = a.bFloating;
    n.origRot = a.origRot;
    n.moverTag = a.moverTag;
    n.bCanBeBase = a.bCanBeBase;
    n.bGenerateFlies = a.bGenerateFlies;
    n.pushSoundId = a.pushSoundId;

    ReplaceDecoration(a, n);
}

function ReplaceDecoration(Decoration a, Decoration n)
{
    n.bPushable = a.bPushable;
    n.EffectWhenDestroyed = a.EffectWhenDestroyed;
    /*
var() bool bOnlyTriggerable;
var bool bSplash;
var bool bBobbing;
var bool bWasCarried;
var() sound PushSound;
var const int	 numLandings; // Used by engine physics.
var() class<inventory> contents;
var() class<inventory> content2;
var() class<inventory> content3;
var() sound EndPushSound;
var bool bPushSoundPlaying;

// DEUS_EX AJY
// Converstion Crap
var Float   BaseEyeHeight;
*/
}
