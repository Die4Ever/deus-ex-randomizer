class DXRTelemetry extends DXRActorsBase transient;

var transient Telemetry t;

var config int config_version;
var config bool enabled;
var config string server;
var config int cache_addr;
var config string last_notification;

var string notification_url;

function CheckConfig()
{
    if( server == "" ) {
        server = "raycarro.com";
        cache_addr = 0;
    }
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        server = "raycarro.com";
        cache_addr = 0;
    }
    Super.CheckConfig();
}

function AnyEntry()
{
    local #var PlayerPawn  p;
    Super.AnyEntry();
    //info log player's health, item counts...?
    p = player();
    if( p == None ) return;
    info("health: "$p.health$", HealthLegLeft: "$p.HealthLegLeft$", HealthLegRight: "$p.HealthLegRight$", HealthTorso: "$p.HealthTorso$", HealthHead: "$p.HealthHead$", HealthArmLeft: "$p.HealthArmLeft$", HealthArmRight: "$p.HealthArmRight);
}

function set_enabled(bool e)
{
    log(Self$": set_enabled "$e);
    enabled = e;
    SaveConfig();
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
    if( InStr(data,"ERROR") >= 0 || InStr(data, "ok") == -1 ) {
        l("HTTPReceivedData: " $ data);
    }
    CheckNotification(data);
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

function CheckNotification(string data)
{
    local int i;
    local string update, title, message, url, marker;

    if( ! CanShowNotification() ) return;

    marker = " notification: ";
    i = InStr(data, marker);
    if( i == -1 ) return;

    update = Mid(data, i+Len(marker) );
    i = InStr(update, t.LF);
    title = Left(update, i);
    message = Mid(update, i+1);
    if( title == last_notification ) return;
    last_notification = title;
    SaveConfig();

    i = InStr(message, t.LF);
    message = Left(message, i);
    i = InStr(message, "https://");
    notification_url = Mid(message, i);
    i = InStr(notification_url, " ");
    if( i != -1 ) notification_url = Left(notification_url, i);

    CreateMessageBox(title, message, 0, Self, 1);
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
    module = dxr.telemetry;
    if( module == None ) {
        module = DXRTelemetry(dxr.FindModule(class'DXRTelemetry'));
        dxr.telemetry = module;
    }
    if( module != None ) module._SendLog(a, LogLevel, message);
}
