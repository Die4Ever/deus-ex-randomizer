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
var bool online;
var bool offline;

var bool effectsDisabled;

var int reconnectTimer;
const ReconDefault = 5;

var string pendingMsg;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

const CrowdControlPort = 43384;

const cVISIBLE=0x80;
const cNOTVISIBLE=0x81;
const cSELECTABLE=0x82;
const cNOTSELECTABLE=0x83;

const MILLISEC_TO_SEC=1000;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                  CROWD CONTROL FRAMEWORK                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function Init( DXRando tdxr, DXRCrowdControl cc, string addr, bool anonymous, bool online_mode, bool offline_mode)
{
    dxr = tdxr;
    ccModule = cc;
    crowd_control_addr = addr;
    anon = anonymous;
    effectsDisabled=False;

    //Initialize the effect class
    foreach AllActors(class'DXRCrowdControlEffects', ccEffects) { break; }
    if(ccEffects == None)
        ccEffects = Spawn(class'DXRCrowdControlEffects');
    ccEffects.Init(self,dxr);

    //Initialize the pending message buffer
    pendingMsg = "";

    //Initialize the ticker
    ticker = 0;

    online = online_mode;
    offline = offline_mode;

    if(online) {
        Resolve(crowd_control_addr);
    }
    reconnectTimer = ReconDefault;
    SetTimer(0.1,True);

}

function Timer() {

    ticker++;
    if (IsConnected()) {
        if (effectsDisabled==False){
            DisableEffectsByMod();
            effectsDisabled=True;
        }
        ManualReceiveBinary();
    }

    ccEffects.ContinuousUpdates();

    if (ticker%10 != 0) {
        return;
    }
    //Everything below here runs once a second

    if (online && !IsConnected()) {
        reconnectTimer-=1;
        if (reconnectTimer <= 0){
            Resolve(crowd_control_addr);
        }
    }

    ccEffects.PeriodicUpdates();

    if(offline) {
        RandomOfflineEffects();
    }

    if (online && IsConnected()) {
        ccEffects.HandleEffectSelectability();
    }

}

function DisableEffectsByMod()
{
    sendEffectVisibility("lamthrower",#defined(vanilla));
    sendEffectVisibility("dmg_double",#defined(vanilla));
    sendEffectVisibility("dmg_half",#defined(vanilla));
    sendEffectVisibility("flipped",#defined(vanilla));
    sendEffectVisibility("limp_neck",#defined(vanilla));
    sendEffectVisibility("barrel_roll",#defined(vanilla));
}


function int RandomOfflineEffects() {
    local string param[5];
    local string viewer;

    // only 1.5% chance for an effect, each second
    if(FRand() > 0.015) return 0;

    viewer = "Simulated Crowd Control";
    param[0] = "1";

    switch(Rand(85)) {
    case 0: if(Rand(2)==0){ return 0; } else { return ccEffects.doCrowdControlEvent("poison", param, viewer, 0, 0); }
    case 1: return ccEffects.doCrowdControlEvent("glass_legs", param, viewer, 0, 0);
    case 2: param[0] = string(Rand(20)); return ccEffects.doCrowdControlEvent("give_health", param, viewer, 0, 0);
    case 3: if(Rand(2)==0){ return 0; } else {return ccEffects.doCrowdControlEvent("set_fire", param, viewer, 0, 0);}
    case 4: return ccEffects.doCrowdControlEvent("full_heal", param, viewer, 0, 0);
    case 5: return ccEffects.doCrowdControlEvent("disable_jump", param, viewer, 0, 0);
    case 6: return ccEffects.doCrowdControlEvent("gotta_go_fast", param, viewer, 0, 0);
    case 7: return ccEffects.doCrowdControlEvent("gotta_go_slow", param, viewer, 0, 0);
    case 8: return ccEffects.doCrowdControlEvent("drunk_mode", param, viewer, 0, 0);
    case 9: return ccEffects.doCrowdControlEvent("drop_selected_item", param, viewer, 0, 0);
    case 10: return ccEffects.doCrowdControlEvent("emp_field", param, viewer, 0, 0);
    case 11: return ccEffects.doCrowdControlEvent("matrix", param, viewer, 0, 0);
    case 12: return ccEffects.doCrowdControlEvent("third_person", param, viewer, 0, 0);
    case 13: param[0] = string(Rand(10)); return ccEffects.doCrowdControlEvent("give_energy", param, viewer, 0, 0);
    case 14: param[0] = string(Rand(25)); return ccEffects.doCrowdControlEvent("give_skillpoints", param, viewer, 0, 0);
    case 15: param[0] = string(Rand(10)); return ccEffects.doCrowdControlEvent("remove_skillpoints", param, viewer, 0, 0);
    case 16: param[0] = string(Rand(50)); return ccEffects.doCrowdControlEvent("add_credits", param, viewer, 0, 0);
    case 17: param[0] = string(Rand(25)); return ccEffects.doCrowdControlEvent("remove_credits", param, viewer, 0, 0);
    case 18: return ccEffects.doCrowdControlEvent("ice_physics", param, viewer, 0, 0);
    case 19: return ccEffects.doCrowdControlEvent("ask_a_question", param, viewer, 0, 0);
    case 20: return ccEffects.doCrowdControlEvent("nudge", param, viewer, 0, 0);
    case 21: return ccEffects.doCrowdControlEvent("swap_player_position", param, viewer, 0, 0);
    case 22: if(Rand(2)==0){ return 0; } else {return ccEffects.doCrowdControlEvent("floaty_physics", param, viewer, 0, 0);}
    case 23: if(Rand(2)==0){ return 0; } else {return ccEffects.doCrowdControlEvent("floor_is_lava", param, viewer, 0, 0);}
    case 24: return ccEffects.doCrowdControlEvent("invert_mouse", param, viewer, 0, 0);
    case 25: return ccEffects.doCrowdControlEvent("invert_movement", param, viewer, 0, 0);

#ifdef vanilla
    case 26: return ccEffects.doCrowdControlEvent("lamthrower", param, viewer, 0, 0);
    case 27: return ccEffects.doCrowdControlEvent("dmg_double", param, viewer, 0, 0);
    case 28: return ccEffects.doCrowdControlEvent("dmg_half", param, viewer, 0, 0);
#endif

    case 29: return ccEffects.doCrowdControlEvent("drop_lam", param, viewer, 0, 0);
    case 30: return ccEffects.doCrowdControlEvent("drop_empgrenade", param, viewer, 0, 0);
    case 31: return ccEffects.doCrowdControlEvent("drop_gasgrenade", param, viewer, 0, 0);
    case 32: return ccEffects.doCrowdControlEvent("drop_nanovirusgrenade", param, viewer, 0, 0);

    case 33: return ccEffects.doCrowdControlEvent("give_medkit", param, viewer, 0, 0);
    case 34: return ccEffects.doCrowdControlEvent("give_bioelectriccell", param, viewer, 0, 0);
    case 35: return ccEffects.doCrowdControlEvent("give_fireextinguisher", param, viewer, 0, 0);
    case 36: return ccEffects.doCrowdControlEvent("give_ballisticarmor", param, viewer, 0, 0);
    case 37: return ccEffects.doCrowdControlEvent("give_lockpick", param, viewer, 0, 0);
    case 38: return ccEffects.doCrowdControlEvent("give_multitool", param, viewer, 0, 0);
    case 39: return ccEffects.doCrowdControlEvent("give_rebreather", param, viewer, 0, 0);
    case 40: return ccEffects.doCrowdControlEvent("give_adaptivearmor", param, viewer, 0, 0);
    case 41: return ccEffects.doCrowdControlEvent("give_hazmatsuit", param, viewer, 0, 0);

    case 42: return ccEffects.doCrowdControlEvent("give_ammo10mm", param, viewer, 0, 0);
    case 43: return ccEffects.doCrowdControlEvent("give_ammo20mm", param, viewer, 0, 0);
    case 44: return ccEffects.doCrowdControlEvent("give_ammo762mm", param, viewer, 0, 0);
    case 45: return ccEffects.doCrowdControlEvent("give_ammo3006", param, viewer, 0, 0);
    case 46: return ccEffects.doCrowdControlEvent("give_ammobattery", param, viewer, 0, 0);
    case 47: return ccEffects.doCrowdControlEvent("give_ammodart", param, viewer, 0, 0);
    case 48: return ccEffects.doCrowdControlEvent("give_ammodartflare", param, viewer, 0, 0);
    case 49: return ccEffects.doCrowdControlEvent("give_ammodartpoison", param, viewer, 0, 0);
    case 50: return ccEffects.doCrowdControlEvent("give_ammonapalm", param, viewer, 0, 0);
    case 51: return ccEffects.doCrowdControlEvent("give_ammopepper", param, viewer, 0, 0);
    case 52: return ccEffects.doCrowdControlEvent("give_ammoplasma", param, viewer, 0, 0);
    case 53: return ccEffects.doCrowdControlEvent("give_ammorocket", param, viewer, 0, 0);
    case 54: return ccEffects.doCrowdControlEvent("give_ammorocketwp", param, viewer, 0, 0);
    case 55: return ccEffects.doCrowdControlEvent("give_ammosabot", param, viewer, 0, 0);
    case 56: return ccEffects.doCrowdControlEvent("give_ammoshell", param, viewer, 0, 0);

    case 57:
        // add and remove augs...
        switch(Rand(36)) {
        case 0: return ccEffects.doCrowdControlEvent("add_augaqualung", param, viewer, 0, 0);
        case 1: return ccEffects.doCrowdControlEvent("add_augballistic", param, viewer, 0, 0);
        case 2: return ccEffects.doCrowdControlEvent("add_augcloak", param, viewer, 0, 0);
        case 3: return ccEffects.doCrowdControlEvent("add_augcombat", param, viewer, 0, 0);
        case 4: return ccEffects.doCrowdControlEvent("add_augdefense", param, viewer, 0, 0);
        case 5: return ccEffects.doCrowdControlEvent("add_augdrone", param, viewer, 0, 0);
        case 6: return ccEffects.doCrowdControlEvent("add_augemp", param, viewer, 0, 0);
        case 7: return ccEffects.doCrowdControlEvent("add_augenviro", param, viewer, 0, 0);
        case 8: return ccEffects.doCrowdControlEvent("add_aughealing", param, viewer, 0, 0);
        case 9: return ccEffects.doCrowdControlEvent("add_augheartlung", param, viewer, 0, 0);
        case 10: return ccEffects.doCrowdControlEvent("add_augmuscle", param, viewer, 0, 0);
        case 11: return ccEffects.doCrowdControlEvent("add_augpower", param, viewer, 0, 0);
        case 12: return ccEffects.doCrowdControlEvent("add_augradartrans", param, viewer, 0, 0);
        case 13: return ccEffects.doCrowdControlEvent("add_augshield", param, viewer, 0, 0);
        case 14: return ccEffects.doCrowdControlEvent("add_augspeed", param, viewer, 0, 0);
        case 15: return ccEffects.doCrowdControlEvent("add_augstealth", param, viewer, 0, 0);
        case 16: return ccEffects.doCrowdControlEvent("add_augtarget", param, viewer, 0, 0);
        case 17: return ccEffects.doCrowdControlEvent("add_augvision", param, viewer, 0, 0);

        case 18: return ccEffects.doCrowdControlEvent("rem_augaqualung", param, viewer, 0, 0);
        case 19: return ccEffects.doCrowdControlEvent("rem_augballistic", param, viewer, 0, 0);
        case 20: return ccEffects.doCrowdControlEvent("rem_augcloak", param, viewer, 0, 0);
        case 21: return ccEffects.doCrowdControlEvent("rem_augcombat", param, viewer, 0, 0);
        case 22: return ccEffects.doCrowdControlEvent("rem_augdefense", param, viewer, 0, 0);
        case 23: return ccEffects.doCrowdControlEvent("rem_augdrone", param, viewer, 0, 0);
        case 24: return ccEffects.doCrowdControlEvent("rem_augemp", param, viewer, 0, 0);
        case 25: return ccEffects.doCrowdControlEvent("rem_augenviro", param, viewer, 0, 0);
        case 26: return ccEffects.doCrowdControlEvent("rem_aughealing", param, viewer, 0, 0);
        case 27: return ccEffects.doCrowdControlEvent("rem_augheartlung", param, viewer, 0, 0);
        case 28: return ccEffects.doCrowdControlEvent("rem_augmuscle", param, viewer, 0, 0);
        case 29: return ccEffects.doCrowdControlEvent("rem_augpower", param, viewer, 0, 0);
        case 30: return ccEffects.doCrowdControlEvent("rem_augradartrans", param, viewer, 0, 0);
        case 31: return ccEffects.doCrowdControlEvent("rem_augshield", param, viewer, 0, 0);
        case 32: return ccEffects.doCrowdControlEvent("rem_augspeed", param, viewer, 0, 0);
        case 33: return ccEffects.doCrowdControlEvent("rem_augstealth", param, viewer, 0, 0);
        case 34: return ccEffects.doCrowdControlEvent("rem_augtarget", param, viewer, 0, 0);
        case 35: return ccEffects.doCrowdControlEvent("rem_augvision", param, viewer, 0, 0);
        }
        break;
    case 58: return ccEffects.doCrowdControlEvent("earthquake",param,viewer,0, 0);
    case 59: return ccEffects.doCrowdControlEvent("give_full_energy",param,viewer,0, 0);
    case 60: return ccEffects.doCrowdControlEvent("trigger_alarms",param,viewer,0, 0);
    case 61: return ccEffects.doCrowdControlEvent("give_winebottle",param,viewer,0, 0);
    case 62: return ccEffects.doCrowdControlEvent("give_techgoggles",param,viewer,0, 0);
#ifdef vanilla
    case 63: return ccEffects.doCrowdControlEvent("flipped", param, viewer, 0, 0);
    case 64: return ccEffects.doCrowdControlEvent("limp_neck", param, viewer, 0, 0);
    case 65: return ccEffects.doCrowdControlEvent("barrel_roll", param, viewer, 0, 0);
#endif
    case 66: return ccEffects.doCrowdControlEvent("flashbang", param, viewer, 0, 0);
    case 67: return ccEffects.doCrowdControlEvent("eat_beans", param, viewer, 0, 0);
    case 68: return ccEffects.doCrowdControlEvent("fire_weapon", param, viewer, 0, 0);
    case 69: return ccEffects.doCrowdControlEvent("next_item", param, viewer, 0, 0);
    case 70: return ccEffects.doCrowdControlEvent("next_hud_color", param, viewer, 0, 0);
    case 71: return ccEffects.doCrowdControlEvent("spawnfriendly_medicalbot", param, viewer, 0, 0);
    case 72: return ccEffects.doCrowdControlEvent("spawnfriendly_repairbot", param, viewer, 0, 0);
    case 73: return ccEffects.doCrowdControlEvent("spawnfriendly_securitybot4", param, viewer, 0, 0);
    case 74: return ccEffects.doCrowdControlEvent("spawnfriendly_militarybot", param, viewer, 0, 0);
    case 75: return ccEffects.doCrowdControlEvent("spawnenemy_spiderbot2", param, viewer, 0, 0);
    case 76: return ccEffects.doCrowdControlEvent("spawnenemy_mj12commando", param, viewer, 0, 0);
    case 77: return ccEffects.doCrowdControlEvent("spawnenemy_securitybot4", param, viewer, 0, 0);
    case 78: return ccEffects.doCrowdControlEvent("spawnenemy_militarybot", param, viewer, 0, 0);
    case 79: return ccEffects.doCrowdControlEvent("spawnenemy_doberman", param, viewer, 0, 0);
    case 80: return ccEffects.doCrowdControlEvent("spawnenemy_greasel", param, viewer, 0, 0);
    case 81: return ccEffects.doCrowdControlEvent("nasty_rat", param, viewer, 0, 0);
    case 82: return ccEffects.doCrowdControlEvent("drop_piano", param, viewer, 0, 0);
    case 83: return ccEffects.doCrowdControlEvent("swap_enemies", param, viewer, 0, 0);
    case 84: return ccEffects.doCrowdControlEvent("swap_items", param, viewer, 0, 0);
    }

    return 0;
}

function bool isCrowdControl(string msg) {
    local string tmp;
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

function sendEffectVisibility(string effect, bool visible){
    local string resp;
    local byte respbyte[255];
    local int i;
    local int status;

    if (visible){
        status=cVISIBLE;
    } else {
        status=cNOTVISIBLE;
    }

    resp = "{\"id\":0,\"type\":1,\"status\":"$status$",\"code\":\""$effect$"\"}";

    for (i=0;i<Len(resp);i++){
        respbyte[i]=Asc(Mid(resp,i,1));
    }

    //PlayerMessage(resp);
    SendBinary(Len(resp)+1,respbyte);

}

function sendEffectSelectability(string effect, bool selectable){
    local string resp;
    local byte respbyte[255];
    local int i;
    local int status;

    if (selectable){
        status=cSELECTABLE;
    } else {
        status=cNOTSELECTABLE;
    }

    resp = "{\"id\":0,\"type\":1,\"status\":"$status$",\"code\":\""$effect$"\"}";

    for (i=0;i<Len(resp);i++){
        respbyte[i]=Asc(Mid(resp,i,1));
    }

    //PlayerMessage(resp);
    SendBinary(Len(resp)+1,respbyte);
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


function handleMessage(string msg) {

    local int id,type,duration;
    local string code,viewer;
    local string param[5];

    local int result;

    local Json jmsg;
    local int i;

    if (isCrowdControl(msg)) {
        //dxr.Player.ClientMessage(msg);
        jmsg = class'Json'.static.parse(Level, msg);
        code = jmsg.get("code");
        viewer = jmsg.get("viewer");
        id = int(jmsg.get("id"));
        type = int(jmsg.get("type"));
        duration = int(jmsg.get("duration")); //This comes through in milliseconds (If not present, this will give 0)
        duration = duration/MILLISEC_TO_SEC; //Make it be in seconds

        // maybe a little cleaner than using get_vals and having to worry about matching the array sizes?
        for(i=0; i<ArrayCount(param); i++) {
            param[i] = jmsg.get("parameters", i);
        }

        //Streamers may not want names to show up in game
        //so that they can avoid troll names, etc
        if (anon) {
            viewer = "Crowd Control";
        }
        result = ccEffects.doCrowdControlEvent(code,param,viewer,type,duration);

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
    effectsDisabled=False;
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


simulated final function #var(PlayerPawn) player()
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
    local Json j;

    SplitString("add_aug_aqualung", "_", words);
    m.teststring(words[0], "add", "SplitString");
    m.teststring(words[1], "aug", "SplitString");
    m.teststring(words[2], "aqualung", "SplitString");
    m.teststring(words[3], "", "SplitString");

    msg="";
    m.testbool( isCrowdControl(msg), false, "isCrowdControl "$msg);

    msg="{}";
    m.testbool( isCrowdControl(msg), false, "isCrowdControl "$msg);

    msg=" \"key\": \"value\" ";
    j = class'Json'.static.parse(Level, msg);
    m.teststring(j.get("key"), "", "did not parse invalid json");
    m.teststring(j.JsonStripSpaces(msg), "", "invalid json completely stripped");
    m.teststring(j.JsonStripSpaces(" { " $ msg), "", "invalid json completely stripped");
    m.teststring(j.JsonStripSpaces(msg $ " } "), "", "invalid json completely stripped");

    m.teststring(j.JsonStripSpaces(" { } "), "{}", "JsonStripSpaces");

    log("testing json parsing");
    msg="{\"key\": \"value\"}";
    j = class'Json'.static.parse(Level, msg);
    m.teststring(j.get("key"), "value", "parsed basic json value");

    log("testing json array parsing");
    msg="{\"key\": [\"value\", 2]}";
    j = class'Json'.static.parse(Level, msg);
    m.teststring(j.get("key", 1), "2", "parsed basic json array");

    msg=" { \"key\": \"value \\\"{}[]()\\\"\" } ";
    j = class'Json'.static.parse(Level, msg);
    m.teststring(j.get("key"), "value \"{}[]()\"", "did parse valid json");

    msg="{\"id\":3,\"code\":\"disable_jump\",\"targets\":[{\"id\":\"1234\",\"name\":\"dxrandotest\",\"avatar\":\"\"}],\"viewer\":\"dxrandotest\",\"type\":1}";
    m.testbool( isCrowdControl(msg), true, "isCrowdControl "$msg);
    _TestMsg(m,msg,3,1,"disable_jump","dxrandotest",params);

    // test multiple payloads, Crowd Control always puts a \0 between them so this isn't an issue, but still good to be safe
    msg=" {\"id\":3,\"code\":\"disable_jump\",\"viewer\":\"dxrandotest\",\"type\":1}{\"parameters\":[1,2,3],\"code\":\"testcode\"} ";
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

    TestMsg(m, 123, 1, "drop_grenade", "-(:die[4]ever{dm}:)-", params);

    //Need to do more work to validate escaped characters
    //TestMsg(m, 123, 1, "test\\\\with\\\\escaped\\\\backslashes", "die4ever", ""); //Note that we have to double escape so that the end result is a single escaped backslash

    msg = "{ \"testkeyname\": 1 ";
    for(i=0; i<90; i++) {
        msg = msg $ " , \"testlongkeyname-"$i$"\": [1,2,3,4,5,6,7,8,9] ";
    }
    msg = msg $ "}";
    log("TIME: start long json parses 90 arrays");
    for(i=0; i<3; i++)
        j = class'Json'.static.parse(Level, msg);
    log("TIME: end long json parses 90 arrays");


    msg = "{ \"testkeyname\": 1 ";
    for(i=0; i<90; i++) {
        msg = msg $ " , \"testlongkeyname-"$i$"\": [\"1\",\"2\",\"3\",\"4\",\"5\",\"6\",\"7\",\"8\",\"9\"] ";
    }
    msg = msg $ "}";
    log("TIME: start long json parses 90 arrays with quotes");
    for(i=0; i<3; i++)
        j = class'Json'.static.parse(Level, msg);
    log("TIME: end long json parses 90 arrays with quotes");


    msg = "{ \"test really long key name\": \"1\" ";
    for(i=0; Len(msg)<4000; i++) {
        msg = msg $ " , \"test long key name-"$i$"\": \"[1, 2, 3,4, 5, 6, 7, 8, 9]\" ";
        if(i>=99) m.test(false, "oops");
    }
    msg = msg $ "}";
    log("TIME: start long json parses strings");
    for(i=0; i<3; i++)
        j = class'Json'.static.parse(Level, msg);
    log("TIME: end long json parses strings");

    msg = "{ \"test really long key name\": \"1\" ";
    for(i=0; i<90; i++) {
        msg = msg $ " , \"test long key name-"$i$"\": \"[1, 2, 3,4, 5, 6, 7, 8, 9]\" ";
        if(i>=99) m.test(false, "oops");
    }
    msg = msg $ "}";
    log("TIME: start long json parses 90 strings");
    for(i=0; i<3; i++)
        j = class'Json'.static.parse(Level, msg);
    log("TIME: end long json parses 90 strings");
}


function int TestJsonField(DXRCrowdControl m, Json jmsg, string key, coerce string expected)
{
    local int len;
    m.test(jmsg.count() < jmsg.max_count(), "jmsg.count() < jmsg.max_count()");
    len = jmsg.get_vals_count(key);
    if(expected == "" && len == 0) {
        m.test(true, "TestJsonField "$key$" correctly missing");
    } else {
        m.test(len > 0, "je.valCount > 0");
        m.test(len < jmsg.max_values(), "je.valCount < ArrayCount(je.value)");
        m.teststring(jmsg.get(key, 0), expected, "TestJsonField " $ key);
    }
    return len;
}

function _TestMsg(DXRCrowdControl m, string msg, int id, int type, string code, string viewer, string params[5])
{
    local int p;
    local Json jmsg;

    m.testbool( isCrowdControl(msg), true, "isCrowdControl: "$msg);

    jmsg = class'Json'.static.parse(Level, msg);
    m.testint(TestJsonField(m, jmsg, "code", code), 1, "got 1 code");
    m.testint(TestJsonField(m, jmsg, "viewer", viewer), 1, "got 1 viewer");
    m.testint(TestJsonField(m, jmsg, "id", id), 1, "got 1 id");
    m.testint(TestJsonField(m, jmsg, "type", type), 1, "got 1 type");


    TestJsonField(m, jmsg, "parameters", params[0]);
    for(p=0; p<ArrayCount(params); p++) {
        m.teststring(jmsg.get("parameters", p), params[p], "param "$p);
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
    local string msg, params_string, targets;

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


