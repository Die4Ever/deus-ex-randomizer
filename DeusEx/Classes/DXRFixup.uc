class DXRFixup expands DXRBase;

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
}

function FirstEntry()
{
    Super.FirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber $ " FirstEntry()");

    IncreaseBrightness(dxr.flags.brightness);
    OverwriteDecorations();
    
    switch(dxr.dxInfo.missionNumber) {
        case 2:
            NYC_02_FirstEntry();
            break;
        case 3:
            Airfield_FirstEntry();
            break;
        case 6:
            HongKong_FirstEntry();
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
    l( "mission " $ dxr.dxInfo.missionNumber $ " AnyEntry()");

    BuffScopes();

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
    local BlackHelicopter chopper;
    local Music m;
    Super.Timer();

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

function BuffScopes()
{
    local DXRScopeView scope;
    local DeusExRootWindow win;

    win = DeusExRootWindow(dxr.Player.rootWindow);
    if ( win.scopeView.IsA('DXRScopeView') == false ) {
        scope = DXRScopeView(win.NewChild(Class'DXRScopeView', False));
        scope.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
        scope.Lower();
        win.scopeView = scope;
    }
}

function OverwriteDecorations()
{
    local DeusExDecoration d;
    local class<Actor> a;
    local int i;
    for(i=0; i < ArrayCount(DecorationsOverwrites); i++) {
        if(DecorationsOverwrites[i].type == "") continue;
        foreach AllActors(class'DeusExDecoration', d) {
            a = GetClassFromString(DecorationsOverwrites[i].type, class'DeusExDecoration');
            if( d.IsA( a.name) == false ) continue;
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

function NYC_02_FirstEntry()
{
    local NYPoliceBoat b;
    
    switch (dxr.localURL)
    {
        case "02_NYC_BATTERYPARK":
            foreach AllActors(class'NYPoliceBoat',b) {
                b.BindName = "NYPoliceBoat";
                b.ConBindEvents();
            }
            break;
    }
}

function Airfield_FirstEntry()
{
    local Mover m;
    
    switch (dxr.localURL)
    {
        case "03_NYC_AirfieldHeliBase":
            foreach AllActors(class'Mover',m) {
                if (m.Tag == 'BasementDoorOpen')
                {
                    m.Event = 'BasementFloor';
                }
                else if (m.Tag == 'GroundDoorOpen')
                {
                    m.Event = 'GroundLevel';
                }
            }
            break;
        case "03_NYC_BROOKLYNBRIDGESTATION":
            //Put a button behind the hidden bathroom door
            //Mostly for entrance rando, but just in case
            AddSwitch( vect(-1673, -1319.913574, 130.813538), rot(0, 32767, 0), 'MoleHideoutOpened' );
            break;
    }
}

function NYC_04_AnyEntry()
{
    switch (dxr.localURL)
    {
        case "04_NYC_HOTEL":
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

function HongKong_AnyEntry()
{
    local Actor a;
    local ScriptedPawn p;
    local bool boolFlag;
    local bool recruitedFlag;

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
    SetTimer(1.0, True);
}

function Area51_FirstEntry()
{
    local DeusExMover d;
    switch(dxr.localURL)
    {
        case "15_AREA51_FINAL":
            foreach AllActors(class'DeusExMover', d, 'Generator_overload') {
                d.move(vect(0, 0, -1));
            }
            AddSwitch( vect(-3745, -1114, -1950), rot(0,0,0), 'Page_Blastdoors' );
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
    local Switch2 s;
    s = Spawn(class'Switch2',,,loc,rotate);
    s.Event = Event;
    s.bCollideWorld=False;
    s.SetLocation(loc);
    return s;
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
