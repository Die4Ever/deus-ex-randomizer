class MenuChoice_BalanceMaps extends MenuChoice_BalanceEtc;

static function bool MinorEnabled()
{
    return default.value>0;
}

static function bool ModerateEnabled()
{
    return (default.value>2) || (default.value==1 && !class'DXRFlags'.default.bZeroRando);
}

static function bool MajorEnabled()
{
    return (default.value>3) || (default.value==1 && !class'DXRFlags'.default.bReducedRando);
}

defaultproperties
{
    HelpText="Balance changes for maps."
    actionText="Maps Balance Changes"
    enumText(0)="All Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Minor Enabled"
    enumText(3)="Moderate Enabled"
    enumText(4)="All Enabled"
}
