class MenuChoice_RefuseFoodDrink extends MenuChoice_ItemRefusal;

defaultproperties
{
    enabled=False
    defaultvalue=False
    HelpText="When starting a new game, should food and drinks be added to the list of Junk items that get dropped when looting a corpse?"
    actionText="Food and Drinks"
    enumText(0)="Not Junk"
    enumText(1)="Junk"

    refusedItems(0)=class'SoyFood'
    refusedItems(1)=class'Candybar'
    refusedItems(2)=class'Sodacan'
    refusedItems(3)=class'Liquor40oz'
    refusedItems(4)=class'LiquorBottle'
    refusedItems(5)=class'WineBottle'
}
