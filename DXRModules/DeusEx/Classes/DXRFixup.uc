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

var config DecorationsOverwrite DecorationsOverwrites[16];
var class<DeusExDecoration> DecorationsOverwritesClasses[16];

struct AddDatacube {
    var string map;
    var string text;
    var vector location;// 0,0,0 for random
    // spawned in PreFirstEntry, so if you set a location then it will be moved according to the logic of DXRPasswords
};
var config AddDatacube add_datacubes[32];

var int old_pawns;// used for NYC_04_CheckPaulRaid()
var int storedWeldCount;// ship weld points
var int storedReactorCount;// Area 51 goal


function CheckConfig()
{
    local int i;
    local class<DeusExDecoration> c;
    if( ConfigOlderThan(2,3,0,4) ) {
        for(i=0; i < ArrayCount(DecorationsOverwrites); i++) {
            DecorationsOverwrites[i].type = "";
        }
        i=0;
        DecorationsOverwrites[i].type = "CrateUnbreakableLarge";
        DecorationsOverwrites[i].bInvincible = false;
        DecorationsOverwrites[i].HitPoints = 2000;
        DecorationsOverwrites[i].minDamageThreshold = 0;
        c = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
        DecorationsOverwrites[i].bFlammable = c.default.bFlammable;
        DecorationsOverwrites[i].Flammability = c.default.Flammability;
        DecorationsOverwrites[i].bExplosive = c.default.bExplosive;
        DecorationsOverwrites[i].explosionDamage = c.default.explosionDamage;
        DecorationsOverwrites[i].explosionRadius = c.default.explosionRadius;
        DecorationsOverwrites[i].bPushable = c.default.bPushable;

        i++;
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

        i=0;

        add_datacubes[i].map = "00_Training";
        add_datacubes[i].text = "In the real game, the locations of nanokeys will be randomized.";
        add_datacubes[i].location = vect(362.768005, 1083.160889, -146.629639);
        i++;

        add_datacubes[i].map = "00_Training";
        add_datacubes[i].text = "Passwords are randomized! And in the real game, the locations of datacubes will also be randomized.";
        add_datacubes[i].location = vect(1492.952026, 824.573669, -146.630493);
        i++;

        add_datacubes[i].map = "00_TrainingCombat";
        add_datacubes[i].text = "Each type of weapon has its stats randomized.|n|nFor example, every knife will have the same stats so you don't need to compare different knives. But you will want to compare the knife vs the baton to see which one is better to keep.";
        add_datacubes[i].location = vect(-237.082443, 5.800471, -94.629921);
        i++;

        add_datacubes[i].map = "00_TrainingFinal";
        add_datacubes[i].text = "Many other things will be randomized when you get to the real game. In order to be prepared, check out our README and Wiki on the Deus Ex Randomizer GitHub.";
        add_datacubes[i].location = vect(6577.697266, -3884.925049, 33.369633);
        i++;

        add_datacubes[i].map = "05_NYC_UNATCOMJ12lab";
        add_datacubes[i].text = "Agent Sherman, I've updated the demiurge password for Agent Navarre's killphrase to archon. Make sure you don't leave this datacube lying around.";
        i++;

        add_datacubes[i].map = "06_HONGKONG_VERSALIFE";
        add_datacubes[i].text = "Versalife employee ID: 06288.  Use this to access the VersaLife elevator north of the market.";
        i++;

        add_datacubes[i].map = "06_HONGKONG_STORAGE";
        add_datacubes[i].text = "Access code to the Versalife nanotech research wing: 55655.";
        i++;

        add_datacubes[i].map = "09_NYC_Dockyard";
        add_datacubes[i].text = "Jenny I've got your number|nI need to make you mine|nJenny don't change your number|n 8675309";// DXRPasswords doesn't recognize |n as a wordstop
        i++;

#ifdef vanillamaps
        add_datacubes[i].map = "15_AREA51_BUNKER";
        add_datacubes[i].text = "Security Personnel:|nDue to the the threat of a mass civilian raid of Area 51, we have updated the ventilation security system.|n|nUser: SECURITY |nPassword: NarutoRun |n|nBe on the lookout for civilians running with their arms swept behind their backs...";
        i++;

        add_datacubes[i].map = "15_AREA51_BUNKER";
        add_datacubes[i].text = "Security Personnel:|nFor increased ventilation system security, we have replaced the elevator button with a keypad.  The code is 17092019.  Do not share the code with anyone and destroy this datacube after reading.";
        i++;
#endif

        add_datacubes[i].map = "15_AREA51_ENTRANCE";
        add_datacubes[i].text =
            "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
            $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
            $ "  The code is 6786.  I love you."
            $ "|n|nJustin";
        i++;

        add_datacubes[i].map = "15_AREA51_ENTRANCE";
        add_datacubes[i].text =
            "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
            $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
            $ "  The code is 3901.  I love you."
            $ "|n|nJohn";
        i++;

        add_datacubes[i].map = "15_AREA51_ENTRANCE";
        add_datacubes[i].text =
            "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
            $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
            $ "  The code is 4322.  I love you."
            $ "|n|nJim";
        i++;

        add_datacubes[i].map = "15_AREA51_PAGE";
        add_datacubes[i].text =
            "The security guys found my last datacube so they changed the UC Control Rooms code to 1234. I don't know what they're so worried about, no one could make it this far into Area 51. What's the worst that could happen?";
        i++;

        add_datacubes[i].map = "15_AREA51_PAGE";
        add_datacubes[i].text =
            "The security guys found my last datacube so they changed the Aquinas Router code to 6188. I don't know what they're so worried about, no one could make it this far into Area 51. What's the worst that could happen?";
        i++;
    }
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
    Super.PreFirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" PreFirstEntry()");

    SetSeed( "DXRFixup PreFirstEntry" );

    OverwriteDecorations();
    FixFlagTriggers();
    SpawnDatacubes();

    SetSeed( "DXRFixup PreFirstEntry missions" );
    if(#defined(mapfixes))
        PreFirstEntryMapFixes();
}

function PostFirstEntry()
{
    Super.PostFirstEntry();

    if(#defined(mapfixes))
        PostFirstEntryMapFixes();
}

function AnyEntry()
{
    local #var(prefix)Vehicles v;
    local #var(prefix)Button1 b;
    local #var(prefix)Teleporter t;
    Super.AnyEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" AnyEntry()");

    SetSeed( "DXRFixup AnyEntry" );

    FixSamCarter();
    SetSeed( "DXRFixup AnyEntry missions" );
    if(#defined(mapfixes))
        AnyEntryMapFixes();

    FixAmmoShurikenName();

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
    foreach AllActors(class'#var(prefix)Teleporter', t) {
        if(t.bCollideActors)
            t.bHidden = false;
    }
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);
    if(#defined(vanillamaps))
        FixLogTimeout(p);

    FixAmmoShurikenName();
    FixInventory(p);
}

function PreTravel()
{
    Super.PreTravel();
    if(#defined(mapfixes))
        PreTravelMapFixes();
}

function Timer()
{
    Super.Timer();
    if( dxr == None ) return;

    if(#defined(mapfixes))
        TimerMapFixes();
}

function PreFirstEntryMapFixes()
{
    switch(dxr.dxInfo.missionNumber) {
    case 2:
        NYC_02_FirstEntry();
        break;
    case 3:
        Airfield_FirstEntry();
        break;
    case 4:
        NYC_04_FirstEntry();
        break;
    case 5:
        Jailbreak_FirstEntry();
    case 6:
        HongKong_FirstEntry();
        break;
    case 9:
        Shipyard_FirstEntry();
        break;
    case 10:
    case 11:
        Paris_FirstEntry();
        break;
    case 12:
    case 14:
        Vandenberg_FirstEntry();
        break;
    case 15:
        Area51_FirstEntry();
        break;
    }
}

function PostFirstEntryMapFixes()
{
    local RetinalScanner r;
    local #var(prefix)CrateUnbreakableLarge c;
    local DeusExMover m;
    local UNATCOTroop u;
    local Actor a;
    local Male1 male;
    local BlockPlayer bp;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        foreach AllActors(class'DeusExMover', m, 'UN_maindoor') {
            m.bBreakable = false;
            m.bPickable = false;
            m.bIsDoor = false;// this prevents Floyd from opening the door
        }
        foreach AllActors(class'BlockPlayer', bp) {
            if(bp.Group == 'waterblock') {
                bp.bBlockPlayers = false;
            }
        }
        break;
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
    case "05_NYC_UNATCOHQ":
        foreach AllActors(class'RetinalScanner', r) {
            if( r.Event == 'retinal_msg_trigger' ){
                r.Event = 'UN_blastdoor2';
                r.bHackable = true;
                r.hackStrength = 0;
                r.msgUsed = "Access De-/.&*% g r a n t e d";
            } else if (r.Event == 'securitytrigger') {
                r.Event = 'UNblastdoor';
                r.bHackable = true;
                r.hackStrength = 0;
                r.msgUsed = "Access De-/.&*% g r a n t e d";
            }
        }
        break;

    case "02_NYC_WAREHOUSE":
        if(!#defined(revision)) {
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vect(183.993530, 926.125000, 1162.103271));// apartment
            AddBox(class'#var(prefix)CrateUnbreakableMed', vect(-389.361969, 744.039978, 1088.083618));// ladder
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vect(-328.287048, 767.875000, 1072.113770));
        }

        // this map is too hard
        Spawn(class'#var(prefix)AdaptiveArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)AdaptiveArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());
        break;

#ifndef revision
    case "03_NYC_BrooklynBridgeStation":
        a = _AddActor(Self, class'Barrel1', vect(-27.953907, -3493.229980, 45.101418), rot(0,0,0));
        Barrel1(a).SkinColor = SC_Explosive;
        a.BeginPlay();
        break;

    case "03_NYC_AirfieldHeliBase":
        //crates to get back over the beginning of the level
        _AddActor(Self, class'#var(prefix)CrateUnbreakableSmall', vect(-9463.387695, 3377.530029, 60), rot(0,0,0));
        _AddActor(Self, class'#var(prefix)CrateUnbreakableMed', vect(-9461.959961, 3320.718750, 75), rot(0,0,0));
        break;
#endif

    case "04_NYC_NSFHQ":
        // no cheating!
        foreach AllActors(class'DeusExMover', m, 'SignalComputerDoorOpen') {
            m.bBreakable = false;
            m.bPickable = false;
        }
        // these crates can make the basement nearly impossible to get through
        foreach AllActors(class'#var(prefix)CrateUnbreakableLarge', c) {
            if(c.Location.Z > -28.799877) continue;
            c.Destroy();
        }
        break;
    case "05_NYC_UNATCOMJ12LAB":
        BalanceJailbreak();
        break;

#ifndef revision
    case "06_HONGKONG_VERSALIFE":
        foreach AllActors(class'Male1',male){
            if (male.BindName=="Disgruntled_Guy"){
                male.bImportant=True;
            }
        }
        break;
    case "09_NYC_DOCKYARD":
        // this crate can block the way out of the start through the vent
        foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 160, vect(2510.350342, 1377.569336, 103.858093)) {
            info("removing " $ c $ " dist: " $ VSize(c.Location - vect(2510.350342, 1377.569336, 103.858093)) );
            c.Destroy();
        }
        break;

    case "09_NYC_SHIPBELOW":
        // add a tnt crate on top of the pipe, visible from the ground floor
        _AddActor(Self, class'#var(prefix)CrateExplosiveSmall', vect(141.944641, -877.442627, -175.899567), rot(0,0,0));
        // remove big crates blocking the window to the pipe, 16 units == 1 foot
        foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 16*4, vect(-136.125000, -743.875000, -215.899323)) {
            c.Event = '';
            c.Destroy();
        }
        break;

    case "12_VANDENBERG_CMD":
        foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 16, vect(570.835083, 1934.114014, -1646.114746)) {
            info("removing " $ c $ " dist: " $ VSize(c.Location - vect(570.835083, 1934.114014, -1646.114746)) );
            c.Destroy();
        }
        break;

    case "14_OCEANLAB_LAB":
        // ensure rebreather before greasel lab, in case the storage closet key is in the flooded area
        a = _AddActor(Self, class'#var(prefix)Rebreather', vect(1569, 24, -1628), rot(0,0,0));
        a.SetPhysics(PHYS_None);
        l("PostFirstEntryMapFixes spawned "$ActorToString(a));
        break;
#endif
    }
}

function AnyEntryMapFixes()
{
    switch(dxr.dxInfo.missionNumber) {
    case 3:
        Airfield_AnyEntry();
        break;
    case 4:
        NYC_04_AnyEntry();
        break;
    case 6:
        HongKong_AnyEntry();
        break;
    case 8:
        NYC_08_AnyEntry();
        break;
    case 9:
        Shipyard_AnyEntry();
        break;
    case 10:
    case 11:
        Paris_AnyEntry();
        break;
    case 12:
    case 14:
        Vandenberg_AnyEntry();
        break;
    case 15:
        Area51_AnyEntry();
        break;
    }
}

function AllAnyEntry()
{
    // for when mapfixes isn't defined, but currently it's defined for all mods even Revision
}

function PreTravelMapFixes()
{
    if(dxr == None) {
        warning("PreTravelMapFixes with dxr None");
        return;
    }
    switch(dxr.localURL) {
    case "04_NYC_HOTEL":
        if(#defined(vanilla))
            NYC_04_LeaveHotel();
        break;
    }
}

function TimerMapFixes()
{
    local BlackHelicopter chopper;
    local Music m;
    local int i;

    switch(dxr.localURL)
    {
    case "03_NYC_747":
        FixAnnaAmbush();
        break;

    case "04_NYC_HOTEL":
        if(#defined(vanilla))
            NYC_04_CheckPaulRaid();
        break;

    case "06_HONGKONG_WANCHAI_MARKET":
        UpdateGoalWithRandoInfo('InvestigateMaggieChow');
        break;

    case "08_NYC_STREET":
        if (#defined(vanillamaps) && dxr.flagbase.GetBool('StantonDowd_Played') )
        {
            foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
                chopper.EnterWorld();
            dxr.flagbase.SetBool('MS_Helicopter_Unhidden', True,, 9);
        }
        UpdateGoalWithRandoInfo('FindHarleyFilben');
        break;

    case "09_NYC_SHIPBELOW":
        NYC_09_CountWeldPoints();
        break;

    case "10_PARIS_CATACOMBS_TUNNELS":
        UpdateGoalWithRandoInfo('FindNicolette');
        break;

    case "15_AREA51_PAGE":
        Area51_CountBlueFusion();
        break;
    }
}

function FixSamCarter()
{
    local SamCarter s;
    foreach AllActors(class'SamCarter', s) {
        RemoveFears(s);
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

simulated function FixInventory(#var(PlayerPawn) p)
{
    local Inventory item, nextItem;
    local DXRLoadouts loadouts;

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
            log(f @ f.FlagName @ f.flagValue $" changed expiration from -1 to 999");
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
    local int i;

    for(i=0; i<ArrayCount(add_datacubes); i++) {
        if( dxr.localURL != add_datacubes[i].map ) continue;

        loc = add_datacubes[i].location;
        if( loc.X == 0 && loc.Y == 0 && loc.Z == 0 )
            loc = GetRandomPosition();

#ifdef injections
        dc = Spawn(class'#var(prefix)DataCube',,, loc, rot(0,0,0));
#else
        dc = Spawn(class'DXRInformationDevices',,, loc, rot(0,0,0));
#endif

        if( dc != None ){
             dc.plaintext = add_datacubes[i].text;
             l("add_datacubes spawned "$dc @ dc.plaintext @ loc);
        }
        else warning("failed to spawn datacube at "$loc$", text: "$add_datacubes[i].text);
    }
}

function NYC_02_FirstEntry()
{
    local DeusExMover d;
    local NanoKey k;
    local NYPoliceBoat b;
    local CrateExplosiveSmall c;
    local BarrelAmbrosia ambrosia;
    local Trigger t;

    switch (dxr.localURL)
    {
#ifdef vanillamaps
    case "02_NYC_BATTERYPARK":
        foreach AllActors(class'BarrelAmbrosia', ambrosia) {
            foreach RadiusActors(class'Trigger', t, 16, ambrosia.Location) {
                if(t.CollisionRadius < 100)
                    t.SetCollisionSize(t.CollisionRadius*2, t.CollisionHeight*2);
            }
        }
        foreach AllActors(class'NYPoliceBoat',b) {
            b.BindName = "NYPoliceBoat";
            b.ConBindEvents();
        }
        foreach AllActors(class'DeusExMover', d) {
            if( d.Name == 'DeusExMover19' ) {
                d.KeyIDNeeded = 'ControlRoomDoor';
            }
        }
        k = Spawn(class'NanoKey',,, vect(1574.209839, -238.380142, 339.215179));
        k.KeyID = 'ControlRoomDoor';
        k.Description = "Control Room Door Key";
        break;
#endif

#ifdef revision
    case "02_NYC_STREET":
        foreach AllActors(class'CrateExplosiveSmall', c) {
            l("hiding " $ c @ c.Tag @ c.Event);
            c.bHidden = true;// hide it so DXRSwapItems doesn't move it, this is supposed to be inside the plane that flies overhead
        }
        break;
#endif
    }
}

function Airfield_FirstEntry()
{
    local Mover m;
    local Actor a;
    local Trigger t;
    local NanoKey k;
    local #var(prefix)InformationDevices i;
    local #var(prefix)UNATCOTroop unatco;

    switch (dxr.localURL)
    {
    case "03_NYC_BATTERYPARK":
        foreach AllActors(class'NanoKey', k) {
            // unnamed key normally unreachable
            if( k.KeyID == '' || k.KeyID == 'KioskDoors' ) {
                k.Destroy();
            }
        }
        foreach AllActors(class'#var(prefix)InformationDevices', i) {
            if( i.textTag == '03_Book06' ) {
                i.bAddToVault = true;
            }
        }

        //rebreather because of #TOOCEAN connection
        _AddActor(Self, class'Rebreather', vect(-936.151245, -3464.031006, 293.710968), rot(0,0,0));

        //Add some junk around the park so that there are some item locations outside of the shanty town
        _AddActor(Self, class'Liquor40oz', vect(933.56,-3554.86,279.04), rot(0,0,0));
        _AddActor(Self, class'Sodacan', vect(2203.28,-3558.84,279.04), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-980.83,-3368.42,286.24), rot(0,0,0));
        _AddActor(Self, class'Cigarettes', vect(-682.67,-3771.20,282.24), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-2165.67,-3546.039,285.30), rot(0,0,0));
        _AddActor(Self, class'Sodacan', vect(-2170.83,-3094.94,330.24), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-3180.75,-3546.79,281.43), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-2619.56,-2540.80,330.25), rot(0,0,0));
        _AddActor(Self, class'Cigarettes', vect(-3289.43,-919.07,360.80), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(-2799.94,-922.68,361.86), rot(0,0,0));
        _AddActor(Self, class'Sodacan', vect(800.76,1247.99,330.25), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(1352.29,2432.98,361.58), rot(0,0,0));
        _AddActor(Self, class'Cigarettes', vect(788.50,2359.26,360.63), rot(0,0,0));
        _AddActor(Self, class'Liquor40oz', vect(3153.26,-310.73,326.25), rot(0,0,0));
        _AddActor(Self, class'Sodacan', vect(-2132.21,1838.89,326.25), rot(0,0,0));

        break;

#ifdef vanillamaps
    case "03_NYC_AirfieldHeliBase":
        foreach AllActors(class'Mover',m) {
            // call the elevator at the end of the level when you open the appropriate door
            if (m.Tag == 'BasementDoorOpen')
            {
                m.Event = 'BasementFloor';
            }
            else if (m.Tag == 'GroundDoorOpen')
            {
                m.Event = 'GroundLevel';
            }
            // sewer door backtracking so we can make a switch for this
            else if ( DeusExMover(m) != None && DeusExMover(m).KeyIDNeeded == 'Sewerdoor')
            {
                m.Tag = 'Sewerdoor';
            }
        }
        foreach AllActors(class'Trigger', t) {
            //disable the platforms that fall when you step on them
            if( t.Name == 'Trigger0' || t.Name == 'Trigger1' ) {
                t.Event = '';
            }
        }
        foreach AllActors(class'#var(prefix)UNATCOTroop', unatco) {
            unatco.bHateCarcass = false;
            unatco.bHateDistress = false;
        }

        // Sewerdoor backtracking
        AddSwitch( vect(-6878.640137, 3623.358398, 150.903931), rot(0,0,0), 'Sewerdoor');

        //stepping stone valves out of the water, I could make the collision radius a little wider even if it isn't realistic?
        _AddActor(Self, class'Valve', vect(-3105,-385,-210), rot(0,0,16384));
        a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3105,-385,-210), rot(0,0,0));
        SetActorScale(a, 1.3);

        _AddActor(Self, class'Valve', vect(-3080,-395,-170), rot(0,0,16384));
        a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3080,-395,-170), rot(0,0,0));
        SetActorScale(a, 1.3);

        _AddActor(Self, class'Valve', vect(-3065,-405,-130), rot(0,0,16384));
        a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3065,-405,-130), rot(0,0,0));
        SetActorScale(a, 1.3);

        //rebreather because of #TOOCEAN connection
        _AddActor(Self, class'Rebreather', vect(1411.798950, 546.628845, 247.708572), rot(0,0,0));
        break;
#endif

    case "03_NYC_AIRFIELD":
        //rebreather because of #TOOCEAN connection
        _AddActor(Self, class'Rebreather', vect(-2031.959473, 995.781067, 75.709816), rot(0,0,0));
        break;

#ifdef vanillamaps
    case "03_NYC_BROOKLYNBRIDGESTATION":
        //Put a button behind the hidden bathroom door
        //Mostly for entrance rando, but just in case
        AddSwitch( vect(-1673, -1319.913574, 130.813538), rot(0, 32767, 0), 'MoleHideoutOpened' );
        break;

    case "03_NYC_MOLEPEOPLE":
        foreach AllActors(class'Mover', m, 'DeusExMover') {
            if( m.Name == 'DeusExMover65' ) m.Tag = 'BathroomDoor';
        }
        AddSwitch( vect(3745, -2593.711914, 140.335358), rot(0, 0, 0), 'BathroomDoor' );
        break;
#endif

    case "03_NYC_747":
        // fix Jock's conversation state so he doesn't play the dialog for unatco->battery park but now plays dialog for airfield->unatco
        // DL_Airfield is "You're entering a helibase terminal below a private section of LaGuardia."
        dxr.flagbase.SetBool('DL_Airfield_Played', true,, 4);
        if(#defined(vanillamaps)) {
            foreach AllActors(class'#var(prefix)InformationDevices', i) {
                if(i.imageClass == Class'Image03_747Diagram') {
                    // move the out of bounds datacabe onto the bed of the empty room
                    i.SetLocation(vect(1554.862549, -741.237427, 363.370605));
                }
            }
        }
        break;

    case "03_NYC_UNATCOISLAND":
        foreach AllActors(class'#var(prefix)UNATCOTroop', unatco) {
            if(unatco.BindName != "PrivateLloyd") continue;
            unatco.FamiliarName = "Corporal Lloyd";
            unatco.UnfamiliarName = "Corporal Lloyd";
        }
        break;
    }
}

function Airfield_AnyEntry()
{
    switch(dxr.localURL) {
    case "03_NYC_747":
        SetTimer(1, true);
        break;
    }
}

function FixAnnaAmbush()
{
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)ThrownProjectile p;

    foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {break;}

    // if she's angry then let her blow up
    if(anna != None && anna.GetAllianceType('player') == ALLIANCE_Hostile) anna = None;

    foreach AllActors(class'#var(prefix)ThrownProjectile', p) {
        if(!p.bProximityTriggered || !p.bStuck) continue;
        if(p.Owner==player() && anna != None) p.SetOwner(anna);
        if(anna == None && p.Owner!=player()) p.SetOwner(player());
    }
}

function Jailbreak_FirstEntry()
{
    local #var(PlayerPawn) p;
    local PaulDenton paul;
    local ComputerPersonal c;
    local DeusExMover dxm;
    local #var(prefix)UNATCOTroop lloyd;
    local #var(prefix)AlexJacobson alex;
    local #var(prefix)JaimeReyes j;
    local DXREnemies dxre;
    local int i;

    switch (dxr.localURL)
    {
    case "05_NYC_UNATCOMJ12LAB":
        if(!dxr.flags.f.GetBool('MS_InventoryRemoved')) {
            p = player();
            p.HealthHead = Max(50, p.HealthHead);
            p.HealthTorso =  Max(50, p.HealthTorso);
            p.HealthLegLeft =  Max(50, p.HealthLegLeft);
            p.HealthLegRight =  Max(50, p.HealthLegRight);
            p.HealthArmLeft =  Max(50, p.HealthArmLeft);
            p.HealthArmRight =  Max(50, p.HealthArmRight);
            p.GenerateTotalHealth();
            if(dxr.flags.settings.prison_pocket > 0 || #defined(vanillamaps))
                dxr.flags.f.SetBool('MS_InventoryRemoved', true,, 6);
            // we have to move the items in PostFirstEntry, otherwise they get swapped around with other things
        }
        foreach AllActors(class'PaulDenton', paul) {
            paul.RaiseAlarm = RAISEALARM_Never;// https://www.twitch.tv/die4ever2011/clip/ReliablePerfectMarjoramDxAbomb
        }

#ifdef vanillamaps
        foreach AllActors(class'DeusExMover',dxm){
            if (dxm.Name=='DeusExMover34'){
                //I think this filing cabinet door was supposed to
                //be unlockable with Agent Sherman's key as well
                dxm.KeyIDNeeded='Cabinet';
            }
        }
#endif

        break;

#ifdef vanillamaps
    case "05_NYC_UNATCOHQ":
        foreach AllActors(class'ComputerPersonal', c) {
            if( c.Name != 'ComputerPersonal3' ) continue;
            // gunther and anna's computer across from Carter
            for(i=0; i < ArrayCount(c.UserList); i++) {
                if( c.UserList[i].userName != "JCD" ) continue;
                // it's silly that you can use JC's account to get part of Anna's killphrase, and also weird that Anna's account isn't on here
                c.UserList[i].userName = "anavarre";
                c.UserList[i].password = "scryspc";
            }
        }
        foreach AllActors(class'#var(prefix)AlexJacobson', alex) {
            RemoveFears(alex);
        }
        foreach AllActors(class'#var(prefix)JaimeReyes', j) {
            RemoveFears(j);
        }
        break;
#endif

    case "05_NYC_UNATCOISLAND":
        foreach AllActors(class'#var(prefix)UNATCOTroop', lloyd) {
            if(lloyd.BindName != "PrivateLloyd") continue;
            RemoveFears(lloyd);
            lloyd.MinHealth = 0;
            lloyd.BaseAccuracy *= 0.1;
            GiveItem(lloyd, class'#var(prefix)BallisticArmor');
            dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
            if(dxre != None) {
                dxre.GiveRandomWeapon(lloyd, false, 2);
                dxre.GiveRandomMeleeWeapon(lloyd);
            }
            lloyd.FamiliarName = "Master Sergeant Lloyd";
            lloyd.UnfamiliarName = "Master Sergeant Lloyd";
            if(!#defined(vmd)) {// vmd allows AI to equip armor, so maybe he doesn't need the health boost?
                SetPawnHealth(lloyd, 200);
            }
        }
        break;
    }
}

function BalanceJailbreak()
{
    local class<Inventory> iclass;
    local DXREnemies e;
    local DXRLoadouts loadout;
    local int i, num;
    local float r;
    local Inventory nextItem;
    local SpawnPoint SP;
    local #var(PlayerPawn) p;
    local vector itemLocations[50];
    local DXRMissions missions;
    local string PaulLocation;
    local #var(prefix)DataLinkTrigger dlt;

    SetSeed("BalanceJailbreak");

    // move the items instead of letting Mission05.uc do it
    p = player();
    if(dxr.flags.settings.prison_pocket <= 0 && #defined(vanillamaps)) {
        if(DeusExWeapon(p.inHand) != None)
            DeusExWeapon(p.inHand).LaserOff();

        PaulLocation = "Surgery Ward";
        missions = DXRMissions(dxr.FindModule(class'DXRMissions'));
        for(i=0;missions!=None && i<missions.num_goals;i++) {
            if(missions.GetSpoiler(i).goalName == "Paul") {
                PaulLocation = missions.GetSpoiler(i).goalLocation;
            }
        }
        num=0;
        l("BalanceJailbreak PaulLocation == " $ PaulLocation);
        if(PaulLocation == "Surgery Ward" || PaulLocation == "Greasel Pit")
            foreach AllActors(class'SpawnPoint', SP, 'player_inv')
                itemLocations[num++] = SP.Location;
        else {
            // put the items in the surgery ward
            itemLocations[num++] = vect(2174.416504,-569.534729,-213.660309);// paul's bed
            itemLocations[num++] = vect(2176.658936,-518.937012,-213.659302);// paul's bed
            itemLocations[num++] = vect(1792.696533,-738.417175,-213.660248);// bed 2
            itemLocations[num++] = vect(1794.898682,-802.133301,-213.658630);// bed 2
            itemLocations[num++] = vect(1572.443237,-739.527649,-213.660095);// bed 1
            itemLocations[num++] = vect(1570.557007,-801.213806,-213.660095);// bed 1
            itemLocations[num++] = vect(1269.494019,-522.082458,-221.659180);// near ambrosia
            itemLocations[num++] = vect(1909.302979,-376.711639,-221.660095);// desk with microscope and datacube
            itemLocations[num++] = vect(1572.411865,-967.828735,-261.659546);// on the floor, at the wall with the monitors
            itemLocations[num++] = vect(1642.170532,-968.813354,-261.660736);
            itemLocations[num++] = vect(1715.513062,-965.846558,-261.657837);
            itemLocations[num++] = vect(1782.731689,-966.754700,-261.661041);

            foreach AllActors(class'#var(prefix)DataLinkTrigger', dlt) {
                if(dlt.datalinkTag != 'dl_equipment') continue;
                dlt.bCollideWorld = false;
                l("BalanceJailbreak moving "$dlt @ dlt.SetLocation(vect(1670.443237,-702.527649,-179.660095)) @ dlt.Location);
            }
        }

        nextItem = p.Inventory;
        while(nextItem != None)
            for(i=0; i<num; i++)
                nextItem = MoveNextItemTo(nextItem, itemLocations[i], 'player_inv');
    }

    e = DXREnemies(dxr.FindModule(class'DXREnemies'));
    if( e != None ) {
        r = initchance();
        for(i=0; i < ArrayCount(e._randommelees); i++ ) {
            if( e._randommelees[i].type == None ) break;
            if( chance( e._randommelees[i].chance, r ) ) iclass = e._randommelees[i].type;
        }
        chance_remaining(r);
    }
    else iclass = class'#var(prefix)WeaponCombatKnife';

    // make sure Stick With the Prod and Ninja JC can beat this
    loadout = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    if(loadout != None && loadout.is_banned(iclass)) {
        iclass = loadout.get_starting_item();
    }

    switch(rng(4)) {
    case 1:// crate past the desk
        Spawn(iclass,,, vect(-1838.230225, 1250.242676, -110.399773));
        break;
    case 2:// desk
        Spawn(iclass,,, vect(-2105.412598, 1232.926758, -134.400101));
        break;
    case 3:// locked jail cell with medbot
        Spawn(iclass,,, vect(-3020.846924, 910.062134, -201.399750));
        break;
    default:// unlocked jail cell
        Spawn(iclass,,, vect(-2688.502686, 1424.474731, -158.099915));
        break;
    }
}

function UpdateReactorGoal(int count)
{
    local string goalText;
    local DeusExGoal goal;
    local int bracketPos;
    goal = player().FindGoal('OverloadForceField');

    if (goal!=None){
        goalText = goal.text;
        bracketPos = InStr(goalText,"[");

        if (bracketPos>0){ //If the extra text is already there, strip it.
            goalText = Mid(goalText,0,bracketPos-1);
        }

        goalText = goalText$" ["$count$" remaining]";

        goal.SetText(goalText);
    }
}

function Area51_CountBlueFusion()
{
    local int newCount;

    newCount = 4;

    if (dxr.flagbase.GetBool('Node1_Frobbed'))
        newCount--;
    if (dxr.flagbase.GetBool('Node2_Frobbed'))
        newCount--;
    if (dxr.flagbase.GetBool('Node3_Frobbed'))
        newCount--;
    if (dxr.flagbase.GetBool('Node4_Frobbed'))
        newCount--;

    if (newCount!=storedReactorCount){
        // A fusion reactor has been shut down!
        storedReactorCount = newCount;

        switch(newCount){
            case 0:
                player().ClientMessage("All Blue Fusion reactors shut down!");
                SetTimer(0, False);  // Disable the timer now that all fusion reactors are shut down
                break;
            case 1:
                player().ClientMessage("1 Blue Fusion reactor remaining");
                break;
            case 4:
                // don't alert the player at the start of the level
                break;
            default:
                player().ClientMessage(newCount$" Blue Fusion reactors remaining");
                break;
        }

        UpdateReactorGoal(newCount);
    }
}

function UpdateWeldPointGoal(int count)
{
    local string goalText;
    local DeusExGoal goal;
    local int bracketPos;
    goal = player().FindGoal('ScuttleShip');

    if (goal!=None){
        goalText = goal.text;
        bracketPos = InStr(goalText,"(");

        if (bracketPos>0){ //If the extra text is already there, strip it.
            goalText = Mid(goalText,0,bracketPos-1);
        }

        goalText = goalText$" ("$count$" remaining)";

        goal.SetText(goalText);
    }
}

function NYC_09_CountWeldPoints()
{
    local int newWeldCount;
    local DeusExMover m;

    newWeldCount=0;

    //Search for the weld point movers
    foreach AllActors(class'DeusExMover',m, 'ShipBreech') {
        if (!m.bDestroyed){
            newWeldCount++;
        }
    }

    if (newWeldCount != storedWeldCount) {
        //A weld point has been destroyed!
        storedWeldCount = newWeldCount;

        switch(newWeldCount){
            case 0:
                player().ClientMessage("All weld points destroyed!");
                SetTimer(0, False);  //Disable the timer now that all weld points are gone
                break;
            case 1:
                player().ClientMessage("1 weld point remaining");
                break;
            default:
                player().ClientMessage(newWeldCount$" weld points remaining");
                break;
        }

        UpdateWeldPointGoal(newWeldCount);
    }
}

function UpdateGoalWithRandoInfo(name goalName)
{
    local string goalText;
    local DeusExGoal goal;
    local int randoPos;
    goal = player().FindGoal(goalName);
    if (goal!=None){
        goalText = goal.text;
        randoPos = InStr(goalText,"Rando: ");

        if (randoPos==-1){
            switch(goalName){
                case 'InvestigateMaggieChow':
                    goalText = goalText$"|nRando: The sword may not be in Maggie's apartment, instead there will be a Datacube with a hint.";
                    break;
                case 'FindHarleyFilben':
                    if(dxr.flags.settings.goals > 0)
                        goalText = goalText$"|nRando: Harley could be anywhere in Hell's Kitchen";
                    break;
                case 'FindNicolette':
                    if(dxr.flags.settings.goals > 0)
                        goalText = goalText$"|nRando: Nicolette could be anywhere in the city";
                    break;
            }
            goal.SetText(goalText);
            player().ClientMessage("Goal Updated - Check DataVault For Details",, true);
        }
    }
}

// if you bail on Paul but then have a change of heart and re-enter to come back and save him
function NYC_04_CheckPaulUndead()
{
    local PaulDenton paul;
    local int count;

    if( ! dxr.flagbase.GetBool('PaulDenton_Dead')) return;

    foreach AllActors(class'PaulDenton', paul) {
        if( paul.Health > 0 ) {
            dxr.flagbase.SetBool('PaulDenton_Dead', false,, -999);
            return;
        }
    }
}

function NYC_04_CheckPaulRaid()
{
    local PaulDenton paul;
    local ScriptedPawn p;
    local int count, dead, pawns;

    if( ! dxr.flagbase.GetBool('M04RaidTeleportDone') ) return;

    foreach AllActors(class'PaulDenton', paul) {
        // fix a softlock if you jump while approaching Paul
        if( ! dxr.flagbase.GetBool('TalkedToPaulAfterMessage_Played') ) {
            player().StartConversationByName('TalkedToPaulAfterMessage', paul, False, False);
        }

        count++;
        if( paul.Health <= 0 ) dead++;
        if( ! paul.bInvincible ) continue;

        paul.bInvincible = false;
        SetPawnHealth(paul, 400);
        paul.ChangeAlly('Player', 1, true);
    }

    foreach AllActors(class'ScriptedPawn', p) {
        if( PaulDenton(p) != None ) continue;
        if( IsCritter(p) ) continue;
        if( p.bHidden ) continue;
        if( p.GetAllianceType('Player') != ALLIANCE_Hostile ) continue;
        p.bStasis = false;
        pawns++;
    }

    if( dead > 0 || dxr.flagbase.GetBool('PaulDenton_Dead') ) {
        player().ClientMessage("RIP Paul :(",, true);
        dxr.flagbase.SetBool('PaulDenton_Dead', true,, 999);
        SetTimer(0, False);
    }
    else if( dead == 0 && (count == 0 || pawns == 0) ) {
        NYC_04_MarkPaulSafe();
        SetTimer(0, False);
    }
    else if( pawns == 1 && pawns != old_pawns )
        player().ClientMessage(pawns$" enemy remaining");
    else if( pawns <3 && pawns != old_pawns )
        player().ClientMessage(pawns$" enemies remaining");
    old_pawns = pawns;
}

function NYC_04_MarkPaulSafe()
{
    local PaulDenton paul;
    local FlagTrigger t;
    local SkillAwardTrigger st;
    local int health;
    if( dxr.flagbase.GetBool('PaulLeftHotel') ) return;

    dxr.flagbase.SetBool('PaulLeftHotel', true,, 999);

    foreach AllActors(class'PaulDenton', paul) {
        paul.GenerateTotalHealth();
        health = paul.Health * 100 / 400;// as a percentage
        if(health == 0) health = 1;
        paul.SetOrders('Leaving', 'PaulLeaves', True);
    }

    if(health > 0) {
        player().ClientMessage("Paul had " $ health $ "% health remaining.");
    }

    foreach AllActors(class'FlagTrigger', t) {
        switch(t.tag) {
            case 'KillPaul':
            case 'BailedOutWindow':
                t.Destroy();
                break;
        }
        if( t.Event == 'BailedOutWindow' )
            t.Destroy();
    }

    foreach AllActors(class'SkillAwardTrigger', st) {
        switch(st.Tag) {
            case 'StayedWithPaul':
            case 'PaulOutaHere':
                st.Touch(player());
        }
    }
    class'DXREvents'.static.SavedPaul(dxr, player(), health);
}

function NYC_04_LeaveHotel()
{
    local FlagTrigger t;
    foreach AllActors(class'FlagTrigger', t) {
        if( t.Event == 'BailedOutWindow' )
        {
            t.Touch(player());
        }
    }
}

function NYC_04_FirstEntry()
{
    local FlagTrigger ft;
    local OrdersTrigger ot;
    local SkillAwardTrigger st;
    local #var(prefix)BoxSmall b;
    local #var(prefix)HackableDevices hd;
    local #var(prefix)CrateUnbreakableLarge crate;
    local #var(prefix)UNATCOTroop lloyd;

    switch (dxr.localURL)
    {
#ifdef vanilla
    case "04_NYC_HOTEL":
        foreach AllActors(class'OrdersTrigger', ot, 'PaulSafe') {
            if( ot.Orders == 'Leaving' )
                ot.Orders = 'Seeking';
        }
        foreach AllActors(class'FlagTrigger', ft) {
            if( ft.Event == 'PaulOutaHere' )
                ft.Destroy();
        }
        foreach AllActors(class'SkillAwardTrigger', st) {
            if( st.Tag == 'StayedWithPaul' ) {
                st.skillPointsAdded = 100;
                st.awardMessage = "Stayed with Paul";
                st.Destroy();// HACK: this trigger is buggy for some reason, just forget about it for now
            }
            else if( st.Tag == 'PaulOutaHere' ) {
                st.skillPointsAdded = 500;
                st.awardMessage = "Saved Paul";
            }
        }
        break;
#endif

    case "04_NYC_NSFHQ":
        foreach RadiusActors(class'#var(prefix)BoxSmall', b, 100, vect(-640.699402, 66.666039, -209.364014)) {
            b.Destroy();
        }
        foreach AllActors(class'#var(prefix)HackableDevices', hd) {
            hd.hackStrength /= 3.0;
        }
        foreach AllActors(class'#var(prefix)CrateUnbreakableLarge', crate) {
            crate.Event = '';
            crate.Destroy();
        }
        break;

    case "04_NYC_UNATCOISLAND":
        foreach AllActors(class'#var(prefix)UNATCOTroop', lloyd) {
            if(lloyd.BindName != "PrivateLloyd") continue;
            lloyd.FamiliarName = "Sergeant Lloyd";
            lloyd.UnfamiliarName = "Sergeant Lloyd";
            lloyd.bImportant = true;
        }
        break;
    }
}

function NYC_04_AnyEntry()
{
    local FordSchick ford;
    local #var(prefix)AnnaNavarre anna;

    DeleteConversationFlag(GetConversation('AnnaBadMama'), 'TalkedToPaulAfterMessage_Played', true);
    if(dxr.flagbase.GetBool('NSFSignalSent')) {
        foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {
            anna.EnterWorld();
        }
    }

    switch (dxr.localURL)
    {
#ifdef vanilla
    case "04_NYC_HOTEL":
        NYC_04_CheckPaulUndead();
        if( ! dxr.flagbase.GetBool('PaulDenton_Dead') )
            SetTimer(1, True);
        if(dxr.flagbase.GetBool('NSFSignalSent')) {
            dxr.flagbase.SetBool('PaulInjured_Played', true,, 5);
        }

        // conversations are transient, so they need to be fixed in AnyEntry
        FixConversationFlag(GetConversation('PaulAfterAttack'), 'M04RaidDone', true, 'PaulLeftHotel', true);
        FixConversationFlag(GetConversation('PaulDuringAttack'), 'M04RaidDone', false, 'PaulLeftHotel', false);
        break;
#endif

#ifdef vanillamaps
    case "04_NYC_SMUG":
        if( dxr.flagbase.GetBool('FordSchickRescued') )
        {
            foreach AllActors(class'FordSchick', ford)
                ford.EnterWorld();
        }
        break;
#endif
    }
}

function Vandenberg_FirstEntry()
{
    local ElevatorMover e;
    local Button1 b;
    local ComputerSecurity comp;
    local KarkianBaby kb;
    local DataLinkTrigger dlt;
    local FlagTrigger ft;
    local HowardStrong hs;
    local #var(Mover) door;
    local DXREnemies dxre;

    switch(dxr.localURL)
    {
    case "12_VANDENBERG_CMD":
        // add goals and keypad code
        Player().StartDataLinkTransmission("DL_no_carla");
        break;

#ifdef vanillamaps
    case "12_VANDENBERG_TUNNELS":
        foreach AllActors(class'ElevatorMover', e, 'Security_door3') {
            e.BumpType = BT_PlayerBump;
            e.BumpEvent = 'SC_Door3_opened';
        }
        AddSwitch( vect(-396.634888, 2295, -2542.310547), rot(0, -16384, 0), 'SC_Door3_opened').bCollideWorld = false;
        foreach AllActors(class'Button1', b) {
            if( b.Event == 'Top' || b.Event == 'middle' || b.Event == 'Bottom' ) {
                AddDelay(b, 5);
            }
        }
        break;

    case "14_VANDENBERG_SUB":
        AddSwitch( vect(3790.639893, -488.639587, -369.964142), rot(0, 32768, 0), 'Elevator1');
        AddSwitch( vect(3799.953613, -446.640015, -1689.817993), rot(0, 16384, 0), 'Elevator1');

        foreach AllActors(class'KarkianBaby',kb) {
            if(kb.BindName == "tankkarkian"){
                kb.BindName = "TankKharkian";
            }
        }
        break;

    case "14_OCEANLAB_LAB":
        if(!#defined(vmd))// button to open the door heading towards the ladder in the water
            AddSwitch( vect(3077.360107, 497.609467, -1738.858521), rot(0, 0, 0), 'Access');
        foreach AllActors(class'ComputerSecurity', comp) {
            if( comp.UserList[0].userName == "Kraken" && comp.UserList[0].Password == "Oceanguard" ) {
                comp.UserList[0].userName = "Oceanguard";
                comp.UserList[0].Password = "Kraken";
            }
        }
        break;
    case "14_OCEANLAB_UC":
        //Make the datalink immediately trigger when you download the schematics, regardless of where the computer is
        foreach AllActors(class'FlagTrigger',ft){
            if (ft.name=='FlagTrigger0'){
                ft.bTrigger = True;
                ft.event = 'schematic2';
            }
        }
        foreach AllActors(class'DataLinkTrigger',dlt){
            if (dlt.name=='DataLinkTrigger2'){
                dlt.Tag = 'schematic2';
            }
        }

        //This door can get stuck if a spiderbot gets jammed into the little bot-bay
        foreach AllActors(class'#var(Mover)', door, 'Releasebots') {
            door.MoverEncroachType=ME_IgnoreWhenEncroach;
        }
        break;

    case "14_Oceanlab_silo":
        foreach AllActors(class'HowardStrong', hs) {
            hs.ChangeAlly('', 1, true);
            hs.ChangeAlly('mj12', 1, true);
            hs.ChangeAlly('spider', 1, true);
            RemoveFears(hs);
            hs.MinHealth = 0;
            hs.BaseAccuracy *= 0.1;
            GiveItem(hs, class'#var(prefix)BallisticArmor');
            dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
            if(dxre != None) {
                dxre.GiveRandomWeapon(hs, false, 2);
                dxre.GiveRandomMeleeWeapon(hs);
            }
            hs.FamiliarName = "Howard Stronger";
            hs.UnfamiliarName = "Howard Stronger";
            if(!#defined(vmd)) {// vmd allows AI to equip armor, so maybe he doesn't need the health boost?
                SetPawnHealth(hs, 200);
            }
        }
        break;
#endif
    }
}

function HongKong_FirstEntry()
{
    local Actor a;
    local ScriptedPawn p;
    local Button1 b;
    local ElevatorMover e;
    local #var(Mover) m;
    local FlagTrigger ft;
    local AllianceTrigger at;
    local DeusExMover d;
    local DataLinkTrigger dt;
    local ComputerSecurity cs;
    local #var(prefix)Keypad pad;
    local ProjectileGenerator pg;

    switch(dxr.localURL)
    {
    case "06_HONGKONG_HELIBASE":
#ifdef vanillamaps
        foreach AllActors(class'ProjectileGenerator', pg, 'purge') {
            pg.CheckTime = 0.25;
            pg.spewTime = 0.4;
            pg.ProjectileClass = class'PurgeGas';
            switch(pg.Name) {
            case 'ProjectileGenerator5':// left side
                pg.SetRotation(rot(-7000, 80000, 0));
                break;
            case 'ProjectileGenerator2':// middle left
                pg.SetRotation(rot(-6024, 70000, 0));
                break;
            case 'ProjectileGenerator3':// middle right
                pg.SetRotation(rot(-8056, 64000, 0));
                break;
            case 'ProjectileGenerator7':// right side
                pg.SetRotation(rot(-8056, 60000, 0));
                break;
            }
        }
#endif
        break;

    case "06_HONGKONG_TONGBASE":
        foreach AllActors(class'Actor', a)
        {
            switch(string(a.Tag))
            {
                case "AlexGone":
                case "TracerGone":
                case "JaimeGone":
                    a.Destroy();
                    break;
                case "Breakintocompound":
                case "LumpathPissed":
                    Trigger(a).bTriggerOnceOnly = False;
                    break;
                default:
                    break;
            }
        }
        break;
    case "06_HONGKONG_WANCHAI_MARKET":
        foreach AllActors(class'Actor', a)
        {
            switch(string(a.Tag))
            {
                case "DummyKeypad01":
                    a.Destroy();
                    break;
                case "BasementKeypad":
                case "GateKeypad":
                    a.bHidden=False;
                    break;
                case "Breakintocompound":
                case "LumpathPissed":
                    Trigger(a).bTriggerOnceOnly = False;
                    break;
                case "Keypad3":
                    if( a.Event == 'elevator_door' && HackableDevices(a) != None ) {
                        HackableDevices(a).hackStrength = 0;
                    }
                    break;
                case "PoliceVault":
                    a.SetCollision(False,False,False);
                    break;
                default:
                    break;
            }
        }

        break;

#ifdef vanillamaps
    case "06_HONGKONG_WANCHAI_STREET":
        foreach AllActors(class'Button1',b)
        {
            if (b.Event=='JockShaftTop')
            {
                b.Event='JocksElevatorTop';
            }
        }

        foreach AllActors(class'ElevatorMover',e)
        {
            if(e.Tag=='JocksElevator')
            {
                e.Event = '';
            }
        }
        foreach AllActors(class'DeusExMover',d)
        {
            if(d.Tag=='DispalyCase') //They seriously left in that typo?
            {
                d.SetKeyframe(1,vect(0,0,-136),d.Rotation);  //Make sure the keyframe exists for it to drop into the floor
                d.bIsDoor = true; //Mark it as a door so the troops can actually open it...
            }
            else if(d.Tag=='JockShaftTop')
            {
                d.bFrobbable=True;
            }
            else if(d.Tag=='JockShaftBottom')
            {
                d.bFrobbable=True;
            }
        }
        break;
#endif

    case "06_HONGKONG_MJ12LAB":
        foreach AllActors(class'#var(Mover)', m, 'security_doors') {
            m.bBreakable = false;
            m.bPickable = false;
        }
        foreach AllActors(class'#var(Mover)', m, 'Lower_lab_doors') {
            m.bBreakable = false;
            m.bPickable = false;
        }
        foreach AllActors(class'#var(Mover)', m, 'elevator_door') {
            m.bIsDoor = true;// DXRDoors will pick this up later since we're in PreFirstEntry
        }
        foreach AllActors(class'FlagTrigger', ft, 'MJ12Alert') {
            ft.Tag = 'TongHasRom';
        }
        foreach AllActors(class'DataLinkTrigger', dt) {
            if(dt.name == 'DataLinkTrigger0')
                dt.Tag = 'TongHasRom';
        }
        // don't wait for M07Briefing_Played to get rid of the dummy keypad
        foreach AllActors(class'#var(prefix)Keypad', pad)
        {
            if (pad.Tag == 'DummyKeypad_02')
                pad.Destroy();
            else if (pad.Tag == 'RealKeypad_02')
                pad.bHidden = False;
        }
        break;
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
#ifdef injections
        foreach AllActors(class'AllianceTrigger',at,'StoreSafe') {
            at.bPlayerOnly = true;
        }
#endif
        foreach AllActors(class'DeusExMover',d){
            if (d.Region.Zone.ZoneGroundFriction < 8) {
                //Less than default friction should be the freezer
                d.Tag='FreezerDoor';
            }
        }
        foreach AllActors(class'ComputerSecurity',cs){
            if (cs.UserList[0].UserName=="LUCKYMONEY"){
                cs.Views[2].doorTag='FreezerDoor';
            }
        }
        break;

    case "06_HONGKONG_WANCHAI_GARAGE":
        foreach AllActors(class'DeusExMover',d,'secret_door'){
            d.bFrobbable=False;
        }
        break;
    default:
        break;
    }
}

function Shipyard_FirstEntry()
{
    local DeusExMover m;
    local ComputerSecurity cs;
    local Keypad2 k;
    local Button1 b;
    local WeaponGasGrenade gas;
    local Teleporter t;
    local BlockPlayer bp;
    local DynamicBlockPlayer dbp;

    switch(dxr.localURL)
    {
#ifdef vanillamaps
    case "09_NYC_SHIP":
        foreach AllActors(class'DeusExMover', m, 'DeusExMover') {
            if( m.Name == 'DeusExMover7' ) m.Tag = 'shipbelowdecks_door';
        }
        AddSwitch( vect(2534.639893, 227.583054, 339.803802), rot(0,-32760,0), 'shipbelowdecks_door' );
        break;
#endif

    case "09_NYC_SHIPBELOW":
        // make the weld points highlightable
        foreach AllActors(class'DeusExMover', m, 'ShipBreech') {
            m.bHighlight = true;
            m.bLocked = true;
        }
        UpdateWeldPointGoal(5);

#ifdef vanillamaps
        Tag = 'FanToggle';
        foreach AllActors(class'ComputerSecurity',cs){
            if (cs.Name == 'ComputerSecurity4'){
                cs.specialOptions[0].Text = "Disable Ventilation Fan";
                cs.specialOptions[0].TriggerEvent='FanToggle';
                cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
            }
        }

        //Remove the stupid gas grenades that are past the level exit
        foreach AllActors(class'Teleporter',t){
            if (t.Tag=='ToAbove') break;
        }
        gas = WeaponGasGrenade(findNearestToActor(class'WeaponGasGrenade',t));
        if (gas!=None){
            gas.Destroy();
        }
        gas = WeaponGasGrenade(findNearestToActor(class'WeaponGasGrenade',t));
        if (gas!=None){
            gas.Destroy();
        }
#endif
        break;

    case "09_NYC_DOCKYARD":
        foreach AllActors(class'Button1',b){
            if (b.Tag=='Button1' && b.Event=='Lift' && b.Location.Z < 200){ //vanilla Z is 97 for the lower button, just giving some slop in case it was changed in another mod?
                k = Spawn(class'Keypad2',,,b.Location,b.Rotation);
                k.validCode="8675309"; //They really like Jenny in this place
                k.bToggleLock=False;
                k.Event='Lift';
                b.Event=''; //If you don't unset the event, it gets called when the button is destroyed...
                b.Destroy();
                break;
            }
        }
        // near the start of the map to jump over the wall, from (2536.565674, 1600.856323, 251.924713) to 3982.246826
        foreach RadiusActors(class'BlockPlayer', bp, 725, vect(3259, 1601, 252)) {
            bp.bBlockPlayers=false;
        }
        // 4030.847900 to 4078.623779
        foreach RadiusActors(class'BlockPlayer', bp, 25, vect(4055, 1602, 252)) {
            dbp = Spawn(class'DynamicBlockPlayer',,, bp.Location + vect(0,0,200));
            dbp.SetCollisionSize(bp.CollisionRadius, bp.CollisionHeight + 101);
        }
        break;

    case "09_NYC_SHIPFAN":
#ifdef vanillamaps
        Tag = 'FanToggle';
        foreach AllActors(class'ComputerSecurity',cs){
            if (cs.Name == 'ComputerSecurity6'){
                cs.specialOptions[0].Text = "Disable Ventilation Fan";
                cs.specialOptions[0].TriggerEvent='FanToggle';
                cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
            }
        }
#endif
        break;
    }
}

function Shipyard_AnyEntry()
{
    local #var(Mover) m;

    switch(dxr.localURL)
    {
    case "09_NYC_SHIP":
#ifdef vanillamaps
        if(dxr.flagbase.GetBool('HelpSailor')) {
            foreach AllActors(class'#var(Mover)', m, 'FrontDoor') {
                m.bLocked = false;
            }
        }
#endif
        break;

    case "09_NYC_SHIPBELOW":
        SetTimer(1, True);
        break;
    }
}


function Paris_FirstEntry()
{
    local GuntherHermann g;
    local DeusExMover m;
    local Trigger t;
    local Dispatcher d;
    local ScriptedPawn sp;
    local Conversation c;
    local #var(prefix)JaimeReyes j;

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        FixConversationAddNote(GetConversation('MeetAimee'), "Stupid, stupid, stupid password.");
        break;

#ifdef vanillamaps
    case "10_PARIS_CATACOMBS_TUNNELS":
        foreach AllActors(class'Trigger', t)
            if( t.Event == 'MJ12CommandoSpecial' )
                t.Touch(player());// make this guy patrol instead of t-pose

        AddSwitch( vect(897.238892, -120.852928, -9.965580), rot(0,0,0), 'catacombs_blastdoor02' );
        AddSwitch( vect(-2190.893799, 1203.199097, -6.663990), rot(0,0,0), 'catacombs_blastdoorB' );
        break;

    case "10_PARIS_CHATEAU":
        foreach AllActors(class'DeusExMover', m, 'everettsignal')
            m.Tag = 'everettsignaldoor';
        d = Spawn(class'Dispatcher',, 'everettsignal', vect(176.275253, 4298.747559, -148.500031) );
        d.OutEvents[0] = 'everettsignaldoor';
        AddSwitch( vect(-769.359985, -4417.855469, -96.485504), rot(0, 32768, 0), 'everettsignaldoor' );

        //speed up the secret door...
        foreach AllActors(class'Dispatcher', d, 'cellar_doordispatcher') {
            d.OutDelays[1] = 0;
            d.OutDelays[2] = 0;
            d.OutDelays[3] = 0;
            d.OutEvents[2] = '';
            d.OutEvents[3] = '';
        }
        foreach AllActors(class'DeusExMover', m, 'secret_candle') {
            m.MoveTime = 0.5;
        }
        foreach AllActors(class'DeusExMover', m, 'cellar_door') {
            m.MoveTime = 1;
        }
        break;
    case "10_PARIS_METRO":
        //If neither flag is set, JC never talked to Jaime, so he just didn't bother
        if (!dxr.flagbase.GetBool('JaimeRecruited') && !dxr.flagbase.GetBool('JaimeLeftBehind')){
            //Need to pretend he *was* recruited, so that he doesn't spawn
            dxr.flagbase.SetBool('JaimeRecruited',True);
        }
        // fix the night manager sometimes trying to talk to you while you're flying away https://www.youtube.com/watch?v=PeLbKPSHSOU&t=6332s
        c = GetConversation('MeetNightManager');
        if(c!=None) {
            c.bInvokeBump = false;
            c.bInvokeSight = false;
            c.bInvokeRadius = false;
        }
        foreach AllActors(class'#var(prefix)JaimeReyes', j) {
            RemoveFears(j);
        }
        break;
#endif

    case "10_PARIS_CLUB":
        foreach AllActors(class'ScriptedPawn',sp){
            if (sp.BindName=="LDDPAchille" || sp.BindName=="Camille"){
                sp.bImportant=True;
            }
        }

    case "11_PARIS_CATHEDRAL":
        foreach AllActors(class'GuntherHermann', g) {
            g.ChangeAlly('mj12', 1, true);
        }
        break;
    }
}

function Paris_AnyEntry()
{
    local DXRNPCs npcs;
    local DXREnemies dxre;
    local ScriptedPawn sp;
    local Merchant m;
    local TobyAtanwe toby;

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        // spawn Le Merchant with a hazmat suit because there's no guarantee of one before the highly radioactive area
        // we need to do this in AnyEntry because we need to recreate the conversation objects since they're transient
        npcs = DXRNPCs(dxr.FindModule(class'DXRNPCs'));
        if(npcs != None) {
            sp = npcs.CreateForcedMerchant("Le Merchant", 'lemerchant', vect(-3209.483154, 5190.826172,1199.610352), rot(0, -10000, 0), class'#var(prefix)HazMatSuit');
            m = Merchant(sp);
            if (m!=None){  // CreateForcedMerchant returns None if he already existed, but we still need to call it to recreate the conversation since those are transient
                m.MakeFrench();
            }
        }
        // give him weapons to defend himself
        dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
        if(dxre != None && sp != None) {
            sp.bKeepWeaponDrawn = true;
            GiveItem(sp, class'#var(prefix)WineBottle');
            dxre.RandomizeSP(sp, 100);
            RemoveFears(sp);
            sp.ChangeAlly('Player', 0.0, false);
            sp.MaxProvocations = 0;
            sp.AgitationSustainTime = 3600;
            sp.AgitationDecayRate = 0;
        }
        break;
    case "10_PARIS_CATACOMBS_TUNNELS":
        SetTimer(1.0, True); //To update the Nicolette goal description
        break;
    case "10_PARIS_CLUB":
        FixConversationAddNote(GetConversation('MeetCassandra'),"with a keypad back where the offices are");
        break;
    case "10_PARIS_CHATEAU":
        FixConversationAddNote(GetConversation('NicoletteInStudy'),"I used to use that computer whenever I was at home");
        break;
    case "11_PARIS_EVERETT":
        foreach AllActors(class'TobyAtanwe', toby) {
            toby.bInvincible = false;
        }
        break;
    }
}

function Vandenberg_AnyEntry()
{
    local MIB mib;
    local NanoKey key;
    local #var(prefix)HowardStrong hs;

    switch(dxr.localURL)
    {
    case "12_Vandenberg_gas":
        foreach AllActors(class'MIB', mib, 'mib_garage') {
            key = NanoKey(mib.FindInventoryType(class'NanoKey'));
            l(mib$" has key "$key$", "$key.KeyID$", "$key.Description);
            if(key == None) continue;
            if(key.KeyID != '') continue;
            l("fixing "$key$" to garage_entrance");
            key.KeyID = 'garage_entrance';
            key.Description = "Garage Door";
            key.Timer();// make sure to fix the ItemName in vanilla
        }
        break;
    case "14_OCEANLAB_SILO":
        foreach AllActors(class'#var(prefix)HowardStrong', hs) {
            hs.ChangeAlly('', 1, true);
            hs.ChangeAlly('mj12', 1, true);
            hs.ChangeAlly('spider', 1, true);
            RemoveFears(hs);
            hs.MinHealth = 0;
        }
        Player().StartDataLinkTransmission("DL_FrontGate");
        break;
    }
}

function HandleJohnSmithDeath()
{
    if (dxr.flagbase.GetBool('Disgruntled_Guy_Dead')){ //He's already dead
        return;
    }

    if (!dxr.flagbase.GetBool('Supervisor01_Dead') &&
        dxr.flagbase.GetBool('HaveROM') &&
        !dxr.flagbase.GetBool('Disgruntled_Guy_Return_Played'))
    {
        dxr.flagbase.SetBool('Disgruntled_Guy_Dead',true);
        //We could send a death message here?
    }
}

function HongKong_AnyEntry()
{
    local Actor a;
    local ScriptedPawn p;
    local #var(Mover) m;
    local bool boolFlag;
    local bool recruitedFlag;
    local DeusExCarcass carc;

    // if flag Have_ROM, set flags Have_Evidence and KnowsAboutNanoSword?
    // or if flag Have_ROM, Gordon Quick should let you into the compound? requires Have_Evidence and MaxChenConvinced

    switch(dxr.localURL)
    {
    case "06_HONGKONG_TONGBASE":
        boolFlag = dxr.flagbase.GetBool('QuickLetPlayerIn');
        foreach AllActors(class'Actor', a)
        {
            switch(string(a.Tag))
            {
                case "TriadLumPath":
                    ScriptedPawn(a).ChangeAlly('Player',1,False);
                    break;

                case "TracerTong":
                    if ( boolFlag == True )
                    {
                        ScriptedPawn(a).EnterWorld();
                    } else {
                        ScriptedPawn(a).LeaveWorld();
                    }
                    break;
                case "AlexJacobson":
                    recruitedFlag = dxr.flagbase.GetBool('JacobsonRecruited');
                    if ( boolFlag == True && recruitedFlag == True)
                    {
                        ScriptedPawn(a).EnterWorld();
                    } else {
                        ScriptedPawn(a).LeaveWorld();
                    }
                    break;
                case "JaimeReyes":
                    recruitedFlag = dxr.flagbase.GetBool('JaimeRecruited') && dxr.flagbase.GetBool('Versalife_Done');
                    if ( boolFlag == True && recruitedFlag == True)
                    {
                        ScriptedPawn(a).EnterWorld();
                    } else {
                        ScriptedPawn(a).LeaveWorld();
                    }
                    break;
                case "Operation1":
                    DataLinkTrigger(a).checkFlag = 'QuickLetPlayerIn';
                    break;
                case "TurnOnTheKillSwitch":
                    if (boolFlag == True)
                    {
                        Trigger(a).TriggerType = TT_PlayerProximity;
                    } else {
                        Trigger(a).TriggerType = TT_ClassProximity;
                        Trigger(a).ClassProximityType = class'Teleporter';//Impossible, thus disabling it
                    }
                    break;
                default:
                    break;
            }
        }
        break;
    case "06_HONGKONG_WANCHAI_MARKET":
        foreach AllActors(class'Actor', a)
        {
            switch(string(a.Tag))
            {
                case "TriadLumPath":
                case "TriadLumPath1":
                case "TriadLumPath2":
                case "TriadLumPath3":
                case "TriadLumPath4":
                case "TriadLumPath5":
                case "GordonQuick":

                    ScriptedPawn(a).ChangeAlly('Player',1,False);
                    break;
            }
        }
        HandleJohnSmithDeath();
        SetTimer(1.0, True); //To handle updating the DTS goal description
        break;

    case "06_HONGKONG_VERSALIFE":
        // allow you to get the code from him even if you've been to the labs, to fix backtracking
        DeleteConversationFlag( GetConversation('Disgruntled_Guy_Convos'), 'VL_Found_Labs', false);
        GetConversation('Disgruntled_Guy_Return').AddFlagRef('Disgruntled_Guy_Done', true);
        break;

    case "06_HONGKONG_WANCHAI_STREET":
        foreach AllActors(class'#var(Mover)', m, 'JockShaftTop') {
            m.bLocked = false;
            m.bHighlight = true;
        }
        HandleJohnSmithDeath();
        break;

    case "06_HONGKONG_WANCHAI_CANAL":
        HandleJohnSmithDeath();
        if (dxr.flagbase.GetBool('Disgruntled_Guy_Dead')){
            foreach AllActors(class'DeusExCarcass', carc, 'John_Smith_Body')
                if (carc.bHidden){
				    carc.bHidden = False;
#ifdef injections
                    //HACK: to be removed once the problems with Carcass2 are fixed/removed
                    carc.mesh = LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassC';  //His body starts in the water, so this is fine
                    carc.SetMesh2(LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassB');
                    carc.SetMesh3(LodMesh'DeusExCharacters.GM_DressShirt_F_CarcassC');
#endif
                }
        }
        break;

    default:
        break;
    }
}

function NYC_08_AnyEntry()
{
    local StantonDowd s;

    switch(dxr.localURL) {
    case "08_NYC_STREET":
        SetTimer(1.0, True);
        foreach AllActors(class'StantonDowd', s) {
            RemoveReactions(s);
        }
        Player().StartDataLinkTransmission("DL_Entry");
        break;

#ifdef vanillamaps
    case "08_NYC_SMUG":
        FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
        break;
#endif
    }
}

function Area51_FirstEntry()
{
    local DeusExMover d;
    local ComputerSecurity c;
    local Keypad k;
    local Switch1 s;
    local Switch2 s2;
    local SequenceTrigger st;
    local SpecialEvent se;
    local DataLinkTrigger dlt;
    local ComputerPersonal comp_per;

#ifdef vanillamaps
    switch(dxr.localURL)
    {
    case "15_AREA51_BUNKER":
        // doors_lower is for backtracking
        AddSwitch( vect(4309.076660, -1230.640503, -7522.298340), rot(0, 16384, 0), 'doors_lower');
        player().DeleteAllGoals();

        //Change vent entry security computer password so it isn't pre-known
        foreach AllActors(class'ComputerSecurity',c){
            if (c.UserList[0].UserName=="SECURITY" && c.UserList[0].Password=="SECURITY"){
                c.UserList[0].Password="NarutoRun"; //They can't stop all of us
            }
        }

        //Move the vent entrance elevator to the bottom to make it slightly less convenient
        foreach AllActors(class'SequenceTrigger',st){
            if (st.Tag=='elevator_mtunnel_down'){
                st.Trigger(Self,player());
            }
        }

        //This door can get stuck if a spiderbot gets jammed into the little bot-bay
        foreach AllActors(class'DeusExMover',d){
            if (d.Tag=='bot_door'){
                d.MoverEncroachType=ME_IgnoreWhenEncroach;
            }
        }

        //Swap the button at the top of the elevator to a keypad to make this path a bit more annoying
        foreach AllActors(class'Switch2',s2){
            if (s2.Event=='elevator_mtunnel_up'){
                k = Spawn(class'Keypad2',,,s2.Location,s2.Rotation);
                k.validCode="17092019"; //September 17th, 2019 - First day of "Storm Area 51"
                k.bToggleLock=False;
                k.Event='elevator_mtunnel_up';
                s2.event='';
                s2.Destroy();
                break;
            }
        }

        //Lock the fan entrance top door
        foreach AllActors(class'DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='DL_Bunker_Fan'){ break;}
        }
        d = DeusExMover(findNearestToActor(class'DeusExMover',dlt));
        d.bLocked=True;
        d.bBreakable=True;
        d.FragmentClass=Class'DeusEx.MetalFragment';
        d.ExplodeSound1=Sound'DeusExSounds.Generic.MediumExplosion1';
        d.ExplodeSound2=Sound'DeusExSounds.Generic.MediumExplosion2';
        d.minDamageThreshold=25;
        d.doorStrength = 0.20; //It's just grating on top of the vent, so it's not that strong

        break;

    case "15_AREA51_FINAL":
        // Generator_overload is the cover over the beat the game button used in speedruns
        foreach AllActors(class'DeusExMover', d, 'Generator_overload') {
            d.move(vect(0, 0, -1));
        }
        AddSwitch( vect(-5112.805176, -2495.639893, -1364), rot(0, 16384, 0), 'blastdoor_final');// just in case the dialog fails
        AddSwitch( vect(-5112.805176, -2530.276123, -1364), rot(0, -16384, 0), 'blastdoor_final');// for backtracking
        AddSwitch( vect(-3745, -1114, -1950), rot(0,0,0), 'Page_Blastdoors' );

        foreach AllActors(class'DeusExMover', d, 'doors_lower') {
            d.bLocked = false;
            d.bHighlight = true;
            d.bFrobbable = true;
        }

        //Generator Failsafe buttons should spit out some sort of message if the coolant isn't cut
        //start_buzz1 and start_buzz2 are the tags that get hit when the coolant isn't cut
        se = Spawn(class'SpecialEvent',,'start_buzz1');
        se.Message = "Coolant levels normal - Failsafe cannot be disabled";
        se = Spawn(class'SpecialEvent',,'start_buzz2');
        se.Message = "Coolant levels normal - Failsafe cannot be disabled";

        //Increase the radius of the datalink that opens the sector 4 blast doors
        foreach AllActors(class'DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='DL_Helios_Door2'){
                dlt.SetCollisionSize(900,dlt.CollisionHeight);
            }
        }

        break;

    case "15_AREA51_ENTRANCE":
        foreach AllActors(class'DeusExMover', d, 'DeusExMover') {
            if( d.Name == 'DeusExMover20' ) d.Tag = 'final_door';
        }
        AddSwitch( vect(-867.193420, 244.553101, 17.622702), rot(0, 32768, 0), 'final_door');

        foreach AllActors(class'DeusExMover', d, 'doors_lower') {
            d.bLocked = false;
            d.bHighlight = true;
            d.bFrobbable = true;
        }

        //Change break room security computer password so it isn't pre-known
        //This code isn't written anywhere, so you shouldn't have knowledge of it
        foreach AllActors(class'ComputerSecurity',c){
            if (c.UserList[0].UserName=="SECURITY" && c.UserList[0].Password=="SECURITY"){
                c.UserList[0].Password="TinFoilHat";
            }
        }

        break;

    case "15_AREA51_PAGE":
        foreach AllActors(class'ComputerSecurity', c) {
            if( c.UserList[0].userName != "graytest" || c.UserList[0].Password != "Lab12" ) continue;
            c.UserList[0].userName = "Lab 12";
            c.UserList[0].Password = "graytest";
        }
        foreach AllActors(class'Keypad', k) {
            if( k.validCode == "9248" )
                k.validCode = "2242";
        }
        foreach AllActors(class'Switch1',s){
            if (s.Name == 'Switch21'){
                s.Event = 'door_page_overlook';
            }
        }

        // fix the Helios ending skip
        foreach AllActors(class'ComputerPersonal', comp_per) {
            if(comp_per.Name == 'ComputerPersonal0') {
                comp_per.Tag = 'router_computer';
                class'DXRTriggerEnable'.static.Create(comp_per, 'router_door', 'router_computer');
                break;
            }
        }
        // get the password from Helios sooner
        FixConversationAddNote(GetConversation('DL_Final_Helios06'), "Use the login");
        break;
    }
#endif
}

function Area51_AnyEntry()
{
    local Gray g;
    local ElectricityEmitter ee;
    local #var(Mover) d;

    switch(dxr.localURL)
    {
    case "15_AREA51_FINAL":
#ifdef vanillamaps
        foreach AllActors(class'Gray', g) {
            if( g.Tag == 'reactorgray1' ) g.BindName = "ReactorGray1";
            else if( g.Tag == 'reactorgray2' ) g.BindName = "ReactorGray2";
        }
#endif
        break;

    case "15_AREA51_PAGE":
        SetTimer(1, True);

        foreach AllActors(class'ElectricityEmitter', ee, 'emitter_relay_room') {
            if(ee.DamageAmount >= 30) {
                ee.DamageAmount /= 2;
                ee.damageTime *= 2.0;
                ee.randomAngle /= 2.0;
            }
        }

        if((!#defined(revision)) && (!#defined(gmdx))) {
            foreach AllActors(class'#var(Mover)', d, 'Page_button') {
                d.SetLocation(vect(6152.000000, -6512.000000, -5136.000000)); // original Z was -5134
            }
        }
        break;
    }
}

function AddDelay(Actor trigger, float time)
{
    local Dispatcher d;
    local name tagname;
    tagname = StringToName( "dxr_delay_" $ trigger.Event );
    d = Spawn(class'Dispatcher', trigger, tagname);
    d.OutEvents[0] = trigger.Event;
    d.OutDelays[0] = time;
    trigger.Event = d.Tag;
}

#ifdef vanillamaps
function ToggleFan()
{
    local Fan1 f;
    local ParticleGenerator pg;
    local ZoneInfo z;
    local AmbientSound as;
    local ComputerSecurity cs;
    local bool enable;
    local name compName;
    local DeusExMover dxm;

    //This function is now used in two maps
    switch(dxr.localURL)
    {
        case "09_NYC_SHIPBELOW":
            compName = 'ComputerSecurity4';
            break;
        case "09_NYC_SHIPFAN":
            compName = 'ComputerSecurity6';
            break;
        default:
            player().ClientMessage("Not in a map that understands how to toggle a fan!");
            return;
            break;
    }

    foreach AllActors(class'ComputerSecurity',cs){
        if (cs.Name == compName){
            //If you press disable, you want to disable...
            if (cs.SpecialOptions[0].Text == "Disable Ventilation Fan"){
                enable = False;
            } else {
                enable = True;
            }

            if (enable){
                cs.specialOptions[0].Text = "Disable Ventilation Fan";
                cs.specialOptions[0].TriggerText="Ventilation Fan Enabled"; //Unintuitive, but it prints the text before the trigger call
            } else {
                cs.specialOptions[0].Text = "Enable Ventilation Fan";
                cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
            }
            break;
        }
    }

    if (dxr.localURL=="09_NYC_SHIPBELOW"){
        //Fan1
        foreach AllActors(class'Fan1',f){
            if (f.Name == 'Fan1'){
                if (enable) {
                    f.RotationRate.Yaw = 50000;
                } else {
                    f.RotationRate.Yaw = 0;
                }
            }
        }

        //ParticleGenerator3
        foreach AllActors(class'ParticleGenerator',pg){
            if (pg.Name == 'ParticleGenerator3'){
                pg.bSpewing = enable;
                pg.bFrozen = !enable;
                pg.proxy.bHidden=!enable;
                break;
            }
        }

        //ZoneInfo0
        foreach AllActors(class'ZoneInfo',z){
            if (z.Name=='ZoneInfo0') {
                if (enable){
                    z.ZoneGravity.Z = 100;
                } else {
                    z.ZoneGravity.Z = -950;
                }
                break;
            }
        }

        //AmbientSound7
        //AmbientSound8
        foreach AllActors(class'AmbientSound',as){
            if (as.Name=='AmbientSound7'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.HumTurbine2", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            } else if (as.Name=='AmbientSound8'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.StrongWind", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            }
        }
    } else if (dxr.localURL=="09_NYC_SHIPFAN"){
        foreach AllActors(class'DeusExMover',dxm){
            if (dxm.Name == 'DeusExMover1'){
                if (enable) {
                    dxm.RotationRate.Yaw = -20000;
                } else {
                    dxm.RotationRate.Yaw = 0;
                }
            }
        }
        foreach AllActors(class'AmbientSound',as){
            if (as.Name=='AmbientSound6'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.FanLarge", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            } else if (as.Name=='AmbientSound0'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.MachinesLarge3", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            }
        }



    }
}
#endif

function Trigger(Actor Other, Pawn Instigator)
{
    if (Tag=='FanToggle'){
#ifdef vanillamaps
        ToggleFan();
#endif
    }
}

static function DeleteConversationFlag(Conversation c, name Name, bool Value)
{
    local ConFlagRef f, prev;
    if( c == None ) return;
    for(f = c.flagRefList; f!=None; f=f.nextFlagRef) {
        if( f.flagName == Name && f.value == Value ) {
            if( prev == None )
                c.flagRefList = f.nextFlagRef;
            else
                prev.nextFlagRef = f.nextFlagRef;
            return;
        }
        prev = f;
    }
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

defaultproperties
{
}
