class MenuChoice_GMDXStamina extends MenuChoice_AccordingToGameMode;

static function bool IsEnabled()
{
    //Only enabled if explicitly enabled, or in Zero Rando (pure)
    return (default.value>=2) || (default.value==1 && class'DXRFlags'.default.bZeroRandoPure);
}

defaultproperties
{
    HelpText="Should the GMDX stamina system be forced on when playing in Hardcore mode?  When disabled, the stamina system must be explicitly enabled.  According to Game Mode is only enabled in Zero Rando."
    actionText="GMDX Stamina"
}
