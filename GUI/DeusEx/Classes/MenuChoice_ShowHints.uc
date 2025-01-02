//=============================================================================
// MenuChoice_ShowHints
//=============================================================================

class MenuChoice_ShowHints extends DXRMenuUIChoiceInt;

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

static function bool IsEnabled(DXRFlags f)
{
    //
    return (default.value==2) || (default.value==1 && !f.IsZeroRando() && !f.IsSpeedrunMode());
}

defaultproperties
{
    value=1
    defaultvalue=1
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Show hints when a level loads. This is automatically disabled for Zero Rando."
    actionText="Level Start Hints"
    enumText(0)="No Hints Shown"
    enumText(1)="According to Game Mode"
    enumText(2)="Hints Shown"
}
