class MenuChoice_RefuseMisc extends MenuChoice_ItemRefusal;
#compileif injections

defaultproperties
{
    HelpText="Should rebreathers, tech goggles, binoculars and flares be included in the list of Junk items that get dropped when looting a body?"
    actionText="Miscellaneous"

    refusedItems(0)=class'Rebreather'
    refusedItems(1)=class'TechGoggles'
    refusedItems(2)=class'Binoculars'
    refusedItems(3)=class'Flare'
}
