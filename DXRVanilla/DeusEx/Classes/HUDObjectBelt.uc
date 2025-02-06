class DXRHUDObjectBelt injects HUDObjectBelt;

function UpdateObjectText(int pos)
{
    local int i;

    //Update all belt texts (So that ammo counts are shown correctly)
    for (i=0; i<ArrayCount(objects); i++) {
        if(objects[i] != None) objects[i].UpdateItemText();
    }
}

// DXRando: replace a used item with another of the same type
function RemoveObjectFromBelt(Inventory item)
{
    local int i;
    local int StartPos;
    local Inventory n;

    StartPos = 1;
    if ( (Player != None) && (Player.Level.NetMode != NM_Standalone) && (Player.bBeltIsMPInventory) )
        StartPos = 0;

        for (i=StartPos; IsValidPos(i); i++)
        {
            if (objects[i].GetItem() == item)
            {
                objects[i].SetItem(None);
                item.bInObjectBelt = False;
                item.beltPos = -1;
                if(!item.bDisplayableInv) {
                    for(n=Player.Inventory; n!=None; n=n.Inventory) {
                        if(n==item) continue;
                        if(n.class!=item.class) continue;
                        if(n.Icon==None) continue;
                        if(n.beltPos!=-1) continue;
                        if(!n.bDisplayableInv) continue;
                        if(n.bDeleteMe) continue;
                        AddObjectToBelt(n, i, false);
                        return;
                    }
                }
                return;
            }
        }
}

event DrawWindow(GC gc)
{
    Super.DrawWindow(gc);
    UpdateObjectText(0); //Make sure ammo counts are updated
}
