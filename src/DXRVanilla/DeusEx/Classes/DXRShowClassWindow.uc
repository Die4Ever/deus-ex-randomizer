class DXRShowClassWindow injects ShowClassWindow;

var ToolEditWindow custAttribName;
var ToolEditWindow nameFilter;
var ToolEditWindow tagFilter;
var ToolEditWindow eventFilter;
var ToolEditWindow radiusFilter;
var ToolEditWindow customFilterAttrib;
var ToolEditWindow customFilterVal;
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
var ToolCheckboxWindow	chkTextures;

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

    CreateToolLabel(rightX, rightY, "Custom Filter");
    rightY += 20;
    CreateToolLabel(rightX+3, rightY, "Attribute:");
    CreateToolLabel(rightX+97, rightY, "Value:");
    rightY += 15;
    customFilterAttrib = CreateToolEditWindow(rightX, rightY, 91, 64);
    customFilterAttrib.SetText(actorDisplay.GetCustomFilterAttrib());
    customFilterAttrib.SetInsertionPoint(Len(actorDisplay.GetCustomFilterAttrib()) - 1);
    customFilterAttrib.SetSelectedArea(0, Len(actorDisplay.GetCustomFilterAttrib()));
    customFilterVal = CreateToolEditWindow(rightX+94, rightY, 91, 64);
    rightY += 40;
    customFilterVal.SetText(actorDisplay.GetCustomFilterVal());
    customFilterVal.SetInsertionPoint(Len(actorDisplay.GetCustomFilterVal()) - 1);
    customFilterVal.SetSelectedArea(0, Len(actorDisplay.GetCustomFilterVal()));

    // Show inventory
    chkInventory = CreateToolCheckbox(rightX, rightY,  "Show Inventory", actorDisplay.IsInventoryVisible());
    rightY += 25;

    // Show Alliances
    chkAlliances  = CreateToolCheckbox(rightX, rightY,  "Show Alliances", actorDisplay.AreAlliancesVisible());
    rightY += 25;

    // Show Patrol Paths
    chkPatrolPaths = CreateToolCheckbox(rightX, rightY,  "Show Patrol Paths", actorDisplay.ArePatrolPathsVisible());
    rightY += 25;

    // Show Textures
    chkTextures = CreateToolCheckbox(rightX, rightY,  "Show Textures", actorDisplay.AreTexturesVisible());
    rightY += 25;


//////////////////////////////////////////////////
}

function SaveSettings()
{
    Super.SaveSettings();

    actorDisplay.default.viewClass = actorDisplay.GetViewClass();
    actorDisplay.default.bShowEyes = actorDisplay.AreEyesVisible();
    actorDisplay.default.bShowArea = actorDisplay.IsAreaVisible();
    actorDisplay.default.bShowCylinder = actorDisplay.IsCylinderVisible();
    actorDisplay.default.bShowMesh = actorDisplay.IsMeshVisible();
    actorDisplay.default.bShowZone = actorDisplay.IsZoneVisible();
    actorDisplay.default.bShowLineOfSight = actorDisplay.IsLOSVisible();
    // actorDisplay.default.bShowData = actorDisplay.bShowData;
    actorDisplay.default.bShowVisibility = actorDisplay.IsVisibilityVisible();
    actorDisplay.default.bShowState = actorDisplay.IsStateVisible();
    actorDisplay.default.bShowEnemy = actorDisplay.IsEnemyVisible();
    actorDisplay.default.bShowInstigator = actorDisplay.IsInstigatorVisible();
    actorDisplay.default.bShowBase = actorDisplay.IsBaseVisible();
    actorDisplay.default.bShowOwner = actorDisplay.IsOwnerVisible();
    actorDisplay.default.bShowBindName = actorDisplay.IsBindNameVisible();
    actorDisplay.default.bShowLightLevel = actorDisplay.IsLightVisible();
    actorDisplay.default.bShowDist = actorDisplay.IsDistVisible();
    actorDisplay.default.bShowPos = actorDisplay.IsPosVisible();
    actorDisplay.default.bShowHealth = actorDisplay.IsHealthVisible();
    actorDisplay.default.bShowMass = actorDisplay.IsMassVisible();
    actorDisplay.default.bShowPhysics = actorDisplay.ArePhysicsVisible();
    actorDisplay.default.bShowVelocity = actorDisplay.IsVelocityVisible();
    actorDisplay.default.bShowAcceleration= actorDisplay.IsAccelerationVisible();
    actorDisplay.default.bShowLastRendered = actorDisplay.IsLastRenderedVisible();
    actorDisplay.default.bShowEnemyResponse = actorDisplay.IsEnemyResponseVisible();
    // actorDisplay.default.maxPoints = actorDisplay.maxPoints;
    // actorDisplay.default.sinTable = actorDisplay.sinTable;

    actorDisplay.SetNameFilter(nameFilter.GetText());
    actorDisplay.default.nameFilter = actorDisplay.GetNameFilter();
    actorDisplay.SetTagFilter(tagFilter.GetText());
    actorDisplay.default.tagFilter = actorDisplay.GetTagFilter();
    actorDisplay.SetEventFilter(eventFilter.GetText());
    actorDisplay.default.eventFilter = actorDisplay.GetEventFilter();
    actorDisplay.SetCustomAttrib(custAttribName.GetText());
    actorDisplay.default.customAttrib = actorDisplay.GetCustomAttrib();
    actorDisplay.ShowCustom(chkCustom.GetToggle());
    actorDisplay.default.bShowCustom = actorDisplay.IsCustomVisible();
    actorDisplay.SetCustomFilterAttrib(customFilterAttrib.GetText());
    actorDisplay.default.customFilterAttrib = actorDisplay.GetCustomFilterAttrib();
    actorDisplay.SetCustomFilterVal(customFilterVal.GetText());
    actorDisplay.default.customFilterVal = actorDisplay.GetCustomFilterVal();

    actorDisplay.ShowInventory(chkInventory.GetToggle());
    actorDisplay.default.bShowInventory = actorDisplay.IsInventoryVisible();
    actorDisplay.ShowAlliances(chkAlliances.GetToggle());
    actorDisplay.default.bShowAlliances = actorDisplay.AreAlliancesVisible();
    actorDisplay.ShowTagEvent(chkTagEvent.GetToggle());
    actorDisplay.default.bShowTagEvent = actorDisplay.IsTagEventVisible();
    actorDisplay.ShowTagConns(chkTagConns.GetToggle());
    actorDisplay.default.bShowTagConnections = actorDisplay.IsTagConnsVisible();
    actorDisplay.ShowEventConns(chkEventConns.GetToggle());
    actorDisplay.default.bShowEventConnections = actorDisplay.IsEventConnsVisible();
    actorDisplay.ShowCollision(chkCollision.GetToggle());
    actorDisplay.default.bShowCollision = actorDisplay.IsCollisionVisible();
    actorDisplay.ShowTextTags(chkTextTags.GetToggle());
    actorDisplay.default.bShowTextTags = actorDisplay.AreTextTagsVisible();
    actorDisplay.ShowWeaponScores(chkWeaponScore.GetToggle());
    actorDisplay.default.bShowWeaponScore = actorDisplay.AreWeaponScoresVisible();
    actorDisplay.ShowReactions(chkReactions.GetToggle());
    actorDisplay.default.bShowReactions = actorDisplay.AreReactionsVisible();
    actorDisplay.ShowPatrolPaths(chkPatrolPaths.GetToggle());
    actorDisplay.default.bShowPatrolPaths = actorDisplay.ArePatrolPathsVisible();
    actorDisplay.ShowTextures(chkTextures.GetToggle());
    actorDisplay.default.bShowTextures = actorDisplay.AreTexturesVisible();

    actorDisplay.LimitRadius(chkLimitRadius.GetToggle());
    actorDisplay.default.bLimitRadius = actorDisplay.IsRadiusLimited();
    actorDisplay.SetActorRadius(radiusFilter.GetText());
    actorDisplay.default.actorRadius = actorDisplay.GetActorRadius();
}
