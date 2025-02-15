class MenuChoice_NewGamePlus extends MenuChoice_AccordingToGameMode;

/* just let DXRFlags take care of this directly
static function bool IsEnabled(DXRFlags f)
{
    return (default.value==2) || (default.value==1 && !f.IsSpeedrunMode());
}
*/

defaultproperties
{
    HelpText="Should New Game+ be enabled by default? Also adjustable inside Advanced settings via New Game+ Scaling %."
    actionText="New Game+"
    enumText(0)="Disabled"
    enumText(2)="Enabled"
}
