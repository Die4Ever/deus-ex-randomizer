class MenuChoice_BalanceMaps extends MenuChoice_BalanceEtc;

static function bool AnyEnabled()
{
    return (default.value==2) || (default.value==1 && !class'DXRFlags'.default.bZeroRandoPure);
}

static function bool ManyEnabled()
{
    return (default.value==2) || (default.value==1 && !class'DXRFlags'.default.bZeroRando);
}

static function bool AllEnabled()
{
    return (default.value==2) || (default.value==1 && !class'DXRFlags'.default.bReducedRando);
}

defaultproperties
{
    HelpText="Balance changes for maps."
    actionText="Maps Balance Changes"
}
