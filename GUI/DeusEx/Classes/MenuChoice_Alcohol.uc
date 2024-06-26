class MenuChoice_Alcohol extends MenuChoice_ItemRefusal;
#compileif injections

defaultproperties
{
    HelpText="Should alcohol be included in the list of Junk items that get dropped when looting a body, or consumed automatically?"
    actionText="Alcohol"

    refusedItems(0)=class'Liquor40oz'
    refusedItems(1)=class'LiquorBottle'
    refusedItems(2)=class'WineBottle'
    enumText(2)="Consume"
}
