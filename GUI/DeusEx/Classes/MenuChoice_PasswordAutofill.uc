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

defaultproperties
{
    value=2;
    defaultvalue=2
    HelpText="Help with finding randomized passwords from your notes."
    actionText="Password Assistance"
    enumText(0)="No Assistance"
    enumText(1)="Mark Known Passwords"
    enumText(2)="Autofill Passwords"
}
