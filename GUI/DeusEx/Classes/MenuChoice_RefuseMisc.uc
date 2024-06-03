class MenuChoice_RefuseMisc extends MenuChoice_ItemRefusal;

defaultproperties
{
    enabled=False
    defaultvalue=False
    HelpText="Should rebreathers, tech goggles, binoculars and flares be included in the list of Junk items that get dropped when looting a body?"
    actionText="Drop Miscellaneous"
    enumText(0)="Don't Drop"
    enumText(1)="Drop"

    refusedItems(0)=class'Rebreather'
    refusedItems(1)=class'TechGoggles'
    refusedItems(2)=class'Binoculars'
    refusedItems(3)=class'Flare'
}
