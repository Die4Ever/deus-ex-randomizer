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
var ToolCheckboxWindow	chkPhysics;
var ToolCheckboxWindow	chkConvoInfo;
var ToolCheckboxWindow  chkPartialMatch;
var ToolCheckboxWindow  chkOverlap;
var ToolCheckboxWindow  chkCompAccts;

event InitWindow()
{
    Super(ToolWindow).InitWindow();

    //Super.InitWindow(); //Don't do this for compatibility, do it manually instead...
    VanillaInitWindow();

    SetSize(630,420); //215,420 normally

    CreateDXRandoControls();
}

//So that the base window is consistent across mods...
function VanillaInitWindow()
{
    local String displayClass;

    //Super.InitWindow();

    // Center this window
    //SetSize(215, 420); //We're changing the window size anyway
    SetTitle("Show Class");

    // Get a pointer to the ActorDisplayWindow
    actorDisplay = root.actorDisplay;

    // Create the controls
    //CreateControls();
    VanillaCreateControls();

    // Set focus to the edit control and highlight the text in it.
    if ( actorDisplay.GetViewClass() != None )
    {
        displayClass = String(actorDisplay.GetViewClass());
        editClassName.SetText(displayClass);
        editClassName.SetInsertionPoint(Len(displayClass) - 1);
        editClassName.SetSelectedArea(0, Len(displayClass));
    }
    SetFocusWindow(editClassName);
}

function VanillaCreateControls()
{
    // Labels
    CreateToolLabel(18, 30, "Current View Class:");

    // Edit Control
    editClassName       = CreateToolEditWindow(15, 50, 185, 64);

    // Checkboxes
    chkEyes			= CreateToolCheckbox(15, 90,  "Show |&Eyes", actorDisplay.AreEyesVisible());
    chkArea			= CreateToolCheckbox(15, 115, "Show |&Area", actorDisplay.IsAreaVisible());
    chkCylinder		= CreateToolCheckbox(15, 140, "Show C|&ylinder", actorDisplay.IsCylinderVisible());
    chkMesh			= CreateToolCheckbox(15, 165, "Show |&Mesh", actorDisplay.IsMeshVisible());
    chkLOS          = CreateToolCheckbox(15, 190, "Show |&Line of Sight", actorDisplay.IsLOSVisible());
    chkVisibility   = CreateToolCheckbox(15, 215, "Show |&Visibility", actorDisplay.IsVisibilityVisible());
    chkState        = CreateToolCheckbox(15, 240, "Sho|&w State", actorDisplay.IsStateVisible());
    chkLight        = CreateToolCheckbox(15, 265, "Show Li|&ght Level", actorDisplay.IsLightVisible());
    chkDist         = CreateToolCheckbox(15, 290, "Show |&Distance", actorDisplay.IsDistVisible());
    chkPos          = CreateToolCheckbox(15, 315, "Show |&Position", actorDisplay.IsPosVisible());
    chkHealth       = CreateToolCheckbox(15, 340, "Show |&Health", actorDisplay.IsHealthVisible());

    // Buttons
    btnOK     = CreateToolButton(25,  373, "|&OK");
    btnCancel = CreateToolButton(118, 373, "|&Cancel");
}

function #var(injectsprefix)ActorDisplayWindow GetActorDisplayWindow()
{
#ifdef injections
    return actorDisplay;
#else
    return #var(injectsprefix)ActorDisplayWindow(actorDisplay);
#endif
}

function CreateDXRandoControls()
{
    local #var(injectsprefix)ActorDisplayWindow actorDisplayWin;

    local int leftY,middleY,rightY;
    local int leftX,middleX,rightX;

    actorDisplayWin = GetActorDisplayWindow();

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
    nameFilter.SetText(actorDisplayWin.GetNameFilter());
    nameFilter.SetInsertionPoint(Len(actorDisplayWin.GetNameFilter()) - 1);
    nameFilter.SetSelectedArea(0, Len(actorDisplayWin.GetNameFilter()));

    chkCustom = CreateToolCheckbox(middleX, middleY,  "Show Custom Attribute", actorDisplayWin.IsCustomVisible());
    middleY += 20;

    // Spot to enter the custom attribute to show
    custAttribName = CreateToolEditWindow(middleX+20, middleY, 160, 64);
    middleY += 25;
    custAttribName.SetText(actorDisplayWin.GetCustomAttrib());
    custAttribName.SetInsertionPoint(Len(actorDisplayWin.GetCustomAttrib()) - 1);
    custAttribName.SetSelectedArea(0, Len(actorDisplayWin.GetCustomAttrib()));

    //Limit the actors shown to a radius?
    chkLimitRadius = CreateToolCheckbox(middleX, middleY,  "Limit to Radius", actorDisplayWin.IsRadiusLimited());
    middleY += 15;

    // Spot to enter the radius limit
    radiusFilter = CreateToolEditWindow(middleX+20, middleY, 160, 64);
    middleY += 25;
    radiusFilter.SetText(string(actorDisplayWin.GetActorRadius()));
    radiusFilter.SetInsertionPoint(Len(string(actorDisplayWin.GetActorRadius())) - 1);
    radiusFilter.SetSelectedArea(0, Len(string(actorDisplayWin.GetActorRadius())));

    //Show the tag and event of the actors?
    chkTagEvent = CreateToolCheckbox(middleX, middleY,  "Show Tag and Event", actorDisplayWin.IsTagEventVisible());
    middleY += 25;

    chkTagConns    = CreateToolCheckbox(middleX, middleY,  "Show Connections to Tag (Green)", actorDisplayWin.IsTagConnsVisible());
    middleY += 25;
    chkEventConns  = CreateToolCheckbox(middleX, middleY,  "Show Connections to Event (Red)", actorDisplayWin.IsEventConnsVisible());
    middleY += 25;

    chkCollision  = CreateToolCheckbox(middleX, middleY,  "Show Collision Values", actorDisplayWin.IsCollisionVisible());
    middleY += 25;

    chkTextTags  = CreateToolCheckbox(middleX, middleY,  "Show Text Tags", actorDisplayWin.AreTextTagsVisible());
    middleY += 25;

    chkWeaponScore  = CreateToolCheckbox(middleX, middleY,  "Show Weapon Scores", actorDisplayWin.AreWeaponScoresVisible());
    middleY += 25;

    chkReactions  = CreateToolCheckbox(middleX, middleY,  "Show Reactions", actorDisplayWin.AreReactionsVisible());
    middleY += 25;

    chkConvoInfo  = CreateToolCheckbox(middleX, middleY,  "Show Conversation Info", actorDisplayWin.IsConvoInfoVisible());
    middleY += 25;


////////////////////////////////////////////////////////

    // Right Column
    rightY = 30;
    rightX = 415;

    CreateToolLabel(rightX+3, rightY, "Tag Filter:");
    rightY += 20;
    tagFilter = CreateToolEditWindow(rightX, rightY, 185, 64);
    rightY += 40;
    tagFilter.SetText(actorDisplayWin.GetTagFilter());
    tagFilter.SetInsertionPoint(Len(actorDisplayWin.GetTagFilter()) - 1);
    tagFilter.SetSelectedArea(0, Len(actorDisplayWin.GetTagFilter()));

    CreateToolLabel(rightX+3, rightY, "Event Filter:");
    rightY += 20;
    eventFilter = CreateToolEditWindow(rightX, rightY, 185, 64);
    rightY += 40;
    eventFilter.SetText(actorDisplayWin.GetEventFilter());
    eventFilter.SetInsertionPoint(Len(actorDisplayWin.GetEventFilter()) - 1);
    eventFilter.SetSelectedArea(0, Len(actorDisplayWin.GetEventFilter()));

    CreateToolLabel(rightX, rightY, "Custom Filter");
    rightY += 20;

    CreateToolLabel(rightX+3, rightY, "Attribute:");
    CreateToolLabel(rightX+97, rightY, "Value:");
    rightY += 15;

    customFilterAttrib = CreateToolEditWindow(rightX, rightY, 91, 64);
    customFilterAttrib.SetText(actorDisplayWin.GetCustomFilterAttrib());
    customFilterAttrib.SetInsertionPoint(Len(actorDisplayWin.GetCustomFilterAttrib()) - 1);
    customFilterAttrib.SetSelectedArea(0, Len(actorDisplayWin.GetCustomFilterAttrib()));

    customFilterVal = CreateToolEditWindow(rightX+94, rightY, 91, 64);
    customFilterVal.SetText(actorDisplayWin.GetCustomFilterVal());
    customFilterVal.SetInsertionPoint(Len(actorDisplayWin.GetCustomFilterVal()) - 1);
    customFilterVal.SetSelectedArea(0, Len(actorDisplayWin.GetCustomFilterVal()));
    rightY += 25;

    // Custom Filter, Partial Match
    chkPartialMatch = CreateToolCheckbox(rightX, rightY,  "Partial Match", actorDisplayWin.IsCustomFilterPartialMatch());
    rightY += 35;

    // Show inventory
    chkInventory = CreateToolCheckbox(rightX, rightY,  "Show Inventory", actorDisplayWin.IsInventoryVisible());
    rightY += 25;

    // Show Alliances
    chkAlliances  = CreateToolCheckbox(rightX, rightY,  "Show Alliances", actorDisplayWin.AreAlliancesVisible());
    rightY += 25;

    // Show Patrol Paths
    chkPatrolPaths = CreateToolCheckbox(rightX, rightY,  "Show Patrol Paths", actorDisplayWin.ArePatrolPathsVisible());
    rightY += 25;

    // Show Textures
    chkTextures = CreateToolCheckbox(rightX, rightY,  "Show Textures", actorDisplayWin.AreTexturesVisible());
    rightY += 25;

    // Show Physics
    chkPhysics = CreateToolCheckbox(rightX, rightY,  "Show Physics", actorDisplayWin.ArePhysicsVisible());
    rightY += 25;

    // Show Touching Actors
    chkOverlap = CreateToolCheckbox(rightX, rightY,  "Show Overlapping Actors", actorDisplayWin.AreOverlappedVisible());
    rightY += 25;

    // Show Computer Accounts
    chkCompAccts = CreateToolCheckbox(rightX, rightY,  "Show Computer Accounts", actorDisplayWin.AreComputerAcctsVisible());
    rightY += 25;


//////////////////////////////////////////////////
}

function VanillaSaveSettings()
{
    if ( editClassName.GetText() == "" )
        actorDisplay.SetViewClass(None);
    else
        // let UnrealScript parse the class name for us
        GetPlayerPawn().ConsoleCommand("ShowClass "$editClassName.GetText());

    actorDisplay.ShowEyes(chkEyes.GetToggle());
    actorDisplay.ShowArea(chkArea.GetToggle());
    actorDisplay.ShowCylinder(chkCylinder.GetToggle());
    actorDisplay.ShowMesh(chkMesh.GetToggle());
    actorDisplay.ShowLOS(chkLOS.GetToggle());
    actorDisplay.ShowVisibility(chkVisibility.GetToggle());
    actorDisplay.ShowState(chkState.GetToggle());
    actorDisplay.ShowLight(chkLight.GetToggle());
    actorDisplay.ShowDist(chkDist.GetToggle());
    actorDisplay.ShowPos(chkPos.GetToggle());
    actorDisplay.ShowHealth(chkHealth.GetToggle());
}

function SaveSettings()
{
    local #var(injectsprefix)ActorDisplayWindow actorDisplayWin;

    actorDisplayWin = GetActorDisplayWindow();

    //Super.SaveSettings();
    VanillaSaveSettings();

    actorDisplayWin.default.viewClass = actorDisplayWin.GetViewClass();
    actorDisplayWin.default.bShowEyes = actorDisplayWin.AreEyesVisible();
    actorDisplayWin.default.bShowArea = actorDisplayWin.IsAreaVisible();
    actorDisplayWin.default.bShowCylinder = actorDisplayWin.IsCylinderVisible();
    actorDisplayWin.default.bShowMesh = actorDisplayWin.IsMeshVisible();
    actorDisplayWin.default.bShowZone = actorDisplayWin.IsZoneVisible();
    actorDisplayWin.default.bShowLineOfSight = actorDisplayWin.IsLOSVisible();
    // actorDisplayWin.default.bShowData = actorDisplayWin.bShowData;
    actorDisplayWin.default.bShowVisibility = actorDisplayWin.IsVisibilityVisible();
    actorDisplayWin.default.bShowState = actorDisplayWin.IsStateVisible();
    actorDisplayWin.default.bShowEnemy = actorDisplayWin.IsEnemyVisible();
    actorDisplayWin.default.bShowInstigator = actorDisplayWin.IsInstigatorVisible();
    actorDisplayWin.default.bShowBase = actorDisplayWin.IsBaseVisible();
    actorDisplayWin.default.bShowOwner = actorDisplayWin.IsOwnerVisible();
    actorDisplayWin.default.bShowBindName = actorDisplayWin.IsBindNameVisible();
    actorDisplayWin.default.bShowLightLevel = actorDisplayWin.IsLightVisible();
    actorDisplayWin.default.bShowDist = actorDisplayWin.IsDistVisible();
    actorDisplayWin.default.bShowPos = actorDisplayWin.IsPosVisible();
    actorDisplayWin.default.bShowHealth = actorDisplayWin.IsHealthVisible();
    actorDisplayWin.default.bShowMass = actorDisplayWin.IsMassVisible();
    actorDisplayWin.default.bShowPhysics = actorDisplayWin.ArePhysicsVisible();
    actorDisplayWin.default.bShowVelocity = actorDisplayWin.IsVelocityVisible();
    actorDisplayWin.default.bShowAcceleration= actorDisplayWin.IsAccelerationVisible();
    actorDisplayWin.default.bShowLastRendered = actorDisplayWin.IsLastRenderedVisible();
    actorDisplayWin.default.bShowEnemyResponse = actorDisplayWin.IsEnemyResponseVisible();
    actorDisplayWin.default.bShowConvoInfo = actorDisplayWin.IsConvoInfoVisible();
    // actorDisplayWin.default.maxPoints = actorDisplayWin.maxPoints;
    // actorDisplayWin.default.sinTable = actorDisplayWin.sinTable;

    actorDisplayWin.SetNameFilter(nameFilter.GetText());
    actorDisplayWin.default.nameFilter = actorDisplayWin.GetNameFilter();
    actorDisplayWin.SetTagFilter(tagFilter.GetText());
    actorDisplayWin.default.tagFilter = actorDisplayWin.GetTagFilter();
    actorDisplayWin.SetEventFilter(eventFilter.GetText());
    actorDisplayWin.default.eventFilter = actorDisplayWin.GetEventFilter();
    actorDisplayWin.SetCustomAttrib(custAttribName.GetText());
    actorDisplayWin.default.customAttrib = actorDisplayWin.GetCustomAttrib();
    actorDisplayWin.ShowCustom(chkCustom.GetToggle());
    actorDisplayWin.default.bShowCustom = actorDisplayWin.IsCustomVisible();
    actorDisplayWin.SetCustomFilterPartialMatch(chkPartialMatch.GetToggle());
    actorDisplayWin.default.bCustomFilterPartial = actorDisplayWin.IsCustomFilterPartialMatch();
    actorDisplayWin.SetCustomFilterAttrib(customFilterAttrib.GetText());
    actorDisplayWin.default.customFilterAttrib = actorDisplayWin.GetCustomFilterAttrib();
    actorDisplayWin.SetCustomFilterVal(customFilterVal.GetText());
    actorDisplayWin.default.customFilterVal = actorDisplayWin.GetCustomFilterVal();

    actorDisplayWin.ShowInventory(chkInventory.GetToggle());
    actorDisplayWin.default.bShowInventory = actorDisplayWin.IsInventoryVisible();
    actorDisplayWin.ShowAlliances(chkAlliances.GetToggle());
    actorDisplayWin.default.bShowAlliances = actorDisplayWin.AreAlliancesVisible();
    actorDisplayWin.ShowTagEvent(chkTagEvent.GetToggle());
    actorDisplayWin.default.bShowTagEvent = actorDisplayWin.IsTagEventVisible();
    actorDisplayWin.ShowTagConns(chkTagConns.GetToggle());
    actorDisplayWin.default.bShowTagConnections = actorDisplayWin.IsTagConnsVisible();
    actorDisplayWin.ShowEventConns(chkEventConns.GetToggle());
    actorDisplayWin.default.bShowEventConnections = actorDisplayWin.IsEventConnsVisible();
    actorDisplayWin.ShowCollision(chkCollision.GetToggle());
    actorDisplayWin.default.bShowCollision = actorDisplayWin.IsCollisionVisible();
    actorDisplayWin.ShowTextTags(chkTextTags.GetToggle());
    actorDisplayWin.default.bShowTextTags = actorDisplayWin.AreTextTagsVisible();
    actorDisplayWin.ShowWeaponScores(chkWeaponScore.GetToggle());
    actorDisplayWin.default.bShowWeaponScore = actorDisplayWin.AreWeaponScoresVisible();
    actorDisplayWin.ShowReactions(chkReactions.GetToggle());
    actorDisplayWin.default.bShowReactions = actorDisplayWin.AreReactionsVisible();
    actorDisplayWin.ShowPatrolPaths(chkPatrolPaths.GetToggle());
    actorDisplayWin.default.bShowPatrolPaths = actorDisplayWin.ArePatrolPathsVisible();
    actorDisplayWin.ShowTextures(chkTextures.GetToggle());
    actorDisplayWin.default.bShowTextures = actorDisplayWin.AreTexturesVisible();
    actorDisplayWin.ShowPhysics(chkPhysics.GetToggle());
    actorDisplayWin.default.bShowPhysics = actorDisplayWin.ArePhysicsVisible();
    actorDisplayWin.ShowConvoInfo(chkConvoInfo.GetToggle());
    actorDisplayWin.default.bShowConvoInfo = actorDisplayWin.IsConvoInfoVisible();
    actorDisplayWin.ShowOverlapping(chkOverlap.GetToggle());
    actorDisplayWin.default.bShowOverlap = actorDisplayWin.AreOverlappedVisible();
    actorDisplayWin.ShowComputerAccts(chkCompAccts.GetToggle());
    actorDisplayWin.default.bShowComputerAccts = actorDisplayWin.AreComputerAcctsVisible();

    actorDisplayWin.LimitRadius(chkLimitRadius.GetToggle());
    actorDisplayWin.default.bLimitRadius = actorDisplayWin.IsRadiusLimited();
    actorDisplayWin.SetActorRadius(radiusFilter.GetText());
    actorDisplayWin.default.actorRadius = actorDisplayWin.GetActorRadius();
}
