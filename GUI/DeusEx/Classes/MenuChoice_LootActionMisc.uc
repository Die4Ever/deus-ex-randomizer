class MenuChoice_LootActionMisc extends MenuChoice_LootAction;
#compileif injections

defaultproperties
{
    HelpText="Should rebreathers, tech goggles, binoculars and flares be included in the list of Junk items that get dropped when looting a body?"
    actionText="Miscellaneous"

    itemClasses(0)=class'Rebreather'
    itemClasses(1)=class'TechGoggles'
    itemClasses(2)=class'Binoculars'
    itemClasses(3)=class'Flare'
}
