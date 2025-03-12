class MenuChoice_LockBelt extends DXRMenuUIChoiceInt;

static function bool AddWeapons()
{
    return (default.value==0) || (default.value==1);
}

static function bool AddNonWeapons()
{
    return (default.value==0) || (default.value==2);
}

defaultproperties
{
    value=0
    defaultvalue=0
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Should items automatically get added to your item belt?"
    actionText="Add New Items to Belt"
    enumText(0)="Add All Items"
    enumText(1)="Add Weapons"
    enumText(2)="Add Non-Weapons"
    enumText(3)="Add None"
}
