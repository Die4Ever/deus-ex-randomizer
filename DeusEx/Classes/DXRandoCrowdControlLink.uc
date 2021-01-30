//=============================================================================
// DXRandoCrowdControlLink.
//=============================================================================
class DXRandoCrowdControlLink expands TcpLink;

var transient DXRando dxr;
var int ListenPort;
var IpAddr addr;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

function Init( DXRando tdxr)
{
    dxr = tdxr;
    
    Resolve("localhost");
}


function bool isCrowdControl( string msg) {
    //Validate if it looks json-like
    if (InStr(msg,"{")!=0){
        //dxr.Player.ClientMessage("Message doesn't start with curly");
        return False;
    }
    
    if (InStr(msg,"}")!=Len(msg)-1){
        //dxr.Player.ClientMessage("Message doesn't end with curly");
        return False;    
    }
    
    //Check to see if it looks like it has the right fields in it
    
    //id field
    if (InStr(msg,"id")==-1){
        return False;
    }
    
    //code field
    if (InStr(msg,"code")==-1){
        return False;
    }    
    //viewer field
    if (InStr(msg,"viewer")==-1){
        return False;
    }   
    //type field
    if (InStr(msg,"type")==-1){
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
    
    //dxr.Player.ClientMessage(resp);
    SendBinary(Len(resp)+1,respbyte);
}

function int doCrowdControlEvent(string code, string viewer, int type) {
    local vector v;
    local rotator r;
    v.X=0;
    v.Y=0;
    v.Z=0;
    r.Pitch = 0;
    r.Yaw = 0;
    r.Roll =0;
    
    if (code=="poison"){
        dxr.Player.StartPoison(dxr.Player,5);
    } else if (code == "kill"){
        dxr.Player.Died(dxr.Player,'CrowdControl',v);
    } else if (code == "drop_lam"){
        r.Yaw = 16000;
        Spawn(Class'LAM',,,dxr.Player.Location,r);
    }
    return Success;
}

function handleMessage( string msg) {
    local int loc1,loc2,length;
    local string tmpstr1,tmpstr2;
    
    local int id,type;
    local string code,viewer;
    
    local int result;

    if (isCrowdControl(msg)) {
        //Yolo
        //dxr.Player.ClientMessage("Looks pretty crowd control-y to me");
        
        //Find ID
        loc1 = InStr(msg,"id");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":");
        loc2= InStr(tmpstr1,",");
        length = loc2-loc1;
        tmpstr2 = Mid(tmpstr1,loc1+1,length);
        id = int(tmpstr2);
        dxr.Player.ClientMessage("Crowd Control ID = "$id);
        
        //Find Code
        loc1 = InStr(msg,"code");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":")+2;
        loc2= InStr(tmpstr1,",")-1;
        length = loc2-loc1;
        code = Mid(tmpstr1,loc1,length);
        dxr.Player.ClientMessage("Crowd Control Code = "$code);        
        
        //Find Viewer
        loc1 = InStr(msg,"viewer");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":")+2;
        loc2= InStr(tmpstr1,",")-1;
        length = loc2-loc1;
        viewer = Mid(tmpstr1,loc1,length);
        dxr.Player.ClientMessage("Crowd Control Viewer = "$viewer);

        //Find Type
        loc1 = InStr(msg,"type");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":");
        loc2= InStr(tmpstr1,"}");
        length = loc2-loc1;
        tmpstr2 = Mid(tmpstr1,loc1+1,length);
        type = int(tmpstr2);
        dxr.Player.ClientMessage("Crowd Control Type = "$type);     
        
        result = doCrowdControlEvent(code,viewer,type);
        
        sendReply(id,Success);   
        
    }

}

event ReceivedText ( string Text ) {
    //dxr.Player.ClientMessage(Text);
    handleMessage(Text);
}

event Opened(){
    dxr.Player.ClientMessage("Crowd Control connection opened");
}

event Closed(){
    dxr.Player.ClientMessage("Crowd Control connection closed");
}

event Destroyed(){
    Close();
    Super.Destroyed();
}

function Resolved( IpAddr Addr )
{
    //dxr.Player.ClientMessage("Resolved IP!");

    //dxr.Player.ClientMessage("Trying to open port");
    ListenPort=BindPort(0,False);
    if (ListenPort==0){
        dxr.Player.ClientMessage("Failed to bind port for Crowd Control");
    }
    Addr.port=43384;
    if (False==Open(Addr)){
        dxr.Player.ClientMessage("Could not connect to Crowd Control client");

    }
    LinkMode=MODE_Text;
}
function ResolveFailed()
{
    dxr.Player.ClientMessage("Could not resolve Crowd Control address");
}
