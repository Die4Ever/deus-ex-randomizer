class DXRStats extends DXRBase transient;

function AnyEntry()
{
    Super.AnyEntry();

    l("Total time so far: "$GetTotalTimeString()$", deaths so far: "$GetDataStorageStat(dxr, "DXRStats_deaths"));

    SetTimer(0.1, True);
}

simulated function ReEntry(bool IsTravel)
{
    Super.ReEntry(IsTravel);
    if(!IsTravel) {
        IncDataStorageStat(player(),"DXRStats_loads");
    }
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
    local string flagname, dataname;
    local name flag;
    local int time, ftime;

    local DataStorage datastorage;

    if (mission < 1) {
        return;
    }

    datastorage = class'DataStorage'.static.GetObj(dxr);

    //Track both the "success path" time (via flags) and
    //the complete time (via datastorage)
    if (InGame()) {
        flagname = "DXRando_Mission"$mission$"_Timer";
        dataname = "DXRando_Mission"$mission$"_Complete_Timer";
    } else {
        flagname = "DXRando_Mission"$mission$"Menu_Timer";
        dataname = "DXRando_Mission"$mission$"_Complete_Menu_Timer";
    }

    flag = StringToName(flagname);
    ftime = dxr.flagbase.GetInt(flag);
    dxr.flagbase.SetInt(flag,ftime+1,,999);

    time = int(datastorage.GetConfigKey(dataname));
    time = Max(time, ftime);
    datastorage.SetConfig(dataname, time+1, 3600*24*366);
}

function int GetCompleteMissionTime(int mission)
{
    local string flagname;
    local int time;
    local DataStorage datastorage;

    if (mission < 1) {
        return 0;
    }

    datastorage = class'DataStorage'.static.GetObj(dxr);

    flagname = "DXRando_Mission"$mission$"_Complete_Timer";
    time = int(datastorage.GetConfigKey(flagname));

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
    local int time;
    local DataStorage datastorage;

    if (mission < 1) {
        return 0;
    }

    datastorage = class'DataStorage'.static.GetObj(dxr);

    flagname = "DXRando_Mission"$mission$"_Complete_Menu_Timer";
    time = int(datastorage.GetConfigKey(flagname));

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

function string GetCompleteMissionTimeWithMenusString(int mission)
{
    local int time;
    time = GetCompleteMissionTime(mission);
    time += GetCompleteMissionMenuTime(mission);
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
    local int time;
    time = GetTotalMenuTime(dxr);
    return fmtTimeToString(time);
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
        flagname = "DXRando_Mission"$i$"Menu_Timer";
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

static function IncDataStorageStat(DeusExPlayer p, string valname)
{
    local DataStorage datastorage;
    local int val;
    datastorage = class'DataStorage'.static.GetObjFromPlayer(p);
    val = int(datastorage.GetConfigKey(valname));
    datastorage.SetConfig(valname, val+1, 3600*24*366);
    datastorage.Flush();
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
    IncDataStorageStat(p,"DXRStats_deaths");
}

static function AddBurnKill(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_burnkills');
}

static function AddGibbedKill(DeusExPlayer p)
{
    IncStatFlag(p,'DXRStats_gibbedkills');
}

static function int GetDataStorageStat(DXRando dxr, string valname)
{
    local DataStorage datastorage;
    datastorage = class'DataStorage'.static.GetObj(dxr);
    return int(datastorage.GetConfigKey(valname));
}

function String FormatCreditsTimeStrings(String missionNum, String missionName, String missionTime, String completeTime)
{
    local String s;
    local int i;

    s = "";
    s = s $ missionNum;

    if (Len(missionNum)<2) {
        s=s $ " ";
    }

    s = s $ " " $ missionName $ ":";

    //Pad to mission time offset
    for (i=Len(s); i < 25 ; i++){
        s = s $ " ";
    }

    s = s $ missionTime;

    //Pad to complete mission time offset
    for (i=Len(s); i < 55 ; i++){
        s = s $ " ";
    }

    s = s $ completeTime;

    //l("Formatted line for credits: "$s$"   length is "$Len(s));

    return s;

}

function AddMissionTimeTable(CreditsWindow cw)
{
    local CreditsTimerWindow ctw;
    local int i, totalTime, totalRealTime;

    ctw = CreditsTimerWindow(cw.winScroll.NewChild(Class'CreditsTimerWindow'));
    ctw.SetSize(450,450);

    ctw.AddMissionTime("1","Liberty Island",GetMissionTimeString(1),GetCompleteMissionTimeWithMenusString(1));
    ctw.AddMissionTime("2","NYC Generator",GetMissionTimeString(2),GetCompleteMissionTimeWithMenusString(2));
    ctw.AddMissionTime("3","Airfield",GetMissionTimeString(3),GetCompleteMissionTimeWithMenusString(3));
    ctw.AddMissionTime("4","NSF HQ",GetMissionTimeString(4),GetCompleteMissionTimeWithMenusString(4));
    ctw.AddMissionTime("5","UNATCO MJ12 Base",GetMissionTimeString(5),GetCompleteMissionTimeWithMenusString(5));
    ctw.AddMissionTime("6","Hong Kong",GetMissionTimeString(6),GetCompleteMissionTimeWithMenusString(6));
    ctw.AddMissionTime("8","Return to NYC",GetMissionTimeString(8),GetCompleteMissionTimeWithMenusString(8));
    ctw.AddMissionTime("9","Superfreighter",GetMissionTimeString(9),GetCompleteMissionTimeWithMenusString(9));
    ctw.AddMissionTime("10","Paris Streets",GetMissionTimeString(10),GetCompleteMissionTimeWithMenusString(10));
    ctw.AddMissionTime("11","Cathedral",GetMissionTimeString(11),GetCompleteMissionTimeWithMenusString(11));
    ctw.AddMissionTime("12","Vandenberg",GetMissionTimeString(12),GetCompleteMissionTimeWithMenusString(12));
    ctw.AddMissionTime("14","Ocean Lab",GetMissionTimeString(14),GetCompleteMissionTimeWithMenusString(14));
    ctw.AddMissionTime("15","Area 51",GetMissionTimeString(15),GetCompleteMissionTimeWithMenusString(15));
    ctw.AddMissionTime("----","--------------","-------------","-------------");
    ctw.AddMissionTime(" ","Total Without Menus",GetTotalTimeString(),GetTotalCompleteTimeString());
    ctw.AddMissionTime(" ","Total Menu Time",GetTotalMenuTimeString(),GetTotalCompleteMenuTimeString());

    totalTime = GetTotalTime(dxr)+GetTotalMenuTime(dxr);
    totalRealTime = 0;
    for (i=1;i<=15;i++) {
        totalRealTime += GetCompleteMissionTime(i);
        totalRealTime += GetCompleteMissionMenuTime(i);
    }
    ctw.AddMissionTime(" ","Total With Menus",fmtTimeToString(totalTime),fmtTimeToString(totalRealTime));
}

function AddDXRCredits(CreditsWindow cw)
{
    local int fired,swings,jumps,deaths,burnkills,gibbedkills,saves,autosaves,loads;

    cw.PrintLn();

    AddMissionTimeTable(cw);

    cw.PrintLn();

    fired = dxr.flagbase.GetInt('DXRStats_shotsfired');
    swings = dxr.flagbase.GetInt('DXRStats_weaponswings');
    jumps = dxr.flagbase.GetInt('DXRStats_jumps');
    burnkills = dxr.flagbase.GetInt('DXRStats_burnkills');
    gibbedkills = dxr.flagbase.GetInt('DXRStats_gibbedkills');
    deaths = GetDataStorageStat(dxr, "DXRStats_deaths");
    saves = player().saveCount;
    autosaves = GetDataStorageStat(dxr, "DXRStats_autosaves");
    loads = GetDataStorageStat(dxr, "DXRStats_loads");

    cw.PrintHeader("Statistics");

    cw.PrintText("Shots Fired: "$fired);
    cw.PrintText("Weapon Swings: "$swings);
    cw.PrintText("Jumps: "$jumps);
    cw.PrintText("Nano Keys: "$player().KeyRing.GetKeyCount());
    cw.PrintText("Skill Points Earned: "$player().SkillPointsTotal);

    cw.PrintText("Enemies Burned to Death: "$burnkills);
    cw.PrintText("Enemies Gibbed: "$gibbedkills);
    cw.PrintText("Deaths: "$deaths);
    cw.PrintText("Saves: "$saves$" ("$autosaves$" Autosaves)");
    cw.PrintText("Loads: "$loads);

    cw.PrintLn();
}

function ExtendedTests()
{
    local int time, completeTime, menutime, completemenutime;

    Super.ExtendedTests();

    // mission 1 tests
    testint( GetMissionTime(1), 0, "GetMissionTime(1) == 0");
    testint( GetCompleteMissionTime(1), 0, "GetCompleteMissionTime(1) == 0");
    testint( GetMissionMenuTime(1), 0, "GetMissionMenuTime(1) == 0");
    testint( GetCompleteMissionMenuTime(1), 0, "GetCompleteMissionMenuTime(1) == 0");

    IncMissionTimer(1);

    testint( GetMissionTime(1), 1, "GetMissionTime(1) == 1");
    testint( GetCompleteMissionTime(1), 1, "GetCompleteMissionTime(1) == 1");
    testint( GetMissionMenuTime(1), 0, "GetMissionMenuTime(1) == 0");
    testint( GetCompleteMissionMenuTime(1), 0, "GetCompleteMissionMenuTime(1) == 0");

    DeusExRootWindow(player().rootWindow).hud.Hide();
    IncMissionTimer(1);
    DeusExRootWindow(player().rootWindow).hud.Show();

    testint( GetMissionTime(1), 1, "GetMissionTime(1) == 1");
    testint( GetCompleteMissionTime(1), 1, "GetCompleteMissionTime(1) == 1");
    testint( GetMissionMenuTime(1), 1, "GetMissionMenuTime(1) == 1");
    testint( GetCompleteMissionMenuTime(1), 1, "GetCompleteMissionMenuTime(1) == 1");

    teststring( GetMissionTimeString(1), "00:00:00.1", "GetMissionTimeString(1)");
    teststring( GetCompleteMissionTimeWithMenusString(1), "00:00:00.2", "GetCompleteMissionTimeWithMenusString(1)");

    // reset non-real-time timers
    dxr.flagbase.SetInt('DXRando_Mission1_Timer',0,,999);
    dxr.flagbase.SetInt('DXRando_Mission1Menu_Timer',0,,999);

    // mission 1 tests again
    testint( GetMissionTime(1), 0, "GetMissionTime(1) == 0");
    testint( GetCompleteMissionTime(1), 1, "GetCompleteMissionTime(1) == 1");
    testint( GetMissionMenuTime(1), 0, "GetMissionMenuTime(1) == 0");
    testint( GetCompleteMissionMenuTime(1), 1, "GetCompleteMissionMenuTime(1) == 1");

    IncMissionTimer(1);

    testint( GetMissionTime(1), 1, "GetMissionTime(1) == 1");
    testint( GetCompleteMissionTime(1), 2, "GetCompleteMissionTime(1) == 2");
    testint( GetMissionMenuTime(1), 0, "GetMissionMenuTime(1) == 0");
    testint( GetCompleteMissionMenuTime(1), 1, "GetCompleteMissionMenuTime(1) == 1");

    DeusExRootWindow(player().rootWindow).hud.Hide();
    IncMissionTimer(1);
    DeusExRootWindow(player().rootWindow).hud.Show();

    testint( GetMissionTime(1), 1, "GetMissionTime(1) == 1");
    testint( GetCompleteMissionTime(1), 2, "GetCompleteMissionTime(1) == 2");
    testint( GetMissionMenuTime(1), 1, "GetMissionMenuTime(1) == 1");
    testint( GetCompleteMissionMenuTime(1), 2, "GetCompleteMissionMenuTime(1) == 2");

    teststring( GetMissionTimeString(1), "00:00:00.1", "GetMissionTimeString(1)");
    teststring( GetCompleteMissionTimeWithMenusString(1), "00:00:00.4", "GetCompleteMissionTimeWithMenusString(1)");

    // mission 12 tests
    testint( dxr.dxInfo.MissionNumber, 12, "current mission is 12 as expected");

    time = GetMissionTime(12);
    completeTime = GetCompleteMissionTime(12);
    menuTime = GetMissionMenuTime(12);
    completemenutime = GetCompleteMissionMenuTime(12);

    test( time > 0, "GetMissionTime(12) > 0");
    test( completeTime > 0, "GetCompleteMissionTime(12) > 0");
    testint( menuTime, 0, "GetMissionMenuTime(12) == 0");
    testint( completemenutime, 0, "GetCompleteMissionMenuTime(12) == 0");

    Timer();

    testint( GetMissionTime(12), time + 1, "GetMissionTime(12) == time + 1");
    testint( GetCompleteMissionTime(12), completeTime + 1, "GetCompleteMissionTime(12) == completeTime + 1");
    testint( GetMissionMenuTime(12), 0, "GetMissionMenuTime(12) == 0");
    testint( GetCompleteMissionMenuTime(12), 0, "GetCompleteMissionMenuTime(12) == 0");

    DeusExRootWindow(player().rootWindow).hud.Hide();
    Timer();
    DeusExRootWindow(player().rootWindow).hud.Show();

    testint( GetMissionTime(12), time + 1, "GetMissionTime(12) == time + 1");
    testint( GetCompleteMissionTime(12), completeTime + 1, "GetCompleteMissionTime(12) == completeTime + 1");
    testint( GetMissionMenuTime(12), 1, "GetMissionMenuTime(12) == 1");
    testint( GetCompleteMissionMenuTime(12), 1, "GetCompleteMissionMenuTime(12) == 1");

    // ensure correct key names
    test( GetTotalTime(dxr) > 0, "GetTotalTime");
    test( GetTotalMenuTime(dxr) > 0, "GetTotalMenuTime");

    TestScoring();
}

static function int ScoreRun(int time, int time_without_menus, float difficulty, int saves, int loads, int bingos, int bingospots, int SkillPointsTotal, int Nanokeys)
{
    local int i;
    i = 100000;
    i -= time;
    i -= time_without_menus;
    i += difficulty * 1000.0;
    // TODO: also need to score randomizer difficulty separately from combat difficulty, especially for VMD
    i -= saves * 50;
    i -= loads * 50;
    i += bingos * 500;
    i += bingospots * 50;// make sure to ignore the free space
    i += SkillPointsTotal / 2;
    i += Nanokeys * 20;
    return i;
}

function TestScores(int better, int worse, int testnum)
{
    l("TestScores "$testnum @ better $" > "$ worse);// so you can see it in UCC.log even if it passes
    test( better > worse, "TestScores "$testnum @ better $" > "$ worse);
}

function TestScoring()
{
    local int better, worse, testnum;
    better = ScoreRun(7200, 3600, 2, 5, 5, 12, 24, 10000, 200);// slower but way less saves/loads, and did more
    worse = ScoreRun(3600, 3000, 2, 100, 100, 3, 12, 10000, 20);
    TestScores(better, worse, ++testnum);

    better = ScoreRun(3600, 3000, 2, 100, 100, 3, 12, 10000, 50);
    worse = ScoreRun(10800, 9001, 2, 50, 50, 10, 20, 10000, 100);// too much slower to be better
    TestScores(better, worse, ++testnum);
}

defaultproperties
{
     bAlwaysTick=True
}
