class DXRShowClassWindow injects ShowClassWindow;

var ToolEditWindow custAttribName;
var ToolCheckboxWindow	chkCustom;

event InitWindow()
{
    Super.InitWindow();

    SetSize(420,420); //215,420 normally

    CreateDXRandoControls();
}

function CreateDXRandoControls()
{
    // If you wanted the custom attribute up at the top of the window
    //CreateToolLabel(218, 30, "Custom Attribute:");
    //custAttribName = CreateToolEditWindow(215, 50, 185, 64);


    chkCustom	= CreateToolCheckbox(215, 90,  "Show Custom Attribute", actorDisplay.IsCustomVisible());

    // Spot to enter the custom attribute to show
    custAttribName = CreateToolEditWindow(235, 105, 160, 64);
    custAttribName.SetText(actorDisplay.GetCustomAttrib());
    custAttribName.SetInsertionPoint(Len(actorDisplay.GetCustomAttrib()) - 1);
    custAttribName.SetSelectedArea(0, Len(actorDisplay.GetCustomAttrib()));

}

function SaveSettings()
{
    Super.SaveSettings();

    actorDisplay.SetCustomAttrib(custAttribName.GetText());
    actorDisplay.ShowCustom(chkCustom.GetToggle());

}
