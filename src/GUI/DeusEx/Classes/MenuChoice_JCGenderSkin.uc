//=============================================================================
// MenuChoice_ShowHints
//=============================================================================

class MenuChoice_JCGenderSkin extends DXRMenuUIChoiceInt;

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

static function bool IsRandom()
{
    return (default.value==1);
}

static function bool IsRemember()
{
    return (default.value==2);
}

defaultproperties
{
    value=1
    defaultvalue=1
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="What gender and skin of JC should be selected on the new game screen?"
    actionText="JC Gender/Skin"
    enumText(0)="Default"
    enumText(1)="Random"
    enumText(2)="Last Used"
}
