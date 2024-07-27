class MenuChoice_LootActionUseless extends MenuChoice_LootAction;
#compileif injections

defaultproperties
{
    value=1
    defaultvalue=1
    HelpText="Should cigarettes and zyme be included in the list of Junk items that get dropped when looting a body?"
    actionText="Cigarettes and Zyme"

    itemClasses(0)=class'Cigarettes'
    itemClasses(1)=class'VialCrack'
}
