class MenuChoice_ShowTeleporters extends DXRMenuUIChoiceInt;

function SaveSetting()
{
    local DXRFixup f;
    Super.SaveSetting();

    foreach player.AllActors(class'DXRFixup', f) {
        f.ShowTeleporters();
    }
}

defaultproperties
{
    value=2
    defaultvalue=2
    enumText(0)="Hidden"
    enumText(1)="Visible without descriptions"
    enumText(2)="Visible with descriptions"
    HelpText="Visible icons for teleporters with text descriptions."
    actionText="Teleporter Icons"
}
