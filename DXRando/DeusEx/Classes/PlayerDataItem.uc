class PlayerDataItem extends Inventory config(DXRBingo);

var travel bool local_inited;
var travel int version;
#ifdef multiplayer
var travel int SkillPointsTotal;
var travel int SkillPointsAvail;
#endif

var travel int EntranceRandoMissionNumber;
var travel int numConns;
var travel string conns[120];

struct BingoSpot {
    var travel string event;
    var travel string desc;
    var travel int progress;
    var travel int max;
};
var travel BingoSpot bingo[25];
var travel int bingo_missions_masks[25];// can't be inside the travel struct because that breaks compatibility with old saves

struct BingoSpotExport {
    var string event;
    var string desc;
    var int progress;
    var int max;
    var int active;// if the current mission is active, 0 is no, 1 is maybe, 2 is active
};
var transient config BingoSpotExport bingoexport[25];

var travel name readTexts[50];

simulated function static PlayerDataItem GiveItem(#var(PlayerPawn) p)
{
    local PlayerDataItem i;

    i = PlayerDataItem(p.FindInventoryType(class'PlayerDataItem'));
    if( i == None )
    {
        i = p.Spawn(class'PlayerDataItem');
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
    n.version = o.version;
#ifdef multiplayer
    n.SkillPointsTotal = o.SkillPointsTotal;
    n.SkillPointsAvail = o.SkillPointsAvail;
#endif

    o.Destroy();
    n.GiveTo(p);
    log("spawned new "$n$" for "$p);
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


simulated function int GetBingoSpot(int x, int y, out string event, out string desc, out int progress, out int max)
{
    local DXRando dxr;
    local int currentMission;

    event = bingo[x*5+y].event;
    desc = bingo[x*5+y].desc;
    progress = bingo[x*5+y].progress;
    max = bingo[x*5+y].max;

    foreach AllActors(class'DXRando', dxr) { break; }
    if(dxr == None) return 1;// 1==maybe

    currentMission = dxr.dxInfo.missionNumber;
    return class'DXREvents'.static.BingoActiveMission(currentMission, bingo_missions_masks[x*5+y]);
}

simulated function SetBingoSpot(int x, int y, string event, string desc, int progress, int max, int missions)
{
    bingo[x*5+y].event = event;
    bingo[x*5+y].desc = desc;
    bingo[x*5+y].progress = progress;
    bingo[x*5+y].max = max;
    bingo_missions_masks[x*5+y] = missions;
}

simulated function bool IncrementBingoProgress(string event)
{
    local int i;
    for(i=0; i<ArrayCount(bingo); i++) {
        if(bingo[i].event != event) continue;
        bingo[i].progress++;
        log("IncrementBingoProgress "$event$": " $ bingo[i].progress $" / "$ bingo[i].max, self.class.name);
        ExportBingoState();
        return bingo[i].progress == bingo[i].max;
    }
    return false;
}

simulated function string GetBingoDescription(string event)
{
    local int i;
    for(i=0; i<ArrayCount(bingo); i++) {
        if(bingo[i].event != event) continue;
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

simulated function ExportBingoState()
{
    local DXRando dxr;
    local int currentMission, i;

    foreach AllActors(class'DXRando', dxr) {
        currentMission = dxr.dxInfo.missionNumber;
        break;
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
