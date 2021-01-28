class Telemetry extends UBrowserHTTPClient config(DXRando);

var string server_host;
var string content[32];
var int start;
var bool running;

var config int config_version;
var config bool enabled;

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        log(Self$": upgraded config from "$config_version$" to "$class'DXRFlags'.static.VersionNumber());
        config_version = class'DXRFlags'.static.VersionNumber();
        SaveConfig();
    }
}

function set_enabled(bool e)
{
    log(Self$": set_enabled "$e);
    enabled = e;
    SaveConfig();
}

function Browse(string InAddress, string InURI, optional int InPort, optional int InTimeout)
{
    if(server_host == "") server_host = InAddress;
    log( Self$": Browse "$server_host$" with " $ Len(content[start]) $ " bytes, ServerIpAddr.Addr == " $ ServerIpAddr.Addr );
    running = true;
    Super.Browse(InAddress, InURI, InPort, InTimeout);
}

event Opened()
{
    local string c;
    local int i;

    SetTimer(10, False);

    c = content[start];
    content[start] = "";
    start = (start+1) % ArrayCount(content);
    i = Len(c);

    //LinkMode = MODE_Binary;
    log(Self$": Opened, sending "$i$", LinkMode: "$LinkMode);
	Enable('Tick');
	if(ProxyServerAddress != "")
		SendBufferedData("POST http://"$server_host$":"$string(ServerPort)$ServerURI$" HTTP/1.1"$CR$LF);
	else
		SendBufferedData("POST "$ServerURI$" HTTP/1.1"$CR$LF);
	SendBufferedData("User-Agent: Unreal"$CR$LF);
	SendBufferedData("Connection: close"$CR$LF);
    SendBufferedData("Content-Length: "$i$CR$LF);
	SendBufferedData("Host: "$server_host$":"$ServerPort$CR$LF$CR$LF);
    SendBufferedData( c $ LF $ Chr(0) );

	CurrentState = WaitingForHeader;
}

function int SendText( coerce string Str )
{
    Str = Left(Str, 500);
    return Super.SendText(Str);
}

function HTTPError(int Code)
{
    log(Self$": HTTPError: " $ Code);
    Super.HTTPError(Code);
    Done();
}

function HTTPReceivedData(string Data)
{
    //log(Self$": HTTPReceivedData: " $ Len(Data));
    log(Self$": HTTPReceivedData: " $ Data);
    Done();
}

event Closed()
{
    log(Self$": Closed");
    Super.Closed();
    Done();
}

function SetError(int Code)
{
    log(Self$": SetError: " $ Code);
    Super.SetError(Code);
    //Done();
}

event Timer()
{
    log(Self$": Timer");
	Super.Timer();
}

function Done()
{
    local int i;
    local string addr;
    SetTimer(0, False);
    log(Self$": Done()");
    addr = "raycarro.com";
    if( ServerIpAddr.Addr == 0 )
    {
        log(Self$": never got server IP?");
        addr = "144.217.91.214";
        server_host = "raycarro.com";
    }
    running = false;
    i = Len(content[start]);
    if( i > 0 ) {
        log(Self$": coming back for "$i$" more!");
        Browse(addr, "/dxrando/log.py", 80, 3);
    }
}

function bool Queue(string message)
{
    local int slot;
    if( enabled == false ) return true;//just get out of here

    slot = QueueSlot(Len(message));
    if( slot == -1 ) return false;
    LF = Chr(10);
    content[slot] = content[slot] $ message $ LF;
    if( running == false ) Browse("raycarro.com", "/dxrando/log.py", 80, 3);
    return true;
}

function int QueueSlot(int length)
{
    local int i, slot, c_len;
    for(i=0; i<ArrayCount(content); i++) {
        slot = i+start;
        slot = slot % ArrayCount(content);
        c_len = Len(content[slot]);
        if( c_len + length < 10000 || c_len == 0 ) return slot;
    }
    log(Self$": failed to find a QueueSlot for "$length);
    return -1;
}

static function SendLog(Actor a, string LogLevel, string message)
{
    local Telemetry t;

    message = LogLevel $ ": " $ a $ ": " $ message;

    foreach a.AllActors(class'Telemetry', t) {
        if( t.Queue(message) ) return;
    }
    t = a.Spawn(class'Telemetry');
    t.Queue(message);
}
