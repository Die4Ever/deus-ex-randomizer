class MenuChoice_RefuseUseless extends MenuChoice_ItemRefusal;

defaultproperties
{
    enabled=True
    defaultvalue=True
    HelpText="Should cigarettes and zyme be included in the list of Junk items that get dropped when looting a body?"
    actionText="Drop Cigarettes & Zyme" // text is too long without abreviating "and"
    enumText(0)="Don't Drop"
    enumText(1)="Drop"

    refusedItems(0)=class'Cigarettes'
    refusedItems(1)=class'VialCrack'
}
