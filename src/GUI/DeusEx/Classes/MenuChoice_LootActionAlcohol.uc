class MenuChoice_LootActionAlcohol extends MenuChoice_LootAction;
#compileif injections

defaultproperties
{
    HelpText="Should alcohol be included in the list of Junk items that get dropped when looting a body, or get consumed automatically?"
    actionText="Alcohol"

    itemClasses(0)=class'Liquor40oz'
    itemClasses(1)=class'LiquorBottle'
    itemClasses(2)=class'WineBottle'
    enumText(2)="Consume"
}
