class Telemetry extends UBrowserHTTPClient transient;

var DXRTelemetry module;

var string server_host;
var string content[32];
var int start;
var bool running;

function Resolved( IpAddr Addr )
{
    log(Self$" Resolved "$Addr.Addr);
    module.CacheAddr(Addr.Addr);
    Super.Resolved(Addr);
}

function Browse(string InAddress, string InURI, optional int InPort, optional int InTimeout)
{
    if(server_host == "") server_host = InAddress;
    //log( Self$": Browse "$server_host$" with " $ Len(content[start]) $ " bytes, ServerIpAddr.Addr == " $ ServerIpAddr.Addr );
    running = true;
    Super.Browse(InAddress, InURI, InPort, InTimeout);
}

event Opened()
{
    local string c;
    local int i;

    // timeout!
    SetTimer(120, False);

    c = content[start];
    content[start] = "";
    start = (start+1) % ArrayCount(content);
    i = Len(c);

    //LinkMode = MODE_Binary;
    log(Self$": Opened, sending "$i$" to http://"$server_host$":"$string(ServerPort)$ServerURI$", LinkMode: "$LinkMode);
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
    //log(Self$" SendText: "$Len(Str));
    Str = Left(Str, 500);
    return Super.SendText(Str);
}

function HTTPError(int Code)
{
    log(Self$": HTTPError: " $ Code);
    Super.HTTPError(Code);
}

function HTTPReceivedData(string Data)
{
    log(Self$": HTTPReceivedData: "$Len(Data));
    module.ReceivedData(Data);
    Done();
}

event Closed()
{
    //log(Self$": Closed, InputBuffer: "$Len(InputBuffer));
    Super.Closed();
    if(CurrentState != ReceivingData)
        Done();
}

function SetError(int Code)
{
    log(Self$": SetError: " $ Code);
    Super.SetError(Code);
}

event Timer()
{
    log(Self$": Timer");
    Super.Timer();
    Done();
}

function string GetUrl()
{
    local string version;
    local int i;
    version = module.VersionString(true);
    i = InStr(version, " ");
    while( i != -1 ) {
        version = Left(version, i) $ "%20" $ Mid(version, i+1);
        i = InStr(version, " ");
    }
    return module.path $ "?version="$version$"&mod=#var(package)";
}

function Done()
{
    local int i;
    SetTimer(0, False);
    //log(Self$": Done(), InputBuffer: "$Len(InputBuffer));
    if( ServerIpAddr.Addr == 0 )
    {
        log(Self$": ERROR: never got server IP! trying cached_addr");
        ServerIpAddr.Addr = module.GetAddrFromCache();
    }
    running = false;
    if( ServerIpAddr.Addr == 0 ) return;
    i = Len(content[start]);
    if( i > 0 ) {
        log(Self$": coming back for "$i$" more!");
        Browse(module.server, GetUrl(), 80, 3);
    }
}

function bool Queue(string message)
{
    local int slot;

    slot = QueueSlot(Len(message));
    if( slot == -1 ) return false;
    LF = Chr(10);
    content[slot] = content[slot] $ message $ LF;
    if( running == false ) Browse(module.server, GetUrl(), 80, 3);
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
