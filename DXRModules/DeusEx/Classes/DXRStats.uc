class DXRStats extends DXRBase transient;

function AnyEntry()
{
    Super.AnyEntry();

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

    if (mission < 1) {
        return;
    }

    if (InGame()) {
        flagname = "DXRando_Mission"$mission$"_Timer";
        flag = StringToName(flagname);
        time = dxr.flagbase.GetInt(flag);
        dxr.flagbase.SetInt(flag,time+1,,999);
    } else {
        flagname = "DXRando_Mission"$mission$"Menu_Timer";
        flag = StringToName(flagname);
        time = dxr.flagbase.GetInt(flag);
        dxr.flagbase.SetInt(flag,time+1,,999);
    }

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

function int GetDataStorageStat(name valname)
{
    local DataStorage datastorage;
    datastorage = class'DataStorage'.static.GetObj(dxr);
    return int(datastorage.GetConfigKey(valname));
}

function AddDXRCredits(CreditsWindow cw)
{
    local int fired,swings,jumps,deaths,burnkills,gibbedkills;

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
    cw.PrintLn();

    fired = dxr.flagbase.GetInt('DXRStats_shotsfired');
    swings = dxr.flagbase.GetInt('DXRStats_weaponswings');
    jumps = dxr.flagbase.GetInt('DXRStats_jumps');
    burnkills = dxr.flagbase.GetInt('DXRStats_burnkills');
    gibbedkills = dxr.flagbase.GetInt('DXRStats_gibbedkills');
    deaths = GetDataStorageStat('DXRStats_deaths');

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
