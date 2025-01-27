class MenuChoice_Fog extends DXRMenuUIChoiceBool;

function SaveSetting()
{
    local DXRBrightness b;

    Super.SaveSetting();
    enabled = bool(GetValue());
    b = DXRBrightness(class'DXRBrightness'.static.Find());
    b.ApplyFog(enabled);
}

defaultproperties
{
    enabled=True
    defaultvalue=True
    HelpText="You can disable fog effects for additional performance in certain areas."
    actionText="Fog Effects"
}
