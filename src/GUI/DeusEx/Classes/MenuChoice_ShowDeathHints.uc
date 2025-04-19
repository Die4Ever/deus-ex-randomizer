//=============================================================================
// MenuChoice_ShowDeathHints
//=============================================================================

class MenuChoice_ShowDeathHints extends DXRMenuUIChoiceInt;

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

static function bool IsEnabled(DXRFlags f)
{
    //
    return (default.value==2) || (default.value==1 && !f.IsZeroRando());
}

defaultproperties
{
    value=1
    defaultvalue=1
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Show hints after you die.  This is automatically disabled for Zero Rando."
    actionText="Death Hints"
    enumText(0)="No Hints Shown"
    enumText(1)="According to Game Mode"
    enumText(2)="Hints Shown"
}
