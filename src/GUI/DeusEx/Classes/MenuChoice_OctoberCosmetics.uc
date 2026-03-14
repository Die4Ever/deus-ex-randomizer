class MenuChoice_OctoberCosmetics extends DXRMenuUIChoiceInt;

static function bool IsEnabled(DXRFlags f)
{
    return default.value == 2 || (default.value == 1 && (f.IsHalloweenMode() || (!f.IsReducedRando() && f.IsOctober())));
}

static function bool IsFullyEnabled(DXRFlags f)
{
    return default.value == 2 || (default.value == 1 && (f.IsHalloweenMode() || (!f.IsReducedRando() && f.IsHalloween())));
}

defaultproperties
{
    value=1
    defaultvalue=1
    HelpText="Enable or Disable spiderwebs and jack-o'-lanterns.  This is automatically disabled for Zero Rando and Rando Lite modes."
    actionText="October Cosmetics"
    enumText(0)="Spooks Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Spooks Enabled"
}
