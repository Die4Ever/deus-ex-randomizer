class MenuChoice_RefuseUseless extends MenuChoice_ItemRefusal;

defaultproperties
{
    enabled=True
    defaultvalue=True
    HelpText="Should cigarettes and zyme be dropped when looting a body?"
    actionText="Drop Cigarettes & Zyme"
    enumText(0)="Don't Drop"
    enumText(1)="Drop"

    refusedItems(0)=class'Cigarettes'
    refusedItems(1)=class'VialCrack'
}
