class MenuChoice_ShowNewSeed extends DXRMenuUIChoiceInt;

static function bool ShowNewSeed(DXRando dxr)
{
    return default.value == 1 || (default.value == 0 && dxr.flags.moresettings.splits_overlay > 0);
}

defaultproperties
{
    value=0;
    defaultvalue=0
    HelpText="Should the New Seed button be shown on the New Game window?"
    actionText="New Seed Button"
    enumText(0)="According to Game Mode"
    enumText(1)="Show"
    enumText(2)="Don't Show"
}
