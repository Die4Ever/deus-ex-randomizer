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
        if( #var prefix AllianceTrigger(a) != None ) {
            ReplaceAllianceTrigger(#var prefix AllianceTrigger(a));
        }
        if( #var prefix ClothesRack(a) != None ) {
            ReplaceClothesRack(#var prefix ClothesRack(a));
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
#ifndef hx
    local GMDXGepGun n;

    if(GMDXGepGun(a) != None)
        return;

    n = GMDXGepGun(SpawnReplacement(a, class'GMDXGepGun'));
    if(n == None)
        return;

    ReplaceWeapon(a, n);
#endif
}

function ReplaceAllianceTrigger(#var prefix AllianceTrigger a)
{
    local DXRAllianceTrigger n;
    local int i;

    if(DXRAllianceTrigger(a) != None)
        return;

    n = DXRAllianceTrigger(SpawnReplacement(a, class'DXRAllianceTrigger'));
    if(n == None)
        return;

    n.Alliance = a.Alliance;
    for(i=0; i<ArrayCount(a.Alliances); i++) {
        n.Alliances[i].AllianceName = a.Alliances[i].AllianceName;
        n.Alliances[i].AllianceLevel = a.Alliances[i].AllianceLevel;
        n.Alliances[i].bPermanent = a.Alliances[i].bPermanent;
    }

    ReplaceTrigger(a, n);
}

function ReplaceClothesRack(#var prefix ClothesRack a)
{
    local DXRClothesRack n;

    if(DXRClothesRack(a) != None)
        return;

    n = DXRClothesRack(SpawnReplacement(a, class'DXRClothesRack'));
    if(n == None)
        return;

    n.SkinColor = a.SkinColor;
    n.Skin = a.Skin;
    // probably doesn't need this since it's all defaults
    //ReplaceDecoration(a, n);
#ifdef hx
    n.PrecessorName = a.PrecessorName;
#endif
}

function ReplaceTrigger(#var prefix Trigger a, #var prefix Trigger n)
{
    n.TriggerType = a.TriggerType;
    n.Message = a.Message;
    n.bTriggerOnceOnly = a.bTriggerOnceOnly;
    n.bInitiallyActive = a.bInitiallyActive;
    n.ClassProximityType = a.ClassProximityType;
    n.RepeatTriggerTime = a.RepeatTriggerTime;
    n.ReTriggerDelay = a.ReTriggerDelay;
    n.TriggerTime = a.TriggerTime;
    n.DamageThreshold = a.DamageThreshold;
    n.TriggerActor = a.TriggerActor;
    n.TriggerActor2 = a.TriggerActor2;
#ifdef hx
    n.PrecessorName = a.PrecessorName;
#endif
}

#ifdef hx
function HXWeapon ReplaceWeapon(HXWeapon a, HXWeapon n)
#else
function DeusExWeapon ReplaceWeapon(DeusExWeapon a, DeusExWeapon n)
#endif
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
#ifdef hx
    n.PrecessorName = a.PrecessorName;
#endif
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
