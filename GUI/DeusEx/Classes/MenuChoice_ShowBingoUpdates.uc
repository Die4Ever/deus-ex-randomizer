class MenuChoice_ShowBingoUpdates extends DXRMenuUIChoiceInt;

static function bool IsEnabled(DXRFlags f)
{
    return (default.value==2) ||
           (default.value==1 && !f.IsReducedRando() && !f.IsSpeedrunMode()) ||
           (default.value==1 && f.settings.bingo_win>0);
}

defaultproperties
{
    value=1
    defaultvalue=1
    HelpText="Should bingo goal messages be shown in-game? This is automatically disabled for Zero Rando, Rando Lite, and Speedrun modes."
    actionText="Show Bingo Messages"
    enumText(0)="Bingo Messages Hidden"
    enumText(1)="According to Game Mode"
    enumText(2)="Bingo Messages Shown"
}
