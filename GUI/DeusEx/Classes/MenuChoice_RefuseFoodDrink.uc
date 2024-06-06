class MenuChoice_RefuseFoodDrink extends MenuChoice_ItemRefusal;
#compileif injections

defaultproperties
{
    enabled=False
    defaultvalue=False
    HelpText="Should food and drinks be included in the list of Junk items that get dropped when looting a body?"
    actionText="Drop Food & Drinks"
    enumText(0)="Don't Drop"
    enumText(1)="Drop"

    refusedItems(0)=class'SoyFood'
    refusedItems(1)=class'Candybar'
    refusedItems(2)=class'Sodacan'
    refusedItems(3)=class'Liquor40oz'
    refusedItems(4)=class'LiquorBottle'
    refusedItems(5)=class'WineBottle'
}
