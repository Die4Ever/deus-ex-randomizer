class Telemetry extends UBrowserHTTPClient;

var string content[256];
var int start;
var bool running;

function Browse(string InAddress, string InURI, optional int InPort, optional int InTimeout)
{
    log(Self$": Browse");
    running = true;
    Super.Browse(InAddress, InURI, InPort, InTimeout);
}

event Opened()
{
    local string c;
    local int i;

    c = content[start];
    content[start] = "";
    start = (start+1) % ArrayCount(content);
    i = Len(c);

    //LinkMode = MODE_Binary;
    log(Self$": Opened, sending "$i$", LinkMode: "$LinkMode);
	Enable('Tick');
	if(ProxyServerAddress != "")
		SendBufferedData("POST http://"$ServerAddress$":"$string(ServerPort)$ServerURI$" HTTP/1.1"$CR$LF);
	else
		SendBufferedData("POST "$ServerURI$" HTTP/1.1"$CR$LF);
	SendBufferedData("User-Agent: Unreal"$CR$LF);
	SendBufferedData("Connection: close"$CR$LF);
    SendBufferedData("Content-Length: "$i$CR$LF);
	SendBufferedData("Host: "$ServerAddress$":"$ServerPort$CR$LF$CR$LF);
    SendBufferedData( c $ LF $ Chr(0) );

	CurrentState = WaitingForHeader;
}

function HTTPError(int Code)
{
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
    Super.Closed();
    Done();
}

function SetError(int Code)
{
    Super.SetError(Code);
    Done();
}

function Done()
{
    local int i;
    running = false;
    i = Len(content[start]);
    if( i > 0 ) {
        log(Self$": coming back for "$i$" more!");
        Browse("raycarro.com", "/dxrando/log.py");
    }
}

function bool Queue(string message)
{
    local int slot;
    slot = QueueSlot(Len(message));
    if( slot == -1 ) return false;
    LF = Chr(10);
    content[slot] = content[slot] $ message $ LF;
    if( running == false ) Browse("raycarro.com", "/dxrando/log.py");
    return true;
}

function int QueueSlot(int length)
{
    local int i, slot, c_len;
    for(i=0; i<ArrayCount(content); i++) {
        slot = i+start;
        slot = slot % ArrayCount(content);
        c_len = Len(content[slot]);
        if( c_len + length < 800 || c_len == 0 ) return slot;
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
