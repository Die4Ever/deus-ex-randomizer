class PlayerDataItem extends Inventory;

simulated function static PlayerDataItem GiveItem(#var PlayerPawn  p)
{
    local PlayerDataItem i;

    i = PlayerDataItem(p.FindInventoryType(class'PlayerDataItem'));
    if( i == None )
    {
        i = p.Spawn(class'PlayerDataItem');
        i.GiveTo(p);
        i.SetBase(p);
    }
    return i;
}

defaultproperties
{
    bDisplayableInv=false
    ItemName="PlayerDataItem"
    bHidden=true
}
