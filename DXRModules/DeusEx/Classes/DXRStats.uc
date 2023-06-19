class DXRStats extends DXRBase transient;

struct RunInfo
{
    var string name;
    var int score;
    var int time;
    var int seed;
    var string flagshash;
    var bool bSetSeed;
    var string place;// string because it can be "--"
    var string playthrough_id;
};

var RunInfo runs[20];

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


static function IncStatFlag(DeusExPlayer p, name flagname, optional int add)
{
    local int val;

    val = p.FlagBase.GetInt(flagname);
    if(add == 0)//optional
        add=1;
    p.FlagBase.SetInt(flagname, val+add, , 999);
}

static function IncDataStorageStat(DeusExPlayer p, string valname, optional int add)
{
    local DataStorage datastorage;
    local int val;
    if(add == 0)//optional
        add=1;
    datastorage = class'DataStorage'.static.GetObjFromPlayer(p);
    val = int(datastorage.GetConfigKey(valname));
    datastorage.SetConfig(valname, val + add, 3600*24*366);
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

static function AddCheatOffense(DeusExPlayer p, optional int add)
{
    IncStatFlag(p,'DXRStats_cheats', add);
}
static function AddSpoilerOffense(DeusExPlayer p, optional int add)
{
    IncDataStorageStat(p,"DXRStats_spoilers", add);
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

function QueryLeaderboard()
{
    local string j;
    local class<Json> js;
    js = class'Json';
    j = js.static.Start("QueryLeaderboard");
    js.static.Add(j, "seed", dxr.flags.seed);
    js.static.Add(j, "flagshash", dxr.flags.FlagsHash());
    js.static.Add(j, "bSetSeed", dxr.flags.bSetSeed);
    js.static.Add(j, "PlayerName", class'DXRActorsBase'.static.GetActorName(dxr.player));
    js.static.End(j);

    l("QueryLeaderboard(): "$j);
    class'DXRTelemetry'.static.SendEvent(dxr, self, j);
}

function ReceivedLeaderboard(Json j)
{
    local int i;
    local string vals[10];

    l("ReceivedLeaderboard");

    for(i=0; i<15; i++) {
        vals[0] = "";
        j.get_vals("leaderboard-"$i, vals);
        if(vals[0] == "") return;
        runs[i].name = Left(vals[0], 22);
        runs[i].score = int(vals[1]);
        runs[i].time = int(vals[2]);
        runs[i].seed = int(vals[3]);
        runs[i].flagshash = ToHex(int(vals[4]));
        runs[i].bSetSeed = bool(vals[5]);
        runs[i].place = vals[6];
        runs[i].playthrough_id = Caps(vals[7]);
    }
}

function DrawLeaderboard(GC gc)
{
    local string playthrough_id;
    local int yPos, i;

    playthrough_id = ToHex(dxr.flags.playthrough_id);
    gc.SetFont(Font'DeusExUI.FontConversationLarge');
    for(i=0; i<ArrayCount(runs) && runs[i].name!=""; i++){
        yPos = (i+1) * 25;
        if(runs[i].playthrough_id ~= playthrough_id) {
            gc.DrawBox(0, yPos, 650, 25, 0, 0, 1, Texture'Solid');
        }
        gc.DrawText(2,yPos,30,50, "#"$runs[i].place$".");
        gc.DrawText(30,yPos,200,50, runs[i].name);
        gc.DrawText(250,yPos,100,50, IntCommas(runs[i].score));
        gc.DrawText(350,yPos,100,50, fmtTimeToString(runs[i].time));
        gc.DrawText(450,yPos,100,50, runs[i].flagshash);
        gc.DrawText(550,yPos,100,50, runs[i].playthrough_id);
    }
}

static function CheckLeaderboard(DXRando dxr, Json j)
{
    local DXRStats stats;
    if(j.get("leaderboard-0") == "") {
        return;
    }

    stats = DXRStats(dxr.FindModule(class'DXRStats'));
    if(stats != None)
        stats.ReceivedLeaderboard(j);
}

function AddDXRCredits(CreditsWindow cw)
{
    local int fired,swings,jumps,deaths,burnkills,gibbedkills,saves,autosaves,loads;
    local CreditsLeaderboardWindow leaderboard;

    cw.PrintLn();

    if(dxr.telemetry != None && dxr.telemetry.enabled) {
        QueryLeaderboard();
        leaderboard = CreditsLeaderboardWindow(cw.winScroll.NewChild(Class'CreditsLeaderboardWindow'));
        leaderboard.InitStats(self);
        cw.PrintLn();
    }

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

    if(dxr.dxInfo.missionNumber == 99)
        cw.PrintHeader("Score: " $ IntCommas(ScoreRun()));
    cw.PrintText("Flagshash: " $ ToHex(dxr.flags.FlagsHash()));
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

function int ScoreRun()
{
    local PlayerDataItem data;
    local string event, desc;
    local int x, y, progress, max, bingos, bingo_spots, cheats, flags_score;
    local int time, time_without_menus, i, loads, keys, score;
    local #var(PlayerPawn) p;
    p = player();
    for (i=1;i<=15;i++) {
        time_without_menus += GetCompleteMissionTime(i);
        time += GetCompleteMissionMenuTime(i);
    }
    time += time_without_menus;

    data = class'PlayerDataItem'.static.GiveItem(dxr.player);
    bingos = data.NumberOfBingos();

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            data.GetBingoSpot(x, y, event, desc, progress, max);
            if(progress >= max && event != "Free Space")
                bingo_spots++;
        }
    }

    loads = GetDataStorageStat(dxr, "DXRStats_loads");
    keys = p.KeyRing.GetKeyCount();
    cheats = p.FlagBase.GetInt('DXRStats_cheats');
    cheats += GetDataStorageStat(dxr, "DXRStats_spoilers");
    flags_score = dxr.flags.ScoreFlags();

    score = _ScoreRun(time, time_without_menus, p.CombatDifficulty, flags_score, p.saveCount, loads, dxr.flags.settings.bingo_win, bingos, bingo_spots, p.SkillPointsTotal, keys, cheats);
    info("_ScoreRun(" $ time @ time_without_menus @ p.CombatDifficulty @ flags_score @ p.saveCount @ loads @ dxr.flags.settings.bingo_win @ bingos @ bingo_spots @ p.SkillPointsTotal @ keys @ cheats $ "): "$score);
    return score;
}

static function int _ScoreRun(int time, int time_without_menus, float CombatDifficulty, int flags_score, int saves, int loads,
    int bingo_win, int bingos, int bingospots, int SkillPointsTotal, int Nanokeys, int cheats)
{
    local int i;
    i = 100000;
    i -= time / 10;// times are in tenths of a second
    i -= time_without_menus / 10;
    i += FClamp(CombatDifficulty, 0, 8) * 1000.0;
    i += flags_score;
    i -= saves * 10;
    i -= loads * 50;
    if(bingo_win > 0 && bingos >= bingo_win)
        i -= (13-bingo_win) * 5000;
    i += bingos * 500;
    i += bingospots * 150;// make sure to ignore the free space
    i += SkillPointsTotal;
    i += Nanokeys * 20;// unique nanokeys
    i -= Clamp(cheats, 0, 100) * 300;
    return i;
}

function TestScoring()
{
    local int scores[32];
    local string names[32];
    local string testname;
    local int num, i;
    local float combat_difficulty;
    local int time, time_without_menus, rando_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats;

    dxr.flags.SetDifficulty(1);
    testint(dxr.flags.ScoreFlags(), 3705, "score bonus for Normal");

    dxr.flags.SetDifficulty(2);
    testint(dxr.flags.ScoreFlags(), 7685, "score bonus for Hard");

    dxr.flags.SetDifficulty(3);
    testint(dxr.flags.ScoreFlags(), 9450, "score bonus for Extreme");

    dxr.flags.SetDifficulty(4);
    testint(dxr.flags.ScoreFlags(), 11985, "score bonus for Impossible");

    names[num] = "1 Million Points!";
    scores[num++] = 1000000;

    names[num] = "130k Points";
    scores[num++] = 130000;

    names[num] = "literal god: 1 hour, Impossible difficulty, full bingo, 5 saves, 5 loads";
    time=72000; time_without_menus=36000; combat_difficulty=3; rando_difficulty=4; saves=5; loads=5;
    bingo_win=0; bingos=12; bingo_spots=24; skill_points=10000; nanokeys=200; cheats=0;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "literal god: 1 hour, full bingo, 5 saves, 5 loads";
    time=72000; time_without_menus=36000; combat_difficulty=2; rando_difficulty=2; saves=5; loads=5;
    bingo_win=0; bingos=12; bingo_spots=24; skill_points=10000; nanokeys=200; cheats=0;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "120k Points";
    scores[num++] = 120000;

    names[num] = "1 hour, 3 bingos, 5 saves, 5 loads";
    time=36000; time_without_menus=36000; combat_difficulty=2; rando_difficulty=2; saves=5; loads=5;
    bingo_win=0; bingos=3; bingo_spots=12; skill_points=10000; nanokeys=20; cheats=0;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "1 hour, 3 bingos, 100 saves, 100 loads";
    time=36000; time_without_menus=30000; combat_difficulty=2; rando_difficulty=2; saves=100; loads=100;
    bingo_win=0; bingos=3; bingo_spots=12; skill_points=10000; nanokeys=50; cheats=0;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "3 hours, 9 bingos, 100 saves, 100 loads";
    time=108000; time_without_menus=90010; combat_difficulty=2; rando_difficulty=2; saves=100; loads=100;
    bingo_win=0; bingos=9; bingo_spots=20; skill_points=10000; nanokeys=100; cheats=0;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "100k Points";
    scores[num++] = 100000;

    names[num] = "Astro: 7 hours, full bingo";
    time=290879; time_without_menus=242176; combat_difficulty=1.7; rando_difficulty=2; saves=796; loads=171;
    bingo_win=0; bingos=12; bingo_spots=24; skill_points=25357; nanokeys=59; cheats=0;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "Astro: 6 hours, but with some glitches";
    time=216000; time_without_menus=216000; combat_difficulty=1.7; rando_difficulty=2; saves=796; loads=171;
    bingo_win=0; bingos=12; bingo_spots=24; skill_points=25357; nanokeys=59; cheats=35;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "Astro: a little faster, but less bingos";
    time=290800; time_without_menus=242176; combat_difficulty=1.7; rando_difficulty=2; saves=796; loads=171;
    bingo_win=0; bingos=10; bingo_spots=23; skill_points=25357; nanokeys=59; cheats=0;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "Any% 1 hour";
    time=36000; time_without_menus=36000; combat_difficulty=1.2; rando_difficulty=1; saves=500; loads=200;
    bingo_win=0; bingos=0; bingo_spots=0; skill_points=10000; nanokeys=20; cheats=100000;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "Any% 2 hours";
    time=72000; time_without_menus=72000; combat_difficulty=1.2; rando_difficulty=1; saves=500; loads=200;
    bingo_win=0; bingos=0; bingo_spots=0; skill_points=10000; nanokeys=20; cheats=100000;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "Any% 2 hours, Super Easy QA mode";
    time=72000; time_without_menus=72000; combat_difficulty=0; rando_difficulty=0; saves=500; loads=200;
    bingo_win=0; bingos=0; bingo_spots=0; skill_points=10000; nanokeys=20; cheats=100000;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "1 hour bingo win";
    time=36000; time_without_menus=36000; combat_difficulty=1.2; rando_difficulty=1; saves=50; loads=50;
    bingo_win=1; bingos=1; bingo_spots=4; skill_points=5000; nanokeys=20; cheats=0;
    dxr.flags.SetDifficulty(rando_difficulty);
    flags_score = dxr.flags.ScoreFlags();
    scores[num++] = _ScoreRun(time, time_without_menus, combat_difficulty, flags_score, saves, loads,
        bingo_win, bingos, bingo_spots, skill_points, nanokeys, cheats);

    names[num] = "0 Points";
    scores[num++] = 0;

    l("TestScoring() " $ names[0] $ ": " $ scores[0]);
    for(i=1; i<num; i++) {
        testname = "TestScoring() " $ names[i-1] $ ": " $ scores[i-1] $ " > " $ names[i] $ ": " $ scores[i];
        l("TestScoring() " $ names[i] $ ": " $ scores[i]);// so you can see it in UCC.log even if it passes
        test(scores[i-1] > scores[i], testname);
    }
}

function ExtendedTests()
{
    local int time, completeTime, menutime, completemenutime;

    Super.ExtendedTests();

    teststring( IntCommas(1), "1", "IntCommas 1");
    teststring( IntCommas(123), "123", "IntCommas 123");
    teststring( IntCommas(1234), "1,234", "IntCommas 1,234");
    teststring( IntCommas(-1234), "-1,234", "IntCommas -1,234");
    teststring( IntCommas(1234567), "1,234,567", "IntCommas 1,234,567");
    teststring( IntCommas(12345678), "12,345,678", "IntCommas 12,345,678");
    teststring( IntCommas(1234567890), "1,234,567,890", "IntCommas 1,234,567,890");
    teststring( IntCommas(1000), "1,000", "IntCommas 1,000");
    teststring( IntCommas(40000), "40,000", "IntCommas 40,000");
    teststring( IntCommas(100000), "100,000", "IntCommas 100,000");
    teststring( IntCommas(104000), "104,000", "IntCommas 104,000");
    teststring( IntCommas(1000000), "1,000,000", "IntCommas 1,000,000");

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

defaultproperties
{
     bAlwaysTick=True
}
