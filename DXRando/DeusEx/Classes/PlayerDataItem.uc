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
var travel config BingoSpot bingo[25];

simulated function static PlayerDataItem GiveItem(#var(PlayerPawn) p)
{
    local PlayerDataItem i;

    i = PlayerDataItem(p.FindInventoryType(class'PlayerDataItem'));
    if( i == None )
    {
        i = p.Spawn(class'PlayerDataItem');
        i.InitBingoList();
        i.GiveTo(p);
        log("spawned new "$i$" for "$p);
    }
    i.SaveConfig();
    return i;
}

simulated function static ResetData(#var(PlayerPawn) p)
{
    local PlayerDataItem o, n;
    o = GiveItem(p);
    n = p.Spawn(class'PlayerDataItem');
    n.InitBingoList();

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

simulated function GetBingoSpot(int x, int y, out string event, out string desc, out int progress, out int max)
{
    event = bingo[x*5+y].event;
    desc = bingo[x*5+y].desc;
    progress = bingo[x*5+y].progress;
    max = bingo[x*5+y].max;
}

//This is needed so that we don't actually reuse pre-saved data.
//The saved "config" shouldn't really be loaded back in.
simulated function InitBingoList()
{
    local int i;
    for(i=0; i<ArrayCount(bingo); i++) {
        bingo[i].event = "";
        bingo[i].desc = "";
        bingo[i].progress = 0;
        bingo[i].max = 0;
    }
    SaveConfig();
}

simulated function SetBingoSpot(int x, int y, string event, string desc, int progress, int max)
{
    bingo[x*5+y].event = event;
    bingo[x*5+y].desc = desc;
    bingo[x*5+y].progress = progress;
    bingo[x*5+y].max = max;
}

simulated function bool IncrementBingoProgress(string event)
{
    local int i;
    for(i=0; i<ArrayCount(bingo); i++) {
        if(bingo[i].event != event) continue;
        bingo[i].progress++;
        log("IncrementBingoProgress "$event$": " $ bingo[i].progress $" / "$ bingo[i].max, self.class.name);
        SaveConfig();
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
