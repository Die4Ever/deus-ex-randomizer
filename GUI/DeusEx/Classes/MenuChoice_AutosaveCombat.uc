class MenuChoice_AutosaveCombat extends DXRMenuUIChoiceEnum;

var config int autosave_combat;

function PopulateOptions()
{
    enumText[0] = "Wait for combat to finish";
    enumText[1] = "Autosave immediately";
}

function SetInitialOption()
{
    SetValue(autosave_combat);
}

function SaveSetting()
{
    autosave_combat = GetValue();
    SaveConfig();
}

function LoadSetting()
{
    SetValue(autosave_combat);
}

function ResetToDefault()
{
    autosave_combat = default.autosave_combat;
    SetValue(autosave_combat);
    SaveSetting();
}

defaultproperties
{
    autosave_combat=0
    HelpText="Should autosave wait for combat to finish?"
    actionText="Autosave During Combat"
}
