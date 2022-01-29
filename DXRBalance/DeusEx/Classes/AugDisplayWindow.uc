class AugDisplayWindow injects AugmentationDisplayWindow;

var Actor drawQueue[128];
var int drawQueueLen;

function DrawVisionAugmentation(GC gc)
{
    local int i;
    drawQueueLen = 0;

    _DrawVisionAugmentation(gc);

    for(i=0; i<drawQueueLen; i++) {
        DrawBrush(drawQueue[i], gc);
        drawQueue[i] = None;
    }
    drawQueueLen = 0;
}

function bool IsHeatSource(Actor A)
{
    if ((A.bHidden) && (Player.Level.NetMode != NM_Standalone))
        return False;
    if (A.IsA('Pawn'))
    {
        if (A.IsA('ScriptedPawn'))
            return True;
        else if ( (A.IsA('DeusExPlayer')) && (A != Player) )//DEUS_EX AMSD For multiplayer.
            return True;
        return False;
    }
    else if (A.IsA('DeusExCarcass'))
        return True;
    else if (A.IsA('FleshFragment'))
        return True;
    else if ( (A.IsA('Mover') || A.IsA('Decoration')) && A.bVisionImportant && !A.bHidden)
        return true;
    else
        return False;
}


function SetSkins(Actor actor, out Texture oldSkins[9])
{
    local vector forwards, backwards;
    local float dist;

    if(actor.Mesh == None) {
        dist = VSize(Player.Location - actor.Location);
        forwards = Player.Location + (Vector(Player.ViewRotation) * dist);
        backwards = Player.Location + (Vector(Player.ViewRotation) * (-dist));
        if( VSize(actor.Location - forwards) < VSize(actor.Location - backwards) )
            drawQueue[drawQueueLen++] = actor;
    }
    else
        Super.SetSkins(actor, oldSkins);
}

function ResetSkins(Actor actor, Texture oldSkins[9])
{
    if(actor.Mesh == None) {}
    else
        Super.ResetSkins(actor, oldSkins);
}

function DrawBrush(Actor a, GC gc)
{
    local float boxTLX, boxTLY, boxBRX, boxBRY, width, height;
    class'FrobDisplayWindow'.static.GetActorBox(self, a, 1, boxTLX, boxTLY, boxBRX, boxBRY);
    
    width = boxBRX - boxTLX;
    height = boxBRY - boxTLY;
    //log(self$" DrawBrush "$a @ width @ height);
    gc.DrawPattern(boxTLX, boxTLY, width, height, 0, 0, Texture'Virus_SFX');
    //gc.DrawText(boxTLX, boxTLY, width, height, a.name @ a.bHidden);
}

function _DrawVisionAugmentation(GC gc)
{
    local Vector loc;
    local float boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
    local float x, y, w, h;
    local Actor A;

    boxW = width/2;
    boxH = height/2;
    boxCX = width/2;
    boxCY = height/2;
    boxTLX = boxCX - boxW/2;
    boxTLY = boxCY - boxH/2;
    boxBRX = boxCX + boxW/2;
    boxBRY = boxCY + boxH/2;

    // at level one and higher, enhance heat sources (FLIR)
    // use DrawActor to enhance NPC visibility
    if (visionLevel >= 1)
    {
        // shift the entire screen to dark red (except for the middle box)
        if (player.Level.Netmode == NM_Standalone)
        {
            gc.SetStyle(DSTY_Modulated);
            gc.DrawPattern(0, 0, width, boxTLY, 0, 0, Texture'ConWindowBackground');
            gc.DrawPattern(0, boxBRY, width, height-boxBRY, 0, 0, Texture'ConWindowBackground');
            gc.DrawPattern(0, boxTLY, boxTLX, boxH, 0, 0, Texture'ConWindowBackground');
            gc.DrawPattern(boxBRX, boxTLY, width-boxBRX, boxH, 0, 0, Texture'ConWindowBackground');
            gc.DrawPattern(0, 0, width, boxTLY, 0, 0, Texture'SolidRed');
            gc.DrawPattern(0, boxBRY, width, height-boxBRY, 0, 0, Texture'SolidRed');
            gc.DrawPattern(0, boxTLY, boxTLX, boxH, 0, 0, Texture'SolidRed');
            gc.DrawPattern(boxBRX, boxTLY, width-boxBRX, boxH, 0, 0, Texture'SolidRed');
            gc.SetStyle(DSTY_Translucent);
        }

        // DEUS_EX AMSD In multiplayer, draw green here so that we can draw red actors over it
        if (player.Level.Netmode != NM_Standalone)
        {
            gc.SetStyle(DSTY_Modulated);
            gc.DrawPattern(0, 0, width, height, 0, 0, Texture'VisionBlue');
            gc.DrawPattern(0, 0, width, height, 0, 0, Texture'VisionBlue');
            gc.SetStyle(DSTY_Translucent);
        }
        

        // adjust for the player's eye height
        loc = Player.Location;
        loc.Z += Player.BaseEyeHeight;

        // DEUS_EX AMSD In multiplayer, in order to not let you snipe people hiding in the dark across the map, but not get
        // bad feedback from coloring everything green, we have to make the red non translucent so that scale glow darkens it,
        // instead of fading it out.
        //if (Player.Level.Netmode != NM_Standalone)
            //gc.SetStyle(DSTY_Normal);

        foreach Player.AllActors(class'Actor', A)
        {
            if (ShouldDrawActor(A))
            {
                DrawActor(gc, A, loc);
            }
            else if (ShouldDrawBlinder(A))
            {
                DrawBlinder(gc, A);
            }
        }

        // draw text label
        if (player.Level.Netmode == NM_Standalone)
        {
            gc.GetTextExtent(0, w, h, msgIRAmpActive);
            x = boxTLX + margin;
            y = boxTLY - margin - h;
            gc.SetTextColor(colHeaderText);
            gc.DrawText(x, y, w, h, msgIRAmpActive);
        }
    }

    // shift the middle of the screen green (NV) and increase the contrast
    // DEUS_EX AMSD In singleplayer, draw this here
    // In multiplayer, drawn earlier so you can still see through walls with it.
    if (player.Level.Netmode == NM_Standalone)
    {
        gc.SetStyle(DSTY_Modulated);
        gc.DrawPattern(boxTLX, boxTLY, boxW, boxH, 0, 0, Texture'SolidGreen');
        gc.DrawPattern(boxTLX, boxTLY, boxW, boxH, 0, 0, Texture'SolidGreen');
    }
    gc.SetStyle(DSTY_Normal);

    if (player.Level.NetMode == NM_Standalone)
        DrawDropShadowBox(gc, boxTLX, boxTLY, boxW, boxH);

    // draw text label
    if (player.Level.Netmode == NM_Standalone)
    {
        gc.GetTextExtent(0, w, h, msgLightAmpActive);
        x = boxTLX + margin;
        y = boxTLY + margin;
        gc.SetTextColor(colHeaderText);
        gc.DrawText(x, y, w, h, msgLightAmpActive);
    }
}

function bool ShouldDrawActor(Actor A)
{
    if(A.bHidden)
        return false;
    
    if( visionLevel >= 2 && (Inventory(A) != None || InformationDevices(A) != None || ElectronicDevices(A) != None) )
        return true;
    
    if(!A.bVisionImportant)
        return false;
    
    return IsHeatSource(A) || AutoTurret(A) != None || AutoTurretGun(A) != None || SecurityCamera(A) != None;
}

function bool ShouldDrawBlinder(Actor A)
{
    return A.bVisionImportant && A != VisionBlinder && Player.Level.NetMode != NM_Standalone && A.IsA('ExplosionLight') && Player.LineOfSightTo(A,True);
}

function bool ShouldDrawActorDist(Actor A, float dist)
{
    local float maxDist;
    maxDist = visionLevelvalue;
    if(Player.Level.Netmode != NM_Standalone)
        maxDist /= 2.0;

    if(!IsHeatSource(A))
        maxDist /= 2.0;

    return dist <= maxDist;
}

function DrawActor(GC gc, Actor A, vector loc)
{
    local Texture oldSkins[9];
    local float dist, DrawGlow;

    dist = VSize(A.Location - loc);
    //If within range of vision aug bit
    if ( ShouldDrawActorDist(A, dist) )
    {
        VisionTargetStatus = GetVisionTargetStatus(A);
        SetSkins(A, oldSkins);
        gc.DrawActor(A, False, False, True, 1.0, 2.0, None);
        ResetSkins(A, oldSkins);
    }
    else if ((Player.Level.Netmode != NM_Standalone) && (GetVisionTargetStatus(A) == VISIONENEMY) && (A.Style == STY_Translucent))
    {
        //DEUS_EX AMSD In multiplayer, if looking at a cloaked enemy player within range (greater than see through walls)
        //(If within walls radius he'd already have been seen.
        if ( (dist <= (visionLevelvalue)) && (Player.LineOfSightTo(A,true)) )
        {
            VisionTargetStatus = GetVisionTargetStatus(A);
            SetSkins(A, oldSkins);
            gc.DrawActor(A, False, False, True, 1.0, 2.0, None);
            ResetSkins(A, oldSkins);
        }
    }
    else if (Player.LineOfSightTo(A,true))
    {
        VisionTargetStatus = GetVisionTargetStatus(A);
        SetSkins(A, oldSkins);
        
        if ((Player.Level.NetMode == NM_Standalone) || (dist < VisionLevelValue * 1.5) || (VisionTargetStatus != VISIONENEMY))
        {
            DrawGlow = 2.0;
        }
        else
        {
            // Fadeoff with distance square
            DrawGlow = 2.0 / ((dist / (VisionLevelValue * 1.5)) * (dist / (VisionLevelValue * 1.5)));
            // Don't make the actor harder to see than without the aug.
            //DrawGlow = FMax(DrawGlow,A.ScaleGlow);
            // Set a minimum.
            DrawGlow = FMax(DrawGlow,0.15);
        }
        gc.DrawActor(A, False, False, True, 1.0, DrawGlow, None);
        ResetSkins(A, oldSkins);
    }
}

function DrawBlinder(GC gc, Actor A)
{
    local float BrightDot, dist;
    local float OldFlash, NewFlash;
    local float DrawGlow;
    local float RadianView;
    local vector OldFog, NewFog;

    BrightDot = Normal(Vector(Player.ViewRotation)) dot Normal(A.Location - Player.Location);
    dist = VSize(A.Location - Player.Location);
    
    if (dist > 3000)
        DrawGlow = 0;
    else if (dist < 300)
        DrawGlow = 1;
    else
        DrawGlow = ( 3000 - dist ) / ( 3000 - 300 );
    
    // Calculate view angle in radians.
    RadianView = (Player.FovAngle / 180) * 3.141593;
    
    if ((BrightDot >= Cos(RadianView)) && (DrawGlow > 0.2) && (BrightDot * DrawGlow * 0.9 > 0.2))  //DEUS_EX AMSD .75 is approximately at our view angle edge.
    {
        VisionBlinder = A;
        NewFlash = 10.0 * BrightDot * DrawGlow;
        NewFog = vect(1000,1000,900) * BrightDot * DrawGlow * 0.9;
        OldFlash = player.DesiredFlashScale;
        OldFog = player.DesiredFlashFog * 1000;
        
        // Don't add increase the player's flash above the current newflash.
        NewFlash = FMax(0,NewFlash - OldFlash);
        NewFog.X = FMax(0,NewFog.X - OldFog.X);
        NewFog.Y = FMax(0,NewFog.Y - OldFog.Y);
        NewFog.Z = FMax(0,NewFog.Z - OldFog.Z);
        player.ClientFlash(NewFlash,NewFog);
        player.IncreaseClientFlashLength(4.0*BrightDot*DrawGlow*BrightDot);
    }
}
