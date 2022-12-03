class DXRFixup expands DXRActorsBase;

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

struct ZoneBrightness
{
    var name zonename;
    var byte brightness;
};
var ZoneBrightness zone_brightness[32];


function CheckConfig()
{
    local int i;
    local class<DeusExDecoration> c;
    if( ConfigOlderThan(2,0,3,4) ) {
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

        add_datacubes[i].map = "06_HONGKONG_VERSALIFE";
        add_datacubes[i].text = "Versalife employee ID: 06288.  Use this to access the VersaLife elevator north of the market.";
        i++;

        add_datacubes[i].map = "06_HONGKONG_STORAGE";
        add_datacubes[i].text = "Access code to the Versalife nanotech research wing: 55655.";
        i++;

        add_datacubes[i].map = "09_NYC_Dockyard";
        add_datacubes[i].text = "Jenny I've got your number|nI need to make you mine|nJenny don't change your number|n 8675309";// DXRPasswords doesn't recognize |n as a wordstop
        i++;

        add_datacubes[i].map = "15_AREA51_ENTRANCE";
        add_datacubes[i].text = "My code is 6786";
        i++;

        add_datacubes[i].map = "15_AREA51_ENTRANCE";
        add_datacubes[i].text = "My code is 3901";
        i++;

        add_datacubes[i].map = "15_AREA51_ENTRANCE";
        add_datacubes[i].text = "My code is 4322";
        i++;

        add_datacubes[i].map = "15_AREA51_PAGE";
        add_datacubes[i].text = "UC Control Rooms code: 1234";
        i++;

        add_datacubes[i].map = "15_AREA51_PAGE";
        add_datacubes[i].text = "Aquinas Router code: 6188";
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

function int GetSavedBrightnessBoost()
{
    return int(player().ConsoleCommand("get #var(package).MenuChoice_BrightnessBoost BrightnessBoost"));
}

function PreFirstEntry()
{
    local ZoneInfo Z;

    Super.PreFirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" PreFirstEntry()");

    SetSeed( "DXRFixup PreFirstEntry" );

    //Save default brightnesses
    foreach AllActors(class'ZoneInfo',Z){
        SaveDefaultZoneBrightness(Z);
    }

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
    Super.AnyEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" AnyEntry()");

    SetSeed( "DXRFixup AnyEntry" );

    IncreaseBrightness(GetSavedBrightnessBoost());

    FixSamCarter();
    SetSeed( "DXRFixup AnyEntry missions" );
    if(#defined(mapfixes))
        AnyEntryMapFixes();

    FixAmmoShurikenName();

    AllAnyEntry();
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);
    if(#defined(vanilla))
        FixLogTimeout(p);

    FixAmmoShurikenName();
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
    local CrateUnbreakableLarge c;
    local DeusExMover m;
    local UNATCOTroop u;
    local Actor a;
    local Male1 male;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        foreach AllActors(class'DeusExMover', m, 'UN_maindoor') {
            m.bBreakable = false;
            m.bPickable = false;
            m.bIsDoor = false;// this prevents Floyd from opening the door
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

#ifndef revision
    case "02_NYC_WAREHOUSE":
        AddBox(class'#var(prefix)CrateUnbreakableSmall', vect(183.993530, 926.125000, 1162.103271));// apartment
        AddBox(class'#var(prefix)CrateUnbreakableMed', vect(-389.361969, 744.039978, 1088.083618));// ladder
        AddBox(class'#var(prefix)CrateUnbreakableSmall', vect(-328.287048, 767.875000, 1072.113770));
        break;

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
        foreach AllActors(class'CrateUnbreakableLarge', c) {
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
        foreach RadiusActors(class'CrateUnbreakableLarge', c, 160, vect(2510.350342, 1377.569336, 103.858093)) {
            info("removing " $ c $ " dist: " $ VSize(c.Location - vect(2510.350342, 1377.569336, 103.858093)) );
            c.Destroy();
        }
        break;

    case "09_NYC_SHIPBELOW":
        // add a tnt crate on top of the pipe, visible from the ground floor
        _AddActor(Self, class'#var(prefix)CrateExplosiveSmall', vect(141.944641, -877.442627, -175.899567), rot(0,0,0));
        break;

    case "12_VANDENBERG_CMD":
        foreach RadiusActors(class'CrateUnbreakableLarge', c, 16, vect(570.835083, 1934.114014, -1646.114746)) {
            info("removing " $ c $ " dist: " $ VSize(c.Location - vect(570.835083, 1934.114014, -1646.114746)) );
            c.Destroy();
        }
        break;
#endif
    }
}

function AnyEntryMapFixes()
{
    switch(dxr.dxInfo.missionNumber) {
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
    local HowardStrong hs;

    switch(dxr.localURL) {
    case "14_Oceanlab_Silo":
        foreach AllActors(class'HowardStrong', hs) {
            hs.ChangeAlly('', 1, true);
            hs.ChangeAlly('mj12', 1, true);
            hs.ChangeAlly('spider', 1, true);
        }
        break;
    }
}

function PreTravelMapFixes()
{
#ifdef vanilla
    if(dxr == None) {
        warning("PreTravelMapFixes with dxr None");
        return;
    }
    switch(dxr.localURL) {
    case "04_NYC_HOTEL":
        NYC_04_LeaveHotel();
        break;
    }
#endif
}

function TimerMapFixes()
{
    local BlackHelicopter chopper;
    local Music m;
    local int i;

    switch(dxr.localURL)
    {
#ifdef vanilla
    case "04_NYC_HOTEL":
        NYC_04_CheckPaulRaid();
        break;
#endif
    case "06_HONGKONG_WANCHAI_MARKET":
        UpdateGoalWithRandoInfo('InvestigateMaggieChow');
        break;
    case "08_NYC_STREET":
#ifdef vanilla
        if ( dxr.flagbase.GetBool('StantonDowd_Played') )
        {
            foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
                chopper.EnterWorld();
            dxr.flagbase.SetBool('MS_Helicopter_Unhidden', True,, 9);
        }
#endif
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

function IncreaseBrightness(int brightness)
{
    local ZoneInfo z;

    Level.AmbientBrightness = Clamp( int(GetDefaultZoneBrightness(Level)) + brightness, 0, 255 );
    //Level.Brightness += float(brightness)/100.0;
    foreach AllActors(class'ZoneInfo', z) {
        if( z == Level ) continue;
        z.AmbientBrightness = Clamp( int(GetDefaultZoneBrightness(z)) + brightness, 0, 255 );
    }
    player().ConsoleCommand("FLUSH"); //Clears the texture cache, which allows the lighting to rerender
}

static function AdjustBrightness(DeusExPlayer a, int brightness)
{
    local DXRFixup f;

    foreach a.AllActors(class'DXRFixup',f){
        f.IncreaseBrightness(brightness);
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
#ifdef vanilla
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
    local UNATCOTroop unatco;

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
        break;

#ifdef vanilla
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
        foreach AllActors(class'UNATCOTroop', unatco) {
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

#ifdef vanilla
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
        break;
    }
}

function Jailbreak_FirstEntry()
{
    local #var(PlayerPawn) p;
    local PaulDenton paul;
    local ComputerPersonal c;
    local DeusExMover dxm;
    local int i;

    switch (dxr.localURL)
    {
    case "05_NYC_UNATCOMJ12LAB":
        if(dxr.flags.settings.prison_pocket > 0) {
            p = player();
            p.HealthHead = Max(50, p.HealthHead);
			p.HealthTorso =  Max(50, p.HealthTorso);
			p.HealthLegLeft =  Max(50, p.HealthLegLeft);
			p.HealthLegRight =  Max(50, p.HealthLegRight);
			p.HealthArmLeft =  Max(50, p.HealthArmLeft);
			p.HealthArmRight =  Max(50, p.HealthArmRight);
			p.GenerateTotalHealth();
            dxr.flags.f.SetBool('MS_InventoryRemoved', true,, 6);
        }
        foreach AllActors(class'PaulDenton', paul) {
            paul.RaiseAlarm = RAISEALARM_Never;// https://www.twitch.tv/die4ever2011/clip/ReliablePerfectMarjoramDxAbomb
        }

#ifdef vanilla
        foreach AllActors(class'DeusExMover',dxm){
            if (dxm.Name=='DeusExMover34'){
                //I think this filing cabinet door was supposed to
                //be unlockable with Agent Sherman's key as well
                dxm.KeyIDNeeded='Cabinet';
            }
        }
#endif

        break;

#ifdef vanilla
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
        break;
#endif
    }
}

function BalanceJailbreak()
{
    local class<Inventory> iclass;
    local DXREnemies e;
    local DXRLoadouts loadout;
    local int i;
    local float r;

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

    Spawn(iclass,,, vect(-2688.502686, 1424.474731, -158.099915) );
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
    local DeusExGoal goal;
    goal = player().FindGoal('OverloadForceField');
    if (goal==None){
        return; //Don't do these notifications until the goal is added
    }

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
        //A weld point has been destroyed!
        storedReactorCount = newCount;

        switch(newCount){
            case 0:
                player().ClientMessage("All Blue Fusion reactors shut down!");
                SetTimer(0, False);  //Disable the timer now that all weld points are gone
                break;
            case 1:
                player().ClientMessage("1 Blue Fusion reactor remaining");
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
                    goalText = goalText$"|nRando: Open the sword container.  Finding the sword is not necessary.";
                    break;
                case 'FindHarleyFilben':
                    goalText = goalText$"|nRando: Harley could be anywhere in Hell's Kitchen";
                    break;
                case 'FindNicolette':
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
    local int count, dead, i, pawns;

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
        i = 400;
        // we need to set defaults so that GenerateTotalHealth() works properly
        paul.default.Health = i;
        paul.Health = i;
        paul.default.HealthArmLeft = i;
        paul.HealthArmLeft = i;
        paul.default.HealthArmRight = i;
        paul.HealthArmRight = i;
        paul.default.HealthHead = i;
        paul.HealthHead = i;
        paul.default.HealthLegLeft = i;
        paul.HealthLegLeft = i;
        paul.default.HealthLegRight = i;
        paul.HealthLegRight = i;
        paul.default.HealthTorso = i;
        paul.HealthTorso = i;
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
    local BoxSmall b;

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
        foreach RadiusActors(class'BoxSmall', b, 100, vect(-640.699402, 66.666039, -209.364014)) {
            b.Destroy();
        }
        break;
    }
}

function NYC_04_AnyEntry()
{
    local FordSchick ford;

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
    local Dispatcher d;
    local LogicTrigger lt;
    local ComputerSecurity comp;
    local KarkianBaby kb;
    local DataLinkTrigger dlt;
    local FlagTrigger ft;

    switch(dxr.localURL)
    {
#ifdef vanilla
    case "12_VANDENBERG_CMD":
        foreach AllActors(class'Dispatcher', d)
        {
            switch(d.Tag)
            {
                case 'overload2':
                    d.tag = 'overload2disp';
                    lt = Spawn(class'LogicTrigger',,,d.Location);
                    lt.Tag = 'overload2';
                    lt.Event = 'overload2disp';
                    lt.inGroup1 = 'sec_switch2';
                    lt.inGroup2 = 'sec_switch2';
                    lt.OneShot = True;
                    break;
                case 'overload1':
                    d.tag = 'overload1disp';
                    lt = Spawn(class'LogicTrigger',,,d.Location);
                    lt.Tag = 'overload1';
                    lt.Event = 'overload1disp';
                    lt.inGroup1 = 'sec_switch1';
                    lt.inGroup2 = 'sec_switch1';
                    lt.OneShot = True;
                    break;
            }
        }
        break;
    case "12_VANDENBERG_TUNNELS":
        foreach AllActors(class'ElevatorMover', e, 'Security_door3') {
            e.BumpType = BT_PlayerBump;
            e.BumpEvent = 'SC_Door3_opened';
        }
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

    switch(dxr.localURL)
    {
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

#ifdef vanilla
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
            m.bIsDoor = true;// DXRKeys will pick this up later since we're in PreFirstEntry
        }
        foreach AllActors(class'FlagTrigger', ft, 'MJ12Alert') {
            ft.Tag = 'TongHasRom';
        }
        foreach AllActors(class'DataLinkTrigger', dt) {
            if(dt.name == 'DataLinkTrigger0')
                dt.Tag = 'TongHasRom';
        }
        break;
#ifdef injections
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        foreach AllActors(class'AllianceTrigger',at,'StoreSafe') {
            at.bPlayerOnly = true;
        }
        break;
#endif
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

    switch(dxr.localURL)
    {
#ifdef vanilla
    case "09_NYC_SHIP":
        foreach AllActors(class'DeusExMover', m, 'DeusExMover') {
            if( m.Name == 'DeusExMover7' ) m.Tag = 'shipbelowdecks_door';
        }
        AddSwitch( vect(2534.639893, 227.583054, 339.803802), rot(0,-32760,0), 'shipbelowdecks_door' );
        break;
#endif

    case "09_NYC_SHIPBELOW":
        foreach AllActors(class'DeusExMover', m, 'ShipBreech') {
            m.bHighlight = true;
            m.bLocked = true;
        }
        dxr.flags.f.SetInt('DXRando_WeldPointCount',5);
        UpdateWeldPointGoal(5);

#ifdef vanilla
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
            if (b.Tag=='Button1' && b.Event=='Lift' && b.Location.Z < 200){ //Vanilla Z is 97 for the lower button, just giving some slop in case it was changed in another mod?
                k = Spawn(class'Keypad2',,,b.Location,b.Rotation);
                k.validCode="8675309"; //They really like Jenny in this place
                k.bToggleLock=False;
                k.Event='Lift';
                b.Event=''; //If you don't unset the event, it gets called when the button is destroyed...
                b.Destroy();
                break;
            }
        }
        break;

    case "09_NYC_SHIPFAN":
#ifdef vanilla
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
    switch(dxr.localURL)
    {
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

    switch(dxr.localURL)
    {
#ifdef vanilla
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
        break;
#endif

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
            if (m!=None){  //He should exist now, but... who knows
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
    local DataLinkTrigger dt;
    local MIB mib;
    local NanoKey key;

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
        foreach AllActors(class'DataLinkTrigger', dt) {
            if(dt.datalinkTag == 'DL_FrontGate') {
                dt.Touch(Player());
            }
        }
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

    if( dxr.localURL != "08_NYC_BAR" ) {
#ifdef injections
        player().ChangeSong("NYCStreets2_Music.NYCStreets2_Music", 0);
#endif
    }

    switch(dxr.localURL) {
    case "08_NYC_STREET":
        SetTimer(1.0, True);
        foreach AllActors(class'StantonDowd', s) {
            RemoveReactions(s);
        }
        break;

#ifdef vanilla
    case "08_NYC_SMUG":
        FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
        FixConversationGiveItem(GetConversation('FemJCM08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
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

#ifdef vanilla
    switch(dxr.localURL)
    {
    case "15_AREA51_BUNKER":
        // doors_lower is for backtracking
        AddSwitch( vect(4309.076660, -1230.640503, -7522.298340), rot(0, 16384, 0), 'doors_lower');
        player().DeleteAllGoals();
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
        break;
    }
#endif
}

function Area51_AnyEntry()
{
    local Gray g;

    switch(dxr.localURL)
    {
    case "15_AREA51_FINAL":
#ifdef vanilla
        foreach AllActors(class'Gray', g) {
            if( g.Tag == 'reactorgray1' ) g.BindName = "ReactorGray1";
            else if( g.Tag == 'reactorgray2' ) g.BindName = "ReactorGray2";
        }
#endif
        break;
    case "15_AREA51_PAGE":
        SetTimer(1, True);
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

#ifdef vanilla
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
                    as.AmbientSound = Sound'Ambient.Ambient.HumTurbine2';
                } else {
                    as.AmbientSound = None;
                }
            } else if (as.Name=='AmbientSound8'){
                if (enable){
                    as.AmbientSound = Sound'Ambient.Ambient.StrongWind';
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
                    as.AmbientSound = Sound'Ambient.Ambient.FanLarge';
                } else {
                    as.AmbientSound = None;
                }
            } else if (as.Name=='AmbientSound0'){
                if (enable){
                    as.AmbientSound = Sound'Ambient.Ambient.MachinesLarge3';
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
#ifdef vanilla
        ToggleFan();
#endif
    }
}

function byte GetDefaultZoneBrightness(ZoneInfo z)
{
    local int i;
    for(i=0; i<ArrayCount(zone_brightness); i++) {
        if( z.name == zone_brightness[i].zonename )
            return zone_brightness[i].brightness;
    }
    return 0;
}

function SaveDefaultZoneBrightness(ZoneInfo z)
{
    local int i;
    if( z.AmbientBrightness ~= 0 ) return;
    for(i=0; i<ArrayCount(zone_brightness); i++) {
        if( zone_brightness[i].zonename == '' || z.name == zone_brightness[i].zonename ) {
            zone_brightness[i].zonename = z.name;
            zone_brightness[i].brightness = z.AmbientBrightness;
            return;
        }
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
