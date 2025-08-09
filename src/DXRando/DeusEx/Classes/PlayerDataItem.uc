class PlayerDataItem extends Inventory config(DXRBingo);

const FAILED_MISSION_MASK = 1; // probably failed
const ABSOLUTELY_FAILED_MISSION_MASK = 0xFFFFFFFF;

var travel bool local_inited;
var travel int version, initial_version;
#ifdef multiplayer
var travel int SkillPointsTotal;
var travel int SkillPointsAvail;
#endif

var travel int EntranceRandoMissionNumber;
var travel int numConns;
var travel string conns[120];
var travel string bannedGoals[128];
var travel int bannedGoalsTimers[128];

struct BingoSpot {
    var travel string event;
    var travel string desc;
    var travel int progress;
    var travel int max;
};
var travel BingoSpot bingo[25];
var travel int bingo_missions_masks[25];// can't be inside the travel struct because that breaks compatibility with old saves
var travel int bingo_append_max[25]; //see above...

struct BingoSpotExport {
    var string event;
    var string desc;
    var int progress;
    var int max;
    var int active;// if the current mission is active, -1 is impossible, 0 is no, 1 is maybe, 2 is active
};
var transient config BingoSpotExport bingoexport[25];

var travel name readTexts[50];

simulated function static PlayerDataItem GiveItem(#var(PlayerPawn) p)
{
    local PlayerDataItem i;

    if(p==None){return None;}

    i = PlayerDataItem(p.FindInventoryType(class'PlayerDataItem'));
    if( i == None )
    {
        i = p.Spawn(class'PlayerDataItem');
        i.initial_version = class'DXRVersion'.static.VersionNumber();
        i.ExportBingoState();
        i.GiveTo(p);
        log("spawned new "$i$" for "$p);
    }
    return i;
}

simulated function static ResetData(#var(PlayerPawn) p)
{
    local PlayerDataItem o, n;
    o = GiveItem(p);
    n = p.Spawn(class'PlayerDataItem');
    n.ExportBingoState();

    n.local_inited = o.local_inited;
    n.version = class'DXRVersion'.static.VersionNumber();
    n.initial_version = n.version;
#ifdef multiplayer
    n.SkillPointsTotal = o.SkillPointsTotal;
    n.SkillPointsAvail = o.SkillPointsAvail;
#endif

    log("spawned new "$n$" for "$p$" from "$o);
    o.Destroy();
    n.GiveTo(p);
}

final function BindConn(int slot_a, int slot_b, out string val, bool writing)
{
    if( writing )
        conns[slot_a*6 + slot_b] = val;
    else
        val = conns[slot_a*6 + slot_b];
}

simulated function bool MarkRead(name textTag) {
    local int i;
    for(i=0; i<ArrayCount(readTexts); i++) {
        if(readTexts[i] == textTag) return false;
        if(readTexts[i] == '') {
            readTexts[i] = textTag;
            return true;
        }
    }
    return false;
}

simulated function ForgetRead() {
    local int i;
    for(i=0; i<ArrayCount(readTexts); i++) {
        readTexts[i] = '';
    }
}


simulated function int GetBingoSpot(
    int x,
    int y,
    optional out string event,
    optional out string desc,
    optional out int progress,
    optional out int max,
    optional out int missions,
    optional out int append_max
)
{
    local DXRando dxr;
    local int currentMission;

    event = bingo[x*5+y].event;
    desc = bingo[x*5+y].desc;
    progress = bingo[x*5+y].progress;
    max = bingo[x*5+y].max;
    missions = bingo_missions_masks[x*5+y];
    append_max = bingo_append_max[x*5+y];

    dxr = class'DXRando'.default.dxr;
    if(dxr == None) return 1;// 1==maybe

    currentMission = dxr.dxInfo.missionNumber;
    return class'DXREvents'.static.BingoActiveMission(currentMission, GetBingoMissionMask(x,y));
}

function int GetBingoProgress(string event, optional out int max)
 {
    local int i, progress;

    for (i = 0; i < ArrayCount(bingo); i++) {
        if (bingo[i].event ~= event) {
            max = bingo[i].max;
            return bingo[i].progress;
        }
    }

    max = 1024;
    return 0;
 }

simulated function SetBingoSpot(int x, int y, string event, string desc, int progress, int max, int missions, optional bool append_max)
{
    local int idx;

    idx = x*5+y;

    bingo[idx].event = event;
    bingo[idx].desc = desc;
    bingo[idx].progress = progress;
    bingo[idx].max = max;
    bingo_missions_masks[idx] = missions;
    bingo_append_max[idx] = int(append_max);
}

simulated function int GetBingoMissionMask(int x, int y)
{
    return bingo_missions_masks[x*5+y];
}

simulated function bool GetBingoAppendMax(int x, int y)
{
    return bingo_append_max[x*5+y]==1;
}

simulated function bool IncrementBingoProgress(string event, bool ifNotFailed, string timestamp)
{
    local int i;
    for(i=0; i<ArrayCount(bingo); i++) {
        if(!(bingo[i].event ~= event)) continue;
        if(bingo_missions_masks[i] == ABSOLUTELY_FAILED_MISSION_MASK) {
            log(self$".IncrementBingoProgress("$event$") not incrementing because the goal is already marked as absolutely failed");
            break;
        }
        if(ifNotFailed && (bingo_missions_masks[i] & FAILED_MISSION_MASK)!=0) {
            log(self$".IncrementBingoProgress("$event$") not incrementing because the goal is already marked as probably failed");
            break;
        }
        bingo[i].progress++;
        log("IncrementBingoProgress " $ timestamp @ (i/5) $", " $ int(i%5) @ event$": " $ bingo[i].progress $" / "$ bingo[i].max @ bingo_missions_masks[i], self.class.name);
        ExportBingoState();
        return bingo[i].progress == bingo[i].max;
    }
    return false;
}

simulated function bool MarkBingoAsFailed(string event)
{
    local DXRStats stats;
    local int i;

    if (class'DXREvents'.static.BingoGoalCanFail(event) == false) return false;

    for(i=0; i<ArrayCount(bingo); i++) {
        if(!(bingo[i].event ~= event)) continue;

        if ((bingo_missions_masks[i] & FAILED_MISSION_MASK)!=0) return false;
        if (bingo[i].progress >= bingo[i].max) return false; // don't mark a goal as failed if it's already marked as succeeded

        bingo_missions_masks[i] = bingo_missions_masks[i] | FAILED_MISSION_MASK;
        bingo[i].progress = 0;
        stats = DXRStats(class'DXRStats'.static.Find());
        log("MarkBingoAsFailed "$ stats.GetTotalTimeString() @ (i/5)$", "$ int(i%5) @ event @ bingo_missions_masks[i], self.class.name);
        ExportBingoState();
        return true;
    }

    return false;
}

simulated function CheckForExpiredBingoGoals(DXRando dxr, int missionNum)
{
    local int bingoCampaignMask, i;

    if (dxr.flags.IsBingoCampaignMode()) {
        bingoCampaignMask = class'DXRBingoCampaign'.static.GetBingoMask(dxr.dxInfo.missionNumber, dxr.flags.bingo_duration);
    }

    for(i=0; i<ArrayCount(bingo); i++) {
        if ((bingo_missions_masks[i] & FAILED_MISSION_MASK)!=0) continue; //Skip some extra looping in MarkBingoAsFailed
        if (class'DXREvents'.static.BingoActiveMission(missionNum, bingo_missions_masks[i], bingoCampaignMask)==-1){
            class'DXREvents'.static.MarkBingoAsFailed(bingo[i].event);
        }
    }
}

simulated function string GetBingoDescription(string event)
{
    local int i;
    for(i=0; i<ArrayCount(bingo); i++) {
        if(!(bingo[i].event ~= event)) continue;
        return bingo[i].desc;
    }
    return "";
}

simulated function bool CheckBingo(int sx, int sy, int x, int y)
{
    local int i, hits;

    for(i=0; i<5; i++) {
        if( bingo[x*5+y].progress >= bingo[x*5+y].max ) {
            hits++;
        }
        x += sx;
        y += sy;
    }

    return hits >= 5;
}

simulated function int NumberOfBingos()
{
    local int num, i;

    // check horizontal and vertical lines...
    for(i=0; i<5; i++) {
        if( CheckBingo(1, 0, 0, i) ) num++;
        if( CheckBingo(0, 1, i, 0) ) num++;
    }

    // check diagonal lines
    if( CheckBingo(1, 1, 0, 0) ) num++;
    if( CheckBingo(-1, 1, 4, 0) ) num++;

    return num;
}

// returns the number of bingos if the passed goal was succeeded
simulated function int PreviewNumberOfBingos(coerce string event)
{
    local int realProgress[25], augmentedNum, i;

    for (i = 0; i < 25; i++) {
        realProgress[i] = bingo[i].progress;
        if (bingo_missions_masks[i] != ABSOLUTELY_FAILED_MISSION_MASK && bingo[i].event == event) {
            bingo[i].progress = bingo[i].max;
        }
    }

    augmentedNum = NumberOfBingos();

    for (i = 0; i < 25; i++) {
        bingo[i].progress = realProgress[i];
    }

    return augmentedNum;
}

simulated function ExportBingoState()
{
    local DXRando dxr;
    local int currentMission, i;

    foreach AllActors(class'DXRando', dxr) {
        currentMission = dxr.dxInfo.missionNumber;
        break;
    }

    if(!#defined(hx) && (dxr.OnTitleScreen() || currentMission == 98)) {
        for(i=0; i<ArrayCount(bingo); i++) {
            bingoexport[i].event = "?";
            bingoexport[i].desc = "?";
            bingoexport[i].progress = 0;
            bingoexport[i].max = 1;
            bingoexport[i].active = 0;
        }
        SaveConfig();
        return;
    }

    for(i=0; i<ArrayCount(bingo); i++) {
        bingoexport[i].event = bingo[i].event;
        bingoexport[i].desc = bingo[i].desc;
        bingoexport[i].progress = bingo[i].progress;
        bingoexport[i].max = bingo[i].max;
        bingoexport[i].active = class'DXREvents'.static.BingoActiveMission(currentMission, bingo_missions_masks[i]);
    }

    SaveConfig();
}

simulated function string GetBingoEvent(int i)
{
    return bingo[i].event;
}

simulated function bool IsBanned(string goal)
{
    local int i;

    for(i=0; i < ArrayCount(bannedGoals); i++) {
        if(bannedGoals[i] == "") return false;
        if(bannedGoals[i] == goal) return true;
    }
    return false;
}

simulated function int BanGoal(string goal, int ticks)
{
    local int i;

    for(i=0; i < ArrayCount(bannedGoals); i++) {
        if(bannedGoals[i] == goal || bannedGoals[i] == "") {
            bannedGoals[i] = goal;
            bannedGoalsTimers[i] = ticks;
            return i;
        }
    }
}

simulated function TickUnbanGoals()
{
    local int i, num;

    num = ArrayCount(bannedGoals);
    for(i=0; i < ArrayCount(bannedGoals); i++) {
        if(bannedGoals[i] == "") {
            num = i;
            break;
        }
    }

    for(i=0; i < num; i++) {
        if(bannedGoals[i] == "") return;
        bannedGoalsTimers[i]--;
        if(bannedGoalsTimers[i] <= 0) {
            num--;
            bannedGoalsTimers[i] = bannedGoalsTimers[num];
            bannedGoals[i] = bannedGoals[num];
            bannedGoals[num] = "";
            i--; // repeat this slot
        }
    }
}

simulated function int UnbanGoal(string goal)
{
    local int i, slot, ticks;

    slot = -1;

    for(i=0; i < ArrayCount(bannedGoals); i++) {
        if(bannedGoals[i] == goal) slot = i; // find the goal to be unbanned

        if(bannedGoals[i] == "") { // find next in the array to compress down over the goal to be unbanned
            if(slot == -1) return -1; // goal wasn't banned
            i--;
            bannedGoals[slot] = bannedGoals[i];
            bannedGoals[i] = "";
            ticks = bannedGoalsTimers[slot];
            bannedGoalsTimers[slot] = bannedGoalsTimers[i];
            return ticks;
        }
    }
    if(slot != -1) { // we found the goal, but nothing after it to replace it
        bannedGoals[slot] = "";
        return bannedGoalsTimers[slot];
    }
    return -1;
}

defaultproperties
{
    bDisplayableInv=false
    ItemName="PlayerDataItem"
    bHidden=true
    bHeldItem=true
    InvSlotsX=-1
    InvSlotsY=-1
    Physics=PHYS_None
}
