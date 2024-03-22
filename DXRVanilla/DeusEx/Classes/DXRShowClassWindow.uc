class DXRShowClassWindow injects ShowClassWindow;

var ToolEditWindow custAttribName;
var ToolEditWindow nameFilter;
var ToolEditWindow tagFilter;
var ToolEditWindow eventFilter;
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
    local int y;

    // If you wanted the custom attribute up at the top of the window
    y = 30;
    CreateToolLabel(218, y, "Name Filter:");
    y += 20;
    nameFilter = CreateToolEditWindow(215, y, 185, 64);
    y += 40;
    nameFilter.SetText(actorDisplay.GetNameFilter());
    nameFilter.SetInsertionPoint(Len(actorDisplay.GetNameFilter()) - 1);
    nameFilter.SetSelectedArea(0, Len(actorDisplay.GetNameFilter()));

    CreateToolLabel(218, y, "Tag Filter:");
    y += 20;
    tagFilter = CreateToolEditWindow(215, y, 185, 64);
    y += 40;
    tagFilter.SetText(actorDisplay.GetTagFilter());
    tagFilter.SetInsertionPoint(Len(actorDisplay.GetTagFilter()) - 1);
    tagFilter.SetSelectedArea(0, Len(actorDisplay.GetTagFilter()));

    CreateToolLabel(218, y, "Event Filter:");
    y += 20;
    eventFilter = CreateToolEditWindow(215, y, 185, 64);
    y += 40;
    eventFilter.SetText(actorDisplay.GetEventFilter());
    eventFilter.SetInsertionPoint(Len(actorDisplay.GetEventFilter()) - 1);
    eventFilter.SetSelectedArea(0, Len(actorDisplay.GetEventFilter()));

    chkCustom = CreateToolCheckbox(215, y,  "Show Custom Attribute", actorDisplay.IsCustomVisible());
    y += 20;

    // Spot to enter the custom attribute to show
    custAttribName = CreateToolEditWindow(235, y, 160, 64);
    y += 25;
    custAttribName.SetText(actorDisplay.GetCustomAttrib());
    custAttribName.SetInsertionPoint(Len(actorDisplay.GetCustomAttrib()) - 1);
    custAttribName.SetSelectedArea(0, Len(actorDisplay.GetCustomAttrib()));

    // Show inventory
    chkInventory = CreateToolCheckbox(215, y,  "Show Inventory", actorDisplay.IsInventoryVisible());
    y += 25;

    //Limit the actors shown to a radius?
    chkLimitRadius = CreateToolCheckbox(215, y,  "Limit to Radius", actorDisplay.IsRadiusLimited());
    y += 15;

    // Spot to enter the radius limit
    radiusFilter = CreateToolEditWindow(235, y, 160, 64);
    y += 25;
    radiusFilter.SetText(string(actorDisplay.GetActorRadius()));
    radiusFilter.SetInsertionPoint(Len(string(actorDisplay.GetActorRadius())) - 1);
    radiusFilter.SetSelectedArea(0, Len(string(actorDisplay.GetActorRadius())));

    //Show the tag and event of the actors?
    chkTagEvent = CreateToolCheckbox(215, y,  "Show Tag and Event", actorDisplay.IsTagEventVisible());
    y += 25;

    chkTagConns    = CreateToolCheckbox(215, y,  "Show Connections to Tag (Green)", actorDisplay.IsTagConnsVisible());
    y += 25;
    chkEventConns  = CreateToolCheckbox(215, y,  "Show Connections to Event (Red)", actorDisplay.IsEventConnsVisible());
    y += 25;

}

function SaveSettings()
{
    Super.SaveSettings();

    actorDisplay.SetNameFilter(nameFilter.GetText());
    actorDisplay.SetTagFilter(tagFilter.GetText());
    actorDisplay.SetEventFilter(eventFilter.GetText());
    actorDisplay.SetCustomAttrib(custAttribName.GetText());
    actorDisplay.ShowCustom(chkCustom.GetToggle());

    actorDisplay.ShowInventory(chkInventory.GetToggle());
    actorDisplay.ShowTagEvent(chkTagEvent.GetToggle());
    actorDisplay.ShowTagConns(chkTagConns.GetToggle());
    actorDisplay.ShowEventConns(chkEventConns.GetToggle());

    actorDisplay.LimitRadius(chkLimitRadius.GetToggle());
    actorDisplay.SetActorRadius(radiusFilter.GetText());
}
