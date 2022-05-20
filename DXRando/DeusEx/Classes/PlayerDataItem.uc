class PlayerDataItem extends Inventory;

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
    var travel int progress;
};
var travel BingoSpot bingo[25];

simulated function static PlayerDataItem GiveItem(#var PlayerPawn  p)
{
    local PlayerDataItem i;

    i = PlayerDataItem(p.FindInventoryType(class'PlayerDataItem'));
    if( i == None )
    {
        i = p.Spawn(class'PlayerDataItem');
        i.GiveTo(p);
        log("spawned new "$i$" for "$p);
    }
    return i;
}

final function BindConn(int slot_a, int slot_b, out string val, bool writing)
{
    if( writing )
        conns[slot_a*6 + slot_b] = val;
    else
        val = conns[slot_a*6 + slot_b];
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
