class MenuChoice_NewGamePlus extends DXRMenuUIChoiceInt;

/* just let DXRFlags take care of this directly
static function bool IsEnabled(DXRFlags f)
{
    return (default.value==2) || (default.value==1 && !f.IsSpeedrunMode());
}
*/

defaultproperties
{
    value=1
    defaultvalue=1
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Should New Game+ be enabled by default? Also adjustable inside Advanced settings via New Game+ Scaling %."
    actionText="New Game+"
    enumText(0)="Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Enabled"
}
