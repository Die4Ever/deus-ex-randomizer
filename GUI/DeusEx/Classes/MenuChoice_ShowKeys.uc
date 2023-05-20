//=============================================================================
// MenuChoice_ShowKeys
//=============================================================================

class MenuChoice_ShowKeys extends DXRMenuUIChoiceBool;

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    Super.SaveSetting();
    //Not actually a style change, but a reasonable way to tell FrobDisplayWindow to update its flag info...
    ChangeStyle();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    enabled=True;
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Show when doors can be opened with a key"
    actionText="Nanokey Assistance"
    enumText(0)="No Assistance"
    enumText(1)="Show Key Info"
}
