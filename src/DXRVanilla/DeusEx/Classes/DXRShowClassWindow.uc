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
var ToolCheckboxWindow	chkWeaponScore;
var ToolCheckboxWindow	chkReactions;
var ToolCheckboxWindow	chkPatrolPaths;

event InitWindow()
{
    Super.InitWindow();

    SetSize(630,420); //215,420 normally

    CreateDXRandoControls();
}

function CreateDXRandoControls()
{
    local int leftY,middleY,rightY;
    local int leftX,middleX,rightX;

////////////////////////////////////////////////////////

    //Left Column
    leftY = 365;
    leftX = 15;

    //Move the OK and Cancel buttons down
    leftY += 8; //Make them a bit further down than other options
    btnOk.SetPos(leftX+10,leftY);
    btnCancel.SetPos(leftX+103,leftY);


////////////////////////////////////////////////////////

    // Middle Column
    middleY = 30;
    middleX = 215;

    CreateToolLabel(middleX+3, middleY, "Name Filter:");
    middleY += 20;
    nameFilter = CreateToolEditWindow(middleX, middleY, 185, 64);
    middleY += 40;
    nameFilter.SetText(actorDisplay.GetNameFilter());
    nameFilter.SetInsertionPoint(Len(actorDisplay.GetNameFilter()) - 1);
    nameFilter.SetSelectedArea(0, Len(actorDisplay.GetNameFilter()));

    chkCustom = CreateToolCheckbox(middleX, middleY,  "Show Custom Attribute", actorDisplay.IsCustomVisible());
    middleY += 20;

    // Spot to enter the custom attribute to show
    custAttribName = CreateToolEditWindow(middleX+20, middleY, 160, 64);
    middleY += 25;
    custAttribName.SetText(actorDisplay.GetCustomAttrib());
    custAttribName.SetInsertionPoint(Len(actorDisplay.GetCustomAttrib()) - 1);
    custAttribName.SetSelectedArea(0, Len(actorDisplay.GetCustomAttrib()));

    //Limit the actors shown to a radius?
    chkLimitRadius = CreateToolCheckbox(middleX, middleY,  "Limit to Radius", actorDisplay.IsRadiusLimited());
    middleY += 15;

    // Spot to enter the radius limit
    radiusFilter = CreateToolEditWindow(middleX+20, middleY, 160, 64);
    middleY += 25;
    radiusFilter.SetText(string(actorDisplay.GetActorRadius()));
    radiusFilter.SetInsertionPoint(Len(string(actorDisplay.GetActorRadius())) - 1);
    radiusFilter.SetSelectedArea(0, Len(string(actorDisplay.GetActorRadius())));

    //Show the tag and event of the actors?
    chkTagEvent = CreateToolCheckbox(middleX, middleY,  "Show Tag and Event", actorDisplay.IsTagEventVisible());
    middleY += 25;

    chkTagConns    = CreateToolCheckbox(middleX, middleY,  "Show Connections to Tag (Green)", actorDisplay.IsTagConnsVisible());
    middleY += 25;
    chkEventConns  = CreateToolCheckbox(middleX, middleY,  "Show Connections to Event (Red)", actorDisplay.IsEventConnsVisible());
    middleY += 25;

    chkCollision  = CreateToolCheckbox(middleX, middleY,  "Show Collision Values", actorDisplay.IsCollisionVisible());
    middleY += 25;

    chkTextTags  = CreateToolCheckbox(middleX, middleY,  "Show Text Tags", actorDisplay.AreTextTagsVisible());
    middleY += 25;

    chkWeaponScore  = CreateToolCheckbox(middleX, middleY,  "Show Weapon Scores", actorDisplay.AreWeaponScoresVisible());
    middleY += 25;

    chkReactions  = CreateToolCheckbox(middleX, middleY,  "Show Reactions", actorDisplay.AreReactionsVisible());
    middleY += 25;


////////////////////////////////////////////////////////

    // Right Column
    rightY = 30;
    rightX = 415;

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

    // Show inventory
    chkInventory = CreateToolCheckbox(rightX, rightY,  "Show Inventory", actorDisplay.IsInventoryVisible());
    rightY += 25;

    // Show Alliances
    chkAlliances  = CreateToolCheckbox(rightX, rightY,  "Show Alliances", actorDisplay.AreAlliancesVisible());
    rightY += 25;

    // Show Patrol Paths
    chkPatrolPaths = CreateToolCheckbox(rightX, rightY,  "Show Patrol Paths", actorDisplay.ArePatrolPathsVisible());
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
    actorDisplay.ShowWeaponScores(chkWeaponScore.GetToggle());
    actorDisplay.ShowReactions(chkReactions.GetToggle());
    actorDisplay.ShowPatrolPaths(chkPatrolPaths.GetToggle());

    actorDisplay.LimitRadius(chkLimitRadius.GetToggle());
    actorDisplay.SetActorRadius(radiusFilter.GetText());
}
