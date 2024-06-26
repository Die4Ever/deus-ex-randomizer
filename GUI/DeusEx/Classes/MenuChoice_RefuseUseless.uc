class MenuChoice_RefuseUseless extends MenuChoice_ItemRefusal;
#compileif injections

defaultproperties
{
    value=1
    defaultvalue=1
    HelpText="Should cigarettes and zyme be included in the list of Junk items that get dropped when looting a body?"
    actionText="Cigarettes and Zyme"

    refusedItems(0)=class'Cigarettes'
    refusedItems(1)=class'VialCrack'
}
