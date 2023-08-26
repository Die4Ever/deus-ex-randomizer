class MenuChoice_ShowTeleporters extends DXRMenuUIChoiceEnum;

var config int show_teleporters;

function PopulateOptions()
{
    enumText[0] = "Hidden";
    enumText[1] = "Visible without descriptions";
    enumText[2] = "Visible with descriptions";
}

function SetInitialOption()
{
    SetValue(show_teleporters);
}

function SaveSetting()
{
    local DXRFixup f;
    show_teleporters = GetValue();
    SaveConfig();

    foreach player.AllActors(class'DXRFixup', f) {
        f.ShowTeleporters();
    }
}

function LoadSetting()
{
    SetValue(show_teleporters);
}

function ResetToDefault()
{
    show_teleporters = default.show_teleporters;
    SetValue(show_teleporters);
    SaveSetting();
}

defaultproperties
{
    show_teleporters=2
    HelpText="Visible icons for teleporters with text descriptions."
    actionText="Teleporter Icons"
}
