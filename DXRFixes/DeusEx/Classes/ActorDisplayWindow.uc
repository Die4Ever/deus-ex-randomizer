class ActorDisplayWindow injects ActorDisplayWindow;

var Font textfont;
var bool bShowHidden;
var bool bUserFriendlyNames;

var bool         bShowCustom;
var string       customAttrib;
var bool         bShowInventory;

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

function string GetActorName(Actor a)
{
    local string str;

    // DXRando: we want to show a nicer name for spoilers
    if(DXRGoalMarker(a) != None) {
        str = a.BindName;
    }
    else if(bUserFriendlyNames) {
        if(#var(prefix)Nanokey(a) != None) {
            str = #var(prefix)Nanokey(a).Description;
        }
        else if(#var(prefix)InformationDevices(a) != None) {
            str = string(#var(prefix)InformationDevices(a).textTag);
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

//I just want to change the font :(
function DrawWindow(GC gc)
{
    local float xPos, yPos;
    local float centerX, centerY;
    local float topY, bottomY;
    local float leftX, rightX;
    local int i, j, k;
    local vector tVect;
    local vector cVect;
    local PlayerPawnExt player;
    local Actor trackActor;
    local ScriptedPawn trackPawn;
    local bool bValid;
    local bool bPointValid;
    local float visibility;
    local float dist;
    local float speed;
    local name stateName;
    local float temp;
    local string str;
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

    minpos = vect(999999, 999999, 999999);
    maxpos = vect(-999999, -999999, -999999);

    Super(Window).DrawWindow(gc);

    if (viewClass == None)
        return;

    player  = GetPlayerPawn();

    if (bShowMesh)
        gc.ClearZ();

    foreach player.AllActors(viewClass, trackActor)
    {
        if(!bShowHidden && trackActor.bHidden)
            continue;// DXRando: for spoilers buttons

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

            gc.SetStyle(DSTY_Normal);

            if (bShowCylinder)
                DrawCylinder(gc, trackActor);

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
            if (bShowState || bShowData)
            {
                stateName = trackActor.GetStateName();
                str = str $ "|p1'" $ stateName $ "'" $ CR();
                trackPawn = ScriptedPawn(trackActor);
                if(trackPawn != None && trackPawn.Enemy != None) {
                    str = str $ /*trackPawn.Alliance @*/ "Enemy: " $ trackPawn.Enemy.name $ CR();
                }
            }
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
            if (bShowMass || bShowData)
            {
                str = str $ "|cff80ffM=";
                str = str $ trackActor.Mass $ CR();
            }
            if (bShowEnemy || bShowData)
            {
                str = str $ "|cff8000E=";
                if (Pawn(trackActor) != None)
                    str = str $ "'" $ Pawn(trackActor).Enemy $ "'" $ CR();
                else
                    str = str $ "n/a" $ CR();
            }
            if (bShowInstigator || bShowData)
            {
                str = str $ "|c0080ffI=";
                str = str $ "'" $ trackActor.Instigator $ "'" $ CR();
            }
            if (bShowOwner || bShowData)
            {
                str = str $ "|c80ffffO=";
                str = str $ "'" $ trackActor.Owner $ "'" $ CR();
            }
            if (bShowBindName || bShowData)
            {
                str = str $ "|c80b0b0N=";
                str = str $ "'" $ trackActor.BindName $ "'" $ CR();
            }
            if (bShowBase || bShowData)
            {
                str = str $ "|c808080B=";
                str = str $ "'" $ trackActor.Base $ "'" $ CR();
            }
            if (bShowLastRendered || bShowData)
            {
                str = str $ "|cffffffR=";
                str = str $ "'" $ trackActor.LastRendered() $ "'" $ CR();
            }
            if (bShowLightLevel || bShowData)
            {
                visibility = trackActor.AIVisibility(false);
                str = str $ "|p4L=" $ visibility*100 $ CR();
            }
            if (bShowVisibility || bShowData)
            {
                visibility = player.AICanSee(trackActor, 1.0, true, true, true);
                str = str $ "|p7V=" $ visibility*100 $ CR();
            }
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
            if (bShowPos || bShowData)
            {
                str = str $ "|p2";
                str = str $ "X=" $ trackActor.Location.X $ CR() $
                            "Y=" $ trackActor.Location.Y $ CR() $
                            "Z=" $ trackActor.Location.Z $ CR();
            }
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

            barOffset = 0;
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

            if(bShowCustom && customAttrib != "") {
                str = str $ customAttrib $ ": " $ trackActor.GetPropertyText(customAttrib) $ CR();
            }

            if(bShowInventory && Pawn(trackActor) != None) {
                str = str $ "Inventory:" $ CR();
                for(item = Pawn(trackActor).Inventory; item != None; item = item.Inventory) {
                    str = str $ GetActorName(item) $ CR();
                }
            }

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

defaultproperties
{
    textfont=Font'DeusExUI.FontFixedWidthSmall';
    bShowHidden=true
}
