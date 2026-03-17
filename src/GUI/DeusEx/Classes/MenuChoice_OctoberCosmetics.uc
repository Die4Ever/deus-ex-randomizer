class MenuChoice_OctoberCosmetics extends DXRMenuUIChoiceInt;

static function bool _ShouldEnable(DXRFlags f)
{
    return f.IsHalloweenMode() || (!f.IsReducedRando() && f.IsOctober());
}

static function bool _ShouldFullyEnable(DXRFlags f)
{
    return f.IsHalloweenMode() || (!f.IsReducedRando() && f.IsHalloween());
}

static function bool SpooksEnabled(DXRFlags f)
{
    return
        (default.value == 1 && _ShouldEnable(f))
        || default.value == 2
        || default.value == 4;
}

static function bool SpooksFullyEnabled(DXRFlags f)
{
    return
        (default.value == 1 && _ShouldFullyEnable(f))
        || default.value == 2
        || default.value == 4;
}

static function bool TintEnabled(DXRFlags f)
{
    return
        (default.value == 1 && _ShouldFullyEnable(f))
        || default.value == 3
        || default.value == 4;
}

static function bool IsHalloweenSeason(DXRFlags f)
{
    return
        (default.value == 1 && _ShouldEnable(f))
        || default.value >= 2;
}

defaultproperties
{
    value=1
    defaultvalue=1
    HelpText="Enable or Disable spiderwebs and jack-o'-lanterns, and screen tint.  This is automatically disabled for Zero Rando and Rando Lite modes."
    actionText="October Cosmetics"
    enumText(0)="Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Webs & Jack-o'-Lanterns Enabled"
    enumText(3)="Spooky Red Tint Enabled"
    enumText(4)="All Enabled"
}
