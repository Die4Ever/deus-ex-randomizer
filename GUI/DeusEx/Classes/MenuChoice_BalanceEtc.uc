class MenuChoice_BalanceEtc extends DXRMenuUIChoiceInt;

static function bool IsEnabled()
{
    return (default.value==2) || (default.value==1 && !class'DXRFlags'.default.bZeroRandoPure);
}

static function bool IsDisabled()
{
    return !IsEnabled();
}

defaultproperties
{
    value=1
    defaultvalue=1
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Miscellaneous balance changes."
    actionText="Other Balance Changes"
    enumText(0)="Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Enabled"
}
