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

function CheckConfig()
{
    local int i;
    local class<DeusExDecoration> c;
    if( ConfigOlderThan(1,5,7) ) {
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
        add_datacubes[i].text = "Coolant Room code: 9248";
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

function PreFirstEntry()
{
    Super.PreFirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber @ dxr.localURL$" PreFirstEntry()");

    SetSeed( "DXRFixup PreFirstEntry" );

    IncreaseBrightness(dxr.flags.brightness);
    OverwriteDecorations();
    FixFlagTriggers();
    SpawnDatacubes();

    SetSeed( "DXRFixup PreFirstEntry missions" );
    
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

function PostFirstEntry()
{
    Super.PostFirstEntry();

    switch(dxr.localURL) {
        case "02_NYC_WAREHOUSE":
            AddBox(class'CrateUnbreakableSmall', vect(183.993530, 926.125000, 1162.103271));
        // force the unatco retinal scanner to MJ12 lab to be unhackable, except make it actually work in mission 5
        case "03_NYC_AirfieldHeliBase":
            //crates to get back over the beginning of the level
            _AddActor(Self, class'CrateUnbreakableSmall', vect(-9463.387695, 3377.530029, 60), rot(0,0,0));
            _AddActor(Self, class'CrateUnbreakableMed', vect(-9461.959961, 3320.718750, 75), rot(0,0,0));
            break;
        case "05_NYC_UNATCOMJ12LAB":
            BalanceJailbreak();
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

simulated function PlayerAnyEntry(#var PlayerPawn  p)
{
    Super.PlayerAnyEntry(p);
    FixLogTimeout(p);
    FixAmmoShurikenName();
}

function PreTravel()
{
    Super.PreTravel();
    switch(dxr.localURL) {
        case "04_NYC_HOTEL":
            NYC_04_LeaveHotel();
            break;
    }
}

function Timer()
{
    local BlackHelicopter chopper;
    local Music m;
    local int i;
    Super.Timer();
    if( dxr == None ) return;

    switch(dxr.localURL)
    {
        case "04_NYC_HOTEL":
            NYC_04_CheckPaulRaid();
            break;
        case "08_NYC_STREET":
            if ( dxr.flagbase.GetBool('StantonDowd_Played') )
            {
                foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
                    chopper.EnterWorld();
                dxr.flagbase.SetBool('MS_Helicopter_Unhidden', True,, 9);
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

simulated function FixLogTimeout(#var PlayerPawn  p)
{
    DeusExRootWindow(p.rootWindow).hud.msgLog.SetLogTimeout(10);
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

function SpawnDatacubes()
{
    local DataCube dc;
    local vector loc;
    local int i;

    for(i=0; i<ArrayCount(add_datacubes); i++) {
        if( dxr.localURL != add_datacubes[i].map ) continue;

        loc = add_datacubes[i].location;
        if( loc.X == 0 && loc.Y == 0 && loc.Z == 0 )
            loc = GetRandomPosition();
        
        dc = Spawn(class'DataCube',,, loc, rot(0,0,0));

        if( dc != None ) dc.plaintext = add_datacubes[i].text;
        else warning("failed to spawn datacube at "$loc$", text: "$add_datacubes[i].text);
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

            //rebreather because of #TOOCEAN connection
            _AddActor(Self, class'Rebreather', vect(-936.151245, -3464.031006, 293.710968), rot(0,0,0));
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
        
        case "03_NYC_AIRFIELD":
            //rebreather because of #TOOCEAN connection
            _AddActor(Self, class'Rebreather', vect(-2031.959473, 995.781067, 75.709816), rot(0,0,0));
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
    local ComputerPersonal c;
    local int i;

    switch (dxr.localURL)
    {
        case "05_NYC_UNATCOMJ12LAB":
            foreach AllActors(class'PaulDenton', p) {
                p.RaiseAlarm = RAISEALARM_Never;// https://www.twitch.tv/die4ever2011/clip/ReliablePerfectMarjoramDxAbomb
            }
            break;
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
    }
}

function BalanceJailbreak()
{
    local class<Inventory> iclass;
    local DXREnemies e;
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
    else iclass = class'WeaponCombatKnife';

    Spawn(iclass,,, vect(-2688.502686, 1424.474731, -158.099915) );
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
        paul.Health = i;
        paul.HealthArmLeft = i;
        paul.HealthArmRight = i;
        paul.HealthHead = i;
        paul.HealthLegLeft = i;
        paul.HealthLegRight = i;
        paul.HealthTorso = i;
        paul.ChangeAlly('Player', 1, true);
    }

    foreach AllActors(class'ScriptedPawn', p) {
        if( PaulDenton(p) != None ) continue;
        if( IsCritter(p) ) continue;
        if( p.bHidden ) continue;
        if( p.GetAllianceType(player().alliance) != ALLIANCE_Hostile ) continue;
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
    else if( pawns == 1 )
        player().ClientMessage(pawns$" enemy remaining");
    else if( pawns <3 )
        player().ClientMessage(pawns$" enemies remaining");
}

function NYC_04_MarkPaulSafe()
{
    local PaulDenton paul;
    local FlagTrigger t;
    local SkillAwardTrigger st;
    if( dxr.flagbase.GetBool('PaulLeftHotel') ) return;

    dxr.flagbase.SetBool('PaulLeftHotel', true,, 999);

    foreach AllActors(class'PaulDenton', paul) {
        paul.SetOrders('Leaving', 'PaulLeaves', True);
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

    switch (dxr.localURL)
    {
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
    }
}

function NYC_04_AnyEntry()
{
    local FordSchick ford;

    switch (dxr.localURL)
    {
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
    }
}

function Vandenberg_FirstEntry()
{
    local ElevatorMover e;
    local Button1 b;
    local Dispatcher d;
    local LogicTrigger lt;
    local ComputerSecurity comp;

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
        
        case "14_OCEANLAB_LAB":
            foreach AllActors(class'ComputerSecurity', comp) {
                if( comp.UserList[0].userName == "Kraken" && comp.UserList[0].Password == "Oceanguard" ) {
                    comp.UserList[0].userName = "Oceanguard";
                    comp.UserList[0].Password = "Kraken";
                }
            }
            break;
    }
}

function HongKong_FirstEntry()
{
    local Actor a;
    local ScriptedPawn p;
    local Button1 b;
    local ElevatorMover e;

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
    local GuntherHermann g;
    local DeusExMover m;
    local Trigger t;
    local Dispatcher d;

    switch(dxr.localURL)
    {
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
            break;
        
        case "11_PARIS_CATHEDRAL":
            foreach AllActors(class'GuntherHermann', g) {
                g.ChangeAlly('mj12', 1, true);
            }
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
            boolFlag = dxr.flagbase.GetBool('QuickLetPlayerIn');
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "TriadLumPath":
                        ScriptedPawn(a).ChangeAlly(player().Alliance,1,False);
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
                    
                        ScriptedPawn(a).ChangeAlly(player().Alliance,1,False);
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

    if( dxr.localURL != "08_NYC_BAR" ) {
#ifndef hx
        player().ChangeSong("NYCStreets2_Music.NYCStreets2_Music", 0);
#endif
    }

    switch(dxr.localURL) {
        case "08_NYC_STREET":
            foreach AllActors(class'StantonDowd', s) {
                RemoveFears(s);
            }
            break;

        case "08_NYC_SMUG":
            FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
            break;
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
    tagname = StringToName( "dxr_delay_" $ trigger.Event );
    d = Spawn(class'Dispatcher', trigger, tagname);
    d.OutEvents[0] = trigger.Event;
    d.OutDelays[0] = time;
    trigger.Event = d.Tag;
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

defaultproperties
{
}
