class MenuChoice_ToggleMemes extends DXRMenuUIChoiceInt;

static function bool IsEnabled(DXRFlags f)
{
    return (default.value==2) || (default.value==1 && !f.IsReducedRando());
}

defaultproperties
{
    value=1
    HelpText="Enable or Disable cutscene randomization and a few other things. This is automatically disabled for Zero Rando and Rando Lite modes."
    actionText="Memes"
    enumText(0)="Memes Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Memes Enabled"
}
