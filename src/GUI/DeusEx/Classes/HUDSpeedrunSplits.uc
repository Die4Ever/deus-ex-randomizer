class HUDSpeedrunSplits expands HUDBaseWindow config(DXRSplits);

var DeusExPlayer    player;
var DXRStats        stats;

var config int version;
var config Font  textfont;

var config Color colorBackground, colorNotesBackground, colorText, colorBehind, colorBehindLosingTime, colorBehindGainingTime, colorAhead, colorAheadLosingTime, colorAheadGainingTime, colorBest, colorBestBehind, colorBestAhead;

var config bool enabled, showPrevprev, showPrev, showCurrentMission, showNext, showSeg, showCur, showPB, showSpeed, showAllSplits;
var config bool showAverage, useAverageGoal;

var config int PB[16];
var config int Golds[16];
var config int Avgs[16];
var config int std_devs[16];
var config byte alwaysShowSplit[16];
var config int goal_time;

var config string title, subtitle, footer;
var string ttitle, tsubtitle, tfooter;

var int balanced_splits[16], balanced_splits_totals[16];
var int PB_total, sum_of_bests, average_total;

var config string split_names[16];

var config string splitNotes[16];
var string notes;

var float left_col, left_col_small, center_col, text_height, ty_pos;
var float windowWidth, windowHeight, notesWidth, notesHeight;
var float x, y;

var config float x_pos, y_pos;
var float prevSpeed, avgSpeed, lastTime;
var int rememberedMission;

var config int last_flagshash;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
    Super.InitWindow();

    player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
    Hide();

    if(class'DXRVersion'.static.VersionOlderThan(version, 2,6,1,1)) {
        x_pos = 0;
        y_pos = 0;
    }
    if(textFont == None) {
        textFont = Font'DeusExUI.FontMenuHeaders_DS';
    }
    if( version < class'DXRVersion'.static.VersionToInt(2, 7, 3, 1) ) {
        colorText=RGB(200,200,200);
        colorBehind=RGB(220,90,80);
        colorBehindLosingTime=RGB(255,60,40);
        colorBehindGainingTime=RGB(250,140,131);
    }
    if( class'DXRVersion'.static.VersionOlderThan(version, 3,5,0,1)) {
        splitNotes[1]="The starting location, Leo, and the boat|ncannot be close to each other.|nEdit these notes in DXRSplits.ini";
        splitNotes[6]="The DTS and Gordon won't be on the same map.|nIf one is in market, the other is in Tonnochi.|nEdit these notes in DXRSplits.ini";
        splitNotes[14]="The computer, Howard, and escape Jock won't be close to each other.|nEdit these notes in DXRSplits.ini";
    }
    if( version < class'DXRVersion'.static.VersionNumber() ) {
        version = class'DXRVersion'.static.VersionNumber();
        SaveConfig();
    }
}

function Color RGB(int r, int g, int b)
{
    local Color c;
    c.A=255;
    c.R=r;
    c.G=g;
    c.B=b;
    return c;
}

function string ReplaceVariables(string s)
{
    local string t;
    local DXRando dxr;
    local DXRFlags f;
    local DXRLoadouts loadouts;
    local int i, id;

    dxr = stats.dxr;
    f = dxr.flags;

    t = f.DifficultyName(f.difficulty) $"";
    s = f.ReplaceText(s, "%difficulty", t);

    t = stats.GetDataStorageStat(dxr, "DXRStats_loads") $"";
    s = f.ReplaceText(s, "%loads", t);

    t = stats.GetDataStorageStat(dxr, "DXRStats_deaths") $"";
    s = f.ReplaceText(s, "%deaths", t);

    t = stats.ToHex(f.FlagsHash());
    s = f.ReplaceText(s, "%flagshash", t);

    t = f.VersionString(true);
    s = f.ReplaceText(s, "%version", t);

    t = f.seed $"";
    s = f.ReplaceText(s, "%seed", t);

    t = f.mirroredmaps $ "%";
    s = f.ReplaceText(s, "%mirroredmaps", t);

    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    t = "All Items Allowed";
    if(loadouts != None) {
        id = loadouts.GetIdForSlot(f.loadout);
        t = loadouts.GetName(id);
    }
    s = f.ReplaceText(s, "%loadout", t);

    t = player.TruePlayerName;
    s = f.ReplaceText(s, "%playername", t);

    t = f.GameModeName(f.gamemode);
    s = f.ReplaceText(s, "%gamemode", t);

    t = class'PersonaScreenBingo'.static.GetNextStartingMap(dxr);
    s = f.ReplaceText(s, "%nextmap", t);

    return s;
}

function bool CheckDesiredVisiblity()
{
    local int curMission;

    if(stats == None || stats.dxr == None || stats.dxr.flags.moresettings.splits_overlay == 0) {
        return false;
    }

    if(!enabled) return false;

    curMission = stats.dxr.dxInfo.MissionNumber;
    if(curMission < 1 || curMission > 15) return false;
}

function UpdateVisibility()
{
    Show(CheckDesiredVisiblity());
}

function InitStats(DXRStats newstats)
{
    local int i, t, total, curMission, time;
    local string msg;

    stats = newstats;

    if(stats == None || stats.dxr.flags.moresettings.splits_overlay == 0) {
        Hide();
        return;
    }

    ttitle = ReplaceVariables(title);
    tsubtitle = ReplaceVariables(subtitle);
    tfooter = ReplaceVariables(footer);
    curMission = stats.dxr.dxInfo.MissionNumber;
    if(curMission >= 1 && curMission <= 15) {
        notes = class'DXRInfo'.static.ReplaceText(splitNotes[curMission], "|n", CR());
        notes = ReplaceVariables(notes);
    }

    for(i=1; i<=15; i++) {
        PB_total += PB[i];
        sum_of_bests += Golds[i];
    }
    for(i=1; i<=15; i++) {
        if(Avgs[i] < Golds[i]) {
            if(PB[i] > Golds[i]) Avgs[i] = PB[i];
            else Avgs[i] = Golds[i];
        }
        average_total += Avgs[i];
    }
    for(i=1; i<=15; i++) {
        balanced_splits[i] = BalancedSplit(i);
        for(t=i; t<ArrayCount(balanced_splits_totals); t++) {
            balanced_splits_totals[t] += balanced_splits[i];
        }
    }

    total = TotalTime();

    msg = "Total IGT: " $ stats.fmtTimeToString(total);
    for(i=Min(15,curMission); i>0; i--) {
        time = stats.missions_times[i];
        time += stats.missions_menu_times[i];
        if(time > 0) {
            msg = msg $ ", Mission " $i$ ": " $ stats.fmtTimeToString(time);
            break;
        }
    }
    msg = msg $ ", Deaths: " $ stats.GetDataStorageStat(stats.dxr, "DXRStats_deaths");
    player.ClientMessage(msg);

    if(!enabled) {
        Hide();
        return;
    }

    if(curMission == 99) {
        CompletedRun(total);
    }
    if(curMission > 0 && stats.dxr.flags.newgameplus_loops == 0) {
        last_flagshash = stats.dxr.flags.FlagsHash();
        default.last_flagshash = last_flagshash;
    }
    SaveConfig();

    if(curMission < 1 || curMission > 15) {
        Hide();
        return;
    }

    Show();
    StyleChanged();
}

static function bool CheckFlags(DXRFlags f)
{
    local int last;

    if(f.moresettings.splits_overlay <= 0) return true;
    last = class'HUDSpeedrunSplits'.default.last_flagshash;
    if(last == 0) return true;
    return f.FlagsHash() == last;
}

function CompletedRun(int total)
{
    local int i, time;
    local float avg, dev;
    local bool bNewPB;

    // write back new PBs and Golds
    bNewPB = PB_total == 0 || total < PB_total;
    for(i=1; i<=15; i++) {
        time = stats.missions_times[i];
        time += stats.missions_menu_times[i];
        if(Golds[i] == 0 || time < Golds[i]) {
            Golds[i] = time;
        }
        if(bNewPB) {
            PB[i] = time;
        }
        if(Avgs[i] <= 0) {
            Avgs[i] = time;
            avg = time;
        } else {
            // moving average across about 5 runs
            avg = float(Avgs[i]*4 + time) / 5;
            Avgs[i] = int(avg + 0.5);
        }
        dev = Abs(time-avg);// deviation from average
        dev = (std_devs[i]*4 + dev) / 5;// moving average standard deviation based on a moving average, probably a sin of mathematics
        std_devs[i] = int(dev + 0.5);
    }
}

function UpdatePos()
{
    local float hudWidth, hudHeight, beltWidth, beltHeight;

#ifdef injections
    local DeusExHUD hud;
    hud = DeusExRootWindow(GetRootWindow()).hud;
#else
    local DXRandoHUD hud;
    hud = DXRandoHUD(DeusExRootWindow(GetRootWindow()).hud);
#endif

    if (hud != None) {
        if(hud.belt != None) beltHeight = hud.belt.height;
    }
    ty_pos = GetRootWindow().height - beltHeight - windowHeight - 8 - y_pos;
}

function InitSizes(GC gc)
{
    local int i;
    local float f;
    local string s;

    for(i=0; i<ArrayCount(split_names); i++) {
        s = MissionName(i) $ " ";
        gc.GetTextExtent(0, f, text_height, s);
        left_col = FMax(left_col, f);
    }

    gc.GetTextExtent(0, left_col_small, text_height, "M88: ");

    gc.GetTextExtent(0, center_col, text_height, "+00:00");

    // full window width
    gc.GetTextExtent(0, windowWidth, text_height, " +00:00 8:88:88 ");
    windowWidth += left_col;

    gc.GetTextExtent(0, f, text_height, ttitle);
    windowWidth = FMax(f, windowWidth);
    gc.GetTextExtent(0, f, text_height, tsubtitle $"XX");
    windowWidth = FMax(f, windowWidth);
    gc.GetTextExtent(0, f, text_height, tfooter $"XX");
    windowWidth = FMax(f, windowWidth);

    gc.GetTextExtent(FMax(100, windowWidth), notesWidth, notesHeight, notes);
}

//#region DrawWindow
function DrawWindow(GC gc)
{
    local int cur;

    if(stats == None) return;

#ifdef injections
    if(DeusExRootWindow(player.rootWindow).hud.hms.bShowing) return;
#endif

    UpdatePos();
    Super.DrawWindow(gc);
    gc.SetFont(textfont);

    if(stats.dxr != None) {
        cur = stats.dxr.dxInfo.MissionNumber;
        rememberedMission = cur;
    } else if(rememberedMission > 0 && rememberedMission <= 15) {
        cur = rememberedMission;
    } else {
        return;
    }

    x = 8;
    y = 4;
    DrawHeader(gc);

    if(stats.dxr != None && stats.dxr.flags.IsWaltonWare()) {
        DrawWaltonWare(gc);
    } else {
        DrawSplits(gc, cur);
    }

    DrawFooter(gc);
}

function DrawHeader(GC gc)
{
    local int i, prev, prevprev, curTime, next, time, total, prevTotal;
    local float f, delta;
    local string msg, msg2;
    local Color cmpColor;

    total = TotalTime();
    if(left_col == 0) {
        InitSizes(gc);
    }

    gc.SetTextColor(colorText);
    gc.SetAlignments(HALIGN_Center, VALIGN_Top);
    if(ttitle!="") {
        gc.DrawText(x+x_pos, y+ty_pos, windowWidth - x, text_height, ttitle);
        y += text_height;
    }
    if(tsubtitle!="") {
        gc.DrawText(x+x_pos, y+ty_pos, windowWidth - x, text_height, tsubtitle);
        y += text_height;
    }
}

function DrawFooter(GC gc)
{
    local float delta, f;
    local string msg, msg2;

    if(showSpeed) {
        delta = player.Level.TimeSeconds - lastTime;
        delta *= 4.0;
        lastTime = player.Level.TimeSeconds;

        f = VSize(player.Velocity * vect(1,1,0));
        f = class'DXRActorsBase'.static.GetRealSpeed(f, true);

        avgSpeed -= avgSpeed * delta;
        avgSpeed += f * delta;
        msg = stats.FloatToString(FMax(f, prevSpeed), 1) @ class'DXRActorsBase'.static.GetSpeedUnit(true);
        msg2 = stats.FloatToString(avgSpeed, 1) @ class'DXRActorsBase'.static.GetSpeedUnit(true);
        prevSpeed = f;
        DrawTextLine(gc, "SPD:", msg, colorText, x, y, msg2, true);
        y += text_height;
    }

    if(tfooter != "") {
        gc.SetAlignments(HALIGN_Center, VALIGN_Top);
        gc.SetTextColor(colorText);
        gc.DrawText(x+x_pos, y+ty_pos, windowWidth - x, text_height, tfooter);
        y += text_height;
    }
    windowHeight = y;

    //#region draw notes
    if(notes != "") {
        y = 4;
        x = windowWidth + 24;

        gc.SetAlignments(HALIGN_Left, VALIGN_Top);
        gc.SetTextColor(colorText);
        gc.DrawText(x+x_pos, y+ty_pos, notesWidth, notesHeight, notes);
    }
}

function DrawWaltonWare(GC gc)
{
    local int curTime, total, prevTotal;
    local DXRFlags flags;
    local string msg;

    flags = stats.dxr.flags;
    total = TotalTime();

    gc.SetAlignments(HALIGN_Left, VALIGN_Top);

    prevTotal = flags.newgameplus_total_time;
    if(prevTotal > 0) {
        DrawTextLine(gc, "Loop " $ flags.newgameplus_loops, "", colorText, x, y, fmtTime(prevTotal), true);
        y += text_height;
    }

    curTime = total - prevTotal;
    DrawTextLine(gc, "CUR:", fmtTime(curTime), colorText, x, y, fmtTime(total), true);
    y += text_height;

    if(showAverage) {
        msg = fmtTimeSeg(prevTotal / flags.newgameplus_loops);
        DrawTextLine(gc, "AVG:", msg, colorText, x, y, "", true);
        y += text_height;
    }
}

function DrawSplits(GC gc, int cur)
{
    local int i, prev, prevprev, curTime, next, time, total, prevTotal;
    local float f, delta;
    local string msg, msg2;
    local Color cmpColor;

    total = TotalTime();
    curTime = stats.missions_times[cur];
    curTime += stats.missions_menu_times[cur];

    for(i=1; i<cur; i++) {
        time = stats.missions_times[i];
        time += stats.missions_menu_times[i];
        if(time > 0) {
            prevTotal += time;
            prev = i;
        }
    }

    for(i=prev-1; i>=1; i--) {
        time = stats.missions_times[i];
        time += stats.missions_menu_times[i];
        if(time > 0) {
            prevprev = i;
            break;
        }
    }

    for(i=cur+1; i<=15; i++) {
        if(balanced_splits[i] > 0) {
            next = i;
            break;
        }
    }

    //#region drawing text
    gc.SetAlignments(HALIGN_Left, VALIGN_Top);

    for(i=1; i<ArrayCount(Golds); i++) {
        if(showAllSplits
        || (alwaysShowSplit[i] != 0)
        || (i == prevprev && showPrevprev)
        || (i == prev && showPrev)
        || (i == cur && showCurrentMission)
        || (i == next && showNext)
        || (i == ArrayCount(Golds)-1 && showPB)
        ) {
            y = DrawSplit(gc, i, cur, x, y);
        }
    }

    //#region current segment time with comparison
    if(showSeg) {
        msg = fmtTimeSeg(curTime);
        msg2 = "/ " $ fmtTimeSeg(balanced_splits[cur]) $ " / " $ fmtTimeSeg(Golds[cur]);
        cmpColor = GetCmpColor(curTime, balanced_splits[cur], prevTotal, balanced_splits_totals[prev], Golds[cur]);
        DrawTextLine(gc, "SEG:", msg, cmpColor, x, y, msg2, true);
        y += text_height;
    }

    //#region current overall time
    if(showCur) {
        msg = fmtTime(total);
        cmpColor = GetCmpColor(prevTotal, balanced_splits_totals[prev], curTime, balanced_splits[cur]);
        DrawTextLine(gc, "CUR:", msg, cmpColor, x, y, "", true);
        y += text_height;
    }

    if(showAverage) {
        msg = fmtTimeSeg(Avgs[cur]);
        msg2 = "/ " $ fmtTime(average_total);
        DrawTextLine(gc, "AVG:", msg, colorText, x, y, msg2, true);
        y += text_height;
    }
}

//#region DrawSplit
function int DrawSplit(GC gc, int mission, int curMission, int x, int y)
{
    local int time, total, i, totalDiff;
    local string sDiff, sTime;
    local Color cmpColor;

    time = stats.missions_times[mission];
    time += stats.missions_menu_times[mission];

    if(mission == curMission) {
        // current split
        sTime = fmtTime(balanced_splits_totals[mission]);
        DrawTextLine(gc, MissionName(mission), "", colorText, x, y, sTime);
    }
    else if(time > 0) {
        // past split
        for(i=1; i<=mission; i++) {
            total += stats.missions_times[i];
            total += stats.missions_menu_times[i];
        }
        totalDiff = total - balanced_splits_totals[mission];
        if(balanced_splits_totals[mission] > 0) {
            sDiff = fmtTimeDiff(totalDiff);
        }

        sTime = fmtTime(total);
        cmpColor = GetCmpColor(total, balanced_splits_totals[mission], time, balanced_splits[mission], 0, Golds[mission]);

        DrawTextLine(gc, MissionName(mission), sDiff, cmpColor, x, y, sTime);
    }
    else if(balanced_splits[mission] > 0) {
        // future split
        sTime = fmtTime(balanced_splits_totals[mission]);
        DrawTextLine(gc, MissionName(mission), "", colorText, x, y, sTime);
    }
    else {
        // not a real split
        return y;
    }

    return y + text_height;
}

function string MissionName(int mission)
{
    if(split_names[mission] != "") return split_names[mission];
    if(mission < 10) return "M0" $ mission;
    else return "M" $ mission;
}

function DrawTextLine(GC gc, string header, string msg, Color c, int x, int y, optional string extra, optional bool small)
{
    local float w, h, column;

    x += x_pos;
    y += ty_pos;

    gc.SetTextColor(colorText);
    gc.DrawText(x, y, width - x, text_height, header);
    gc.SetTextColor(c);

    gc.GetTextExtent(0, w, h, header);
    text_height = FMax(text_height, h);
    if(small) {
        left_col_small = FMax(left_col_small, w);
        x += left_col_small;
    } else {
        left_col = FMax(left_col, w);
        x += left_col;
    }

    gc.DrawText(x, y, width - x, text_height, msg);

    if(extra == "") return;

    gc.GetTextExtent(0, w, h, msg);
    center_col = FMax(center_col, w);
    text_height = FMax(text_height, h);
    x += center_col;

    gc.DrawText(x, y, width - x, text_height, " " $ extra);
}

function Color GetCmpColor(int primary_time, int primary_comp, int secondary_time, int secondary_comp, optional int primary_best, optional int secondary_best)
{
    local int prim_diff, sec_diff;
    local bool bGold;

    bGold = (primary_best!=0 && primary_time < primary_best) || (secondary_best!=0 && secondary_time < secondary_best);

    if(primary_comp == 0) {
        if(bGold) return colorBest;
        return colorText;
    }
    prim_diff = primary_time - primary_comp;
    if(secondary_comp != 0) sec_diff = secondary_time - secondary_comp;

    if(prim_diff <= 0) {
        if(bGold) return colorBestAhead;
        if(sec_diff <= 0) return colorAheadGainingTime;
        if(sec_diff > 0) return colorAheadLosingTime;
        return colorAhead; // currently can't happen, but do we want to ever use this color?
    }
    if(prim_diff > 0) {
        if(bGold) return colorBestBehind;
        if(sec_diff < 0) return colorBehindGainingTime;
        if(sec_diff >= 0) return colorBehindLosingTime;
        return colorBehind; // currently can't happen, but do we want to ever use this color?
    }

    return colorText; // just in case
}

function string fmtTimeSeg(int time)
{
    return stats.fmtTimeToString(time, true, true, true);
}

function string fmtTime(int time)
{
    return stats.fmtTimeToString(time, false, true, true);
}

function string fmtTimeDiff(int diff)
{
    if(diff <= 0) return "-" $ stats.fmtTimeToString(-diff, true, true, true);
    return "+" $ stats.fmtTimeToString(diff, true, true, true);
}

function int BalancedSplit(int m)
{
    local int i, balanced_split_time;
    local int total_goal;
    local int typical_split_time, typical_total_time;
    local int timesave, total_timesave;
    local float ratio;

    total_goal = PB_total;
    if(goal_time != 0) total_goal = goal_time;
    if(useAverageGoal && average_total > 0 && (average_total < goal_time || goal_time==0)) {
        total_goal = average_total;
    }

    typical_split_time = Golds[m];
    typical_total_time = sum_of_bests;

    if(average_total > typical_total_time) {
        typical_split_time = Avgs[m];
        typical_total_time = average_total;
    }

    if(total_goal == 0) {
        if(Avgs[m] > 0) return Avgs[m];
        return Golds[m];
    }
    if(m == 15) { // last split, avoid rounding issues
        balanced_split_time = total_goal - balanced_splits_totals[m-1];
        //log("Mission: " $ m $ ", balanced: " $ fmtTimeSeg(balanced_split_time) $ ", gold: " $ fmtTimeSeg(Golds[m]) $ ", PB: " $ fmtTimeSeg(PB[m]) $ ", Avg: " $ fmtTimeSeg(Avgs[m]));
        return balanced_split_time;
    }
    if(typical_total_time == 0) {
        if(Avgs[m] > 0) return Avgs[m];
        return PB[m];
    }

    if(sum_of_bests > 0 && sum_of_bests < total_goal) {
        timesave = typical_split_time - Golds[m];
        total_timesave = typical_total_time - sum_of_bests;
        ratio = float(typical_total_time - total_goal) / float(total_timesave);// ratio is the desired timesave divided by the maximum timesave
        balanced_split_time = typical_split_time - timesave * ratio;
    } else {
        ratio = float(typical_split_time) / float(typical_total_time);
        balanced_split_time = ratio * float(total_goal);
    }
    //log("Mission: " $ m $ ", balanced: " $ fmtTimeSeg(balanced_split_time) $ ", gold: " $ fmtTimeSeg(Golds[m]) $ ", PB: " $ fmtTimeSeg(PB[m]) $ ", Avg: " $ fmtTimeSeg(Avgs[m]));
    return balanced_split_time;
}

function int TotalTime()
{
    local int i, total;
    total = stats.dxr.flags.newgameplus_total_time;
    for(i=1; i<ArrayCount(stats.missions_times); i++) {
        total += stats.missions_times[i];
        total += stats.missions_menu_times[i];
    }
    return total;
}

function DrawBackground(GC gc)
{
    local float width, height;

    backgroundDrawStyle = default.backgroundDrawStyle;// StyleChanged overwrites this, but we can read from default to get the config value
    gc.SetStyle(backgroundDrawStyle);
    gc.SetTileColor(colorBackground);
    width = windowWidth + 8;
    if(notesWidth > 0) width += 12;
    height = FMax(windowHeight, notesHeight + 4);
    gc.DrawPattern(x_pos, ty_pos, width, height, 0, 0, Texture'DeusExUI.UserInterface.WindowShadow_Center');

    if(notesWidth > 0) {
        gc.SetTileColor(colorNotesBackground);
        gc.DrawPattern(x_pos + width, ty_pos, notesWidth + 12, height, 0, 0, Texture'DeusExUI.UserInterface.WindowShadow_Center');
    }
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    enabled=true
    showPrevprev=false
    showPrev=true
    showCurrentMission=true
    showNext=true
    showSeg=true
    showCur=true
    showPB=true
    showSpeed=true
    showAllSplits=false
    showAverage=true

    backgroundDrawStyle=DSTY_Translucent
    textfont=Font'DeusExUI.FontMenuHeaders_DS';
    colorBackground=(R=0,G=0,B=0,A=100)
    colorNotesBackground=(R=0,G=0,B=0,A=100)
    colorText=(R=200,G=200,B=200,A=255)

    colorBehind=(R=220,G=90,B=80,A=255)
    colorBehindLosingTime=(R=255,G=60,B=40,A=255)
    colorBehindGainingTime=(R=250,G=140,B=131,A=255)

    colorAhead=(R=40,G=204,B=80,A=255)
    colorAheadLosingTime=(R=82,G=204,B=115,A=255)
    colorAheadGainingTime=(R=0,G=204,B=54,A=255)

    colorBest=(R=216,G=175,B=31,A=255)
    colorBestBehind=(R=216,G=175,B=31,A=255)
    colorBestAhead=(R=216,G=175,B=31,A=255)

    title="Deus Ex Randomizer"
    subtitle="%version %difficulty %gamemode"
    footer=""

    split_names(1)="Liberty Island"
    split_names(2)="Generator"
    split_names(3)="Airfield"
    split_names(4)="Paul"
    split_names(5)="Jail"
    split_names(6)="Hong Kong"
    split_names(8)="Finding Dowd"
    split_names(9)="Ship"
    split_names(10)="Paris"
    split_names(11)="Cathedral"
    split_names(12)="Vandenberg"
    split_names(14)="Silo"
    split_names(15)="Area 51"

    splitNotes(1)="The starting location, Leo, and the boat|ncannot be close to each other.|nEdit these notes in DXRSplits.ini"
    splitNotes(14)="The computer, Howard, and escape Jock won't be close to each other.|nEdit these notes in DXRSplits.ini"
}
