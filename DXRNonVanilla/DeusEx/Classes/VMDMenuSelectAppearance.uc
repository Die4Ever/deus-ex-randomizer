#ifndef vmd
class DXRVMDMenuSelectAppearanceDummy extends Object;
#else
class DXRVMDMenuSelectAppearance extends VMDMenuSelectAppearance;

function CreateNameEditWindow()
{
    Super.CreateNameEditWindow();
    editName.SetText("");
    DefaultName = "";
}

function SaveSettings()
{
    Super.SaveSettings();
    editName.GetText();
    SaveConfig();
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    root.PopWindow();
    return true;
}
#endif
