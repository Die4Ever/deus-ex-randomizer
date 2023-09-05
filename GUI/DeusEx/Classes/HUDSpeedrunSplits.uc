//=============================================================================
// HUDEnergyDisplay
//=============================================================================
class HUDSpeedrunSplits expands HUDBaseWindow config(DXRSplits);

var DeusExPlayer    player;
var DXRStats        stats;

var config Font  textfont;
var config Color colorBackground, colorText, colorBehind, colorBehindLosingTime, colorBehindGainingTime, colorAhead, colorAheadLosingTime, colorAheadGainingTime, colorBest, colorBestBehind, colorBestAhead;

var config int PB[16];
var config int Golds[16];

var int balanced_splits[16], balanced_splits_totals[16];
var int PB_total, sum_of_bests;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
    Super.InitWindow();

    player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
    Hide();
}

function InitStats(DXRStats newstats)
{
    local int i, t, total, curMission, time;
    local string msg;
    local bool bNewPB;

    stats = newstats;

    if(stats == None || !stats.dxr.flags.IsSpeedrunMode()) {
        Hide();
        return;
    }

    curMission = stats.dxr.dxInfo.MissionNumber;
    Show();

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
        SaveConfig();
    }
    SaveConfig();

    if(curMission < 1 || curMission > 15) {
        Hide();
        return;
    }

    msg = "Total IGT: " $ stats.fmtTimeToString(total);
    for(i=curMission; i>0; i--) {
        time = stats.missions_times[i];
        time += stats.missions_menu_times[i];
        if(time > 0) {
            msg = msg $ ", Mission " $i$ ": " $ stats.fmtTimeToString(time);
            break;
        }
    }
    msg = msg $ ", Deaths: " $ stats.GetDataStorageStat(stats.dxr, "DXRStats_deaths");
    player.ClientMessage(msg);

    SetSize(160, 130);
    StyleChanged();
}

function DrawWindow(GC gc)
{
    local int i, t, prev, prevTime, prevDiff, cur, curTime, next, nextTime, time, total;
    local float x, y, w, h, f, w2;
    local int cur_totals[16];
    local string msg, s;

    if(stats == None) return;

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

    for(i=cur+1; i<=15; i++) {
        if(balanced_splits[i] > 0) {
            next = i;
            nextTime = balanced_splits[next];
            break;
        }
    }

    // drawing text
    x = 8;
    h = gc.GetFontHeight();

    // previous split
    if(prev > 0) {
        if(prev<10) msg = "M0" $ prev;
        else msg = "M" $ prev;
        gc.SetTextColor(colorText);
        gc.DrawText(x, y, width, h, msg);
        gc.GetTextExtent(0, w, f, msg);

        time = cur_totals[prev] - balanced_splits_totals[prev];
        t = prevTime - balanced_splits[prev];
        msg = " " $ fmtTimeDiff(time);
        gc.SetTextColor(GetCmpColor(time, t, prevTime, Golds[prev]));
        gc.DrawText(x + w, y, width - w, h, msg);
        gc.GetTextExtent(0, w2, f, msg);
        w += w2;

        msg = " " $ stats.fmtTimeToString(cur_totals[prev], false, true);
        gc.DrawText(x + w, y, width - w, h, msg);
    }
    y += h;

    // current split, showing balanced PB time
    if(cur<10) msg = "M0" $ cur;
    else msg = "M" $ cur;
    msg = msg $ "     " $ stats.fmtTimeToString(balanced_splits_totals[cur], false, true);
    gc.SetTextColor(colorText);
    gc.DrawText(x, y, width, h, msg);
    y += h;

    // next split
    if(next > 0) {
        if(next<10) msg = "M0" $ next;
        else msg = "M" $ next;
        msg = msg $ "     " $ stats.fmtTimeToString(balanced_splits_totals[next], false, true);
        gc.SetTextColor(colorText);
        gc.DrawText(x, y, width, h, msg);
    }
    y += h;

    // current segment comparison
    msg = "SEG: " $ stats.fmtTimeToString(curTime, true, true) $ " / " $ stats.fmtTimeToString(balanced_splits[cur], true, true);
    t = curTime - balanced_splits[cur];
    gc.SetTextColor(GetCmpColor(t, 0));
    gc.DrawText(x, y, width, h, msg);
    y += h;

    // current overall time
    msg = "CUR: " $ stats.fmtTimeToString(total, false, true);
    time = cur_totals[prev] - balanced_splits_totals[prev];
    gc.SetTextColor(GetCmpColor(time, t));
    gc.DrawText(x, y, width, h, msg);
    y += h;

    // PB and SOB
    gc.SetTextColor(colorText);
    msg = "PB:  " $ stats.fmtTimeToString(PB_total, false, true);
    gc.DrawText(x, y, width, h, msg);
    y += h;

    /*msg = "SOB: " $ stats.fmtTimeToString(sum_of_bests, false, true);
    gc.DrawText(x, y, width, h, msg);
    y += h;*/
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

function string fmtTimeDiff(int diff)
{
    if(diff <= 0) return "-" $ stats.fmtTimeToString(-diff, true, true);
    return "+" $ stats.fmtTimeToString(diff, true, true);
}

function int BalancedSplit(int m)
{
    local int balanced_split_time, i;
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
    gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    textfont=Font'FontComputer8x20_B';
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
}
