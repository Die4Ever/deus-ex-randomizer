class DXRStats extends DXRBase transient;

function AnyEntry()
{
    Super.AnyEntry();

    l("Total time so far: "$GetTotalTimeString()$", deaths so far: "$GetDataStorageStat(dxr, 'DXRStats_deaths'));

    SetTimer(0.1, True);
}

//Returns true when you aren't in a menu, or in the intro, etc.
function bool InGame() {
#ifdef hx
    return true;
#endif

    if( player() == None )
        return false;

    if (player().InConversation()) {
        return True;
    }

    if (None == DeusExRootWindow(player().rootWindow)) {
        return False;
    }

    if (None == DeusExRootWindow(player().rootWindow).hud) {
        return False;
    }

    if (!DeusExRootWindow(player().rootWindow).hud.isVisible()){
        return False;
    }

    return True;
}

function IncMissionTimer(int mission)
{
    local string flagname;
    local name flag;
    local int time;

    local DataStorage datastorage;


    if (mission < 1) {
        return;
    }

    datastorage = class'DataStorage'.static.GetObj(dxr);

    //Track both the "success path" time (via flags) and
    //the complete time (via datastorage)
    if (InGame()) {
        //Success Path
        flagname = "DXRando_Mission"$mission$"_Timer";
        flag = StringToName(flagname);
        time = dxr.flagbase.GetInt(flag);
        dxr.flagbase.SetInt(flag,time+1,,999);

        //Complete Time
        flagname = "DXRando_Mission"$mission$"_Complete_Timer";
        flag = StringToName(flagname);

        time = int(datastorage.GetConfigKey(flag));
        datastorage.SetConfig(flag, time+1, 3600*24*366);

    } else {
        //Success Path
        flagname = "DXRando_Mission"$mission$"Menu_Timer";
        flag = StringToName(flagname);
        time = dxr.flagbase.GetInt(flag);
        dxr.flagbase.SetInt(flag,time+1,,999);

        //Complete Time
        flagname = "DXRando_Mission"$mission$"_Complete_Menu_Timer";
        flag = StringToName(flagname);

        time = int(datastorage.GetConfigKey(flag));
        datastorage.SetConfig(flag, time+1, 3600*24*366);

    }
}

function int GetCompleteMissionTime(int mission)
{
    local string flagname;
    local name flag;
    local int time;
    local DataStorage datastorage;

    if (mission < 1) {
        return 0;
    }

    datastorage = class'DataStorage'.static.GetObj(dxr);

    flagname = "DXRando_Mission"$mission$"_Complete_Timer";
    flag = StringToName(flagname);
    time = int(datastorage.GetConfigKey(flag));

    return time;
}

function int GetMissionTime(int mission)
{
    local string flagname;
    local name flag;
    local int time;

    if (mission < 1) {
        return 0;
    }

    flagname = "DXRando_Mission"$mission$"_Timer";
    flag = StringToName(flagname);
    time = dxr.flagbase.GetInt(flag);

    return time;
}

function int GetCompleteMissionMenuTime(int mission)
{
    local string flagname;
    local name flag;
    local int time;
    local DataStorage datastorage;

    if (mission < 1) {
        return 0;
    }

    datastorage = class'DataStorage'.static.GetObj(dxr);

    flagname = "DXRando_Mission"$mission$"_Complete_Menu_Timer";
    flag = StringToName(flagname);
    time = int(datastorage.GetConfigKey(flag));

    return time;
}


function int GetMissionMenuTime(int mission)
{
    local string flagname;
    local name flag;
    local int time;

    if (mission < 1) {
        return 0;
    }

    flagname = "DXRando_Mission"$mission$"Menu_Timer";
    flag = StringToName(flagname);
    time = dxr.flagbase.GetInt(flag);

    return time;
}

function Timer()
{
    if( dxr == None ) return;
    //Increment timer flag
    IncMissionTimer(dxr.dxInfo.MissionNumber);

}

static function string fmtTimeToString(int time)
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

function string GetCompleteMissionTimeString(int mission)
{
    local int time;
    time = GetCompleteMissionTime(mission);
    return fmtTimeToString(time);
}

function string GetCompleteMissionMenuTimeString(int mission)
{
    local int time;
    time = GetCompleteMissionMenuTime(mission);
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

function String GetTotalCompleteTimeString()
{
    local int i, totaltime;

    for (i=1;i<=15;i++) {
        totaltime += GetCompleteMissionTime(i);
    }

    return fmtTimeToString(totaltime);

}

static function int GetTotalTime(DXRando dxr)
{
    local int i, totaltime;
    local string flagname;
    local name flag;
    local int time;

    for (i=1;i<=15;i++) {
        flagname = "DXRando_Mission"$i$"_Timer";
        flag = dxr.StringToName(flagname);
        time = dxr.flagbase.GetInt(flag);
        totaltime += time;
    }

    return totaltime;
}

function String GetTotalMenuTimeString()
{
    local int i, totaltime;

    for (i=1;i<=15;i++) {
        totaltime += GetMissionMenuTime(i);
    }

    return fmtTimeToString(totaltime);

}

function String GetTotalCompleteMenuTimeString()
{
    local int i, totaltime;

    for (i=1;i<=15;i++) {
        totaltime += GetCompleteMissionMenuTime(i);
    }

    return fmtTimeToString(totaltime);

}
static function int GetTotalMenuTime(DXRando dxr)
{
    local int i, totaltime;
    local string flagname;
    local name flag;
    local int time;

    for (i=1;i<=15;i++) {
        flagname = "DXRando_Mission"$i$"_Menu_Timer";
        flag = dxr.StringToName(flagname);
        time = dxr.flagbase.GetInt(flag);
        totaltime += time;
    }

    return totaltime;
}


static function IncStatFlag(DeusExPlayer p, name flagname)
{
    local int val;
    val = p.FlagBase.GetInt(flagname);
    p.FlagBase.SetInt(flagname,val+1,,999);

}

static function IncDataStorageStat(DeusExPlayer p, name valname)
{
    local DataStorage datastorage;
    local int val;
    datastorage = class'DataStorage'.static.GetObjFromPlayer(p);
    val = int(datastorage.GetConfigKey(valname));
    datastorage.SetConfig(valname, val+1, 3600*24*366);

}

static function AddShotFired(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_shotsfired');
}
static function AddWeaponSwing(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_weaponswings');
}
static function AddJump(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_jumps');
}
static function AddDeath(DeusExPlayer p)
{
    IncDataStorageStat(p,'DXRStats_deaths');
}

static function AddBurnKill(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_burnkills');
}

static function AddGibbedKill(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_gibbedkills');
}

static function int GetDataStorageStat(DXRando dxr, name valname)
{
    local DataStorage datastorage;
    datastorage = class'DataStorage'.static.GetObj(dxr);
    return int(datastorage.GetConfigKey(valname));
}

function AddDXRCredits(CreditsWindow cw)
{
    local int fired,swings,jumps,deaths,burnkills,gibbedkills;

    cw.PrintHeader("In-Game Time (Total Time)");

    cw.PrintText("1 - Liberty Island:"@GetMissionTimeString(1)@"("$GetCompleteMissionTimeString(1)$")");
    cw.PrintText("2 - NYC Generator:"@GetMissionTimeString(2)@"("$GetCompleteMissionTimeString(2)$")");
    cw.PrintText("3 - Airfield:"@GetMissionTimeString(3)@"("$GetCompleteMissionTimeString(3)$")");
    cw.PrintText("4 - NSF HQ:"@GetMissionTimeString(4)@"("$GetCompleteMissionTimeString(4)$")");
    cw.PrintText("5 - UNATCO MJ12 Base:"@GetMissionTimeString(5)@"("$GetCompleteMissionTimeString(5)$")");
    cw.PrintText("6 - Hong Kong:"@GetMissionTimeString(6)@"("$GetCompleteMissionTimeString(6)$")");
    cw.PrintText("8 - Return to NYC:"@GetMissionTimeString(8)@"("$GetCompleteMissionTimeString(8)$")");
    cw.PrintText("9 - Superfreighter:"@GetMissionTimeString(9)@"("$GetCompleteMissionTimeString(9)$")");
    cw.PrintText("10 - Paris Streets:"@GetMissionTimeString(10)@"("$GetCompleteMissionTimeString(10)$")");
    cw.PrintText("11 - Cathedral:"@GetMissionTimeString(11)@"("$GetCompleteMissionTimeString(11)$")");
    cw.PrintText("12 - Vandenberg:"@GetMissionTimeString(12)@"("$GetCompleteMissionTimeString(12)$")");
    cw.PrintText("14 - Ocean Lab:"@GetMissionTimeString(14)@"("$GetCompleteMissionTimeString(14)$")");
    cw.PrintText("15 - Area 51:"@GetMissionTimeString(15)@"("$GetCompleteMissionTimeString(15)$")");
    cw.PrintText("Total:"@GetTotalTimeString()@"("$GetTotalCompleteTimeString()$")");
    //cw.PrintText("Time in Menu:"@GetTotalMenuTimeString()@"("$GetTotalCompleteMenuTimeString()$")");
    cw.PrintLn();

    fired = dxr.flagbase.GetInt('DXRStats_shotsfired');
    swings = dxr.flagbase.GetInt('DXRStats_weaponswings');
    jumps = dxr.flagbase.GetInt('DXRStats_jumps');
    burnkills = dxr.flagbase.GetInt('DXRStats_burnkills');
    gibbedkills = dxr.flagbase.GetInt('DXRStats_gibbedkills');
    deaths = GetDataStorageStat(dxr, 'DXRStats_deaths');

    cw.PrintHeader("Statistics");

    cw.PrintText("Shots Fired: "$fired);
    cw.PrintText("Weapon Swings: "$swings);
    cw.PrintText("Jumps: "$jumps);
    cw.PrintText("Nano Keys: "$player().KeyRing.GetKeyCount());
    cw.PrintText("Skill Points Earned: "$player().SkillPointsTotal);
    cw.PrintText("Enemies Burned to Death: "$burnkills);
    cw.PrintText("Enemies Gibbed: "$gibbedkills);
    cw.PrintText("Deaths: "$deaths);

    cw.PrintLn();
}

defaultproperties
{
     bAlwaysTick=True
}
