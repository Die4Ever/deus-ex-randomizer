//=============================================================================
// HUDEnergyDisplay
//=============================================================================
class HUDSpeedrunSplits expands HUDBaseWindow config(DXRSplits);

var DeusExPlayer	player;
var DXRStats        stats;

var TextWindow      text;
var Font            textfont;

var config int PB[16];
var config int Golds[16];
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
    local int i, total, curMission, time;
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
        sum_of_bests += Golds[i];
    }

    total = TotalTime();

    if(curMission == 99) {
        // write back PBs and Golds
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
    bTickEnabled = True;
    CreateWindow();
    StyleChanged();
}

// ----------------------------------------------------------------------
// Tick()
//
// Used to update the text
//
// ----------------------------------------------------------------------

event Tick(float deltaSeconds)
{
    local int i, prev, prevTime, cur, curTime, next, nextTime, time, total;
    local string msg;

    if(stats == None) return;

    total = TotalTime();
    cur = stats.dxr.dxInfo.MissionNumber;
    curTime = stats.missions_times[cur];
    curTime += stats.missions_menu_times[cur];

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
        time = Golds[i];
        time += Golds[i];
        if(time > 0) {
            next = i;
            nextTime = BalancedSplit(next);
            break;
        }
    }

    if(prev > 0) {
        if(prev<10) msg = msg $ "M0" $ prev;
        else msg = msg $ "M" $ prev;
        msg = msg $ " CUR " $ stats.fmtTimeToString(prevTime) $ "|n";
    } else {
        msg = msg $ "|n";
    }

    if(cur<10) msg = msg $ "M0" $ cur;
    else msg = msg $ "M" $ cur;
    msg = msg $ " CUR " $ stats.fmtTimeToString(curTime) $ "|n";

    if(next > 0) {
        if(next<10) msg = msg $ "M0" $ next;
        else msg = msg $ "M" $ next;
        msg = msg $ " PB  " $ stats.fmtTimeToString(nextTime) $ "|n";
    } else {
        msg = msg $ "|n";
    }

    msg = msg $ "PB:  " $ stats.fmtTimeToString(PB_total) $ "|nSOB: " $ stats.fmtTimeToString(sum_of_bests) $ "|nCUR: " $ stats.fmtTimeToString(total);
    text.SetText(msg);
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

function CreateWindow()
{
    local Color colName;
    local ColorTheme theme;

    theme = player.ThemeManager.GetCurrentHUDColorTheme();
    colName = theme.GetColorFromName('HUDColor_NormalText');

    text = TextWindow(NewChild(Class'TextWindow'));
    text.SetFont(textfont);
    text.SetTextColor(colName);
    text.SetLines(6,6);
    text.SetTextAlignments(HALIGN_Left,VALIGN_Center);
    text.SetText("");
    text.SetPos(8,0);
}


function DrawBackground(GC gc)
{
    /*gc.SetStyle(backgroundDrawStyle);
    gc.SetTileColor(colBackground);
    gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');*/
}


// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
    local ColorTheme theme;
    local Color colName;

    Super.StyleChanged();

    if (text!=None){
        theme = player.ThemeManager.GetCurrentHUDColorTheme();
        colName   = theme.GetColorFromName('HUDColor_NormalText');
        text.SetTextColor(colName);
    }
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    textfont=Font'FontComputer8x20_B';
}
