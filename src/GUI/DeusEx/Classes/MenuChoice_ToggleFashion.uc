class MenuChoice_ToggleFashion extends DXRMenuUIChoiceInt;

static function bool IsEnabled(DXRFlags f)
{
    return (default.value==2) || (default.value==1 && !f.IsReducedRando() && !f.IsSeriousRando());
}

defaultproperties
{
    value=1
    defaultvalue=1
    HelpText="Enable or Disable clothing randomization for JC and Paul.  This is automatically disabled for Zero Rando and Rando Lite modes."
    actionText="Fashion"
    enumText(0)="Fashion Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Fashion Enabled"
}
