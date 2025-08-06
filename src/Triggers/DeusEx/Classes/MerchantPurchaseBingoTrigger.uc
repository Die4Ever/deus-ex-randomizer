class MerchantPurchaseBingoTrigger extends BingoTrigger;

var string           merchantBindName;
var class<Inventory> purchaseItem;
var int              purchasePrice;

function bool DoBingoThing()
{
    local DXRando dxr;
    local BingoTrigger bt;

    if (purchaseItem==None){
        return false;
    }

    class'DXREvents'.static.MarkBingo("MerchantPurchase");  //This is actually surprisingly un-useful
    class'DXREvents'.static.MarkBingo("MerchantPurchase_"$purchaseItem.name);
    class'DXREvents'.static.MarkBingo("MerchantPurchaseBind_"$merchantBindName);
    //mark certain price thresholds?  Eg. Under 500, under 1000, over 1000?

    return true;
}

defaultproperties
{
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bTriggerOnceOnly=false
    bDestroyOthers=false
}
