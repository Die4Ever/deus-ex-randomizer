class MenuChoice_Fog extends DXRMenuUIChoiceBool;

function SaveSetting()
{
    Super.SaveSetting();
    enabled = bool(GetValue());
    if(!enabled) {
        player.ConsoleCommand("set ZoneInfo bFogZone false");
    }
}

defaultproperties
{
    enabled=True
    defaultvalue=True
    HelpText="You can disable fog effects for additional performance in certain areas. Enabling will not take affect until you get to a new map."
    actionText="Fog Effects"
}
