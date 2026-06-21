class MenuChoice_BalanceMaps extends MenuChoice_BalanceEtc;

static function bool MinorEnabled()
{// enabled even in Zero Rando Pure by default
    return default.value>0;
}

static function bool ModerateEnabled()
{// moderate changes, enabled in Zero Rando Plus and above
    return (default.value>2) || (default.value==1 && !class'DXRFlags'.default.bZeroRandoPure);
}

static function bool AllEnabled()
{// major, enabled in Rando Lite and above
    return (default.value>3) || (default.value==1 && !class'DXRFlags'.default.bReducedRando);
}

static function int EnabledLevel()
{// use for flags hash, and endgame credits display
    if(default.value != 1) return default.value;
    if(class'DXRFlags'.default.bZeroRandoPure) return 2;
    if(class'DXRFlags'.default.bReducedRando) return 3;
    return 4;
}

static function bool IsEnabled()
{// just don't use IsEnabled
    return AllEnabled();
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
