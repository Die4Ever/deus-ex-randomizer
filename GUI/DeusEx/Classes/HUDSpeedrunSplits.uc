//=============================================================================
// HUDEnergyDisplay
//=============================================================================
class HUDSpeedrunSplits expands HUDBaseWindow config(DXRSplits);

var DeusExPlayer    player;
var DXRStats        stats;

var config int version;
var config Font  textfont;

var config Color colorBackground, colorText, colorBehind, colorBehindLosingTime, colorBehindGainingTime, colorAhead, colorAheadLosingTime, colorAheadGainingTime, colorBest, colorBestBehind, colorBestAhead;

var config bool enabled, showPrevprev, showPrev, showCurrentMission, showNext, showSeg, showCur, showPB;

var config int PB[16];
var config int Golds[16];

var config string title, subtitle, footer;
var string ttitle, tsubtitle, tfooter;

var int balanced_splits[16], balanced_splits_totals[16];
var int PB_total, sum_of_bests;

var float left_col, center_col, text_height, ty_pos;
var float windowWidth, windowHeight;

var config float x_pos, y_pos;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
    Super.InitWindow();

    player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
    Hide();

    if(class'DXRVersion'.static.VersionOlderThan(version, 2,5,3,7)) {
        version = class'DXRVersion'.static.VersionNumber();
        x_pos = 0;
        y_pos = 0;
        SaveConfig();
    }
}

function InitStats(DXRStats newstats)
{
    local int i, t, total, curMission, time;
    local string msg, difficulty;
    local bool bNewPB;

    stats = newstats;

    if(stats == None || !stats.dxr.flags.IsSpeedrunMode()) {
        Hide();
        return;
    }

    difficulty = stats.dxr.flags.DifficultyName(stats.dxr.flags.difficulty);
    ttitle = sprintf(title, difficulty);
    tsubtitle = sprintf(subtitle, difficulty);
    tfooter = sprintf(footer, difficulty);
    curMission = stats.dxr.dxInfo.MissionNumber;

    for(i=1; i<=15; i++) {
        PB_total += PB[i];
        if(Golds[i] == 0) Golds[i] = PB[i];
        if(Golds[i] > PB[i] && PB[i] != 0) Golds[i] = PB[i];
        sum_of_bests += Golds[i];
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
        }
    }
    SaveConfig();

    if(curMission < 1 || curMission > 15) {
        Hide();
        return;
    }

    Show();
    StyleChanged();
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

function DrawWindow(GC gc)
{
    local int i, t, prev, prevTime, prevprev, prevprevTime, cur, curTime, next, nextTime, time, total;
    local float x, y, f, h;
    local int cur_totals[16];
    local string msg, s;

    if(stats == None) return;

    UpdatePos();
    Super.DrawWindow(gc);
    gc.SetFont(textfont);

    total = TotalTime();
    cur = stats.dxr.dxInfo.MissionNumber;
    curTime = stats.missions_times[cur];
    curTime += stats.missions_menu_times[cur];

    for(i=1; i<ArrayCount(cur_totals); i++) {
        for(t=i; t<ArrayCount(cur_totals); t++) {
            cur_totals[t] += stats.missions_times[i];
            cur_totals[t] += stats.missions_menu_times[i];
        }
    }

    for(i=cur-1; i>=1; i--) {
        time = stats.missions_times[i];
        time += stats.missions_menu_times[i];
        if(time > 0) {
            prev = i;
            prevTime = time;
            break;
        }
    }

    for(i=prev-1; i>=1; i--) {
        time = stats.missions_times[i];
        time += stats.missions_menu_times[i];
        if(time > 0) {
            prevprev = i;
            prevprevTime = time;
            break;
        }
    }

    for(i=cur+1; i<=15; i++) {
        if(balanced_splits[i] > 0) {
            next = i;
            nextTime = balanced_splits[next];
            break;
        }
    }

    // drawing text
    x = 8;
    y = 4;

    // some init
    if(left_col == 0) {
        gc.GetTextExtent(0, left_col, text_height, "MXXii");
        gc.GetTextExtent(0, center_col, text_height, "+00:00");
        // full window width
        gc.GetTextExtent(0, windowWidth, text_height, "MXXii +00:00 8:88:88 ");
        gc.GetTextExtent(0, f, text_height, ttitle);
        windowWidth = FMax(f, windowWidth);
        gc.GetTextExtent(0, f, text_height, tsubtitle $"XX");
        windowWidth = FMax(f, windowWidth);
        gc.GetTextExtent(0, f, text_height, tfooter $"XX");
        windowWidth = FMax(f, windowWidth);
    }
    h = text_height;

    gc.SetTextColor(colorText);
    if(ttitle!="") {
        gc.DrawText(x+x_pos, y+ty_pos, width - x, text_height, ttitle);
        y += h;
    }
    if(tsubtitle!="") {
        gc.DrawText(x+x_pos, y+ty_pos, width - x, text_height, tsubtitle);
        y += h;
    }

    // prevprev split
    if(prevprev > 0 && showPrevprev) {
        time = cur_totals[prevprev] - balanced_splits_totals[prevprev];
        t = prevprevTime - balanced_splits[prevprev];
        msg = fmtTimeDiff(time);

        s = fmtTime(cur_totals[prevprev]);
        DrawTextLine(gc, MissionName(prevprev), msg, GetCmpColor(time, t, prevprevTime, Golds[prevprev]), x, y, s);
        y += h;
    } else if(showPrevprev) {
        DrawTextLine(gc, "-", "", colorText, x, y);
        y += h;
    }

    // previous split
    if(prev > 0 && showPrev) {
        time = cur_totals[prev] - balanced_splits_totals[prev];
        t = prevTime - balanced_splits[prev];
        msg = fmtTimeDiff(time);

        s = fmtTime(cur_totals[prev]);
        DrawTextLine(gc, MissionName(prev), msg, GetCmpColor(time, t, prevTime, Golds[prev]), x, y, s);
        y += h;
    } else if(showPrev) {
        DrawTextLine(gc, "-", "", colorText, x, y);
        y += h;
    }

    // current/upcoming split, showing balanced PB time
    if(showCurrentMission) {
        msg = fmtTime(balanced_splits_totals[cur]);
        DrawTextLine(gc, MissionName(cur), msg, colorText, x, y);
        y += h;
    }

    // next split
    if(next > 0 && showNext) {
        msg = fmtTime(balanced_splits_totals[next]);
        DrawTextLine(gc, MissionName(next), msg, colorText, x, y);
        y += h;
    } else if(showNext) {
        DrawTextLine(gc, "-", "", colorText, x, y);
        y += h;
    }

    // current segment time with comparison
    if(showSeg) {
        msg = fmtTimeSeg(curTime);
        s = "/ " $ fmtTimeSeg(balanced_splits[cur]);
        t = curTime - balanced_splits[cur];
        DrawTextLine(gc, "SEG:", msg, GetCmpColor(t, t), x, y, s);
        y += h;
    }

    // current overall time
    if(showCur) {
        time = cur_totals[prev] - balanced_splits_totals[prev];
        msg = fmtTime(total);
        DrawTextLine(gc, "CUR:", msg, GetCmpColor(time, t), x, y);
        y += h;
    }

    // PB time
    if(showPB) {
        msg = fmtTime(PB_total);
        DrawTextLine(gc, "PB:", msg, colorText, x, y);
        y += h;
    }

    if(tfooter != "") {
        gc.SetTextColor(colorText);
        gc.DrawText(x+x_pos, y+ty_pos, width - x, text_height, tfooter);
        y += h;
    }
    windowHeight = y;
}

function string MissionName(int mission)
{
    if(mission < 10) return "M0" $ mission;
    else return "M" $ mission;
}

function DrawTextLine(GC gc, string header, string msg, Color c, int x, int y, optional string extra)
{
    local float w, h;

    x += x_pos;
    y += ty_pos;

    gc.SetTextColor(colorText);
    gc.DrawText(x, y, width - x, text_height, header);
    gc.SetTextColor(c);

    gc.GetTextExtent(0, w, h, header);
    left_col = FMax(left_col, w);
    text_height = FMax(text_height, h);
    x += left_col;

    gc.DrawText(x, y, width - x, text_height, msg);

    if(extra == "") return;

    gc.GetTextExtent(0, w, h, msg);
    center_col = FMax(center_col, w);
    text_height = FMax(text_height, h);
    x += center_col;

    gc.DrawText(x, y, width - x, text_height, " " $ extra);
}

function Color GetCmpColor(int overall_diff, int diff, optional int segtime, optional int gold)
{
    if(overall_diff <= 0) {
        if(gold > 0 && segtime < gold) return colorBestAhead;
        else if(diff < 0) return colorAheadGainingTime;
        else if(diff > 0) return colorAheadLosingTime;
        else return colorAhead;
    } else {
        if(gold > 0 && segtime < gold) return colorBestBehind;
        else if(diff < 0) return colorBehindGainingTime;
        else if(diff > 0) return colorBehindLosingTime;
        else return colorBehind;
    }
    return colorText;
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
    if(diff <= 0) return "-" $ stats.fmtTimeToString(-diff, true, true);
    return "+" $ stats.fmtTimeToString(diff, true, true);
}

function int BalancedSplit(int m)
{
    local int balanced_split_time;
    local float ratio_of_game;

    ratio_of_game = float(Golds[m]) / float(sum_of_bests);
    balanced_split_time = ratio_of_game * float(PB_total);
    return balanced_split_time;
}

function int TotalTime()
{
    local int i, total;
    for(i=1; i<ArrayCount(stats.missions_times); i++) {
        total += stats.missions_times[i];
        total += stats.missions_menu_times[i];
    }
    return total;
}

function DrawBackground(GC gc)
{
    gc.SetStyle(backgroundDrawStyle);
    gc.SetTileColor(colorBackground);
    gc.DrawPattern(x_pos, ty_pos, windowWidth, windowHeight, 0, 0, Texture'Solid');
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

    textfont=Font'DeusExUI.FontMenuHeaders_DS';
    colorBackground=(R=0,G=0,B=0,A=100)
    colorText=(R=255,G=255,B=255,A=255)

    colorBehind=(R=204,G=60,B=40,A=255)
    colorBehindLosingTime=(R=204,G=18,B=0,A=255)
    colorBehindGainingTime=(R=204,G=92,B=82,A=255)

    colorAhead=(R=40,G=204,B=80,A=255)
    colorAheadLosingTime=(R=82,G=204,B=115,A=255)
    colorAheadGainingTime=(R=0,G=204,B=54,A=255)

    colorBest=(R=216,G=175,B=31,A=255)
    colorBestBehind=(R=216,G=175,B=31,A=255)
    colorBestAhead=(R=216,G=175,B=31,A=255)

    title="Deus Ex Randomizer"
    subtitle="%s Speedrun"
    footer=""
}
