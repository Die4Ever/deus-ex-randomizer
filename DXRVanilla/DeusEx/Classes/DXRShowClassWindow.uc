class DXRShowClassWindow injects ShowClassWindow;

var ToolEditWindow custAttribName;
var ToolEditWindow nameFilter;
var ToolEditWindow radiusFilter;
var ToolCheckboxWindow	chkCustom;
var ToolCheckboxWindow	chkInventory;
var ToolCheckboxWindow	chkLimitRadius;
var ToolCheckboxWindow	chkTagEvent;
var ToolCheckboxWindow	chkTagConns;
var ToolCheckboxWindow	chkEventConns;

event InitWindow()
{
    Super.InitWindow();

    SetSize(420,420); //215,420 normally

    CreateDXRandoControls();
}

function CreateDXRandoControls()
{
    // If you wanted the custom attribute up at the top of the window
    CreateToolLabel(218, 30, "Name Filter:");
    nameFilter = CreateToolEditWindow(215, 50, 185, 64);
    nameFilter.SetText(actorDisplay.GetNameFilter());
    nameFilter.SetInsertionPoint(Len(actorDisplay.GetNameFilter()) - 1);
    nameFilter.SetSelectedArea(0, Len(actorDisplay.GetNameFilter()));

    chkCustom = CreateToolCheckbox(215, 90,  "Show Custom Attribute", actorDisplay.IsCustomVisible());

    // Spot to enter the custom attribute to show
    custAttribName = CreateToolEditWindow(235, 105, 160, 64);
    custAttribName.SetText(actorDisplay.GetCustomAttrib());
    custAttribName.SetInsertionPoint(Len(actorDisplay.GetCustomAttrib()) - 1);
    custAttribName.SetSelectedArea(0, Len(actorDisplay.GetCustomAttrib()));

    // Show inventory
    chkInventory = CreateToolCheckbox(215, 130,  "Show Inventory", actorDisplay.IsInventoryVisible());

    //Limit the actors shown to a radius?
    chkLimitRadius = CreateToolCheckbox(215, 155,  "Limit to Radius", actorDisplay.IsRadiusLimited());

    // Spot to enter the radius limit
    radiusFilter = CreateToolEditWindow(235, 170, 160, 64);
    radiusFilter.SetText(string(actorDisplay.GetActorRadius()));
    radiusFilter.SetInsertionPoint(Len(string(actorDisplay.GetActorRadius())) - 1);
    radiusFilter.SetSelectedArea(0, Len(string(actorDisplay.GetActorRadius())));

    //Show the tag and event of the actors?
    chkTagEvent = CreateToolCheckbox(215, 195,  "Show Tag and Event", actorDisplay.IsTagEventVisible());

    chkTagConns    = CreateToolCheckbox(215, 220,  "Show Connections to Tag (Green)", actorDisplay.IsTagConnsVisible());
    chkEventConns  = CreateToolCheckbox(215, 245,  "Show Connections to Event (Red)", actorDisplay.IsEventConnsVisible());

}

function SaveSettings()
{
    Super.SaveSettings();

    actorDisplay.SetNameFilter(nameFilter.GetText());
    actorDisplay.SetCustomAttrib(custAttribName.GetText());
    actorDisplay.ShowCustom(chkCustom.GetToggle());

    actorDisplay.ShowInventory(chkInventory.GetToggle());
    actorDisplay.ShowTagEvent(chkTagEvent.GetToggle());
    actorDisplay.ShowTagConns(chkTagConns.GetToggle());
    actorDisplay.ShowEventConns(chkEventConns.GetToggle());

    actorDisplay.LimitRadius(chkLimitRadius.GetToggle());
    actorDisplay.SetActorRadius(radiusFilter.GetText());
}
