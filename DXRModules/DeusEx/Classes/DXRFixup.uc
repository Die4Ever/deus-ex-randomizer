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
    var string map;
    var string text;
    var vector location;// 0,0,0 for random
    // spawned in PreFirstEntry, so if you set a location then it will be moved according to the logic of DXRPasswords
};
var AddDatacube add_datacubes[32];

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

    DecorationsOverwrites[i].type = "Van";
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

    Super.CheckConfig();

    for(i=0; i<ArrayCount(DecorationsOverwrites); i++) {
        if( DecorationsOverwrites[i].type == "" ) continue;
        DecorationsOverwritesClasses[i] = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    }
    for(i=0; i<ArrayCount(add_datacubes); i++) {
        add_datacubes[i].map = Caps(add_datacubes[i].map);
    }
}

function PreFirstEntry()
{
    local #var(prefix)Lamp lmp;

    Super.PreFirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" PreFirstEntry()");

    SetSeed( "DXRFixup PreFirstEntry" );

    OverwriteDecorations();
    FixFlagTriggers();
    FixBeamLaserTriggers();
    SpawnDatacubes();
    AntiEpilepsy();

#ifdef vanilla
    foreach AllActors(class'#var(prefix)Lamp', lmp) {
        lmp.InitLight();
    }
    SetAllLampsState(true, true, true);
#endif

    SetSeed( "DXRFixup PreFirstEntry missions" );
    if(#defined(mapfixes))
        PreFirstEntryMapFixes();
}

function PostFirstEntry()
{
    Super.PostFirstEntry();

    CleanupPlaceholders();
    SetSeed( "DXRFixup PostFirstEntry missions" );
    if(#defined(mapfixes))
        PostFirstEntryMapFixes();
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
}

function ShowTeleporters()
{
    local #var(prefix)Teleporter t;
    local bool hide;

    hide = ! class'MenuChoice_ShowTeleporters'.static.ShowTeleporters();

    foreach AllActors(class'#var(prefix)Teleporter', t) {
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

    switch(dxr.localURL) {
    case "01_NYC_UNATCOHQ":
    case "03_NYC_UNATCOHQ":
    case "04_NYC_UNATCOHQ":
        foreach AllActors(class'RetinalScanner', r) {
            if( r.Event != 'retinal_msg_trigger' ) continue;
            r.bHackable = false;
            r.hackStrength = 0;
            r.msgUsed = "";
        }
        break;
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
        if (cp.UserList[0].UserName=="ajacobson" && cp.UserList[1].UserName==""){
            cp.TextPackage = "#var(package)";
            break;
        }
    }
}

function FixSamCarter()
{
    local SamCarter s;
    foreach AllActors(class'SamCarter', s) {
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
                    err("inventory overlap at (" $ x $ ", " $ y $ ") " $ item);
                    good = false;
                }
                slots[x*8 + y]++;
            }
        }
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

//Scale the damage done by zones to counteract the damage scaling from CombatDifficulty
function ScaleZoneDamage()
{
    local ZoneInfo z;

    if(!#defined(vanilla)){
        return;
    }

    foreach AllActors(class'ZoneInfo',z){
        if (z.bPainZone){
            z.DamagePerSec=Clamp((z.DamagePerSec+1)/player().CombatDifficulty,1,(z.DamagePerSec+1));
        }
    }
}

function OverwriteDecorations()
{
    local DeusExDecoration d;
    local #var(prefix)Barrel1 b;
    local int i;
    foreach AllActors(class'DeusExDecoration', d) {
        if( d.IsA('CrateBreakableMedCombat') || d.IsA('CrateBreakableMedGeneral') || d.IsA('CrateBreakableMedMedical') ) {
            d.Mass = 35;
            d.HitPoints = 1;
        }
        for(i=0; i < ArrayCount(DecorationsOverwrites); i++) {
            if(DecorationsOverwritesClasses[i] == None) continue;
            if( d.IsA(DecorationsOverwritesClasses[i].name) == false ) continue;
            if( d.bIsSecretGoal == True) continue;
            d.bInvincible = DecorationsOverwrites[i].bInvincible;
            d.HitPoints = DecorationsOverwrites[i].HitPoints;
            d.minDamageThreshold = DecorationsOverwrites[i].minDamageThreshold;
            d.bFlammable = DecorationsOverwrites[i].bFlammable;
            d.Flammability = DecorationsOverwrites[i].Flammability;
            d.bExplosive = DecorationsOverwrites[i].bExplosive;
            d.explosionDamage = DecorationsOverwrites[i].explosionDamage;
            d.explosionRadius = DecorationsOverwrites[i].explosionRadius;
            d.bPushable = DecorationsOverwrites[i].bPushable;
        }
    }

    // in DeusExDecoration is the Exploding state, it divides the damage into 5 separate ticks with gradualHurtSteps = 5;
    foreach AllActors(class'#var(prefix)Barrel1', b) {
        if( b.explosionDamage > 50 && b.explosionDamage < 400 ) {
            b.explosionDamage = 400;
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

    foreach AllActors(class'#var(prefix)BeamTrigger',bt){
        bt.TriggerType=TT_AnyProximity;
    }
    foreach AllActors(class'#var(prefix)LaserTrigger',lt){
        lt.TriggerType=TT_AnyProximity;
    }
#endif
}

function SpawnDatacubes()
{
#ifdef injections
    local #var(prefix)DataCube dc;
#else
    local DXRInformationDevices dc;
#endif

    local vector loc;
    local int i;

    if(dxr.flags.IsReducedRando())
        return;

    SetSeed( "DXRFixup SpawnDatacubes" );

    if( dxr.localURL == "" ) {
        warning("SpawnDatacubes() empty localURL, " $ GetURLMap());
        return;
    }

    for(i=0; i<ArrayCount(add_datacubes); i++) {
        if( dxr.localURL != add_datacubes[i].map ) continue;

        loc = add_datacubes[i].location * coords_mult;
        if( loc.X == 0 && loc.Y == 0 && loc.Z == 0 )
            loc = GetRandomPosition();

#ifdef injections
        dc = Spawn(class'#var(prefix)DataCube',,, loc, rotm(0,0,0,0));
#else
        dc = Spawn(class'DXRInformationDevices',,, loc, rotm(0,0,0,0));
#endif

        if( dc != None ){
            dc.SetCollision(true,false,false);
            if(dxr.flags.settings.infodevices > 0)
                GlowUp(dc);
            dc.plaintext = add_datacubes[i].text;
            l("add_datacubes spawned "$dc @ dc.plaintext @ loc);
        }
        else warning("failed to spawn datacube at "$loc$", text: "$add_datacubes[i].text);
    }
}

function AntiEpilepsy()
{
    local Light l;

    if (!class'MenuChoice_Epilepsy'.default.enabled){
        return;
    }


    foreach AllActors(class'Light',l){
        if (l.LightType==LT_Strobe){
            l.LightType=LT_Pulse;
        } else if (l.LightType==LT_Flicker){
            l.LightType=LT_Pulse;
        }
    }
}

function AddDelayEvent(Name tag, Name event, float time)
{
    local Dispatcher d;
    d = Spawn(class'Dispatcher',, tag);
    d.OutEvents[0] = event;
    d.OutDelays[0] = time;
}

function AddDelay(Actor trigger, float time)
{
    local name tagname;
    tagname = StringToName( "dxr_delay_" $ trigger.Event );
    AddDelayEvent(tagname, trigger.Event, time);
    trigger.Event = tagname;
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

function SetAllLampsState(bool type1, bool type2, bool type3, optional Vector loc, optional float rad)
{
#ifdef vanilla
    local #var(prefix)Lamp lmp;

    if (class'MenuChoice_AutoLamps'.default.enabled == false)
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

function MoveSmugglerElevator()
{
    local #var(prefix)DeusExMover elevator;
    local bool street;

    if (!#defined(vanilla)) return;

    street = dxr.localURL == "02_NYC_STREET" || dxr.localURL == "04_NYC_STREET" || dxr.localURL == "08_NYC_STREET";

    foreach AllActors(class'#var(prefix)DeusExMover', elevator, 'elevatorbutton') {
        // street and smuggler's need opposite keyframes for the same ElevatorUsed value
        if (dxr.flagbase.getBool('DXRSmugglerElevatorUsed')) {
            elevator.InterpolateTo(Int(street), 0.0);
        } else {
            elevator.InterpolateTo(Int(!street), 0.0);
        }
        break;
    }
}
