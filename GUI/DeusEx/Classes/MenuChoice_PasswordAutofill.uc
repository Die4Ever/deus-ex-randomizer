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
    local DXRando dxr;
    if(default.value == 3) {
        dxr = class'DXRando'.default.dxr;
        if(dxr==None) return 2;
        if(dxr.flags.IsZeroRandoPure()) return 0;
        return 2;
    }
    return default.value;
}

defaultproperties
{
    value=3
    defaultvalue=3
    HelpText="Help with finding randomized passwords from your notes."
    actionText="Password Assistance"
    enumText(0)="No Assistance"
    enumText(1)="Mark Known Passwords"
    enumText(2)="Autofill Passwords"
    enumText(3)="According to Game Mode"
}
