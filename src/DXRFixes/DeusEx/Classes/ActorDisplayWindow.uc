class ActorDisplayWindow injects ActorDisplayWindow;
// legend, for searching

var Font textfont;
var bool bShowHidden;
var bool bUserFriendlyNames;

var bool         bShowCustom;
var string       customAttrib;
var bool         bShowInventory;
var string       nameFilter;
var string       tagFilter;
var string       eventFilter;
var bool         bLimitRadius;
var int          actorRadius;
var bool         bShowTagEvent;
var bool         bShowTagConnections;
var bool         bShowEventConnections;
var bool         bShowCollision;
var bool         bShowTextTags;
var bool         bShowAlliances;

function SetActorRadius(string newRadius)
{
    actorRadius = int(newRadius);
}

function int GetActorRadius(){
    return actorRadius;
}

function LimitRadius(bool bLimit)
{
    bLimitRadius = bLimit;
}

function Bool IsRadiusLimited()
{
	return bLimitRadius;
}

function SetNameFilter(string newFilter)
{
    nameFilter = newFilter;
}

function String GetNameFilter(){
    return nameFilter;
}

function SetTagFilter(string newFilter)
{
    tagFilter = newFilter;
}

function String GetTagFilter(){
    return tagFilter;
}

function SetEventFilter(string newFilter)
{
    eventFilter = newFilter;
}

function String GetEventFilter(){
    return eventFilter;
}

function SetViewClass(Class<Actor> newViewClass)
{
    Super.SetViewClass(newViewClass);
    bShowHidden = true;
    bUserFriendlyNames = false;
}

function ShowLOS(bool bShow)
{
    Super.ShowLOS(bShow);
    bShowHidden = true;
    bUserFriendlyNames = false;
}

function ShowCustom(bool bShow)
{
    bShowCustom = bShow;
}

function Bool IsCustomVisible()
{
	return bShowCustom;
}

function SetCustomAttrib(string newCustomAttrib)
{
    customAttrib = newCustomAttrib;
}

function String GetCustomAttrib(){
    return customAttrib;
}

function bool IsInventoryVisible()
{
    return bShowInventory;
}

function ShowInventory(bool bShow)
{
    bShowInventory = bShow;
}

function bool IsTagEventVisible()
{
    return bShowTagEvent;
}

function ShowTagEvent(bool bShow)
{
    bShowTagEvent = bShow;
}

function bool IsTagConnsVisible()
{
    return bShowTagConnections;
}

function ShowTagConns(bool bShow)
{
    bShowTagConnections = bShow;
}

function bool IsEventConnsVisible()
{
    return bShowEventConnections;
}

function ShowEventConns(bool bShow)
{
    bShowEventConnections = bShow;
}

function bool IsCollisionVisible()
{
    return bShowCollision;
}

function ShowCollision(bool bShow)
{
    bShowCollision = bShow;
}

function bool AreTextTagsVisible()
{
    return bShowTextTags;
}

function ShowTextTags(bool bShow)
{
    bShowTextTags = bShow;
}

function bool AreAlliancesVisible()
{
    return bShowAlliances;
}

function ShowAlliances(bool bShow)
{
    bShowAlliances = bShow;
}


function string GetActorName(Actor a)
{
    local string str;

    // DXRando: we want to show a nicer name for spoilers
    if(DXRGoalMarker(a) != None || DXRLocationMarker(a) != None) {
        str = a.BindName;
    }
    else if(bUserFriendlyNames) {
        if(#var(prefix)Nanokey(a) != None) {
            str = #var(prefix)Nanokey(a).Description;
        }
        else if(#var(prefix)InformationDevices(a) != None) {
            str = class'#var(injectsprefix)InformationDevices'.static.GetHumanNameFromID(#var(prefix)InformationDevices(a));
            if (str==""){
                str = class'#var(injectsprefix)InformationDevices'.static.GetTextTag(#var(prefix)InformationDevices(a));
            }

        }
        else if(ScriptedPawn(a) != None) {
            str = ScriptedPawn(a).FamiliarName;
        }
        else if(Inventory(a) != None) {
            str = Inventory(a).ItemName;
        }
        else if(DeusExDecoration(a) != None) {
            str = DeusExDecoration(a).ItemName;
        }
    }
    if(str == "" || str == "None")
        str = GetPlayerPawn().GetItemName(String(a));

    return str;
}

function DrawColourLine(GC gc, vector point1, vector point2, int r, int g, int b)
{
    local float fromX, fromY;
    local float toX, toY;

    gc.SetStyle(DSTY_Normal);
    if (ConvertVectorToCoordinates(point1, fromX, fromY) && ConvertVectorToCoordinates(point2, toX, toY))
    {
        gc.SetTileColorRGB(r, g, b);
        DrawPoint(gc, fromX, fromY);
        DrawPoint(gc, toX, toY);
        gc.SetTileColorRGB(r, g, b);
        Interpolate(gc, fromX, fromY, toX, toY, 8);
    }
}

//#region DrawWindow
//I just want to change the font :(
function DrawWindow(GC gc)
{
    local float xPos, yPos;
    local float centerX, centerY;
    local float topY, bottomY;
    local float leftX, rightX;
    local int i, j, k, r, g, b;
    local vector tVect;
    local vector cVect;
    local PlayerPawnExt player;
    local Actor trackActor, otherActor;
    local Dispatcher disp;
    local LogicTrigger logic;
    local ScriptedPawn trackPawn;
    local bool bValid;
    local bool bPointValid;
    local float visibility;
    local float dist;
    local float speed;
    local name stateName;
    local float temp;
    local string str,str2;
    local texture skins[9];
    local color mainColor;
    local byte zoneNum;
    local float oldRenderTime;
    local float barOffset;
    local float barValue;
    local float barWidth;
    local DeusExMover dxMover;
    local vector minpos, maxpos;
    local Inventory item;
    local name filter;
    local int radius;
    local FakeMirrorInfo fmi;
    local class<Actor> classToShow;

    minpos = vect(999999, 999999, 999999);
    maxpos = vect(-999999, -999999, -999999);

    Super(Window).DrawWindow(gc);

    if (viewClass == None && nameFilter=="")
        return;

    classToShow = viewClass;
    if ((nameFilter!="" || tagFilter!="" || eventFilter!="") && classToShow==None){
        classToShow=class'Actor';
    }

    player  = GetPlayerPawn();

    if (bShowMesh)
        gc.ClearZ();

    if (nameFilter!="")
        filter = StringToName(nameFilter);

    radius = 999999;
    if (bLimitRadius){
        radius = actorRadius;
    }

    foreach player.RadiusActors(classToShow, trackActor, radius, player.Location)
    {
        if(!bShowHidden && trackActor.bHidden)
            continue;// DXRando: for spoilers buttons

        if (filter!='' && filter!=trackActor.Name)
            continue;
        if (tagFilter!="" && !(tagFilter~=string(trackActor.Tag)))
            continue;
        if (eventFilter!="" && !(eventFilter~=string(trackActor.Event)))
            continue;

        dxMover = DeusExMover(trackActor);
        cVect.X = trackActor.CollisionRadius;
        cVect.Y = trackActor.CollisionRadius;
        cVect.Z = trackActor.CollisionHeight;
        tVect = trackActor.Location;
        if (bShowEyes && (Pawn(trackActor) != None))
            tVect.Z += Pawn(trackActor).BaseEyeHeight;
        if (trackActor == player)
        {
            if (player.bBehindView)
                bPointValid = ConvertVectorToCoordinates(tVect, centerX, centerY);
            else
                bPointValid = FALSE;
        }
        else if (dxMover != None)
        {
            if (!bShowLineOfSight || (player.AICanSee(trackActor, 1, false, true, bShowArea) > 0))  // need a better way to do this
                bPointValid = ConvertVectorToCoordinates(tVect, centerX, centerY);
            else
                bPointValid = FALSE;
        }
        else
        {
            if (!bShowLineOfSight || (player.AICanSee(trackActor, 1, false, true, bShowArea) > 0))
                bPointValid = ConvertVectorToCoordinates(tVect, centerX, centerY);
            else
                bPointValid = FALSE;
        }

        if (bPointValid)
        {
            bValid = FALSE;
            if (bShowArea)
            {
                for (i=-1; i<=1; i+=2)
                {
                    for (j=-1; j<=1; j+=2)
                    {
                        for (k=-1; k<=1; k+=2)
                        {
                            tVect = cVect;
                            tVect.X *= i;
                            tVect.Y *= j;
                            tVect.Z *= k;
                            tVect.X += trackActor.Location.X;
                            tVect.Y += trackActor.Location.Y;
                            tVect.Z += trackActor.Location.Z;
                            if (ConvertVectorToCoordinates(tVect, xPos, yPos))
                            {
                                if (!bValid)
                                {
                                    leftX = xPos;
                                    rightX = xPos;
                                    topY = yPos;
                                    bottomY = yPos;
                                    bValid = TRUE;
                                }
                                else
                                {
                                    Extend(xPos, leftX, rightX);
                                    Extend(yPos, topY, bottomY);
                                }
                            }
                        }
                    }
                }
            }

            if (!bValid)
            {
                leftX = centerX-10;
                rightX = centerX+10;
                topY = centerY-10;
                bottomY = centerY+10;
                bValid = TRUE;
            }

            gc.EnableDrawing(true);
            gc.SetStyle(DSTY_Translucent);
            if (bShowZone)
            {
                zoneNum = trackActor.Region.ZoneNumber;
                if (zoneNum == 0)
                {
                    mainColor.R = 255;
                    mainColor.G = 255;
                    mainColor.B = 255;
                }
                else
                {
                    // The following color algorithm was copied from UnRender.cpp...
                    mainColor.R = (zoneNum*67)&255;
                    mainColor.G = (zoneNum*1371)&255;
                    mainColor.B = (zoneNum*1991)&255;
                }
            }
            else
            {
                mainColor.R = 0;
                mainColor.G = 255;
                mainColor.B = 0;
            }
            gc.SetTileColor(mainColor);
            //#region Show Mesh
            if (bShowMesh)
            {
                SetSkins(trackActor, skins);
                oldRenderTime = trackActor.LastRenderTime;
                gc.DrawActor(trackActor, false, false, true, 1.0, 1.0, None);
                trackActor.LastRenderTime = oldRenderTime;
                ResetSkins(trackActor, skins);
            }
            if (!bShowMesh || bShowArea)
            {
                gc.SetTileColorRGB(mainColor.R/4, mainColor.G/4, mainColor.B/4);
                gc.DrawBox(leftX, topY, 1+rightX-leftX, 1+bottomY-topY, 0, 0, 1, Texture'Solid');
                leftX += 1;
                rightX -= 1;
                topY += 1;
                bottomY -= 1;
                gc.SetTileColorRGB(mainColor.R*3/16, mainColor.G*3/16, mainColor.B*3/16);
                gc.DrawBox(leftX, topY, 1+rightX-leftX, 1+bottomY-topY, 0, 0, 1, Texture'Solid');
                leftX += 1;
                rightX -= 1;
                topY += 1;
                bottomY -= 1;
                gc.SetTileColorRGB(mainColor.R/8, mainColor.G/8, mainColor.B/8);
                gc.DrawBox(leftX, topY, 1+rightX-leftX, 1+bottomY-topY, 0, 0, 1, Texture'Solid');
            }
            //#endregion

            gc.SetStyle(DSTY_Normal);

            if (bShowCylinder) {
                r=0;
                g=0;
                b=0;
                if (FakeMirrorInfo(trackActor)!=None){
                    r=255;
                    g=255;
                    b=255;

                    fmi = FakeMirrorInfo(trackActor);

                    DrawCube(gc, fmi.min_pos, fmi.max_pos, r, g, b);

                } else {
                    if (trackActor.bCollideActors){
                        g=255;
                    } else {
                        r=255;
                    }
                    DrawColourCylinder(gc, trackActor, r, g, b);
                    //DrawCylinder(gc, trackActor);
                }
            }

            if (trackActor.InStasis())
            {
                gc.SetTileColorRGB(0, 255, 0);
                gc.DrawPattern(centerX, centerY-2, 1, 5, 0, 0, Texture'Solid');
                gc.DrawPattern(centerX-2, centerY, 5, 1, 0, 0, Texture'Solid');
            }
            else
            {
                gc.SetTileColorRGB(255, 255, 255);
                gc.DrawPattern(centerX, centerY-3, 1, 7, 0, 0, Texture'Solid');
                gc.DrawPattern(centerX-3, centerY, 7, 1, 0, 0, Texture'Solid');
            }

            str = "";
            //#region Show Tag and Event
            if (bShowTagEvent || bShowData)
            {
                str = str $ "|cf50aff";
                str = str $ "Tag: "$trackActor.Tag  $ CR();

                disp = Dispatcher(trackActor);

                str = str $ "Event: "$trackActor.Event  $ CR();
                if (disp!=None){
                    for(i=0;i<ArrayCount(disp.OutEvents);i++){
                        if (disp.OutEvents[i]!=''){
                            str = str $ "OutDelays["$i$"]: "$disp.OutDelays[i] $ CR();
                            str = str $ "OutEvents["$i$"]: "$disp.OutEvents[i] $ CR();
                        }
                    }
                }

                logic = LogicTrigger(trackActor);
                if (logic!=None) {
                    if(logic.Not) str = str $ "NOT ";
                    str = str $ logic.inGroup1 @ logic.Op @ logic.inGroup2 $ CR();
                    str = str $ logic.in1 @ logic.in2 $ CR();
                }
            }
            //#endregion

            //#region Show Event Conns
            if (bShowEventConnections)
            {
                if (trackActor.Event!=''){
                    foreach player.AllActors(class'Actor',otherActor,trackActor.Event){
                        DrawColourLine(gc,trackActor.Location,otherActor.Location,255,0,0);
                    }
                }
                disp = Dispatcher(trackActor);
                if (disp!=None){
                    for(i=0;i<ArrayCount(disp.OutEvents);i++){
                        if (disp.OutEvents[i]!=''){
                            foreach player.AllActors(class'Actor',otherActor,disp.OutEvents[i]){
                                DrawColourLine(gc,trackActor.Location,otherActor.Location,255,0,0);
                            }
                        }
                    }
                }
            }
            //#endregion

            //#region Show Tag Conns
            if (bShowTagConnections)
            {
                if (trackActor.Tag!=''){
                    foreach player.AllActors(class'Actor',otherActor){
                        if (otherActor.Event == trackActor.Tag){
                            DrawColourLine(gc,trackActor.Location,otherActor.Location,0,255,0);
                        }
                        foreach player.AllActors(class'Dispatcher',disp){
                            for(i=0;i<ArrayCount(disp.OutEvents);i++){
                                if (disp.OutEvents[i]==trackActor.Tag){
                                    DrawColourLine(gc,trackActor.Location,disp.Location,0,255,0);
                                }
                            }
                        }
                    }
                }
            }
            //#endregion

            //#region Show State
            if (bShowState || bShowData)
            {
                stateName = trackActor.GetStateName();
                str = str $ "|p1'" $ stateName $ "'" $ CR();
                trackPawn = ScriptedPawn(trackActor);
                if(trackPawn != None && trackPawn.Enemy != None) {
                    str = str $ "Enemy: " $ trackPawn.Enemy.name $ CR();
                }
            }
            //#endregion

            //#region Show Physics
            if (bShowPhysics || bShowData)
            {
                str = str $ "|c80ff80P=";
                switch (trackActor.Physics)
                {
                    case PHYS_None:
                        str = str $ "PHYS_None";
                        break;
                    case PHYS_Walking:
                        str = str $ "PHYS_Walking";
                        break;
                    case PHYS_Falling:
                        str = str $ "PHYS_Falling";
                        break;
                    case PHYS_Swimming:
                        str = str $ "PHYS_Swimming";
                        break;
                    case PHYS_Flying:
                        str = str $ "PHYS_Flying";
                        break;
                    case PHYS_Rotating:
                        str = str $ "PHYS_Rotating";
                        break;
                    case PHYS_Projectile:
                        str = str $ "PHYS_Projectile";
                        break;
                    case PHYS_Rolling:
                        str = str $ "PHYS_Rolling";
                        break;
                    case PHYS_Interpolating:
                        str = str $ "PHYS_Interpolating";
                        break;
                    case PHYS_MovingBrush:
                        str = str $ "PHYS_MovingBrush";
                        break;
                    case PHYS_Spider:
                        str = str $ "PHYS_Spider";
                        break;
                    case PHYS_Trailer:
                        str = str $ "PHYS_Trailer";
                        break;
                    default:
                        str = str $ "Unknown";
                        break;
                }
                str = str $ CR();
            }
            //#endregion

            //#region Show Mass
            if (bShowMass || bShowData)
            {
                str = str $ "|cff80ffM=";
                str = str $ trackActor.Mass $ CR();
            }
            //#endregion

            //#region Show Enemy
            if (bShowEnemy || bShowData)
            {
                str = str $ "|cff8000E=";
                if (Pawn(trackActor) != None)
                    str = str $ "'" $ Pawn(trackActor).Enemy $ "'" $ CR();
                else
                    str = str $ "n/a" $ CR();
            }
            //#endregion

            //#region Show Instigator
            if (bShowInstigator || bShowData)
            {
                str = str $ "|c0080ffI=";
                str = str $ "'" $ trackActor.Instigator $ "'" $ CR();
            }
            //#endregion

            //#region Show Owner
            if (bShowOwner || bShowData)
            {
                str = str $ "|c80ffffO=";
                str = str $ "'" $ trackActor.Owner $ "'" $ CR();
            }
            //#endregion

            //#region Show Bind Name
            if (bShowBindName || bShowData)
            {
                str = str $ "|c80b0b0N=";
                str = str $ "'" $ trackActor.BindName $ "'" $ CR();
            }
            //#endregion

            //#region Show Base
            if (bShowBase || bShowData)
            {
                str = str $ "|c808080B=";
                str = str $ "'" $ trackActor.Base $ "'" $ CR();
            }
            //#endregion

            //#region Show Last Rendered
            if (bShowLastRendered || bShowData)
            {
                str = str $ "|cffffffR=";
                str = str $ "'" $ trackActor.LastRendered() $ "'" $ CR();
            }
            //#endregion

            //#region Show Light Level
            if (bShowLightLevel || bShowData)
            {
                visibility = trackActor.AIVisibility(false);
                str = str $ "|p4L=" $ visibility*100 $ CR();
            }
            //#endregion

            //#region Show Visibility
            if (bShowVisibility || bShowData)
            {
                visibility = player.AICanSee(trackActor, 1.0, true, true, true);
                str = str $ "|p7V=" $ visibility*100 $ CR();
            }
            //#endregion

            //#region Show Distance
            if (bShowDist || bShowData)
            {
                // It would be soooo much easier to call
                // (trackActor.Location-player.Location).Size(), but noooooo...
                // that's only supported in the Actor class!

                temp = (trackActor.Location.X - player.Location.X);
                dist = temp*temp;
                temp = (trackActor.Location.Y - player.Location.Y);
                dist += temp*temp;
                temp = (trackActor.Location.Z - player.Location.Z);
                dist += temp*temp;
                dist = sqrt(dist);
                str = str $ "|p3D=" $ dist $ CR();
            }
            //#endregion

            //#region Show Position
            if (bShowPos || bShowData)
            {
                str = str $ "|p2";
                str = str $ "X=" $ trackActor.Location.X $ CR() $
                            "Y=" $ trackActor.Location.Y $ CR() $
                            "Z=" $ trackActor.Location.Z $ CR();
            }
            //#endregion

            //#region Show Velocity
            if (bShowVelocity || bShowData)
            {
                speed  = trackActor.Velocity.X*trackActor.Velocity.X;
                speed += trackActor.Velocity.Y*trackActor.Velocity.Y;
                speed += trackActor.Velocity.Z*trackActor.Velocity.Z;
                speed  = sqrt(speed);

                str = str $ "|c8080ff";
                str = str $ "vS=" $ speed $ CR() $
                            "vX=" $ trackActor.Velocity.X $ CR() $
                            "vY=" $ trackActor.Velocity.Y $ CR() $
                            "vZ=" $ trackActor.Velocity.Z $ CR();
            }
            //#endregion

            //#region Show Acceleration
            if (bShowAcceleration || bShowData)
            {
                speed  = trackActor.Acceleration.X*trackActor.Acceleration.X;
                speed += trackActor.Acceleration.Y*trackActor.Acceleration.Y;
                speed += trackActor.Acceleration.Z*trackActor.Acceleration.Z;
                speed  = sqrt(speed);

                str = str $ "|cff8080";
                str = str $ "aS=" $ speed $ CR() $
                            "aX=" $ trackActor.Acceleration.X $ CR() $
                            "aY=" $ trackActor.Acceleration.Y $ CR() $
                            "aZ=" $ trackActor.Acceleration.Z $ CR();
            }
            //#endregion

            //#region Show Health
            if (bShowHealth || bShowData)
            {
                str = str $ "|p6H=";
                if (Pawn(trackActor) != None)
                {
                    str = str $ Pawn(trackActor).Health $ CR();
                    str = str $ Pawn(trackActor).HealthHead $ CR();
                    str = str $ Pawn(trackActor).HealthArmRight $ "-" $ Pawn(trackActor).HealthTorso $ "-" $ Pawn(trackActor).HealthArmLeft $ CR();
                    str = str $ Pawn(trackActor).HealthLegRight $ "-" $ Pawn(trackActor).HealthLegLeft $ CR();

                }
                else if (DeusExDecoration(trackActor) != None)
                    str = str $ DeusExDecoration(trackActor).HitPoints $ CR();
                else
                    str = str $ "n/a" $ CR();
            }
            //#endregion

            barOffset = 0;
            //#region Show Enemy Response
            if (bShowEnemyResponse || bShowData)
            {
                trackPawn = ScriptedPawn(trackActor);
                if (trackPawn != None)
                {
                    barOffset = 8;
                    barWidth  = 50;
                    barValue  = int(FClamp(trackPawn.EnemyReadiness*barWidth+0.5, 1, barWidth));
                    if (trackPawn.EnemyReadiness <= 0)
                        barValue = 0;
                    gc.SetStyle(DSTY_Normal);
                    gc.SetTileColorRGB(64, 64, 64);
                    gc.DrawPattern((leftX+rightX-barWidth)/2, bottomY+5, barWidth, barOffset,
                                   0, 0, Texture'Dithered');
                    if (trackPawn.EnemyReadiness >= 1.0)
                    {
                        if (int(GetPlayerPawn().Level.TimeSeconds*4)%2 == 1)
                            gc.SetTileColorRGB(255, 0, 0);
                        else
                            gc.SetTileColorRGB(255, 255, 255);
                    }
                    else
                        gc.SetTileColor(GetColorScaled(1-trackPawn.EnemyReadiness));
                    gc.DrawPattern((leftX+rightX-barWidth)/2, bottomY+5, barValue, barOffset,
                                   0, 0, Texture'Solid');
                    barOffset += 5;
                }
            }
            //#endregion

            //#region Show Collision
            if (bShowCollision || bShowData)
            {
                str = str $ "|c8080ff";
                str = str $ "CollisionRadius=" $ trackActor.CollisionRadius $ CR() $
                            "CollisionHeight=" $ trackActor.CollisionHeight $ CR() $
                            "bCollideActors=" $ trackActor.bCollideActors $ CR() $
                            "bCollideWorld=" $ trackActor.bCollideWorld $ CR() $
                            "bBlockActors=" $ trackActor.bBlockActors $ CR() $
                            "bBlockPlayers=" $ trackActor.bBlockPlayers $ CR();
            }
            //#endregion

            //#region Show Custom Value
            if(bShowCustom && customAttrib != "") {
                str = str $ customAttrib $ ": " $ trackActor.GetPropertyText(customAttrib) $ CR();
            }
            //#endregion

            //#region Show Text Tags
            if(bShowTextTags || bShowData)
            {
                if (#var(prefix)InformationDevices(trackActor)!=None){
                    str = str $ "|c34d8eb";
                    str2 = class'#var(injectsprefix)InformationDevices'.static.GetTextTag(#var(prefix)InformationDevices(trackActor));
                    str = str $ "TextTag=" $ str2 $ CR();
                    str = str $ "Human=" $ class'#var(injectsprefix)InformationDevices'.static.GetHumanNameFromID(#var(prefix)InformationDevices(trackActor)) $ CR();
                }
            }
            //#endregion

            //#region Show Inventory
            if(bShowInventory){
                item = None;
                bValid=False;
                if (Pawn(trackActor) != None) {
                    item = Pawn(trackActor).Inventory;
                    bValid=True;
                } else if (DeusExCarcass(trackActor)!=None){
                    item = DeusExCarcass(trackActor).Inventory;
                    bValid=True;
                }

                if (bValid){
                    str = str $ "Inventory:" $ CR();
                    for(item = item; item != None; item = item.Inventory) {
                        str = str $ GetActorName(item);
                        if (Ammo(item)!=None){
                            str = str $ " ("$Ammo(item).AmmoAmount$")";
                        }
                        str = str $ CR();
                    }
                }
            }
            //#endregion

            //#region Show Alliances
            if(bShowAlliances){
                trackPawn = ScriptedPawn(trackActor);
                if (trackPawn != None){
                    str = str $ "|c5b4ce6";
                    str = str $ "Alliance:" $ trackPawn.Alliance $ CR();
                    str = str $ "Alliances:" $ CR();
                    for(i=0;i<ArrayCount(trackPawn.InitialAlliances);i++) {
                        if (trackPawn.InitialAlliances[i].AllianceName!=''){
                            str = str $ trackPawn.InitialAlliances[i].AllianceName$": ";
                            switch(trackPawn.GetAllianceType(trackPawn.InitialAlliances[i].AllianceName)){
                                case ALLIANCE_Friendly:
                                    str = str $ "Frnd";
                                    break;
                                case ALLIANCE_Neutral:
                                    str = str $ "Neut";
                                    break;
                                case ALLIANCE_Hostile:
                                    str = str $ "Host";
                                    break;
                            }
                            str = str $ "  I: ";
                            switch(trackPawn.InitialAlliances[i].AllianceLevel){
                                case 1.0:
                                    str = str $ "Frnd";
                                    break;
                                case 0.0:
                                    str = str $ "Neut";
                                    break;
                                case -1.0:
                                    str = str $ "Host";
                                    break;
                            }
                            str = str $ CR();
                        }
                    }
                }
            }
            //#endregion

            if (str != "")
            {
                gc.SetAlignments(HALIGN_Center, VALIGN_Top);
                gc.SetFont(textfont);
                //gc.SetTextColorRGB(visibility*255, visibility*255, visibility*255);
                gc.SetTextColorRGB(0, 255, 0);
                gc.DrawText(leftX-100, bottomY+barOffset+5, 200+rightX-leftX, 280, str);
            }

            gc.SetTextColor(mainColor);
            gc.SetAlignments(HALIGN_Center, VALIGN_Bottom);
            gc.SetFont(textfont);

            gc.DrawText(leftX-50, topY-140, 100+rightX-leftX, 135, GetActorName(trackActor));

            if(trackActor.Location.X < minpos.X)
                minpos.X = trackActor.Location.X;
            if(trackActor.Location.Y < minpos.Y)
                minpos.Y = trackActor.Location.Y;
            if(trackActor.Location.Z < minpos.Z)
                minpos.Z = trackActor.Location.Z;

            if(trackActor.Location.X > maxpos.X)
                maxpos.X = trackActor.Location.X;
            if(trackActor.Location.Y > maxpos.Y)
                maxpos.Y = trackActor.Location.Y;
            if(trackActor.Location.Z > maxpos.Z)
                maxpos.Z = trackActor.Location.Z;
        }
    }

    /*str = "minpos: ("$minpos$")";
    gc.SetTextColor(mainColor);
    gc.SetAlignments(HALIGN_Left, VALIGN_Bottom);
    gc.SetFont(textfont);
    gc.DrawText(5, 150, 500, 20, str);
    str = "maxpos: ("$maxpos$")";
    gc.DrawText(5, 170, 500, 20, str);*/
}
//#endregion

//DrawCylinder, but now it uses colour lines instead of forced white ones
function DrawColourCylinder(GC gc, actor trackActor, int r, int g, int b)
{
    local int         i;
    local vector      topCircle[8];
    local vector      bottomCircle[8];
    local float       topSide, bottomSide;
    local int         numPoints;
    local DeusExMover dxMover;
    local vector      center, area;

    dxMover = DeusExMover(trackActor);
    if (dxMover == None)
    {
        topSide = trackActor.Location.Z + trackActor.CollisionHeight;
        bottomSide = trackActor.Location.Z - trackActor.CollisionHeight;
        for (i=0; i<maxPoints; i++)
        {
            topCircle[i] = trackActor.Location;
            topCircle[i].Z = topSide;
            topCircle[i].X += sinTable[i]*trackActor.CollisionRadius;
            topCircle[i].Y += sinTable[i+maxPoints/4]*trackActor.CollisionRadius;
            bottomCircle[i] = topCircle[i];
            bottomCircle[i].Z = bottomSide;
        }
        numPoints = maxPoints;
    }
    else
    {
        dxMover.ComputeMovementArea(center, area);
        topCircle[0] = center+area*vect(1,1,1);
        topCircle[1] = center+area*vect(1,-1,1);
        topCircle[2] = center+area*vect(-1,-1,1);
        topCircle[3] = center+area*vect(-1,1,1);
        bottomCircle[0] = center+area*vect(1,1,-1);
        bottomCircle[1] = center+area*vect(1,-1,-1);
        bottomCircle[2] = center+area*vect(-1,-1,-1);
        bottomCircle[3] = center+area*vect(-1,1,-1);
        numPoints = 4;
    }

    for (i=0; i<numPoints; i++)
        DrawColourLine(gc, topCircle[i], bottomCircle[i],r,g,b);
    for (i=0; i<numPoints-1; i++)
    {
        DrawColourLine(gc, topCircle[i], topCircle[i+1],r,g,b);
        DrawColourLine(gc, bottomCircle[i], bottomCircle[i+1],r,g,b);
    }
    DrawColourLine(gc, topCircle[i], topCircle[0],r,g,b);
    DrawColourLine(gc, bottomCircle[i], bottomCircle[0],r,g,b);
}

function vector CreateCubeCorner(float x, float y, float z)
{
    local vector v;

    v.X = x;
    v.Y = y;
    v.Z = z;

    return v;
}

function DrawCube(GC gc, vector c1, vector c2, int r, int g, int b)
{
    local vector corners[8];

    corners[0]=CreateCubeCorner(c1.X,c1.Y,c1.Z); //c1
    corners[1]=CreateCubeCorner(c2.X,c1.Y,c1.Z);
    corners[2]=CreateCubeCorner(c2.X,c2.Y,c1.Z);
    corners[3]=CreateCubeCorner(c1.X,c2.Y,c1.Z);
    corners[4]=CreateCubeCorner(c1.X,c1.Y,c2.Z);
    corners[5]=CreateCubeCorner(c2.X,c1.Y,c2.Z);
    corners[6]=CreateCubeCorner(c2.X,c2.Y,c2.Z); //c2
    corners[7]=CreateCubeCorner(c1.X,c2.Y,c2.Z);

    DrawColourLine(gc,corners[0],corners[1],r,g,b); //Top square
    DrawColourLine(gc,corners[1],corners[2],r,g,b); //Top square
    DrawColourLine(gc,corners[2],corners[3],r,g,b); //Top square
    DrawColourLine(gc,corners[3],corners[0],r,g,b); //Top square
    DrawColourLine(gc,corners[0],corners[4],r,g,b); //Verticals
    DrawColourLine(gc,corners[1],corners[5],r,g,b); //Verticals
    DrawColourLine(gc,corners[2],corners[6],r,g,b); //Verticals
    DrawColourLine(gc,corners[3],corners[7],r,g,b); //Verticals
    DrawColourLine(gc,corners[4],corners[5],r,g,b); //Bottom Square
    DrawColourLine(gc,corners[5],corners[6],r,g,b); //Bottom Square
    DrawColourLine(gc,corners[6],corners[7],r,g,b); //Bottom Square
    DrawColourLine(gc,corners[7],corners[4],r,g,b); //Bottom Square

}

defaultproperties
{
    textfont=Font'DeusExUI.FontFixedWidthSmall';
    bShowHidden=true
    bShowLineOfSight=false
    bShowPos=true
}
