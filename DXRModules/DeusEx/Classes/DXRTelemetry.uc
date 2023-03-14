class DXRTelemetry extends DXRActorsBase transient;

var transient Telemetry t;

var config int config_version;
var config bool enabled, death_markers;
var config string server;
var config string path;
var config int cache_addr;
var config string last_notification;

var string notification_url;

var string newsdates[5];
var string newsheaders[5];
var string newstexts[5];

function CheckConfig()
{
    if( server == "" || config_version < VersionNumber() ) {
        server = "raycarro.com";
        path = "/dxrando/log.py";
        cache_addr = 0;
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
}

function Timer()
{
    local int numActors, numObjects;
    local Actor a;
    local Object o, last;
    local name names[4096];
    local int counts[4096], slot, i;

    foreach AllObjects(class'Object', o) {
        if( o.IsA('Actor') ) {
            numActors++;
            continue;
        }
        numObjects++;
        last = o;
        slot = Abs(dxr.Crc( String(o.class.name) )) % ArrayCount(names);
        if( names[slot] == '' || names[slot] == o.class.name ) {
            names[slot] = o.class.name;
            counts[slot]++;
        }
    }

    info("numActors: "$numActors$", numObjects: "$numObjects$", last object: "$last);
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
    local Json j;
    j = class'Json'.static.parse(Level, data);
    data = "";
    status = j.get("status");
    l("HTTPReceivedData: " $ status $ ", j.count(): " $ j.count());
    if( InStr(status,"ERROR") >= 0 || InStr(status, "ok") == -1 ) {
        // we probably don't want to use warning or err here because that would send to telemetry which could cause an infinite loop
        l("ERROR: HTTPReceivedData: " $ status);
    }
    CheckNotification(j);
    CheckDeaths(j);
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
    local DXRNews news;
    local DeusExRootWindow r;
    local string title, message;

    if( ! CanShowNotification() ) return;
    title = j.get("notification");
    if( title == "" || title == last_notification ) return;
    last_notification = title;
    SaveConfig();

    notification_url = j.get("url");

    message = j.get("longmsg");
    r = DeusExRootWindow(player().rootWindow);
    news = DXRNews(r.InvokeUIScreen(class'DXRNews'));
    news.Set(self, title, message);
}

function MessageBoxClicked(int button, int callbackId){
    Super.MessageBoxClicked(button, callbackId);
    if( button == 0 ) {
        player().ConsoleCommand("start "$notification_url);
    }
    //Implementations in subclasses just need to call Super to pop the window, then can handle the message however they want
    //Buttons:
    //Yes = 0
    //No = 1
    //OK = 2
}

function CheckDeaths(Json j) {
    local string k, t;
    local int i;
    local vector loc;

    // if death_markers is disabled, we still should parse the list so we can tell the server the newest one we've already received?

    for(i=0; i<j.count(); i++) {
        k = j.key_at(i);
        if( InStr(k, "deaths.") == 0 ) {
            loc.x = float(j.at(i, 5));
            loc.y = float(j.at(i, 6));
            loc.z = float(j.at(i, 7));
            if(death_markers) {
                l("CheckDeaths key: "$k$" new deathmarker "$loc);
                // New(Actor a, vector loc, string playername, string killerclass, string killer, string damagetype, int age, int numtimes)
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
