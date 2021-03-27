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

function CheckConfig()
{
    local int i;
    local class<DeusExDecoration> c;
    if( config_version < 4 ) {
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
    }
    Super.CheckConfig();

    for(i=0; i<ArrayCount(DecorationsOverwrites); i++) {
        if( DecorationsOverwrites[i].type == "" ) continue;
        DecorationsOverwritesClasses[i] = class<DeusExDecoration>(GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration'));
    }
}

function FirstEntry()
{
    Super.FirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" FirstEntry()");

    SetSeed( "DXRFixup FirstEntry" );

    IncreaseBrightness(dxr.flags.brightness);
    OverwriteDecorations();
    FixFlagTriggers();

    SetSeed( "DXRFixup FirstEntry missions" );
    
    switch(dxr.dxInfo.missionNumber) {
        case 2:
            NYC_02_FirstEntry();
            break;
        case 3:
            Airfield_FirstEntry();
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
            Paris_FirstEntry();
            break;
        case 12:
            Vandenberg_FirstEntry();
            break;
        case 15:
            Area51_FirstEntry();
            break;
    }
}

function AnyEntry()
{
    Super.AnyEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" AnyEntry()");

    SetSeed( "DXRFixup AnyEntry" );

    FixSamCarter();
    FixAmmoShurikenName();

    SetSeed( "DXRFixup AnyEntry missions" );

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
    }
}

function Timer()
{
    local PaulDenton paul;
    local BlackHelicopter chopper;
    local Music m;
    local int i;
    Super.Timer();
    if( dxr == None ) return;

    switch(dxr.dxInfo.missionNumber) {
        case 8:
            if( dxr.Player.Song == None && Level.Song == None ) {
                m = Music(DynamicLoadObject("NYCStreets2_Music.NYCStreets2_Music", class'Music'));
                //err("replacing "$dxr.Player.Song$":"$dxr.Player.SongSection$":"$dxr.Player.CdTrack$" with "$m);
                UpdateDynamicMusic(m);
            }
            else if( Level.Song == None ) {
                UpdateDynamicMusic(dxr.Player.Song);
            }
            break;
    }

    switch(dxr.localURL)
    {
        case "04_NYC_HOTEL":
            if( dxr.player.flagBase.GetBool('M04RaidBegan') ) {
                foreach AllActors(class'PaulDenton', paul) {
                    paul.bInvincible = false;
                    i = 400;
                    paul.Health = i;
                    paul.HealthArmLeft = i;
                    paul.HealthArmRight = i;
                    paul.HealthHead = i;
                    paul.HealthLegLeft = i;
                    paul.HealthLegRight = i;
                    paul.HealthTorso = i;
                    paul.ChangeAlly('Player', 1, true);
                }
                SetTimer(0, false);
            }
            break;
        case "08_NYC_STREET":
            if ( dxr.Player.flagBase.GetBool('StantonDowd_Played') )
            {
                foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
                    chopper.EnterWorld();
                dxr.Player.flagBase.SetBool('MS_Helicopter_Unhidden', True,, 9);
            }
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

function FixAmmoShurikenName()
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

function IncreaseBrightness(int brightness)
{
    local ZoneInfo z;
    if(brightness <= 0) return;

    Level.AmbientBrightness = Clamp( int(Level.AmbientBrightness) + brightness, 0, 255 );
    //Level.Brightness += float(brightness)/100.0;
    foreach AllActors(class'ZoneInfo', z) {
        if( z == Level ) continue;
        z.AmbientBrightness = Clamp( int(z.AmbientBrightness) + brightness, 0, 255 );
    }
}

function OverwriteDecorations()
{
    local DeusExDecoration d;
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

function NYC_02_FirstEntry()
{
    local DeusExMover d;
    local NanoKey k;
    local NYPoliceBoat b;
    
    switch (dxr.localURL)
    {
        case "02_NYC_BATTERYPARK":
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
    }
}

function Airfield_FirstEntry()
{
    local Mover m;
    local Actor a;
    local Trigger t;
    
    switch (dxr.localURL)
    {
        case "03_NYC_BATTERYPARK":
            foreach AllActors(class'Actor', a) {
                if( a.name == 'NanoKey0' ) {
                    a.Destroy();
                }
                if( a.name == 'BookClosed2' ) {
                    InformationDevices(a).bAddToVault = true;
                }
            }
            break;
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
            }
            foreach AllActors(class'Trigger', t) {
                //disable the platforms that fall when you step on them
                if( t.Name == 'Trigger0' || t.Name == 'Trigger1' ) {
                    t.Event = '';
                }
            }
            //stepping stone valves out of the water
            _AddActor(Self, class'Valve', vect(-3105,-385,-210), rot(0,0,16384));
            a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3105,-385,-210), rot(0,0,0));
            SetActorScale(a, 1.3);

            _AddActor(Self, class'Valve', vect(-3080,-395,-170), rot(0,0,16384));
            a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3080,-395,-170), rot(0,0,0));
            SetActorScale(a, 1.3);

            _AddActor(Self, class'Valve', vect(-3065,-405,-130), rot(0,0,16384));
            a = _AddActor(Self, class'DynamicBlockPlayer', vect(-3065,-405,-130), rot(0,0,0));
            SetActorScale(a, 1.3);

            //crates to get back over the beginning of the level
            _AddActor(Self, class'CrateUnbreakableSmall', vect(-9463.387695, 3377.530029, 60), rot(0,0,0));
            _AddActor(Self, class'CrateUnbreakableMed', vect(-9461.959961, 3320.718750, 75), rot(0,0,0));
            break;
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
    }
}

function Jailbreak_FirstEntry()
{
    local PaulDenton p;
    /*local Inventory item, nextItem;
    local Ammo a;
    local Vector locs[4];
    local class<Ammo> types[5];
    local class<Ammo> type;
    local int i, k, r;*/

    switch (dxr.localURL)
    {
        case "05_NYC_UNATCOMJ12LAB":
            foreach AllActors(class'PaulDenton', p) {
                p.RaiseAlarm = RAISEALARM_Never;// https://www.twitch.tv/die4ever2011/clip/ReliablePerfectMarjoramDxAbomb
            }

            // remove ammo from the player when captured
            /*for( item = dxr.Player.Inventory; item != None; item = nextItem) {
                nextItem = item.Inventory;
                a = Ammo(item);
                if( a != None ) {
                    a.AmmoAmount = 0;
                    dxr.Player.UpdateAmmoBeltText(a);
                }
            }

            // make up for it by adding ammo on the guard's desk
            types[0] = class'Ammo10mm';
            types[1] = class'Ammo762mm';
            types[2] = class'AmmoShell';
            types[3] = class'Ammo3006';
            types[4] = class'AmmoDartPoison';
            locs[0] = vect(-2084.170654, 1212.210327, -132.129761);// the first guard's desk
            locs[1] = vect(-2104.531494, 1232.512817, -132.130157);
            locs[2] = vect(-2140.163330, 1245.518555, -132.130081);
            locs[3] = vect(-2183.612061, 1241.690430, -132.129669);
            for(i=0; i < ArrayCount(locs); i++) {
                if( ! chance_single(dxr.flags.ammo) ) continue;

                r = initchance();
                type = types[0];
                for(k=0; k<ArrayCount(types); k++) {
                    if( chance( 100/ArrayCount(types), r ) ) type = types[k];
                }
                chance_remaining(r);
                a = Spawn( type,,, locs[i] );
            }*/
            break;
    }
}

function NYC_04_AnyEntry()
{
    switch (dxr.localURL)
    {
        case "04_NYC_HOTEL":
            SetTimer(1.0, True);
            if(dxr.Player.flagBase.GetBool('NSFSignalSent')) {
                dxr.Player.flagBase.SetBool('PaulInjured_Played', true,, 5);
            }
            break;
    }
}

function Vandenberg_FirstEntry()
{
    local ElevatorMover e;
    local Button1 b;
    local Dispatcher d;
    local LogicTrigger lt;

    switch(dxr.localURL)
    {
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
    }
}

function HongKong_FirstEntry()
{
    local Actor a;
    local ScriptedPawn p;

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
                    default:
                        break;
                }
            }
            
            break;
        default:
            break;
    }
}

function Shipyard_FirstEntry()
{
    local DeusExMover m;
    switch(dxr.localURL)
    {
        case "09_NYC_SHIP":
            foreach AllActors(class'DeusExMover', m, 'DeusExMover') {
                if( m.Name == 'DeusExMover7' ) m.Tag = 'shipbelowdecks_door';
            }
            AddSwitch( vect(2534.639893, 227.583054, 339.803802), rot(0,-32760,0), 'shipbelowdecks_door' );
            break;
    }
}

function Paris_FirstEntry()
{
    switch(dxr.localURL)
    {
        case "10_PARIS_CATACOMBS_TUNNELS":
            AddSwitch( vect(897.238892, -120.852928, -9.965580), rot(0,0,0), 'catacombs_blastdoor02' );
            AddSwitch( vect(-2190.893799, 1203.199097, -6.663990), rot(0,0,0), 'catacombs_blastdoorB' );
            break;
    }
}

function HongKong_AnyEntry()
{
    local Actor a;
    local ScriptedPawn p;
    local bool boolFlag;
    local bool recruitedFlag;

    // if flag Have_ROM, set flags Have_Evidence and KnowsAboutNanoSword?
    // or if flag Have_ROM, Gordon Quick should let you into the compound? requires Have_Evidence and MaxChenConvinced

    switch(dxr.localURL)
    {
        case "06_HONGKONG_TONGBASE":
            boolFlag = dxr.Player.flagBase.GetBool('QuickLetPlayerIn');
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "TriadLumPath":
                        ScriptedPawn(a).ChangeAlly(dxr.Player.Alliance,1,False);
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
                        recruitedFlag = dxr.Player.flagBase.GetBool('JacobsonRecruited');
                        if ( boolFlag == True && recruitedFlag == True)
                        {
                            ScriptedPawn(a).EnterWorld();                    
                        } else {
                            ScriptedPawn(a).LeaveWorld();
                        }
                        break;
                    case "JaimeReyes":
                        recruitedFlag = dxr.Player.flagBase.GetBool('JaimeRecruited');
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
                    
                        ScriptedPawn(a).ChangeAlly(dxr.Player.Alliance,1,False);
                        break;
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
    SetTimer(1.0, True);
    foreach AllActors(class'StantonDowd', s) {
        RemoveFears(s);
    }
}

function Area51_FirstEntry()
{
    local DeusExMover d;
    local DataCube dc;
    switch(dxr.localURL)
    {
        case "15_AREA51_BUNKER":
            AddSwitch( vect(4309.076660, -1230.640503, -7522.298340), rot(0, 16384, 0), 'doors_lower');
            break;
        case "15_AREA51_FINAL":
            foreach AllActors(class'DeusExMover', d, 'Generator_overload') {
                d.move(vect(0, 0, -1));
            }
            AddSwitch( vect(-5107.805176, -2530.276123, -1374.614258), rot(0, -16384, 0), 'blastdoor_final');
            AddSwitch( vect(-3745, -1114, -1950), rot(0,0,0), 'Page_Blastdoors' );
            break;
        case "15_AREA51_ENTRANCE":
            foreach AllActors(class'DeusExMover', d, 'DeusExMover') {
                if( d.Name == 'DeusExMover20' ) d.Tag = 'final_door';
            }
            AddSwitch( vect(-867.193420, 244.553101, 17.622702), rot(0, 32768, 0), 'final_door');

            dc = Spawn(class'DataCube',,, GetRandomPosition(), rot(0,0,0));
            if( dc != None ) dc.plaintext = "My code is 6786";

            dc = Spawn(class'DataCube',,, GetRandomPosition(), rot(0,0,0));
            if( dc != None ) dc.plaintext = "My code is 3901";

            dc = Spawn(class'DataCube',,, GetRandomPosition(), rot(0,0,0));
            if( dc != None ) dc.plaintext = "My code is 4322";

            foreach AllActors(class'DeusExMover', d, 'doors_lower') {
                d.bLocked = false;
                d.bHighlight = true;
                d.bFrobbable = true;
            }
            break;
        case "15_AREA51_FINAL":
            foreach AllActors(class'DeusExMover', d, 'doors_lower') {
                d.bLocked = false;
                d.bHighlight = true;
                d.bFrobbable = true;
            }
            break;
    }
}

function AddDelay(Actor trigger, float time)
{
    local Dispatcher d;
    local name tagname;
    tagname = dxr.Player.rootWindow.StringToName( "dxr_delay_" $ trigger.Event );
    d = Spawn(class'Dispatcher', trigger, tagname);
    d.OutEvents[0] = trigger.Event;
    d.OutDelays[0] = time;
    trigger.Event = d.Tag;
}

function DeusExDecoration AddSwitch(vector loc, rotator rotate, name Event)
{
    return _AddSwitch(Self, loc, rotate, Event);
}

static function DeusExDecoration _AddSwitch(Actor a, vector loc, rotator rotate, name Event)
{
    local DeusExDecoration d;
    d = DeusExDecoration( _AddActor(a, class'Switch2', loc, rotate) );
    d.Event = Event;
    return d;
}

static function Actor _AddActor(Actor a, class<Actor> c, vector loc, rotator rotate)
{
    local Actor d;
    local bool oldCollideWorld;
    d = a.Spawn(c,,, loc, rotate );
    oldCollideWorld = d.bCollideWorld;
    d.bCollideWorld = false;
    d.SetLocation(loc);
    d.SetRotation(rotate);
    d.bCollideWorld = oldCollideWorld;
    return d;
}

function RemoveFears(ScriptedPawn p)
{
    p.bFearHacking = false;
    p.bFearWeapon = false;
    p.bFearShot = false;
    p.bFearInjury = false;
    p.bFearIndirectInjury = false;
    p.bFearCarcass = false;
    p.bFearDistress = false;
    p.bFearAlarm = false;
    p.bFearProjectiles = false;
}

// mostly copied from DeusExPlayer.uc
function UpdateDynamicMusic(Music Song)
{
    local float deltaTime;
    local bool bCombat;
    local ScriptedPawn npc;
    local Pawn CurPawn;
    local DeusExPlayer p;

	if (Song == None)
		return;

    deltaTime = 1.0;
    p = dxr.Player;

    if(p.Song == None) {
        p.ClientSetMusic(Song, 0, 255, MTRAN_FastFade);
        p.musicMode = MUS_Ambient;
        p.savedSection = 0;
    }
    if(p.Song != Song) {
        p.Song = Song;
    }

	p.musicCheckTimer += deltaTime;
	p.musicChangeTimer += deltaTime;

	if (p.IsInState('Interpolating'))
	{
		if (p.musicMode != MUS_Outro)
		{
			p.ClientSetMusic(Song, 5, 255, MTRAN_FastFade);
			p.musicMode = MUS_Outro;
		}
	}
	else if (p.IsInState('Conversation'))
	{
		if (p.musicMode != MUS_Conversation)
		{
			// save our place in the ambient track
			if (p.musicMode == MUS_Ambient)
				p.savedSection = p.SongSection;
			else
				p.savedSection = 255;

			p.ClientSetMusic(Song, 4, 255, MTRAN_Fade);
			p.musicMode = MUS_Conversation;
		}
	}
	else if (p.IsInState('Dying'))
	{
		if (p.musicMode != MUS_Dying)
		{
			p.ClientSetMusic(Song, 1, 255, MTRAN_Fade);
			p.musicMode = MUS_Dying;
		}
	}
	else
	{
        p.musicCheckTimer = 0.0;
        bCombat = False;

        // check a 100 foot radius around me for combat
        // XXXDEUS_EX AMSD Slow Pawn Iterator
        //foreach RadiusActors(class'ScriptedPawn', npc, 1600)
        for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
        {
            npc = ScriptedPawn(CurPawn);
            if ((npc != None) && (VSize(npc.Location - p.Location) < (1600 + npc.CollisionRadius)))
            {
                if ((npc.GetStateName() == 'Attacking') && (npc.Enemy == p))
                {
                    bCombat = True;
                    break;
                }
            }
        }

        if (bCombat)
        {
            p.musicChangeTimer = 0.0;

            if (p.musicMode != MUS_Combat)
            {
                // save our place in the ambient track
                if (p.musicMode == MUS_Ambient)
                    p.savedSection = p.SongSection;
                else
                    p.savedSection = 0;

                p.ClientSetMusic(Song, 3, 255, MTRAN_FastFade);
                p.musicMode = MUS_Combat;
            }
        }
        else if (p.musicMode != MUS_Ambient)
        {
            // wait until we've been out of combat for 5 seconds before switching music
            if (p.musicChangeTimer >= 5.0)
            {
                // use the default ambient section for this map
                if (p.savedSection == 255)
                    p.savedSection = 0;

                // fade slower for combat transitions
                if (p.musicMode == MUS_Combat)
                    p.ClientSetMusic(Song, p.savedSection, 255, MTRAN_SlowFade);
                else
                    p.ClientSetMusic(Song, p.savedSection, 255, MTRAN_Fade);

                p.savedSection = 255;
                p.musicMode = MUS_Ambient;
                p.musicChangeTimer = 0.0;
            }
        }
	}
}

defaultproperties
{
}
