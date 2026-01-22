//=============================================================================
// MenuChoice_PasswordAutofill
//=============================================================================

class MenuChoice_PasswordAutofill extends DXRMenuUIChoiceInt;

function SaveSetting()
{
    Super.SaveSetting();
    //Not actually a style change, but a reasonable way to tell FrobDisplayWindow to update its flag info...
    ChangeStyle();
}

static function int GetSetting()
{
    if(default.value == 3) {
        if(class'DXRFlags'.default.bZeroRandoPure) return 0;
        return 2;
    }
    return default.value;
}

//Should the real passwords be shown?
static function bool ShowPasswords()
{
    local int setting;
    setting = GetSetting();
    return ((setting==2) || (setting==4));
}

//Should accounts be shown at all?
static function bool ShowKnownAccounts()
{
    local int setting;
    setting = GetSetting();
    return (setting!=0);
}

//For keypads, should the code automatically be entered?
static function bool InstantlyEnterCode()
{
    local int setting;
    setting = GetSetting();
    return (setting==2);
}


//For computers, should you be able to autofill an account from the list?
static function bool CanAutofill()
{
    local int setting;
    setting = GetSetting();
    return (setting==2);
}


defaultproperties
{
    value=3
    defaultvalue=3
    HelpText="Help with finding randomized passwords from your notes."
    actionText="Password Assistance"
    enumText(0)="No Assistance"            //Vanilla, obviously
    enumText(1)="Mark Known Passwords"     //Passwords are just shown as "Known"
    enumText(2)="Autofill Passwords"       //Passwords are actually shown, you can use the login button on computers, and keypads are used automatically
    enumText(3)="According to Game Mode"   //"No Assistance" in Zero Rando Pure, "Autofill" everywhere else
    enumText(4)="Show Known Passwords"     //Passwords are shown on computers and on keypad highlight, but passwords and codes must be entered manually
}
