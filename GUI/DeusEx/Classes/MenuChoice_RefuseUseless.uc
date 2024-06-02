class MenuChoice_RefuseUseless extends MenuChoice_ItemRefusal;

defaultproperties
{
    enabled=True
    defaultvalue=True
    HelpText="When starting a new game, should cigarettes and zyme be added to the list of Junk items that get dropped when looting a corpse?"
    actionText="Cigarettes and Zyme"
    enumText(0)="Not Junk"
    enumText(1)="Junk"

    refusedItems(0)=class'Cigarettes'
    refusedItems(1)=class'VialCrack'
}
