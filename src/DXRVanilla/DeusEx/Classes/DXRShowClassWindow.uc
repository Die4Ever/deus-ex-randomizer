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
var ToolCheckboxWindow	chkCollision;
var ToolCheckboxWindow	chkTextTags;
var ToolCheckboxWindow	chkAlliances;

event InitWindow()
{
    Super.InitWindow();

    SetSize(420,470); //215,420 normally

    CreateDXRandoControls();
}

function CreateDXRandoControls()
{
    local int leftY,rightY;
    local int leftX,rightX;

////////////////////////////////////////////////////////

    //Left Column
    leftY = 365;
    leftX = 15;

    // Show inventory
    chkInventory = CreateToolCheckbox(leftX, leftY,  "Show Inventory", actorDisplay.IsInventoryVisible());
    leftY += 25;

    // Show Alliances
    chkAlliances  = CreateToolCheckbox(leftX, leftY,  "Show Alliances", actorDisplay.AreAlliancesVisible());
    leftY += 25;

    //Move the OK and Cancel buttons down
    leftY += 8; //Make them a bit further down than other options
    btnOk.SetPos(leftX+10,leftY);
    btnCancel.SetPos(leftX+103,leftY);


////////////////////////////////////////////////////////

    // Right Column
    rightY = 30;
    rightX = 215;

    CreateToolLabel(rightX+3, rightY, "Name Filter:");
    rightY += 20;
    nameFilter = CreateToolEditWindow(rightX, rightY, 185, 64);
    rightY += 40;
    nameFilter.SetText(actorDisplay.GetNameFilter());
    nameFilter.SetInsertionPoint(Len(actorDisplay.GetNameFilter()) - 1);
    nameFilter.SetSelectedArea(0, Len(actorDisplay.GetNameFilter()));

    CreateToolLabel(rightX+3, rightY, "Tag Filter:");
    rightY += 20;
    tagFilter = CreateToolEditWindow(rightX, rightY, 185, 64);
    rightY += 40;
    tagFilter.SetText(actorDisplay.GetTagFilter());
    tagFilter.SetInsertionPoint(Len(actorDisplay.GetTagFilter()) - 1);
    tagFilter.SetSelectedArea(0, Len(actorDisplay.GetTagFilter()));

    CreateToolLabel(rightX+3, rightY, "Event Filter:");
    rightY += 20;
    eventFilter = CreateToolEditWindow(rightX, rightY, 185, 64);
    rightY += 40;
    eventFilter.SetText(actorDisplay.GetEventFilter());
    eventFilter.SetInsertionPoint(Len(actorDisplay.GetEventFilter()) - 1);
    eventFilter.SetSelectedArea(0, Len(actorDisplay.GetEventFilter()));

    chkCustom = CreateToolCheckbox(rightX, rightY,  "Show Custom Attribute", actorDisplay.IsCustomVisible());
    rightY += 20;

    // Spot to enter the custom attribute to show
    custAttribName = CreateToolEditWindow(rightX+20, rightY, 160, 64);
    rightY += 25;
    custAttribName.SetText(actorDisplay.GetCustomAttrib());
    custAttribName.SetInsertionPoint(Len(actorDisplay.GetCustomAttrib()) - 1);
    custAttribName.SetSelectedArea(0, Len(actorDisplay.GetCustomAttrib()));

    //Limit the actors shown to a radius?
    chkLimitRadius = CreateToolCheckbox(rightX, rightY,  "Limit to Radius", actorDisplay.IsRadiusLimited());
    rightY += 15;

    // Spot to enter the radius limit
    radiusFilter = CreateToolEditWindow(rightX+20, rightY, 160, 64);
    rightY += 25;
    radiusFilter.SetText(string(actorDisplay.GetActorRadius()));
    radiusFilter.SetInsertionPoint(Len(string(actorDisplay.GetActorRadius())) - 1);
    radiusFilter.SetSelectedArea(0, Len(string(actorDisplay.GetActorRadius())));

    //Show the tag and event of the actors?
    chkTagEvent = CreateToolCheckbox(rightX, rightY,  "Show Tag and Event", actorDisplay.IsTagEventVisible());
    rightY += 25;

    chkTagConns    = CreateToolCheckbox(rightX, rightY,  "Show Connections to Tag (Green)", actorDisplay.IsTagConnsVisible());
    rightY += 25;
    chkEventConns  = CreateToolCheckbox(rightX, rightY,  "Show Connections to Event (Red)", actorDisplay.IsEventConnsVisible());
    rightY += 25;

    chkCollision  = CreateToolCheckbox(rightX, rightY,  "Show Collision Values", actorDisplay.IsCollisionVisible());
    rightY += 25;

    chkTextTags  = CreateToolCheckbox(rightX, rightY,  "Show Text Tags", actorDisplay.AreTextTagsVisible());
    rightY += 25;

//////////////////////////////////////////////////
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
    actorDisplay.ShowAlliances(chkAlliances.GetToggle());
    actorDisplay.ShowTagEvent(chkTagEvent.GetToggle());
    actorDisplay.ShowTagConns(chkTagConns.GetToggle());
    actorDisplay.ShowEventConns(chkEventConns.GetToggle());
    actorDisplay.ShowCollision(chkCollision.GetToggle());
    actorDisplay.ShowTextTags(chkTextTags.GetToggle());

    actorDisplay.LimitRadius(chkLimitRadius.GetToggle());
    actorDisplay.SetActorRadius(radiusFilter.GetText());
}
