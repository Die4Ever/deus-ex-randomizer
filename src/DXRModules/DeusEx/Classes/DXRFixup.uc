class DXRFixup expands DXRActorsBase transient;

struct DecorationsOverwrite {
    var string type;
    var bool bInvincible;
    var int HitPoints;
    var int minDamageThreshold;
    var bool bFlammable;
    var float Flammability; // how long does the object burn?
    var bool bExplosive;
    var int explosionDamage;
    var float explosionRadius;
    var bool bPushable;
};

var DecorationsOverwrite DecorationsOverwrites[16];
var class<DeusExDecoration> DecorationsOverwritesClasses[16];

struct AddDatacube {
    var string text;
    var vector location;// 0,0,0 for random
    var class<DataVaultImage> imageClass;
    var rotator rotation;
    var string plaintextTag;
    // spawned in PreFirstEntry, so if you set a location then it will be moved according to the logic of DXRPasswords
};
var AddDatacube add_datacubes[32];

struct FragmentGuess {
    var Sound sound;
    var class<Fragment> fragmentClass;
};
var FragmentGuess fragmentGuesses[25];

static function class<DXRBase> GetModuleToLoad(DXRando dxr, class<DXRBase> request)
{
    switch(dxr.dxInfo.missionNumber) {
    case 0:
        return class'DXRFixupM00';
    case 1:
        return class'DXRFixupM01';
    case 2:
        return class'DXRFixupM02';
    case 3:
        return class'DXRFixupM03';
    case 4:
        return class'DXRFixupM04';
    case 5:
        return class'DXRFixupM05';
    case 6:
        return class'DXRFixupM06';
    case 8:
        return class'DXRFixupM08';
    case 9:
        return class'DXRFixupM09';
    case 10:
    case 11:
        return class'DXRFixupParis';
    case 12:
    case 14:
        return class'DXRFixupVandenberg';
    case 15:
        return class'DXRFixupM15';
    case 98:
        return class'DXRFixupIntro';
    }
    return request;
}

function CheckConfig()
{
    local int i;
    local class<DeusExDecoration> c;

    i=0;
    if(!dxr.flags.IsZeroRando()) {
        DecorationsOverwrites[i].type = "CrateUnbreakableLarge";
        DecorationsOverwrites[i].bInvincible = false;
        DecorationsOverwrites[i].HitPoints = 500;
        DecorationsOverwrites[i].minDamageThreshold = 0;
        c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
        DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
        DecorationsOverwrites[i].Flammability = c.default.Flammability;
        DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
        DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
        DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
        DecorationsOverwrites[i].bPushable = c.default.bPushable;
        i++;

        DecorationsOverwrites[i].type = "CrateUnbreakableMed";
        DecorationsOverwrites[i].bInvincible = false;
        DecorationsOverwrites[i].HitPoints = 500;
        DecorationsOverwrites[i].minDamageThreshold = 0;
        c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
        DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
        DecorationsOverwrites[i].Flammability = c.default.Flammability;
        DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
        DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
        DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
        DecorationsOverwrites[i].bPushable = c.default.bPushable;
        i++;

        DecorationsOverwrites[i].type = "BarrelVirus";
        DecorationsOverwrites[i].bInvincible = false;
        DecorationsOverwrites[i].HitPoints = 100;
        DecorationsOverwrites[i].minDamageThreshold = 0;
        c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
        DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
        DecorationsOverwrites[i].Flammability = c.default.Flammability;
        DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
        DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
        DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
        DecorationsOverwrites[i].bPushable = c.default.bPushable;
        i++;
    }

    DecorationsOverwrites[i].type = "BarrelFire";
    DecorationsOverwrites[i].bInvincible = false;
    DecorationsOverwrites[i].HitPoints = 50;
    DecorationsOverwrites[i].minDamageThreshold = 0;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;
    i++;

    DecorationsOverwrites[i].type = "CigaretteMachine";
    DecorationsOverwrites[i].bInvincible = false;
    DecorationsOverwrites[i].HitPoints = 100;
    DecorationsOverwrites[i].minDamageThreshold = 0;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;
    i++;

    DecorationsOverwrites[i].type = "ShopLight";
    DecorationsOverwrites[i].bInvincible = false;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].HitPoints = c.default.HitPoints;
    DecorationsOverwrites[i].minDamageThreshold = c.default.minDamageThreshold;
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;
    i++;

    DecorationsOverwrites[i].type = "HangingShopLight";
    DecorationsOverwrites[i].bInvincible = false;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].HitPoints = c.default.HitPoints;
    DecorationsOverwrites[i].minDamageThreshold = c.default.minDamageThreshold;
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;
    i++;

    DecorationsOverwrites[i].type = "HKMarketLight";
    DecorationsOverwrites[i].bInvincible = false;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].HitPoints = c.default.HitPoints;
    DecorationsOverwrites[i].minDamageThreshold = c.default.minDamageThreshold;
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;
    i++;

    DecorationsOverwrites[i].type = "Buoy";
    DecorationsOverwrites[i].bInvincible = false;
    c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    DecorationsOverwrites[i].HitPoints = c.default.HitPoints;
    DecorationsOverwrites[i].minDamageThreshold = c.default.minDamageThreshold;
    DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
    DecorationsOverwrites[i].Flammability = c.default.Flammability;
    DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
    DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
    DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
    DecorationsOverwrites[i].bPushable = c.default.bPushable;
    i++;

    Super.CheckConfig();

    for(i=0; i<ArrayCount(DecorationsOverwrites); i++) {
        if( DecorationsOverwrites[i].type == "" ) continue;
        DecorationsOverwritesClasses[i] = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    }
}

static function class<Fragment> GuessFragmentClass(#var(DeusExPrefix)Mover mov)
{
    local class<Fragment> fragmentClass;
    local FragmentGuess guess;
    local int i;

    for (i = 0; i < ArrayCount(default.fragmentGuesses); i++) {
        guess = default.fragmentGuesses[i];
        if (
            mov.ExplodeSound1 == guess.sound
            || mov.ExplodeSound2 == guess.sound
            || mov.OpeningSound == guess.sound
            || mov.ClosingSound == guess.sound
            || mov.ClosedSound == guess.sound
            || mov.MoveAmbientSound == guess.sound
        ) {
            fragmentClass = guess.fragmentClass;
            break;
        }
    }

    if (fragmentClass != None) {
        if (fragmentClass != mov.fragmentClass) {
            log("Guessing that " $ mov $ " fragmentClass should be '" $ fragmentClass $ "' instead of '" $ mov.fragmentClass $ "'");
        }
        return fragmentClass;
    }

    return mov.FragmentClass;
}

function PreFirstEntry()
{
    local #var(prefix)Lamp lmp;
    local #var(DeusExPrefix)Mover mov;

    Super.PreFirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" PreFirstEntry()");

    SetSeed( "DXRFixup PreFirstEntry" );

    TriggerDebug();

    OverwriteDecorations(true);
    FixFlagTriggers();
    FixBeamLaserTriggers();
    FixAutoTurrets();
    FixAlarmUnits();
    SpawnDatacubes();
    FixHolograms();
    FixShowers();
#ifdef gmdx
    FixGMDXObjects();
#endif

    if (dxr.flags.settings.doorsdestructible > 0) {
        foreach AllActors(class'#var(DeusExPrefix)Mover', mov) {
            if (!mov.bBreakable) {
                mov.FragmentClass = GuessFragmentClass(mov);
            }
        }
    }

#ifdef vanilla
    if (class'MenuChoice_AutoLamps'.static.IsEnabled()) {
        foreach AllActors(class'#var(prefix)Lamp', lmp) {
            lmp.InitLight();
        }
        SetAllLampsState(true, true, true);
    }
#endif

    SetSeed( "DXRFixup PreFirstEntry missions" );
    if(#defined(mapfixes))
        PreFirstEntryMapFixes();
}

function ReEntry(bool IsTravel)
{
    Super.ReEntry(IsTravel);
    OverwriteDecorations(false);
}

function PostFirstEntry()
{
    Super.PostFirstEntry();

    CleanupPlaceholders();

    AdjustBookColours();

    SetSeed( "DXRFixup PostFirstEntry missions" );
    if(#defined(mapfixes))
        PostFirstEntryMapFixes();

    RemoveStopWhenEncroach();
}

function AnyEntry()
{
    local #var(prefix)Vehicles v;
    local #var(prefix)Button1 b;
    Super.AnyEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" AnyEntry()");

    SetSeed( "DXRFixup AnyEntry" );

    FixSamCarter();
    FixCleanerBot();
    FixRevisionJock();
    FixRevisionDecorativeInventory();
    FixInvalidBindNames();
    ScaleZoneDamage();
    SetSeed( "DXRFixup AnyEntry missions" );
    if(#defined(mapfixes))
        AnyEntryMapFixes();

    FixAmmoShurikenName();

    SetSeed( "DXRFixup AllAnyEntry" );
    AllAnyEntry();
    FixFOV();

    foreach AllActors(class'#var(prefix)Button1', b) {
        if(b.CollisionRadius <3 && b.CollisionHeight <3)
            b.SetCollisionSize(3, 3);
    }
    foreach AllActors(class'#var(prefix)Vehicles', v) {
        if(#var(prefix)BlackHelicopter(v) == None && #var(prefix)AttackHelicopter(v) == None)
            continue;
        if(v.CollisionRadius > 360)
            v.SetCollisionSize(360, v.CollisionHeight);
    }

    ShowTeleporters();

    if (dxr.flags.moresettings.empty_medbots > 0) { // this change isn't helpful until the next map reads from the defaults, but that's ok because we run this in the intro too
        class'AugmentationCannister'.default.MustBeUsedOn = "Can only be installed with the help of a MedBot or AugBot.";
    } else {
        class'AugmentationCannister'.default.MustBeUsedOn = "Can only be installed with the help of a MedBot.";
    }
}

function TriggerDebug()
{
    if ('#var(TriggerDebug)'=='' || '#var(TriggerDebug)'=='None') return;

    Player().ClientMessage("Trigger debug enabled for #var(TriggerDebug)");

    Spawn(class'DXRLogTrigger',,'#var(TriggerDebug)');
}

function bool IsManWhoWasThursday(name TextTag)
{
    switch(TextTag)
    {
        case '02_Book05': //M02 Hotel/Underground - Closed
        case '03_Book05': //M03 Airfield Helibase - Closed
        case '04_Book05': //M04 Hotel - Closed
        case '10_Book03': //M10 Pre-Catacombs ("Entrance" in Revision) - Closed
        case '12_Book02': //M12 Cmd - Open
        case '14_Book04': //M14 OceanLab Lab - Closed
        case '15_Book02': //M15 Area 51 Final - Open (Swapped from a Jacob's Shadow book)
            return true;
    }
    return false;
}

function bool IsJacobsShadow(name TextTag)
{
    switch(TextTag)
    {
        case '02_Book03': //M02 Underground - Closed
        case '03_Book04': //M03 Airfield Helibase - Closed
        case '04_Book03': //M04 Hotel - Closed
        case '06_Book03': //M06 Market - Closed
        case '09_Book02': //M09 Ship Below - Open
        case '10_Book02': //M10 Chateau - Closed
        case '12_Book01': //M12 Cmd/Computer - Open
        case '15_Book01': //M15 Bunker/Entrance - Open
            return true;
    }
    return false;
}

function AdjustBookColours()
{
    local #var(prefix)BookOpen bo;
    local #var(prefix)BookClosed bc;
    local bool enable;

    enable = class'MenuChoice_GoalTextures'.static.BookColoursShouldChange();

    foreach AllActors(class'#var(prefix)BookOpen',bo){
        if (enable){
            if (IsManWhoWasThursday(bo.TextTag)){
                bo.Multiskins[0]=Texture'BookOpenTex1Red';
            } else if (IsJacobsShadow(bo.TextTag)){
                bo.Multiskins[0]=Texture'BookOpenTex1Purple';
            }
        } else {
            bo.Multiskins[0]=bo.Default.Multiskins[0];
        }
    }

    foreach AllActors(class'#var(prefix)BookClosed',bc){
        if (enable){
            if (IsManWhoWasThursday(bc.TextTag)){
                bc.Multiskins[0]=Texture'BookClosedTex1Red';
            } else if (IsJacobsShadow(bc.TextTag)){
                bc.Multiskins[0]=Texture'BookClosedTex1Purple';
            }
        } else {
            bc.Multiskins[0]=bc.Default.Multiskins[0];
        }
    }

}

function FixFOV()
{
    local vector v;
    local float n, w;// narrow and wide multipliers
    local Lockpick lp;
    local Multitool mt;
    local NanoKeyRing nkr;

    if(!#defined(vanilla)) return; // would need to check the defaults in other mods

    w = class'Human'.default.DefaultFOV;
    w = (w - 75) / (120 - 75); // put it on a range of 0-1 for 75 to 120
    w = FClamp(w, 0, 1);
    n = 1-w;

    // interpolate between 75 FOV and 120 FOV, multiply vanilla values by n and wide FOV values by w
    // wide values provided by Tundoori https://discord.com/channels/823629359931195394/823629360929046530/1282526555536625778
    // X is distance from camera, Y is left/right, Z is up/down

    // POVCorpse
    v =  vect(20, 12, -5) * n;
    v += vect(15, 15, -5) * w;
    class'POVCorpse'.default.PlayerViewOffset = v;

    // GEP Gun
    v =  vect(46, -22, -10) * n;
    v += vect(32, -22, -10) * w;
    class'WeaponGEPGun'.default.PlayerViewOffset = v;
    v =  vect(-46, 22, 10) * n;
    v += vect(-32, 22, 10) * w;
    class'WeaponGEPGun'.default.FireOffset = v;

    // LAW
    v =  vect(18, -18, -7) * n;
    v += vect( 8, -18, -7) * w;
    class'WeaponLAW'.default.PlayerViewOffset = v;
    v =  vect(28, 12, 4) * n;
    v += vect(38, 12, 4) * w;
    class'WeaponLAW'.default.FireOffset = v;

    // assault gun
    v =  vect(16, -5, -11.5) * n;
    v += vect( 8, -5, -10) * w;
    class'WeaponAssaultGun'.default.PlayerViewOffset = v;
    v =  vect(-16, 5, 11.5) * n;
    v += vect( -8, 5, 10) * w;
    class'WeaponAssaultGun'.default.FireOffset = v;

    // WeaponAssaultShotgun
    v =  vect(30, -10, -12) * n;
    v += vect(17.5, -10, -18) * w;
    class'WeaponAssaultShotgun'.default.PlayerViewOffset = v;
    v =  vect(-30, 10, 12) * n;
    v += vect(-17.5, 10, 18) * w;
    class'WeaponAssaultShotgun'.default.FireOffset = v;

    // WeaponBaton
    v =  vect(24, -14, -17) * n;
    v += vect(18, -14, -22) * w;
    class'WeaponBaton'.default.PlayerViewOffset = v;
    v =  vect(-24, 14, 17) * n;
    v += vect(-18, 14, 22) * w;
    class'WeaponBaton'.default.FireOffset = v;

    // WeaponCombatKnife
    v =  vect(5, -8, -14) * n;
    v += vect(1, -8, -17) * w;
    class'WeaponCombatKnife'.default.PlayerViewOffset = v;
    v =  vect(-5, 8, 14) * n;
    v += vect(-1, 8, 17) * w;
    class'WeaponCombatKnife'.default.FireOffset = v;

    // WeaponCrowbar
    v =  vect(40, -15,  -8) * n;
    v += vect(26, -15, -10) * w;
    class'WeaponCrowbar'.default.PlayerViewOffset = v;
    v =  vect(-40, 15, 8) * n;
    v += vect(-26, 15, 10) * w;
    class'WeaponCrowbar'.default.FireOffset = v;

    // WeaponEMPGrenade
    v =  vect(24, -15, -19) * n;
    v += vect(24, -15, -24) * w;
    class'WeaponEMPGrenade'.default.PlayerViewOffset = v;
    v =  vect(0, 10, 20) * n;
    v += vect(0, 10, 25) * w;
    class'WeaponEMPGrenade'.default.FireOffset = v;

    // WeaponFlamethrower
    v =  vect(20, -14, -12) * n;
    v += vect(12, -14, -12) * w;
    class'WeaponFlamethrower'.default.PlayerViewOffset = v;
    v =  vect(0, 10, 10) * n;
    v += vect(8, 10, 10) * w;
    class'WeaponFlamethrower'.default.FireOffset = v;

    // WeaponGasGrenade
    v =  vect(30, -13, -19) * n;
    v += vect(30, -13, -24) * w;
    class'WeaponGasGrenade'.default.PlayerViewOffset = v;
    v =  vect(0, 10, 20) * n;
    v += vect(0, 10, 25) * w;
    class'WeaponGasGrenade'.default.FireOffset = v;

    // WeaponHideAGun
    v =  vect(20, -10, -16) * n;
    v += vect(12, -10, -16) * w;
    class'WeaponHideAGun'.default.PlayerViewOffset = v;
    v =  vect(-20, 10, 16) * n;
    v += vect(-12, 10, 16) * w;
    class'WeaponHideAGun'.default.FireOffset = v;

    // WeaponLAM
    v =  vect(24, -15, -17) * n;
    v += vect(24, -15, -24) * w;
    class'WeaponLAM'.default.PlayerViewOffset = v;
    v =  vect(0, 10, 20) * n;
    v += vect(0, 10, 25) * w;
    class'WeaponLAM'.default.FireOffset = v;

    // WeaponMiniCrossbow
    v =  vect(25, -8, -14) * n;
    v += vect(25, -8, -14) * w;
    class'WeaponMiniCrossbow'.default.PlayerViewOffset = v;
    v =  vect(-25, 8, 14) * n;
    v += vect(-25, 8, 14) * w;
    class'WeaponMiniCrossbow'.default.FireOffset = v;

    // WeaponNanoSword
    v =  vect(21, -16, -27) * n;
    v += vect(7, -16, -30) * w;
    class'WeaponNanoSword'.default.PlayerViewOffset = v;
    v =  vect(-21, 16, 27) * n;
    v += vect(-7, 16, 30) * w;
    class'WeaponNanoSword'.default.FireOffset = v;

    // WeaponNanoVirusGrenade
    v =  vect(24, -15, -19) * n;
    v += vect(18, -15, -20) * w;
    class'WeaponNanoVirusGrenade'.default.PlayerViewOffset = v;
    v =  vect(0, 10, 20) * n;
    v += vect(6, 10, 21) * w;
    class'WeaponNanoVirusGrenade'.default.FireOffset = v;

    // WeaponPepperGun
    v =  vect(16, -10, -16) * n;
    v += vect( 8, -10, -16) * w;
    class'WeaponPepperGun'.default.PlayerViewOffset = v;
    v =  vect( 8, 4, 14) * n;
    v += vect(16, 4, 14) * w;
    class'WeaponPepperGun'.default.FireOffset = v;

    // WeaponPistol
    v =  vect(22, -10, -14) * n;
    v += vect(18, -10, -17) * w;
    class'WeaponPistol'.default.PlayerViewOffset = v;
    v =  vect(-22, 10, 14) * n;
    v += vect(-18, 10, 17) * w;
    class'WeaponPistol'.default.FireOffset = v;

    // WeaponPlasmaRifle
    v =  vect(18, 0, -7) * n;
    v += vect(10, 0, -7) * w;
    class'WeaponPlasmaRifle'.default.PlayerViewOffset = v;
    v =  vect(  0, 0, 0) * n;
    v += vect(-10, 0, 0) * w;
    class'WeaponPlasmaRifle'.default.FireOffset = v;

    // WeaponProd
    v =  vect(21, -12, -19) * n;
    v += vect(11, -12, -19) * w;
    class'WeaponProd'.default.PlayerViewOffset = v;
    v =  vect(-21, 12, 19) * n;
    v += vect(-11, 12, 19) * w;
    class'WeaponProd'.default.FireOffset = v;

    // WeaponRifle
    v =  vect(20, -2, -30) * n;
    v += vect(13, -2, -29) * w;
    class'WeaponRifle'.default.PlayerViewOffset = v;
    v =  vect(-20, 2, 30) * n;
    v += vect(-13, 2, 29) * w;
    class'WeaponRifle'.default.FireOffset = v;

    // WeaponSawedOffShotgun
    v =  vect(11, -4, -13) * n;
    v += vect( 1, -4, -17) * w;
    class'WeaponSawedOffShotgun'.default.PlayerViewOffset = v;
    v = vect(-11,4,13) * n;
    v += vect(-1,4,17) * w;
    class'WeaponSawedOffShotgun'.default.FireOffset = v;

    // WeaponShuriken
    v =  vect(24, -12, -21) * n;
    v += vect(16, -14, -22) * w;
    class'WeaponShuriken'.default.PlayerViewOffset = v;
    v =  vect(-10, 14, 22) * n;
    v += vect( -2, 14, 23) * w;
    class'WeaponShuriken'.default.FireOffset = v;

    // WeaponStealthPistol
    v =  vect(24, -10, -14) * n;
    v += vect(17, -10, -15) * w;
    class'WeaponStealthPistol'.default.PlayerViewOffset = v;
    v =  vect(-24, 10, 14) * n;
    v += vect(-17, 10, 15) * w;
    class'WeaponStealthPistol'.default.FireOffset = v;

    // WeaponSword
    v =  vect(25, -10, -24) * n;
    v += vect(20, -10, -32) * w;
    class'WeaponSword'.default.PlayerViewOffset = v;
    v =  vect(-25, 10, 24) * n;
    v += vect(-20, 10, 32) * w;
    class'WeaponSword'.default.FireOffset = v;

    // Lockpick
    v =  vect(16, 8, -16) * n;
    v += vect(15, 8, -17) * w;
    class'Lockpick'.default.PlayerViewOffset = v;
    v *= 100;
    foreach AllActors(class'Lockpick', lp) {
        lp.PlayerViewOffset = v;
    }

    // Multitool
    v =  vect(20, 10, -16) * n;
    v += vect(19, 10, -17) * w;
    class'Multitool'.default.PlayerViewOffset = v;
    v *= 100;
    foreach AllActors(class'Multitool', mt) {
        mt.PlayerViewOffset = v;
    }

    // NanoKeyRing
    v =  vect(16, 15, -16) * n;
    v += vect(14, 15, -18) * w;
    class'NanoKeyRing'.default.PlayerViewOffset = v;
    v *= 100;
    foreach AllActors(class'NanoKeyRing', nkr) {
        nkr.PlayerViewOffset = v;
    }
}

function ShowTeleporters()
{
    local #var(prefix)Teleporter t;
    local bool hide, collision;

    hide = ! class'MenuChoice_ShowTeleporters'.static.ShowTeleporters();

    switch(dxr.localURL) {
    // smuggler maps are exempt from teleporter collision, since they don't need it, and it blocks the elevator's button
    case "02_NYC_SMUG":
    case "04_NYC_SMUG":
    case "08_NYC_SMUG":
    case "02_NYC_BATTERYPARK":// the hostages need to be able to get into the subway!
        collision=false;
        break;
    default:
        collision=true;
        break;
    }

    foreach AllActors(class'#var(prefix)Teleporter', t) {
        if(t.bCollideActors && t.bEnabled) {
            t.SetCollision( t.bCollideActors, collision, t.bBlockPlayers );// don't let pawns walk through
        }
        t.bHidden = hide || !t.bCollideActors || !t.bEnabled;
        t.DrawScale = 0.75;
    }
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);
    if(#defined(vanillamaps))
        FixLogTimeout(p);

    FixAmmoShurikenName();
    FixInventory(p);
    GarbageCollection(p);

    if(p.InHand!=None && p.InHand.GetStateName()=='Idle2') {
        warning("p.InHand: " $ p.InHand $ " is in state Idle2");
        p.SetInHand(None);
    }
}

function GarbageCollection(#var(PlayerPawn) p)
{
    local AugmentationManager augman;
    local Augmentation aug, nextaug;
    local SkillManager skillman;
    local Skill skill, nextskill;
    local ColorThemeManager thememan;
    local ColorTheme theme, nexttheme;

    foreach AllActors(class'AugmentationManager', augman) {
        if(p.AugmentationSystem == augman) continue;
        if(augman.Owner != None && augman.Owner != p) continue;

        for(aug=augman.FirstAug; aug!=None; aug=nextaug) {
            nextaug = aug.next;
            aug.Destroy();
        }
        augman.Destroy();
    }
    foreach AllActors(class'SkillManager', skillman) {
        if(p.SkillSystem == skillman) continue;
        if(skillman.Owner != None && skillman.Owner != p) continue;

        for(skill=skillman.FirstSkill; skill!=None; skill=nextskill) {
            nextskill = skill.next;
            skill.Destroy();
        }
        skillman.Destroy();
    }
    foreach AllActors(class'ColorThemeManager', thememan) {
        if(p.ThemeManager == thememan) continue;
        if(thememan.Owner != None && thememan.Owner != p) continue;

        for(theme=thememan.FirstColorTheme; theme!=None; theme=nexttheme) {
            nexttheme = theme.next;
            theme.Destroy();
        }
        thememan.Destroy();
    }
}

function PostAnyEntry()
{
    CleanupPlaceholders(true);
}

function CleanupPlaceholders(optional bool alert)
{
    local PlaceholderItem i;
    local PlaceholderContainer c;
    local PlaceholderEnemy e;
    foreach AllActors(class'PlaceholderItem', i) {
        if(alert) err("found leftover "$i);
        i.Destroy();
    }
    foreach AllActors(class'PlaceholderContainer', c) {
        if(alert) err("found leftover "$c);
        c.Destroy();
    }
    // just in case DXREnemies isn't loaded
    foreach AllActors(class'PlaceholderEnemy', e) {
        if(alert) err("found leftover "$e);
        e.Destroy();
    }
}


function _PreTravel()
{
    if(#defined(mapfixes)) {
        PreTravelMapFixes();
    }

    if(class'MenuChoice_BalanceEtc'.static.IsEnabled() && class'MenuChoice_FixGlitches'.default.enabled) {
        RemoveProjectilesInFlight();
    }
}

//This is a safety mechanism so that if you leave a map with a bunch of projectiles
//flying at you, you can at least somewhat more safely re-enter the map later (No more
//re-entering a map to an about-to-explode LAM)
function RemoveProjectilesInFlight()
{
    local #var(DeusExPrefix)Projectile p;

    foreach AllActors(class'#var(DeusExPrefix)Projectile',p)
    {
        if (p.bStuck) continue; //darts/throwing knives stuck in the wall, planted grenades

        //Destroy any in-flight projectiles
        p.Destroy();
    }
}

function Timer()
{
    Super.Timer();
    if( dxr == None ) return;

    if(#defined(mapfixes)) {
        TimerMapFixes();
    }
}

function PreTravelMapFixes()
{
}

function PreFirstEntryMapFixes()
{
}

function PostFirstEntryMapFixes()
{
}

function AnyEntryMapFixes()
{
}

function AllAnyEntry()
{
    // for when mapfixes isn't defined, but currently it's defined for all mods even Revision
}

function TimerMapFixes()
{
}

function FixUNATCORetinalScanner()
{
    local RetinalScanner r;

    foreach AllActors(class'RetinalScanner', r) {
        if( r.Event != 'retinal_msg_trigger' ) continue;
        r.bHackable = false;
        r.hackStrength = 0;
        r.msgUsed = "";
    }
}

//Or whatever it's supposed to be.  Electrical distribution panel?  The thing in the closet.
function SpeedUpUNATCOFurnaceVent()
{
    local #var(DeusExPrefix)Mover dxm;

    if (!class'MenuChoice_BalanceMaps'.static.MinorEnabled()) return;

    foreach AllActors(class'#var(DeusExPrefix)Mover',dxm) {
        //Only that vent door has 3 keyframes in HQ (This is true in both vanilla and Revision)
        if (dxm.NumKeys==3) {
            dxm.MoveTime=1.5; //Default is 3.0, make it open a bit faster (The move time is between each keyframe)
            break;
        }
    }
}

function PreventUNATCOZombieDanger()
{
    local #var(DeusExPrefix)Carcass carc;
    local #var(prefix)ScriptedPawn sp;

    //Only if zombie reanimation is enabled
    if (dxr.flags.moresettings.reanimation<=0) return;

    foreach AllActors(class'#var(DeusExPrefix)Carcass', carc) {
        carc.bNotDead = true;
        carc.itemName = ReplaceText(carc.itemName, " (Dead)", " (Unconscious)");
    }
}

function MakeTurretsNonHostile()
{
    local #var(prefix)AutoTurret at;

    foreach AllActors(class'#var(prefix)AutoTurret',at){
        at.bTrackPlayersOnly=False;
        at.bTrackPawnsOnly=True;
    }
}

function FixUNATCOCarterCloset()
{
    local Inventory i;
    local #var(DeusExPrefix)Decoration d;

    foreach RadiusActors(class'Inventory', i, 360, vectm(1075, -1150, 10)) {
        i.bIsSecretGoal = true;
    }
    foreach RadiusActors(class'#var(DeusExPrefix)Decoration', d, 360, vectm(1075, -1150, 10)) {
        d.bIsSecretGoal = true;
    }
}

function FixAlexsEmail()
{
    local #var(prefix)ComputerPersonal cp;

    foreach AllActors(class'#var(prefix)ComputerPersonal',cp){
        if (
            (cp.UserList[0].UserName=="ajacobson" && cp.UserList[1].UserName=="") ||
            (cp.UserList[0].UserName=="DEMIURGE" && cp.UserList[1].UserName=="ajacobson" && cp.UserList[2].UserName=="")
        ) {
            cp.TextPackage = "#var(package)";
            break;
        }
    }
}

function FixHarleyFilben()
{
    local #var(prefix)HarleyFilben harley;

    //Harley defaults to not important, which means his name gets randomized
    foreach AllActors(class'#var(prefix)HarleyFilben', harley) {
        harley.bImportant = true;
    }
}

function FixSamCarter()
{
    local #var(prefix)SamCarter s;
    foreach AllActors(class'#var(prefix)SamCarter', s) {
        RemoveFears(s);
    }
}

function FixRevisionJock()
{
#ifdef revision
    local JockHelicopter jock;
    foreach AllActors(class'JockHelicopter',jock){
        jock.bImportant=true;
    }
#endif
}

function FixRevisionDecorativeInventory()
{
#ifdef revision
    local Inventory i;

    foreach AllActors(class'Inventory',i){
        if (i.CollisionRadius==0 && i.CollisionHeight==0){
            l("Making "$i$" grabbable by restoring it's original collision size");
            i.SetCollisionSize(i.default.CollisionRadius,i.default.CollisionHeight);
        }
    }
#endif
}

function FixCleanerBot()
{
    local CleanerBot cb;
    foreach AllActors(class'CleanerBot', cb) {
        cb.bInvincible=False;
    }
}

function FixHolograms()
{
    local #var(prefix)ScriptedPawn sp;
    foreach AllActors(class'#var(prefix)ScriptedPawn', sp) {
        if (sp.Style==STY_Translucent){
            RemoveReactions(sp);
        }
    }
}

function FixShowers()
{
    local #var(prefix)ShowerFaucet faucet;
    local #var(prefix)ShowerHead head,closestHead;
    local int i;

    foreach AllActors(class'#var(prefix)ShowerFaucet', faucet) {
        head=None;
        if (faucet.Tag != ''){
            foreach AllActors(class'#var(prefix)ShowerHead', head, faucet.Tag){ break; }
        }

        //Found a matching head based on the tag, no need to change
        if (head!=None){
            continue;
        }

        //If there are no matching shower heads, look for one nearby instead
        foreach faucet.RadiusActors(class'#var(prefix)ShowerHead',head,100){
            if (closestHead==None){
                closestHead = head;
            } else {
                if (VSize(head.Location-faucet.Location) < VSize(closestHead.Location-faucet.Location)){
                    closestHead = head;
                }
            }
        }

        //No shower heads nearby, give up on this one
        if (closestHead==None){
            continue;
        }

        //player().ClientMessage("Fixing Shower Faucet "$faucet);

        closestHead.Tag=closestHead.Name;
        faucet.Tag = closestHead.Tag;
        faucet.PostBeginPlay();

        //Make sure the water generators are in the right mode
        //They seem to always start turned on
        for(i=0; i<ArrayCount(faucet.waterGen); i++) {
            if (faucet.bOpen != faucet.waterGen[i].bSpewing) {
                faucet.waterGen[i].Trigger(None,None);
            }
        }

    }
}

//Fix up GMDX Containers and other objects!
//OH BOY this one is a doozy!!!
//GMDX does some wacky shenanigans where it will
//create some objects as other objects. For instance, the rocks in the liberty
//island gardens are actually cardboard boxes! So we need to check to make
//sure they have their original skin (or their HDTP Skin).
//Additionally, GMDX "hides" some containers by making them invisibly small
//as part of removing objects for difficulty. We need to handle both cases.
//Handles:
//1. Crates and containers with different models (used for deco)
//2. Crates and containers that aren't highlightable or pushable (BSP blockers, other things)
//3. Crates and containers that aren't collidable ("removed" as part of difficulty balancing)
//4. Scripted Grenades
function FixGMDXObjects()
{
    local #var(prefix)Containers C;
    local #var(prefix)GasGrenade G;

    foreach AllActors(class'#var(prefix)Containers', C)
    {
#ifdef gmdxae
        //GMDX_AE lets you toggle HDTP models on or off, so we need to check both
        if (C.Mesh != C.class.default.mesh && !(string(C.Mesh) ~= C.class.default.HDTPMesh) && C.bHDTPFailsafe)
#elseif gmdx
        //Check model - GMDX v9/vRSD always only had 1 mesh, the HDTP one
        if (C.Mesh != C.class.default.mesh)
#endif
            C.bIsSecretGoal = true;

        //Some non-interactive decos are also in some places
        if (!C.bHighlight || !C.bPushable)
            C.bIsSecretGoal = true;

        //Check collision size
        if (C.collisionHeight == 0 && C.collisionRadius == 0)
            C.bIsSecretGoal = true;

    }
    
#ifdef gmdx
    foreach AllActors(class'#var(prefix)GasGrenade', G)
        if (G.bScriptedGrenade)
            G.bIsSecretGoal = true;
#endif

}

simulated function FixAmmoShurikenName()
{
    local AmmoShuriken a;

    class'AmmoShuriken'.default.ItemName = "Throwing Knives";
    class'AmmoShuriken'.default.ItemArticle = "some";
    class'AmmoShuriken'.default.beltDescription="THW KNIFE";
    foreach AllActors(class'AmmoShuriken', a) {
        a.ItemName = a.default.ItemName;
        a.ItemArticle = a.default.ItemArticle;
        a.beltDescription = a.default.beltDescription;
    }
}

simulated function FixLogTimeout(#var(PlayerPawn) p)
{
    if( p.GetLogTimeout() - 1 <3 ) {
        p.SetLogTimeout(10);
    }
}

simulated function bool FixInventory(#var(PlayerPawn) p)
{
    local Inventory item, nextItem;
    local DXRLoadouts loadouts;
    local int slots[64], x, y;// leave room for up to an 8x8 inventory
    local bool good;

    good = true;
    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));

    for(item=p.Inventory; item!=None; item=nextItem) {
        nextItem = item.Inventory;// save this in case we're deleting an item

        if(loadouts != None && loadouts.ban(p, item)) {
            item.Destroy();
            continue;
        }
        item.BecomeItem();
        item.SetLocation(p.Location);
        item.SetBase(p);

        if(!item.bDisplayableInv) continue;// don't check for inventory overlap
        if(!#defined(injections)) continue;// we're not gonna be able to fix other mods anyways
        if(item.invPosX < 0 || item.invPosY < 0) continue;

        for(x = item.invPosX; x < item.invPosX + item.invSlotsX; x++) {
            for(y = item.invPosY; y < item.invPosY + item.invSlotsY; y++) {
                if(slots[x*8 + y] > 0) {
                    warning("inventory overlap at (" $ x $ ", " $ y $ ") " $ item);
                    good = false;
                }
                slots[x*8 + y]++;
            }
        }
    }

    if(!good && class'MenuChoice_FixGlitches'.default.enabled) {
        err("inventory overlap");
    }

    return good;
}


//Remove characters that shouldn't be allowed in bindnames (since they are often converted into a name)
function FixInvalidBindNames()
{
    local #var(prefix)ScriptedPawn sp;

    foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
        if (InStr(sp.BindName," ")!=-1){
            sp.BindName=ReplaceText(sp.BindName," ","");
            sp.ConBindEvents();
            warning("FixInvalidBindNames: Fixed "$sp.Name$" bindname, removing a space.  BindName is now '"$sp.BindName$"'");
        }
    }
}

function PreventShufflingAmbrosia()
{
    local #var(prefix)BarrelAmbrosia ambrosia;

    //Prevent ambrosia barrels from being shuffled
    foreach AllActors(class'#var(prefix)BarrelAmbrosia', ambrosia) {
        ambrosia.bIsSecretGoal = true;
    }
}

//Scale the damage done by zones to counteract the damage scaling from CombatDifficulty
function ScaleZoneDamage()
{
    local ZoneInfo z;
    local float f;

    if(class'MenuChoice_BalanceEtc'.static.IsDisabled()) return;

#ifdef injections
    foreach AllActors(class'ZoneInfo',z){
        if (z.bPainZone){
            f = player().CombatDifficultyMultEnviro();
            z.DamagePerSec=Clamp((z.DamagePerSec+1)/f, 1, (z.DamagePerSec+1));
        }
    }
#endif
}

function OverwriteDecorations(bool bFirstEntry)
{
    local DeusExDecoration d;
    local #var(prefix)Barrel1 b;
    local int i;
    local bool bBalance;

    bBalance = class'MenuChoice_BalanceEtc'.static.IsEnabled();
    foreach AllActors(class'DeusExDecoration', d) {
        if( bBalance
            && (d.IsA('CrateBreakableMedCombat') || d.IsA('CrateBreakableMedGeneral') || d.IsA('CrateBreakableMedMedical')) ) {
            d.Mass = 35;
            d.HitPoints = 1;
            d.default.HitPoints = 1;
        }
        for(i=0; i < ArrayCount(DecorationsOverwrites); i++) {
            if(DecorationsOverwritesClasses[i] == None) continue;
            if( d.IsA(DecorationsOverwritesClasses[i].name) == false ) continue;
            if( d.bIsSecretGoal == True) continue;
            d.bInvincible = DecorationsOverwrites[i].bInvincible;
            if(d.HitPoints == d.default.HitPoints || bFirstEntry) {
                d.HitPoints = DecorationsOverwrites[i].HitPoints;
            }
            d.minDamageThreshold = DecorationsOverwrites[i].minDamageThreshold;
            d.bFlammable = DecorationsOverwrites[i].bFlammable;
            d.Flammability = DecorationsOverwrites[i].Flammability;
            d.bExplosive = DecorationsOverwrites[i].bExplosive;
            d.explosionDamage = DecorationsOverwrites[i].explosionDamage;
            d.explosionRadius = DecorationsOverwrites[i].explosionRadius;
            d.bPushable = DecorationsOverwrites[i].bPushable;
        }
        if(#var(prefix)Van(d) != None || #var(prefix)CarWrecked(d) != None) {
            d.bBlockSight = true;
        }
    }
    for(i=0; i < ArrayCount(DecorationsOverwrites); i++) {
        if(DecorationsOverwritesClasses[i] == None) continue;
        DecorationsOverwritesClasses[i].default.HitPoints = DecorationsOverwrites[i].HitPoints; // fixes the ScaleGlow
    }

    // in DeusExDecoration is the Exploding state, it divides the damage into 5 separate ticks with gradualHurtSteps = 5;
    if(bBalance) {
        foreach AllActors(class'#var(prefix)Barrel1', b) {
            if( b.explosionDamage > 50 && b.explosionDamage < 400 ) {
                b.explosionDamage = 400;
            }
        }
    }
}

function FixFlagTriggers()
{//the History Un-Eraser Button
    local FlagTrigger f;

    foreach AllActors(class'FlagTrigger', f) {
        if( f.bSetFlag && f.flagExpiration == -1 ) {
            f.flagExpiration = 999;
            l(f @ f.FlagName @ f.flagValue $" changed expiration from -1 to 999");
        }
    }
}

function FixBeamLaserTriggers()
{
#ifdef fixes
    local #var(prefix)BeamTrigger bt;
    local #var(prefix)LaserTrigger lt;

    if(class'MenuChoice_BalanceEtc'.static.IsDisabled()) return;

    foreach AllActors(class'#var(prefix)BeamTrigger',bt){
        bt.TriggerType=TT_AnyProximity;
    }
    foreach AllActors(class'#var(prefix)LaserTrigger',lt){
        lt.TriggerType=TT_AnyProximity;
    }
#endif
}

function FixAutoTurrets()
{
#ifdef fixes
    local #var(prefix)AutoTurret at;

    if(!class'MenuChoice_BalanceMaps'.static.MinorEnabled()) return;

    foreach AllActors(class'#var(prefix)AutoTurret',at){
        at.gunDamage=at.Default.gunDamage; //One turret in Cathedral has non-standard damage
        at.fireRate=at.Default.fireRate; //Make sure large and small turrets use their appropriate firerates
    }
#endif
}

function FixAlarmUnits()
{
#ifdef fixes
    local #var(prefix)AlarmUnit au;

    if(!class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) return;

    foreach AllActors(class'#var(prefix)AlarmUnit',au){
        au.hackStrength = 0.05;
        //Make alarm units universally more hackable (they're low value)
        //Only a few in vanilla don't match the default 0.2 value:
        // - M03 Airfield, in the boat house, hackStrength=0.8
        // - M05 UNATCO Island, at the statue, out of bounds, so doesn't even matter, hackStrength=0.25
        // - M09 Dockyard, all alarm units are hackstrength=0.4

        au.alarmTimeout = au.Default.alarmTimeout;
        //Default alarm timeout is 30 seconds
        //A few vanilla alarm units have non-standard timeouts
        // - The four units in stealth training have 10 seconds
        // - M03 Airfield Helibase, two units (out of four) have 120 seconds
        // - M06 Wan Chai Street, all five units have 120 seconds (I guess to make Maggie's apartment more unbearable?)
    }
#endif
}

function RemoveStopWhenEncroach()
{
    local #var(prefix)Mover m;

    if(!class'MenuChoice_BalanceMaps'.static.MinorEnabled()) return;
    switch(dxr.localURL) {
    case "06_HONGKONG_TONGBASE": // allow the speedrun trick on the killswitch disabling
        return;
    }

    foreach AllActors(class'#var(prefix)Mover',m){
        //Stop when encroach is annoying and can allow some NPCs to block doorways
        //like the UNATCO HQ breakroom door
        if (m.MoverEncroachType==ME_StopWhenEncroach){
            m.MoverEncroachType=ME_IgnoreWhenEncroach;
        }
    }

}

function SpawnDatacubes()
{
#ifdef injections
    local #var(prefix)DataCube dc;
#else
    local DXRInformationDevices dc;
#endif

    local vector loc;
    local rotator rot;
    local int i;

    if(dxr.flags.IsReducedRando())
        return;

    SetSeed( "DXRFixup SpawnDatacubes" );

    if( dxr.localURL == "" ) {
        warning("SpawnDatacubes() empty localURL, " $ GetURLMap());
        return;
    }

    for(i=0; i<ArrayCount(add_datacubes); i++) {
        if(add_datacubes[i].text == "" && add_datacubes[i].imageClass == None) continue;
        loc = add_datacubes[i].location * coords_mult;
        if( loc.X == 0 && loc.Y == 0 && loc.Z == 0 ) {
            if (add_datacubes[i].plaintextTag!=""){
                warning("Spawning datacube with plaintextTag "$add_datacubes[i].plaintextTag$" but random location.  Safe Rules may not be predictable!");
            }
            loc = GetRandomPosition();
        }
        rot = add_datacubes[i].rotation;
        rot = rotm(rot.Pitch, rot.Yaw, rot.Roll, 0.0);

#ifdef injections
        dc = Spawn(class'#var(prefix)DataCube',,, loc, rot);
#else
        dc = Spawn(class'DXRInformationDevices',,, loc, rot);
#endif

        if( dc != None ){
            dc.SetCollision(true,false,false);
            if(dxr.flags.settings.infodevices > 0)
                GlowUp(dc);
            dc.plaintext = add_datacubes[i].text;
            dc.imageClass = add_datacubes[i].imageClass;
            dc.plaintextTag = add_datacubes[i].plaintextTag;
            l("add_datacubes spawned "$dc$", text: \""$dc.plaintext$"\", image: "$dc.imageClass$", plaintextTag: "$dc.plaintextTag$", location: "$loc);
        }
        else warning("failed to spawn datacube at "$loc$", text: \""$add_datacubes[i].text$"\", image: "$dc.imageClass);
    }
}

function Actor CandleabraLight(vector pos, rotator r)
{
    local Actor c, light;
    local vector diff;

    c = AddActor(class'WHRedCandleabra', pos, r);
    c.SetPhysics(PHYS_None);

    diff = vect(-3.1, 6.7, 13.9) >> r;
    light = AddActor(class'LightBulb', pos+diff, rot(0, 0, 0));
    light.LightBrightness = 50;
    light.LightRadius = 16;

    diff = vect(-3.1, -7, 13.9) >> r;
    light = AddActor(class'LightBulb', pos+diff, rot(0, 0, 0));
    light.LightBrightness = 50;
    light.LightRadius = 16;

    return c;
}

static function FixConversationFlag(Conversation c, name fromName, bool fromValue, name toName, bool toValue)
{
    local ConFlagRef f;
    if( c == None ) return;
    for(f = c.flagRefList; f!=None; f=f.nextFlagRef) {
        if( f.flagName == fromName && f.value == fromValue ) {
            f.flagName = toName;
            f.value = toValue;
            return;
        }
    }
}

static function ConEventCheckFlag FixConversationFlagJump(Conversation c, name fromName, bool fromValue, name toName, bool toValue)
{
    local ConEvent e;
    local ConEventCheckFlag ef, matched;
    local ConFlagRef f;
    if( c == None ) return None;
    for(e = c.eventList; e!=None; e=e.nextEvent) {
        ef = ConEventCheckFlag(e);
        if( ef != None ) {
            for(f = ef.flagRef; f!=None; f=f.nextFlagRef) {
                if( f.flagName == fromName && f.value == fromValue ) {
                    f.flagName = toName;
                    f.value = toValue;
                    matched = ef;
                }
            }
        }
    }

    return matched;
}

static function FixConversationGiveItem(Conversation c, string fromName, Class<Inventory> fromClass, Class<Inventory> to)
{
    local ConEvent e;
    local ConEventTransferObject t;
    if( c == None ) return;
    for(e=c.eventList; e!=None; e=e.nextEvent) {
        t = ConEventTransferObject(e);
        if( t == None ) continue;
        if( t.objectName == fromName && t.giveObject == fromClass ) {
            t.objectName = string(to.name);
            t.giveObject = to;
        }
    }
}

static function FixConversationAddNote(Conversation c, string textSnippet)
{
    local ConEvent e;
    local ConEventSpeech s;
    local ConEventAddNote n;
    if( c == None ) return;
    for(e=c.eventList; e!=None; e=e.nextEvent) {
        s = ConEventSpeech(e);
        if( s == None ) continue;
        if( InStr(s.conSpeech.speech,textSnippet)!=-1) {
            n = New class'ConEventAddNote';
            n.nextEvent = e.nextEvent;
            e.nextEvent = n;
            n.noteText = s.conSpeech.speech;

            n.conversation = c;
            n.eventType = ET_AddNote;
        }
    }
}

function SetAllLampsState(optional bool type1, optional bool type2, optional bool type3, optional Vector loc, optional float rad)
{
#ifdef vanilla
    local #var(prefix)Lamp lmp;

    if (!class'MenuChoice_AutoLamps'.static.IsEnabled())
        return;

    if (rad == 0.0) {
        foreach AllActors(class'#var(prefix)Lamp', lmp) {
            lmp.SetState(
                (Lamp1(lmp) != None && type1) ||
                (Lamp2(lmp) != None && type2) ||
                (Lamp3(lmp) != None && type3)
            );
        }
    } else {
        foreach RadiusActors(class'#var(prefix)Lamp', lmp, rad, loc * coords_mult) {
            lmp.SetState(
                (Lamp1(lmp) != None && type1) ||
                (Lamp2(lmp) != None && type2) ||
                (Lamp3(lmp) != None && type3)
            );
        }
    }
#endif
}

static function GoalCompletedSilent(#var(PlayerPawn) player, name goalName)
{
    local DeusExGoal goal;

    goal = player.FindGoal(goalName);
    if (goal != None) {
        goal.SetCompleted();
    }
}

function ConEventAddGoal AddGoalToCon(name conName, name goalName, bool bGoalCompleted, optional string goalText, optional int where)
{
    local Conversation con;
    local ConEvent ce, cePrev;
    local ConEventAddGoal ceag;

    con = GetConversation(conName);
    if (con != None) {
        ce = con.eventList;
        while (where > 0 && ce != None) {
            cePrev = ce;
            ce = ce.nextEvent;
            where--;
        }

        ceag = new(con) class'ConEventAddGoal';
        ceag.eventType = ET_AddGoal;
        ceag.goalName = goalName;
        ceag.bGoalCompleted = bGoalCompleted;
        ceag.goalText = goalText;
        ceag.nextEvent = ce;
        if (cePrev == None) {
            con.eventList = ceag;
        } else {
            cePrev.nextEvent = ceag;
        }
    }

    return ceag;
}

function FixMechanicBarks()
{
    local #var(prefix)Mechanic mec;

    foreach AllActors(class'#var(prefix)Mechanic', mec) {
        if (mec.FamiliarName == "Mechanic" && mec.BarkBindName == "Man") {
            mec.BarkBindName = "Mechanic";
        }
    }
}

defaultproperties
{
    // in order of proportion, then number of occurances.
    // in no cases here would vanilla unbreakable DeusExMovers have their FragmentClass changed to anything but 'MetalFragment' from something else

    fragmentGuesses(0)=(sound=sound'Pneumatic1Open',fragmentClass=class'MetalFragment')    // never breakable
    fragmentGuesses(1)=(sound=sound'Pneumatic1Close',fragmentClass=class'MetalFragment')   // never breakable
    // fragmentGuesses()=(sound=sound'GlassBreakLarge',fragmentClass=class'GlassFragment') // 100.00% (241 / 241)
    // fragmentGuesses()=(sound=sound'WoodDoor2Close',fragmentClass=class'WoodFragment')   // 100.00%   (67 / 67)
    fragmentGuesses(2)=(sound=sound'SmallExplosion2',fragmentClass=class'MetalFragment')   // 100.00%   (66 / 66)
    fragmentGuesses(3)=(sound=sound'MediumExplosion1',fragmentClass=class'MetalFragment')  // 100.00%   (63 / 63)
    fragmentGuesses(4)=(sound=sound'MediumExplosion2',fragmentClass=class'MetalFragment')  // 100.00%   (53 / 53)
    fragmentGuesses(5)=(sound=sound'MetalHit1',fragmentClass=class'MetalFragment')         // 100.00%   (15 / 15)
    fragmentGuesses(6)=(sound=sound'MetalHit2',fragmentClass=class'MetalFragment')         // 100.00%   (15 / 15)
    // fragmentGuesses()=(sound=sound'WoodDrawerMove',fragmentClass=class'WoodFragment')   // 100.00%   (15 / 15)
    fragmentGuesses(7)=(sound=sound'LargeElevStop',fragmentClass=class'MetalFragment')     // 100.00%   (14 / 14)
    fragmentGuesses(8)=(sound=sound'LargeElevMove',fragmentClass=class'MetalFragment')     // 100.00%     (8 / 8)
    fragmentGuesses(9)=(sound=sound'GarageDoorMove',fragmentClass=class'MetalFragment')    // 100.00%     (7 / 7)
    // fragmentGuesses()=(sound=sound'WoodDrawerOpen',fragmentClass=class'WoodFragment')   // 100.00%     (6 / 6)
    // fragmentGuesses()=(sound=sound'WoodSlide2Open',fragmentClass=class'WoodFragment')   // 100.00%     (3 / 3)
    // fragmentGuesses()=(sound=sound'MetalDrawerClos',fragmentClass=class'WoodFragment')  // 100.00%     (2 / 2)
    // fragmentGuesses()=(sound=sound'WoodSlide2Close',fragmentClass=class'WoodFragment')  // 100.00%     (2 / 2)
    // fragmentGuesses()=(sound=sound'WoodSlide2Move',fragmentClass=class'WoodFragment')   // 100.00%     (2 / 2)
    fragmentGuesses(10)=(sound=sound'LargeExplosion2',fragmentClass=class'MetalFragment')  // 100.00%     (2 / 2)
    // fragmentGuesses()=(sound=sound'SmallElevMove',fragmentClass=class'WoodFragment')    // 100.00%     (1 / 1)
    fragmentGuesses(11)=(sound=sound'SmallElevStop',fragmentClass=class'MetalFragment')    // 100.00%     (1 / 1)
    // fragmentGuesses()=(sound=sound'GlassBreakSmall',fragmentClass=class'GlassFragment') //  98.71% (230 / 233)
    fragmentGuesses(12)=(sound=sound'SmallExplosion1',fragmentClass=class'MetalFragment')  //  94.53% (121 / 128)
    // fragmentGuesses()=(sound=sound'WoodBreakLarge',fragmentClass=class'WoodFragment')   //  90.53% (258 / 285)
    // fragmentGuesses()=(sound=sound'WoodBreakSmall',fragmentClass=class'WoodFragment')   //  90.21% (258 / 286)
    // fragmentGuesses()=(sound=sound'WoodDoor2Open',fragmentClass=class'WoodFragment')    //  88.57%   (62 / 70)
    fragmentGuesses(13)=(sound=sound'LargeExplosion1',fragmentClass=class'MetalFragment')  //  86.79%   (46 / 53)
    // fragmentGuesses()=(sound=sound'WoodDrawerClose',fragmentClass=class'WoodFragment')  //  86.67%   (26 / 30)
    fragmentGuesses(14)=(sound=sound'MetalDoorOpen',fragmentClass=class'MetalFragment')    //  81.25%   (65 / 80)
    fragmentGuesses(15)=(sound=sound'SlideDoorMove',fragmentClass=class'MetalFragment')    //  81.25%   (13 / 16)
    // fragmentGuesses()=(sound=sound'WoodDoorOpen',fragmentClass=class'WoodFragment')     //  80.85%   (76 / 94)
    // fragmentGuesses()=(sound=sound'MetalLockerOpen',fragmentClass=class'GlassFragment') //  80.00%     (4 / 5)
    // fragmentGuesses()=(sound=sound'MetalLockerClos',fragmentClass=class'GlassFragment') //  80.00%     (4 / 5)
    fragmentGuesses(16)=(sound=sound'MetalDoorClose',fragmentClass=class'MetalFragment')   //  79.02% (113 / 143)
    fragmentGuesses(17)=(sound=sound'GarageDoorOpen',fragmentClass=class'MetalFragment')   //  77.78%     (7 / 9)
    fragmentGuesses(18)=(sound=sound'GarageDoorClose',fragmentClass=class'MetalFragment')  //  77.78%     (7 / 9)
    fragmentGuesses(19)=(sound=sound'MetalDoorMove',fragmentClass=class'MetalFragment')    //  76.84% (136 / 177)
    // fragmentGuesses()=(sound=sound'WoodDoor2Move',fragmentClass=class'WoodFragment')    //  75.00%   (24 / 32)
    fragmentGuesses(20)=(sound=sound'StoneSlide2Open',fragmentClass=class'MetalFragment')  //  75.00%     (3 / 4)
    fragmentGuesses(21)=(sound=sound'WoodSlide1Move',fragmentClass=class'MetalFragment')   //  75.00%     (3 / 4)
    // fragmentGuesses()=(sound=sound'WoodDoorClose',fragmentClass=class'WoodFragment')    //  74.55%   (41 / 55)
    // fragmentGuesses()=(sound=sound'WoodSlide1Close',fragmentClass=class'WoodFragment')  //  72.73%   (16 / 22)
    // fragmentGuesses()=(sound=sound'StallDoorOpen',fragmentClass=class'WoodFragment')    //  64.71%   (11 / 17)
    fragmentGuesses(22)=(sound=sound'SlideDoorClose',fragmentClass=class'MetalFragment')   //  62.50%   (15 / 24)
    // fragmentGuesses()=(sound=sound'StallDoorClose',fragmentClass=class'WoodFragment')   //  60.00%    (9 / 15)
    fragmentGuesses(23)=(sound=sound'StoneSlide2Move',fragmentClass=class'MetalFragment')  //  60.00%     (3 / 5)
    fragmentGuesses(24)=(sound=sound'SlideDoorOpen',fragmentClass=class'MetalFragment')    //  57.58%   (19 / 33)
}
