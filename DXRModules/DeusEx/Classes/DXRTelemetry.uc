class DXRTelemetry extends DXRActorsBase transient;

var transient Telemetry t;

var config int config_version;
var config bool enabled, death_markers;
var config string server;
var config string path;
var config int cache_addr;
var config int port;
var config string last_notification;

var string notification_url;

var string newsdates[5];
var string newsheaders[5];
var string newstexts[5];

var Json j;

function CheckConfig()
{
    if( server == "" || config_version < VersionNumber() ) {
        server = "mods4ever.com";
        path = "/dxrando/log.py";
        port = 10451;
        cache_addr = -1864803370;
    }
    Super.CheckConfig();
}

function AnyEntry()
{
    local #var(PlayerPawn) p;

    Super.AnyEntry();
#ifdef hx
    //SetTimer(300, true);
#endif
    //info log player's health, item counts...?
    p = player();
    if( p == None ) return;
    info("health: "$p.health$", HealthLegLeft: "$p.HealthLegLeft$", HealthLegRight: "$p.HealthLegRight$", HealthTorso: "$p.HealthTorso$", HealthHead: "$p.HealthHead$", HealthArmLeft: "$p.HealthArmLeft$", HealthArmRight: "$p.HealthArmRight);
    info("renderer: " $ GetConfig("Engine.Engine", "GameRenderDevice"));

    CheckOfflineUpdates();
}

function CheckOfflineUpdates()
{
    local DXRNews news;
    local DXRNewsWindow newswindow;
    local DeusExRootWindow r;

    if(enabled) return;// telemetry enabled, get real updates
    if(!CanShowNotification()) return;
    if(!DateAtLeast(2024, 10, 2)) return;// don't show until Oct 2nd to be safe, especially with timezones

    if(!VersionOlderThan(VersionNumber(), 3,2,1,0)) return;// v3.2.1 doesn't need this notification
    if(VersionIsStable() && !VersionOlderThan(VersionNumber(), 3,2,0,0)) return;// a stable branch of v3.2 doesn't need this

    newsdates[0] = "2024-10-01";
    newsheaders[0] = "v3.2 Halloween Update!";// it's supposed to be a surprise!
    newstexts[0] = "You have Online Features disabled, so we can't know for sure, but there's a good chance that the Halloween Update has been released!";

    notification_url = "https://github.com/Die4Ever/deus-ex-randomizer/releases/latest";

    foreach AllObjects(class'DXRNews', news) {
        news.Set(self);
    }

    r = DeusExRootWindow(player().rootWindow);
    newswindow = DXRNewsWindow(r.InvokeUIScreen(class'DXRNewsWindow'));
    newswindow.Set(self, newsheaders[0]);
}

function Timer()
{
    local int numActors, numObjects;
    local Actor a;
    local Object o, last;
    local name names[4096], fixed[16], n;
    local int counts[4096], slot, i;

    fixed[i++] = 'Container';
    fixed[i++] = 'ScriptedPawn';
    fixed[i++] = 'DeusExDecoration';
    fixed[i++] = 'Inventory';
    fixed[i++] = 'Skill';
    fixed[i++] = 'SkillManager';
    fixed[i++] = 'Augmentation';
    fixed[i++] = 'AugmentationManager';
    fixed[i++] = 'Carcass';
    fixed[i++] = 'DXRInfo';
    fixed[i++] = 'ColorTheme';
    fixed[i++] = 'ColorThemeManager';

    for(i=0; i<ArrayCount(fixed); i++) {
        if(fixed[i] == '') continue;
        slot = Abs(dxr.Crc( String(fixed[i]) )) % ArrayCount(names);
        names[slot] = fixed[i];
    }

    foreach AllObjects(class'Object', o) {
        last = o;
        if( o.IsA('Actor') ) {
            numActors++;
            //continue;
        } else {
            numObjects++;
            continue;
        }

        n = o.class.name;
        for(i=0; i<ArrayCount(fixed); i++) {
            if(fixed[i]=='') break;
            if( o.IsA(fixed[i]) ) {
                n = fixed[i];
                break;
            }
        }

        slot = Abs(dxr.Crc( String(n) )) % ArrayCount(names);
        if( names[slot] == '' || names[slot] == n ) {
            names[slot] = n;
            counts[slot]++;
        }
    }

    err("numActors: "$numActors$", numObjects: "$numObjects$", last object: "$last);
    for(i=0; i<ArrayCount(names); i++) {
        if( names[i] == '' ) continue;
        info(names[i] @ counts[i]);
    }
}

function set_enabled(bool e, bool set_death_markers)
{
    log(Self$": set_enabled "$e);
    enabled = e;
    if (death_markers!=set_death_markers){
        SetDeathMarkerVisibility(set_death_markers);
    }
    death_markers = set_death_markers;
    SaveConfig();
}

function SetDeathMarkerVisibility(bool visible)
{
    local DeathMarker dm;

    foreach AllActors(class'DeathMarker',dm){
        dm.bHidden = !visible;
    }
}

function CacheAddr( int Addr )
{
    if( cache_addr != Addr ) {//these should never be equal anyways in this function?
        cache_addr = Addr;
        SaveConfig();
        log(Self$": cached addr " $ Addr);
    }
}

function int GetAddrFromCache()
{
    log(Self$": got addr from cache " $ cache_addr );
    return cache_addr;
}

function ReceivedData(string data)
{
    local string status;
    local Json tjs;

    if(Len(data) > 500 && j==None) {
        l("ReceivedData doing latent json parsing: " @ Len(data));
        j = new(Level) class'Json';
        j.StartParse(data);
    } else {
        tjs = class'Json'.static.parse(Level, data);
        CheckNotification(tjs);
        CheckDeaths(tjs, 0);
        class'DXRStats'.static.CheckLeaderboard(dxr, tjs);
    }
    data = "";
}

simulated function Tick(float deltaTime)
{
    local int oldCount;
    Super.Tick(deltaTime);

    if(j != None) {
        oldCount = j.count();

        if(j.ParseIter(1)) {
            CheckNotification(j);
            CheckDeaths(j, oldCount);
            class'DXRStats'.static.CheckLeaderboard(dxr, j);
            CriticalDelete(j);
            j = None;
            l("finished latent json parsing");
        } else {
            CheckDeaths(j, oldCount);
        }
    }
}

function bool CanShowNotification()
{
    /*local DeusExRootWindow r;
    local DeusExHUD hud;*/

    if( dxr.localURL == "DX" || dxr.localURL == "DXONLY" ) return true;

    /*if( player() == None ) return false;
    r = DeusExRootWindow(player().rootWindow);
    if( r == None ) return false;
    hud = r.hud;
    if( hud == None ) return false;
    if( ! hud.IsVisible() ) return false;
    return true;*/
    return false;
}


function CheckNotification(Json j)
{
    local DXRNewsWindow newswindow;
    local DXRNews news;
    local DeusExRootWindow r;
    local string title, status;
    local int i;

    status = j.get("status");
    l("HTTPReceivedData: " $ status $ ", j.count(): " $ j.count());
    if( InStr(status,"ERROR") >= 0 || InStr(status, "ok") == -1 ) {
        // we probably don't want to use warning or err here because that would send to telemetry which could cause an infinite loop
        l("ERROR: HTTPReceivedData: " $ status);
    }

    if( ! CanShowNotification() ) return;
    if(j.get("newsheader0") == "") return;

    for(i=0;i<ArrayCount(newsheaders);i++) {
        newsdates[i] = j.get("newsdate"$i);
        newsheaders[i] = j.get("newsheader"$i);
        newstexts[i] = j.get("newsmsg"$i);
    }

    notification_url = j.get("url");

    foreach AllObjects(class'DXRNews', news) {
        news.Set(self);
    }

    title = j.get("notification");
    l("CheckNotification got title: "$title);
    if(title == "") return;
    last_notification = title;
    SaveConfig();

    r = DeusExRootWindow(player().rootWindow);
    newswindow = DXRNewsWindow(r.InvokeUIScreen(class'DXRNewsWindow'));
    newswindow.Set(self, title);
}

function MessageBoxClicked(int button, int callbackId){
    Super.MessageBoxClicked(button, callbackId);
    if( button == 0 ) {
        OpenURL(player(), notification_url);
    }
    //Implementations in subclasses just need to call Super to pop the window, then can handle the message however they want
    //Buttons:
    //Yes = 0
    //No = 1
    //OK = 2
}

function CheckDeaths(Json j, int oldCount) {
    local string k, t;
    local int i;
    local vector loc;

    // if death_markers is disabled, we still should parse the list so we can tell the server the newest one we've already received?

    for(i=oldCount; i<j.count(); i++) {
        k = j.key_at(i);
        if( InStr(k, "deaths.") == 0 ) {
            loc.x = float(j.at(i, 5));
            loc.y = float(j.at(i, 6));
            loc.z = float(j.at(i, 7));
            loc = vectm(loc.x, loc.y, loc.z);
            if(death_markers) {
                l("CheckDeaths key: "$k$" new deathmarker "$loc);
                //                     New(actor,loc,playername(1),killerclass(8),killer(2),damagetype(3),    int age(4), int numtimes(0))
                class'DeathMarker'.static.New(Self, loc, j.at(i, 1), j.at(i, 8), j.at(i, 2), j.at(i, 3), int(j.at(i, 4)), int(j.at(i, 0)));
            }
        }
    }
}

function _SendLog(Actor a, string LogLevel, string message)
{
    if( ! enabled ) return;
    message = LogLevel $ ": " $ a $ ": " $ message;
    if( t != None && t.Queue(message) )  return;

    foreach a.AllActors(class'Telemetry', t) {
        if( t.Queue(message) ) return;
    }
    t = a.Spawn(class'Telemetry');
    t.module = Self;
    t.Queue(message);
}

static function SendLog(DXRando dxr, Actor a, string LogLevel, string message)
{
    local DXRTelemetry module;
    if(dxr == None) return;
    module = dxr.telemetry;
    if( module != None ) module._SendLog(a, LogLevel, message);
}

static function SendEvent(DXRando dxr, Actor a, string json)
{
    if(Len(json)>900)
        log("EVENT: " $ Left(json, 500) $ "...", 'DXRTelemetry');
    else
        log("EVENT: " $ json, 'DXRTelemetry');
    SendLog(dxr, a, "EVENT", json);
}

function ExtendedTests()
{
    local vector loc;
    loc = vect(1,2,3);
    teststring(string(loc), loc.x$","$loc.y$","$loc.z, "vector to string x,y,z");
}

defaultproperties
{
    death_markers=true
    newsheaders(0)="Loading News..."
}
