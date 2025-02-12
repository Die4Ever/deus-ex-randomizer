class MenuChoice_AccordingToGameMode extends DXRMenuUIChoiceInt;

// works fine in BeginPlay because that only happens when traveling, but flags aren't loaded quickly enough for PostPostBeginPlay when loading a save and the game mode of the title screen was different from the save game
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
    HelpText=""
    actionText=""
    enumText(0)="Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Enabled"
}

