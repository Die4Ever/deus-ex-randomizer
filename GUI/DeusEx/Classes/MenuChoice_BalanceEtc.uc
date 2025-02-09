class MenuChoice_BalanceEtc extends DXRMenuUIChoiceInt;

// works fine in BeginPlay because that only happens when traveling, but flags aren't loaded quickly enough for PostPostBeginPlay when loading a save and the game mode of the title screen was different from the save game
static function bool IsEnabled()
{
    return (default.value==2) || (default.value==1 && !class'DXRFlags'.default.bZeroRandoPure);
}

static function bool IsDisabled()
{
    return !IsEnabled();
}

event InitWindow()
{
    Super.InitWindow();

    if(!class'DXRInfo'.static.OnTitleScreen()) {
        SetSensitivity(false);
        btnInfo.SetSensitivity(false);
        btnAction.SetSensitivity(false);
    }
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
