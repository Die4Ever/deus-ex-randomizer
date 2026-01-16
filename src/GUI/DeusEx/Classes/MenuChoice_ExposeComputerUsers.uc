//=============================================================================
// MenuChoice_ExposeComputerUsers
//=============================================================================

class MenuChoice_ExposeComputerUsers extends DXRMenuUIChoiceInt;

static function bool ShowFullAccountNames()
{
    local int setting;
    setting = GetSetting();
    return (setting==2);
}

static function bool ShowUnknownAccounts()
{
    local int setting;
    setting = GetSetting();
    return (setting>=1);
}

static function int GetSetting()
{
    if(default.value == 3) {
        if(class'DXRFlags'.default.bZeroRando) return 0; //Zero Rando and Zero Rando Plus shouldn't expose more information than necessary
        return 2;
    }
    return default.value;
}

defaultproperties
{
    value=3
    defaultvalue=3
    HelpText="Should computer accounts that you don't have the password for show in the account list?"
    actionText="Show Computer Accounts"
    enumText(0)="Hide Unknown"           //Unknown accounts don't show in the user list
    enumText(1)="Anonymous Accounts"     //Unknown accounts are listed, but with a blanked out name
    enumText(2)="Show All Accounts"      //Unknown account names are fully shown
    enumText(3)="According to Game Mode"
}
