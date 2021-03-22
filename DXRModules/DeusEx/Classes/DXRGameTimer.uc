class DXRGameTimer extends DXRBase;

var name NameConversion;

function AnyEntry()
{
    Super.AnyEntry();
    
    SetTimer(0.1, True);
}

//Returns true when you aren't in a menu, or in the intro, etc.
function bool InGame() {

    if (dxr.Player.InConversation()) {
        return True;
    }

    if (None == DeusExRootWindow(dxr.Player.rootWindow)) {
        return False;
    }
    
    if (None == DeusExRootWindow(dxr.Player.rootWindow).hud) {
        return False;
    }
    
    if (!DeusExRootWindow(dxr.Player.rootWindow).hud.isVisible()){
        return False;
    }
    
    return True;
}

function IncMissionTimer(int mission)
{
    local string flagname;
    local int time;
    
    if (mission < 1) {
        return;
    }
    
    if (InGame()) {
        flagname = "DXRando_Mission"$mission$"_Timer";
        SetPropertyText("NameConversion",flagname); //Kludge for logic simplification
        time = dxr.Player.FlagBase.GetInt(NameConversion);
        dxr.Player.FlagBase.SetInt(NameConversion,time+1,,999);
    } else {
        flagname = "DXRando_Mission"$mission$"Menu_Timer";
        SetPropertyText("NameConversion",flagname); //Kludge for logic simplification
        time = dxr.Player.FlagBase.GetInt(NameConversion);
        dxr.Player.FlagBase.SetInt(NameConversion,time+1,,999);
    
    }
     
    
}

function int GetMissionTime(int mission)
{
    local string flagname;
    local int time;
    
    if (mission < 1) {
        return 0;
    }
    
    flagname = "DXRando_Mission"$mission$"_Timer";
    SetPropertyText("NameConversion",flagname); //Kludge for logic simplification
    time = dxr.Player.FlagBase.GetInt(NameConversion);
    
    return time;
}

function int GetMissionMenuTime(int mission)
{
    local string flagname;
    local int time;
    
    if (mission < 1) {
        return 0;
    }
    
    flagname = "DXRando_Mission"$mission$"Menu_Timer";
    SetPropertyText("NameConversion",flagname); //Kludge for logic simplification
    time = dxr.Player.FlagBase.GetInt(NameConversion);
    
    return time;
}

function Timer()
{
    //Increment timer flag
    IncMissionTimer(dxr.dxInfo.MissionNumber);

}

function string fmtTimeToString(int time)
{
    local int hours,minutes,seconds,tenths,remain;
    local string timestr;
    
    tenths = time % 10;
    remain = (time - tenths)/10;
    seconds = remain % 60;
    
    remain = (remain - seconds)/60;
    minutes = remain % 60;
    
    hours = (remain - minutes)/60;
    
    if (hours < 10) {
        timestr="0";
    }
    timestr=timestr$hours$":";
    
    if (minutes < 10) {
        timestr=timestr$"0";
    }
    timestr=timestr$minutes$":";

    if (seconds < 10) {
        timestr=timestr$"0";
    }
    timestr=timestr$seconds$"."$tenths;
    
    return timestr;
}

function string GetMissionTimeString(int mission)
{
    local int time;
    time = GetMissionTime(mission);
    return fmtTimeToString(time);
}

function string GetMissionMenuTimeString(int mission)
{
    local int time;
    time = GetMissionMenuTime(mission);
    return fmtTimeToString(time);
}

function String GetTotalTimeString()
{
    local int i, totaltime;
    
    for (i=1;i<=15;i++) {
        totaltime += GetMissionTime(i);
    }
    
    return fmtTimeToString(totaltime);
    
}

function AddDXRCredits(CreditsWindow cw) 
{  
    cw.PrintHeader("In-Game Time");
    
    cw.PrintText("1 - Liberty Island:"@GetMissionTimeString(1));
    cw.PrintText("2 - NYC Generator:"@GetMissionTimeString(2));
    cw.PrintText("3 - Airfield:"@GetMissionTimeString(3));
    cw.PrintText("4 - NSF HQ:"@GetMissionTimeString(4));
    cw.PrintText("5 - UNATCO MJ12 Base:"@GetMissionTimeString(5));
    cw.PrintText("6 - Hong Kong:"@GetMissionTimeString(6));
    cw.PrintText("8 - Return to NYC:"@GetMissionTimeString(8));
    cw.PrintText("9 - Superfreighter:"@GetMissionTimeString(9));
    cw.PrintText("10 - Paris Streets:"@GetMissionTimeString(10));
    cw.PrintText("11 - Cathedral:"@GetMissionTimeString(11));
    cw.PrintText("12 - Vandenberg:"@GetMissionTimeString(12));
    cw.PrintText("14 - Ocean Lab:"@GetMissionTimeString(14));
    cw.PrintText("15 - Area 51:"@GetMissionTimeString(15));
    cw.PrintText("Total:"@GetTotalTimeString());

}

defaultproperties
{
     bAlwaysTick=True
}