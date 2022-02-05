//=============================================================================
// DXRandoCrowdControlLink.
//=============================================================================
class DXRandoCrowdControlLink extends TcpLink transient;

var string crowd_control_addr;

var DXRCrowdControl ccModule;
var DXRCrowdControlEffects ccEffects;

var DataStorage datastorage;
var transient DXRando dxr;
var int ListenPort;
var IpAddr addr;

var int ticker;

var bool anon;

var int reconnectTimer;
const ReconDefault = 5;

var string pendingMsg;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

const CrowdControlPort = 43384;

//JSON parsing states
const KeyState = 1;
const ValState = 2;
const ArrayState = 3;
const ArrayDoneState = 4;

struct JsonElement
{
    var string key;
    var string value[5];
    var int valCount;
};

struct JsonMsg
{
    var JsonElement e[20];
    var int count;
};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                             JSON STUFF                                                   ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function string StripQuotes (string msg) {
    if (Mid(msg,0,1)==Chr(34)) {
        if (Mid(msg,Len(Msg)-1,1)==Chr(34)) {
            return Mid(msg,1,Len(msg)-2);
        }
    }        
    return msg;
}

function string JsonStripSpaces(string msg) {
    local int i;
    local string c;
    local string buf;
    local bool inQuotes;
    
    inQuotes = False;
    
    for (i = 0; i < Len(msg) ; i++) {
        c = Mid(msg,i,1); //Grab a single character
        
        if (c==" " && !inQuotes) {
            continue;  //Don't add spaces to the buffer if we're outside quotes
        } else if (c==Chr(34)) {
            inQuotes = !inQuotes;
        }
        
        buf = buf $ c;
    }    
    
    return buf;
}

//Returns the appropriate character for whatever is after
//the backslash, eg \c
function string JsonGetEscapedChar(string c) {
    switch(c){
        case "b":
            return Chr(8); //Backspace
        case "f":
            return Chr(12); //Form feed
        case "n":
            return Chr(10); //New line
        case "r":
            return Chr(13); //Carriage return
        case "t":
            return Chr(9); //Tab
        case Chr(34): //Quotes
        case Chr(92): //Backslash
            return c;
        default:
            return "";
    }
}

function JsonMsg ParseJson (string msg) {
    
    local bool msgDone;
    local int i;
    local string c;
    local string buf;
    
    local int parsestate;
    local bool inquotes;
    local bool escape;
    local int inBraces;
    
    local JsonMsg j;
    
    local bool elemDone;
    
    elemDone = False;
    
    parsestate = KeyState;
    inquotes = False;
    escape = False;
    msgDone = False;
    buf = "";

    //Strip any spaces outside of strings to standardize the input a bit
    msg = JsonStripSpaces(msg);
    
    for (i = 0; i < Len(msg) && !msgDone ; i++) {
        c = Mid(msg,i,1); //Grab a single character
        
        if (!inQuotes) {
            switch (c) {
                case ":":
                case ",":
                  //Wrap up the current string that was being handled
                  //PlayerMessage(buf);
                  if (parsestate == KeyState) {
                      j.e[j.count].key = StripQuotes(buf);
                      parsestate = ValState;
                  } else if (parsestate == ValState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                      parsestate = KeyState;
                      elemDone = True;
                  } else if (parsestate == ArrayState) {
                      // TODO: arrays of objects
                      if (c != ":") {
                        //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                        j.e[j.count].value[j.e[j.count].valCount]=buf;
                        j.e[j.count].valCount++;
                      }
                  } else if (parsestate == ArrayDoneState){
                      parseState = KeyState;
                  }
                    buf = "";
                    break; // break for colon and comma

                case "{":
                    inBraces++;
                    buf = "";
                    break;
                
                case "}":
                    //PlayerMessage(buf);
                    inBraces--;
                    if (inBraces == 0 && parsestate == ValState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                      parsestate = KeyState;
                      elemDone = True;
                    }
                    if (parsestate == ArrayState) {
                        // TODO: arrays of objects
                    }
                    else if(inBraces > 0) {
                        // TODO: sub objects
                    }
                    else {
                        msgDone = True;
                    }
                    break;
                
                case "]":
                    if (parsestate == ArrayState) {
                        //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                        j.e[j.count].value[j.e[j.count].valCount]=buf;
                        j.e[j.count].valCount++;
                        elemDone = True;
                        parsestate = ArrayDoneState;
                    } else {
                        buf = buf $ c;
                    }
                    break;
                case "[":
                    if (parsestate == ValState){
                        parsestate = ArrayState;
                    } else {
                        buf = buf $ c;
                    }
                    break;
                case Chr(34): //Quotes
                    inQuotes = !inQuotes;
                    break;
                default:
                    //Build up the buffer
                    buf = buf $ c;
                    break;
                
            }
        } else {
            switch(c) {
                case Chr(34): //Quotes
                    if (escape) {
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        inQuotes = !inQuotes;
                    }
                    break;
                case Chr(92): //Backslash, escape character time
                    if (escape) {
                        //If there has already been one, then we need to turn it into the right char
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        escape = True;
                    }
                    break;
                default:
                    //Build up the buffer
                    if (escape) {
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        buf = buf $ c;
                    }
                    break;
            }
        }
        
        if (elemDone) {
          //PlayerMessage("Key: "$j.e[j.count].key$ "   Val: "$j.e[j.count].value[0]);
          j.count++;
          elemDone = False;
        }
    }
    
    return j;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                  CROWD CONTROL FRAMEWORK                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function Init( DXRando tdxr, DXRCrowdControl cc, string addr, bool anonymous)
{
    dxr = tdxr;   
    ccModule = cc;
    crowd_control_addr = addr; 
    anon = anonymous;
    
    //Initialize the effect class
    ccEffects = Spawn(class'DXRCrowdControlEffects');
    ccEffects.Init(self,dxr);
    
    //Initialize the pending message buffer
    pendingMsg = "";
    
    //Initialize the ticker
    ticker = 0;

    Resolve(crowd_control_addr);

    reconnectTimer = ReconDefault;
    SetTimer(0.1,True);

}

function Timer() {
    
    ticker++;
    if (IsConnected()) {
        ManualReceiveBinary();
    }

    ccEffects.ContinuousUpdates();

    if (ticker%10 != 0) {
        return;
    }
    //Everything below here runs once a second

    if (!IsConnected()) {
        reconnectTimer-=1;
        if (reconnectTimer <= 0){
            Resolve(crowd_control_addr);
        }
    } 

    ccEffects.PeriodicUpdates();
}


function bool isCrowdControl( string msg) {
    local string tmp;
    //Validate if it looks json-like
    if (InStr(msg,"{")!=0){
        //PlayerMessage("Message doesn't start with curly");
        return False;
    }
    
    //Explicitly check last character of string to see if it's a closing curly
    tmp = Mid(msg,Len(msg)-1,1);
    //if (InStr(msg,"}")!=Len(msg)-1){
    if (tmp != "}"){
        //PlayerMessage("Message doesn't end with curly.  Ends with '"$tmp$"'.");
        return False;    
    }
    
    //Check to see if it looks like it has the right fields in it
    
    //id field
    if (InStr(msg,"id")==-1){
        //PlayerMessage("Doesn't have id");
        return False;
    }
    
    //code field
    if (InStr(msg,"code")==-1){
        //PlayerMessage("Doesn't have code");
        return False;
    }
    //viewer field
    if (InStr(msg,"viewer")==-1){
        //PlayerMessage("Doesn't have viewer");
        return False;
    }

    return True;
}

function sendReply(int id, int status) {
    local string resp;
    local byte respbyte[255];
    local int i;
    
    resp = "{\"id\":"$id$",\"status\":"$status$"}"; 
    
    for (i=0;i<Len(resp);i++){
        respbyte[i]=Asc(Mid(resp,i,1));
    }
    
    //PlayerMessage(resp);
    SendBinary(Len(resp)+1,respbyte);
}


function handleMessage( string msg) {
  
    local int id,type;
    local string code,viewer;
    local string param[5];
    
    local int result;
    
    local JsonMsg jmsg;
    local string val;
    local int i,j;

    if (isCrowdControl(msg)) {
        jmsg=ParseJson(msg);
        
        for (i=0;i<jmsg.count;i++) {
            if (jmsg.e[i].valCount>0) {
                val = jmsg.e[i].value[0];
                //PlayerMessage("Key: "$jmsg.e[i].key);
                switch (jmsg.e[i].key) {
                    case "code":
                        code = val;
                        break;
                    case "viewer":
                        viewer = val;
                        break;
                    case "id":
                        id = Int(val);
                        break;
                    case "type":
                        type = Int(val);
                        break;
                    case "parameters":
                        for (j=0;j<5;j++) {
                            param[j] = jmsg.e[i].value[j];
                        }
                        break;
                }
            }
        }
        
        //Streamers may not want names to show up in game
        //so that they can avoid troll names, etc
        if (anon) {
            viewer = "Crowd Control";
        }
        result = ccEffects.doCrowdControlEvent(code,param,viewer,type);
        
        if (result == Success) {
            ccModule.IncHandledEffects();
        }
        
        sendReply(id,result);
        
    } else {
        err("Got a weird message: "$msg);
    }

}

//I cannot believe I had to manually write my own version of ReceivedBinary
function ManualReceiveBinary() {
    local byte B[255]; //I have to use a 255 length array even if I only want to read 1
    local int count,i;
    //PlayerMessage("Manually reading, have "$DataPending$" bytes pending");
    
    if (DataPending!=0) {
        count = ReadBinary(255,B);
        for (i = 0; i < count; i++) {
            if (B[i] == 0) {
                if (Len(pendingMsg)>0){
                    //PlayerMessage(pendingMsg);
                    handleMessage(pendingMsg);
                }
                pendingMsg="";
            } else {
                pendingMsg = pendingMsg $ Chr(B[i]);
                //PlayerMessage("ReceivedBinary: " $ B[i]);
            }
        }
    }
    
}

event Opened(){
    PlayerMessage("Crowd Control connection opened");
}

event Closed(){
    PlayerMessage("Crowd Control connection closed");
    ListenPort = 0;
    reconnectTimer = ReconDefault;
}

event Destroyed(){
    Close();
    Super.Destroyed();
}

function Resolved( IpAddr Addr )
{
    if (ListenPort == 0) {
        ListenPort=BindPort();
        if (ListenPort==0){
            err("Failed to bind port for Crowd Control");
            reconnectTimer = ReconDefault;
            return;
        }   
    }

    Addr.port=CrowdControlPort;
    if (False==Open(Addr)){
        err("Could not connect to Crowd Control client");
        reconnectTimer = ReconDefault;
        return;

    }

    //Using manual binary reading, which is handled by ManualReceiveBinary()
    //This means that we can handle if multiple crowd control messages come in
    //between reads.
    LinkMode=MODE_Binary;
    ReceiveMode = RMODE_Manual;

}
function ResolveFailed()
{
    err("Could not resolve Crowd Control address");
    reconnectTimer = ReconDefault;
}




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                        UTILITY FUNCTIONS                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


simulated final function #var PlayerPawn  player()
{
    return dxr.flags.player();
}

function PlayerMessage(string msg)
{
    log(Self$": "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "INFO", msg);
    player().ClientMessage(msg, 'CrowdControl', true);
}

function err(string msg)
{
    log(Self$": ERROR: "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "ERROR", msg);
    player().ClientMessage(msg, 'ERROR', true);
}

function info(string msg)
{
    log(Self$": INFO: "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "INFO", msg);
}

function SplitString(string src, string divider, out string parts[8])
{
    local int i, c;

    parts[0] = src;
    for(i=0; i+1<ArrayCount(parts); i++) {
        c = InStr(parts[i], divider);
        if( c == -1 ) {
            return;
        }
        parts[i+1] = Mid(parts[i], c+1);
        parts[i] = Left(parts[i], c);
    }
}







//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                           TEST FRAMEWORK                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function RunTests(DXRCrowdControl m)
{
    local int i;
    local string msg;
    local string params[5];
    local string words[8];

    SplitString("add_aug_aqualung", "_", words);
    m.teststring(words[0], "add", "SplitString");
    m.teststring(words[1], "aug", "SplitString");
    m.teststring(words[2], "aqualung", "SplitString");
    m.teststring(words[3], "", "SplitString");

    msg="";
    m.testbool( isCrowdControl(msg), false, "isCrowdControl "$msg);

    msg="{}";
    m.testbool( isCrowdControl(msg), false, "isCrowdControl "$msg);
    
    msg="{\"id\":3,\"code\":\"disable_jump\",\"targets\":[{\"id\":\"1234\",\"name\":\"dxrandotest\",\"avatar\":\"\"}],\"viewer\":\"dxrandotest\",\"type\":1}";
    m.testbool( isCrowdControl(msg), true, "isCrowdControl "$msg);
    _TestMsg(m,msg,3,1,"disable_jump","dxrandotest",params);

    // test multiple payloads, Crowd Control always puts a \0 between them so this isn't an issue, but still good to be safe
    msg="{\"id\":3,\"code\":\"disable_jump\",\"viewer\":\"dxrandotest\",\"type\":1}{\"parameters\":[1,2,3],\"code\":\"fail\"}";
    m.testbool( isCrowdControl(msg), true, "isCrowdControl "$msg);
    _TestMsg(m,msg,3,1,"disable_jump","dxrandotest",params);

    TestMsg(m, 123, 1, "kill", "die4ever", params);
    TestMsg(m, 123, 1, "test with spaces", "die4ever", params);
    TestMsg(m, 123, 1, "test:with:colons", "die4ever", params);
    TestMsg(m, 123, 1, "test,with,commas", "die4ever", params);
    params[0] = "parameter test";
    TestMsg(m, 123, 1, "kill", "die4ever", params);
    params[0] = "g_scrambler";
    TestMsg(m, 123, 1, "drop_grenade", "die4ever", params);
    params[0] = "g_scrambler";
    params[1] = "10";
    TestMsg(m, 123, 1, "drop_grenade", "die4ever", params);
    
    //Need to do more work to validate escaped characters
    //TestMsg(m, 123, 1, "test\\\\with\\\\escaped\\\\backslashes", "die4ever", ""); //Note that we have to double escape so that the end result is a single escaped backslash
}

function int GetJsonField(JsonMsg jmsg, string key, optional out JsonElement je)
{
    local int i;

    for (i=0;i<jmsg.count;i++) {
        if (jmsg.e[i].key == key && jmsg.e[i].valCount>0) {
            je = jmsg.e[i];
            return jmsg.e[i].valCount;
        }
    }
    return 0;
}

function int TestJsonField(DXRCrowdControl m, JsonMsg jmsg, string key, coerce string expected, optional out JsonElement je)
{
    local int len;
    m.test(jmsg.count < ArrayCount(jmsg.e), "jmsg.count < ArrayCount(jmsg.e)");
    len = GetJsonField(jmsg, key, je);
    if(expected == "" && len == 0) {
        m.test(true, "TestJsonField "$key$" correctly missing");
    } else {
        m.test(je.valCount > 0, "je.valCount > 0");
        m.test(je.valCount < ArrayCount(je.value), "je.valCount < ArrayCount(je.value)");
        m.teststring(je.value[0], expected, "TestJsonField " $ key);
    }
    return len;
}

function _TestMsg(DXRCrowdControl m, string msg, int id, int type, string code, string viewer, string params[5])
{
    local JsonMsg jmsg;
    local JsonElement je;
    local int p;

    m.testbool( isCrowdControl(msg), true, "isCrowdControl: "$msg);

    jmsg=ParseJson(msg);
    m.testint(TestJsonField(m, jmsg, "code", code), 1, "got 1 code");
    m.testint(TestJsonField(m, jmsg, "viewer", viewer), 1, "got 1 viewer");
    m.testint(TestJsonField(m, jmsg, "id", id), 1, "got 1 id");
    m.testint(TestJsonField(m, jmsg, "type", type), 1, "got 1 type");


    TestJsonField(m, jmsg, "parameters", params[0], je);
    for(p=0; p<ArrayCount(params); p++) {
        m.teststring(je.value[p], params[p], "param "$p);
    }
}

function string BuildParamsString(string params[5])
{
    local int i, num_params;
    local string params_string;

    for(i=0; i < ArrayCount(params); i++) {
        if( params[i] != "" ) num_params++;
    }

    if( num_params > 1 ) {
        params_string = "[";
        for(i=0; i < ArrayCount(params); i++) {
            if( params[i] != "" )
                params_string = params_string $ params[i] $ ",";
        }
        params_string = Left(params_string, Len(params_string)-1);//trim trailing comma
        params_string = params_string $ "]";
    }
    else if ( num_params <= 1 )
        params_string = "\""$params[0]$"\"";

    return params_string;
}

function TestMsg(DXRCrowdControl m, int id, int type, string code, string viewer, string params[5])
{
    local int i, p, matches;
    local string msg, params_string, targets;
    local JsonMsg jmsg;

    params_string = BuildParamsString(params);

    msg = "{\"id\":\""$id$"\",\"code\":\""$code$"\",\"viewer\":\""$viewer$"\",\"type\":\""$type$"\",\"parameters\":"$params_string$"}";
    _TestMsg(m, msg, id, type, code, viewer, params);

    // test new targets field, in the beginning, in the middle, and at the end...
    targets = "[{\"id\":\"1234\",\"name\":\"Die4Ever\",\"avatar\":\"\"}]";
    msg = "{\"id\":\""$id$"\",\"code\":\""$code$"\",\"targets\":"$targets$",\"viewer\":\""$viewer$"\",\"type\":\""$type$"\",\"parameters\":"$params_string$"}";
    _TestMsg(m, msg, id, type, code, viewer, params);

    msg = "{\"targets\":"$targets$",\"id\":\""$id$"\",\"code\":\""$code$"\",\"viewer\":\""$viewer$"\",\"type\":\""$type$"\",\"parameters\":"$params_string$"}";
    _TestMsg(m, msg, id, type, code, viewer, params);

    msg = "{\"id\":\""$id$"\",\"code\":\""$code$"\",\"targets\":"$targets$",\"viewer\":\""$viewer$"\",\"type\":\""$type$"\",\"parameters\":"$params_string$",\"targets\":"$targets$"}";
    _TestMsg(m, msg, id, type, code, viewer, params);

    // test array of objects
    targets = "[{\"id\":\"1234\",\"name\":\"Die4Ever\",\"avatar\":\"\"},{\"name\":\"TheAstropath\"}]";
    msg = "{\"id\":\""$id$"\",\"code\":\""$code$"\",\"targets\":"$targets$",\"viewer\":\""$viewer$"\",\"type\":\""$type$"\",\"parameters\":"$params_string$",\"targets\":"$targets$"}";
    _TestMsg(m, msg, id, type, code, viewer, params);

    // test sub objects
    targets = "{\"array\":[{\"id\":\"1234\",\"name\":\"Die4Ever\",\"avatar\":\"\"},{\"name\":\"TheAstropath\"}]}";
    msg = "{\"id\":\""$id$"\",\"code\":\""$code$"\",\"targets\":"$targets$",\"viewer\":\""$viewer$"\",\"type\":\""$type$"\",\"parameters\":"$params_string$",\"targets\":"$targets$"}";
    _TestMsg(m, msg, id, type, code, viewer, params);
}


