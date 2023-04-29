class DXRAlarmLight injects AlarmLight;

var bool kludged;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    if (Name=='AlarmLight0' && InStr(Caps(Level.GetLocalURL()),"99_ENDGAME4")!=-1){ //Only one light should do anything
        SetTimer(0.1,true);
    }
}

simulated function Timer()
{
    local DeusExPlayer p;
    if (!kludged){
        foreach AllActors(class'DeusExPlayer',p){
            break;
        }
        if (p!=None){ //Wait until the player is here
            SetTimer(0,false);
            kludged=True;
            SpawnDXRando(p);
        }
    }
}

function SpawnDXRando(DeusExPlayer player)
{
    local DeusExLevelInfo DeusExLevelInfo;
    local PlayerStart ps;

    class'DeusExLevelInfo'.default.MapName = "ENDGAME4";
    class'DeusExLevelInfo'.default.missionNumber = 99;
    class'DeusExLevelInfo'.default.Script = class'MissionEndgame';
    class'DeusExLevelInfo'.default.ConversationPackage="DeusExConversations";
    DeusExLevelInfo = Spawn(class'DeusExLevelInfo');

    //The initial call would have happened before the DXR spawned, so call it again
    player.ClientSetMusic(Level.Song,0,255,MTRAN_FastFade);

    log("SpawnDXRando() "$ self.name);
}
