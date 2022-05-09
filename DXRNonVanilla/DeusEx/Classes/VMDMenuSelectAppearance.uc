#ifndef vmd
class DXRVMDMenuSelectAppearanceDummy extends Object;
#else
class DXRVMDMenuSelectAppearance extends VMDMenuSelectAppearance;

var config string last_player_name;

function CreateNameEditWindow()
{
    Super.CreateNameEditWindow();
    editName.SetText(last_player_name);
    DefaultName = last_player_name;
}

function SaveSettings()
{
    Super.SaveSettings();
    last_player_name = editName.GetText();
    SaveConfig();
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    root.PopWindow();
    return true;
}
#endif
