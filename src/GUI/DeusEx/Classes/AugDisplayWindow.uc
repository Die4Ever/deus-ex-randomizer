#dontcompileif hx
#ifdef revision
class DXRAugDisplayWindow injects RevAugmentationDisplayWindow;
#else
class DXRAugDisplayWindow injects AugmentationDisplayWindow;
#endif

var transient bool d3d11;// d3d11 drawing the viewport of targeting aug fills the entire screen, just disable that

var bool bThermalVision;
var bool bMotionSensor;
var bool bVisionEnhancement; // AugVision and Tech Goggles

var float visionLevelValues[6];

function SetActiveVisionAug(Augmentation aug, int level, float str, bool bActive)
{
    local int slot;
    log("SetActiveVisionAug " $ aug @ level @ str @ bActive);
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled() && aug != None) level++;
    else if (class'MenuChoice_BalanceItems'.static.IsDisabled()) { // tech goggles
        level = 0;
        str = 0.1;
    }

    #ifdef injections
    if(aug != None) {
        switch(aug.class) {
        // slot 0 is tech goggles
        case class'AugVision':
            slot = 1;
            bVisionEnhancement = bActive;
            break;
        case class'AugVisionShort':
            slot = 2;
            bVisionEnhancement = bActive;
            break;
        case class'AugInfraVision':
            slot = 3;
            bThermalVision = bActive;
            break;
        case class'AugMotionSensor':
            slot = 4;
            bMotionSensor = bActive;
            break;
        default: // not None but not one of the above?
            log("WARNING: " $ self $ " unknown vision aug: " $ aug @ level @ str @ bActive);
            slot = 5;
            bVisionEnhancement = bActive;
            break;
        }
    } else if(bActive) {
        bVisionEnhancement = true;
    }
    #endif

    if (bActive)
    {
        visionLevel = Max(visionLevel, level);
        visionLevelValues[slot] = str;
        bVisionActive = true;
        activeCount++;
        if(activeCount == 1) {
            visionLevel = level;
        }
    }
    else
    {
        visionLevelValues[slot] = -1;
    }
}

function float GetVisionLevelValue()
{
    local int i;
    local float f;

    activeCount = 0;
    visionLevelValue = -1;

    for(i=0; i<ArrayCount(visionLevelValues); i++) {
        f = visionLevelValues[i];
        if(f > 0) {
            visionLevelValue = FMax(visionLevelValue, f);
            activeCount++;
        }
    }

    if(activeCount > 0) {
        bVisionActive = true;
    } else {
        bVisionActive = false;
        visionLevel = 0;
        visionBlinder = None;
        bMotionSensor = false;
        bThermalVision = false;
        bVisionEnhancement = false;
    }

    return visionLevelValue;
}

function ConfigurationChanged()
{
    local string r;
    Super.ConfigurationChanged();
    r = GetConfig("Engine.Engine", "GameRenderDevice");
    d3d11 = "D3D11Drv.D3D11RenderDevice" ~= r;
}

function bool IsHeatSource(Actor A)
{
    if ((A.bHidden) && (Player.Level.NetMode != NM_Standalone))
        return False;
    if (A.IsA('Pawn'))
    {
        if (A.IsA('ScriptedPawn'))
            return True;
        else if (A.IsA('DeusExPlayer') && A != Player)//DEUS_EX AMSD For multiplayer.
            return True;
        return False;
    }
    else if (A.IsA('DeusExCarcass'))
        return True;
    else if (A.IsA('FleshFragment'))
        return True;
    else if (A.IsA('Computers'))
        return True;
    else if (A.IsA('BarrelFire'))
        return True;
    else if (A.GetStateName() == 'Burning')
        return True;
    else
        return False;
}

function DrawBrush(GC gc, Actor a)
{
    local vector forwards, backwards, TopLeft, BottomRight, centerLoc, radius;
    local float dist, boxTLX, boxTLY, boxBRX, boxBRY, width, height;

    dist = VSize(Player.Location - a.Location);
    forwards = Player.Location + (Vector(Player.ViewRotation) * dist);
    backwards = Player.Location + (Vector(Player.ViewRotation) * (-dist));

    // don't draw behind us
    if( VSize(a.Location - forwards) >= VSize(a.Location - backwards) )
        return;

    class'#var(injectsprefix)FrobDisplayWindow'.static.GetActorBoundingBox(a, centerLoc, radius);
    class'#var(injectsprefix)FrobDisplayWindow'.static.BoxToWindowCoords(self, 0, centerLoc, radius, boxTLX, boxTLY, boxBRX, boxBRY);

    width = boxBRX - boxTLX;
    height = boxBRY - boxTLY;
    gc.DrawPattern(boxTLX, boxTLY, width, height, 0, 0, Texture'Virus_SFX');
}

function PostDrawWindow(GC gc)
{
    if(#bool(injections)) GetVisionLevelValue();
    else bVisionEnhancement = bVisionActive;
    Super.PostDrawWindow(gc);
}

function DrawVisionAugmentation(GC gc)
{
    local Vector loc;
    local float x, y, w, h;
    local Actor A;

    // brighten and tint the screen
    if(class'MenuUIChoiceVisionTint'.default.value == 1) {
        gc.SetStyle(DSTY_Modulated);
        gc.DrawPattern(30, 30, width-60, height-60, 0, 0, Texture'VisionFilter');
        gc.DrawPattern(30, 30, width-60, height-60, 0, 0, Texture'VisionFilter');
    } else if(class'MenuUIChoiceVisionTint'.default.value == 2) {
        gc.SetStyle(DSTY_Modulated);
        gc.DrawPattern(30, 30, width-60, height-60, 0, 0, Texture'SolidGreen');
        gc.DrawPattern(30, 30, width-60, height-60, 0, 0, Texture'SolidGreen');
    }

    gc.SetStyle(DSTY_Translucent);

    // at level one and higher, enhance heat sources (FLIR)
    // use DrawActor to enhance NPC visibility
    if (visionLevel >= 1)
    {
        // adjust for the player's eye height
        loc = Player.Location;
        loc.Z += Player.BaseEyeHeight;

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
        gc.GetTextExtent(0, w, h, msgIRAmpActive);
        x = width * 0.1;
        y = height * 0.2 + h;
        gc.SetTextColor(colHeaderText);
        gc.DrawText(x, y, w, h, msgIRAmpActive);
    }

    // draw text label
    gc.GetTextExtent(0, w, h, msgLightAmpActive);
    x = width * 0.1;
    y = height * 0.2;
    gc.SetTextColor(colHeaderText);
    gc.DrawText(x, y, w, h, msgLightAmpActive);
}

function bool ShouldDrawActor(Actor A)
{
    if(A.bHidden)
        return false;

    if(bThermalVision) {
        if(IsHeatSource(A)) return true;
    }
    if(bMotionSensor) {
        if(!bVisionEnhancement && Mover(A) != None) return false;
        if(!bVisionEnhancement && Cloud(A) != None) return false;
        if(!bVisionEnhancement && A.Mesh == None) return false;
        if(!A.bHidden && A != Player && VSize(A.Velocity)>1) return true;
    }

    if(!bVisionEnhancement) return false;

    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        if(Inventory(A) != None || InformationDevices(A) != None || ElectronicDevices(A) != None || Containers(A) != None || Vehicles(A) != None)
           return true;
        if(DeusExProjectile(A) != None)
            return true;
    }

    if(!A.bVisionImportant)
        return false;

    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        if(IsHeatSource(A)) return true;
        if ( (A.IsA('Mover') || A.IsA('Decoration')) && A.bVisionImportant && !A.bHidden)
            return true;
    } else {
        if(Super.IsHeatSource(A)) return true;
    }

    return AutoTurret(A) != None || AutoTurretGun(A) != None || SecurityCamera(A) != None;
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

    return dist <= maxDist;
}

//Allow different actors to show up as different colours
function Texture GetGridTexture(Texture tex)
{
    switch(tex) {
        case None:
        case Texture'BlackMaskTex':
        case Texture'GrayMaskTex':
        case Texture'PinkMaskTex':
            return Texture'BlackMaskTex';

        case Texture'DeusExItems.Skins.DataCubeTex1':
        case Texture'DeusExItems.Skins.DataCubeTex2':
        case Texture'DeusExItems.Skins.NanoKeyTex1':
        //case Texture'Effects.Electricity.BioCell_SFX': // nanokey multiskin 1
        case Texture'DeusExDeco.Skins.BookClosedTex1':
        case Texture'DeusExDeco.Skins.BookOpenTex1':
            return Texture'Nano_SFX'; //Blue
    }

    switch(VisionTargetStatus) {
        case VISIONENEMY:
            return Texture'Virus_SFX';
        case VISIONALLY:
            return Texture'Wepn_Prifle_SFX';
        case VISIONNEUTRAL:
            return Texture'WhiteStatic';
    }

    return Texture'WhiteStatic';
}

function _DrawActor(GC gc, Actor A, float DrawGlow)
{
    local Texture oldSkins[9];
    local #var(prefix)Containers c;
    local class<Actor> i; //Revision changed "Contents"/"Content2"/"Content3" to Actor instead of Inventory
    local Mesh oldMesh;
    local DeusExCarcass carc;
    local float heat, motion;

    if(DrawGlow <= 0) return;
    if(!bVisionEnhancement) {
        if(bThermalVision) {
            heat = DrawGlow;
            carc = DeusExCarcass(A);
            if(carc != None && !carc.bNotDead) {
                if(carc.TimerRate <= 0 || carc.Group=='coldbody' || carc.Alliance=='Resurrected') return;
                heat *= FClamp(1-carc.TimerCounter*4, 0, 1);
            }
            if(ScriptedPawn(A) != None && ScriptedPawn(A).Alliance=='Resurrected') {
                heat *= 0.1;
            }
            if(FleshFragment(A) != None) {
                heat *= FMin(A.LifeSpan / 10, 1);
            }
        }
        if(bMotionSensor) {
            motion = DrawGlow;
            motion *= FClamp(VSize(A.Velocity)/100.0, 0, 1);
        }
        DrawGlow = FMax(heat, motion);
        if(DrawGlow <= 0) return;
    }

    if(A.Mesh != None) {
        SetSkins(A, oldSkins);
        gc.DrawActor(A, False, False, True, 1.0, DrawGlow/4, None);

        c = #var(prefix)Containers(A);
        if(c != None) {
            i = c.Contents;
            if(i == None) i = c.Content2;
            if(i == None) i = c.Content3;
            if(i != None) {
                oldMesh = c.Mesh;
                c.Mesh = i.default.Mesh;
                gc.DrawActor(A, False, False, True, 1.0, DrawGlow, None);
                c.Mesh = oldMesh;
            }
        }
        ResetSkins(A, oldSkins);
    } else if(Brush(A) != None) {
        DrawBrush(gc, A);
    }
}

function DrawActor(GC gc, Actor A, vector loc)
{
    local float dist, DrawGlow;
    local bool bLOS;

    dist = VSize(A.Location - loc);
    DrawGlow = FClamp((VisionLevelValue-dist)/8.0, 0, 2);
    bLOS = Player.LineOfSightTo(A,true);
    //If within range of vision aug bit
    if ( !bLOS && ShouldDrawActorDist(A, dist) )
    {
        VisionTargetStatus = GetVisionTargetStatus(A);
        _DrawActor(gc, A, DrawGlow);
    }
    else if ((Player.Level.Netmode != NM_Standalone) && (GetVisionTargetStatus(A) == VISIONENEMY) && (A.Style == STY_Translucent))
    {
        //DEUS_EX AMSD In multiplayer, if looking at a cloaked enemy player within range (greater than see through walls)
        //(If within walls radius he'd already have been seen.
        if (dist <= visionLevelvalue && bLOS)
        {
            VisionTargetStatus = GetVisionTargetStatus(A);
            _DrawActor(gc, A, DrawGlow);
        }
    }
    else if (bLOS)
    {
        VisionTargetStatus = GetVisionTargetStatus(A);

        if ((Player.Level.NetMode == NM_Standalone) || (dist < VisionLevelValue * 1.5) || (VisionTargetStatus != VISIONENEMY))
        {
            DrawGlow = FClamp((VisionLevelValue-dist/2.0)/8.0, 0, 2);
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
        _DrawActor(gc, A, DrawGlow);
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

function Actor TraceHoverHint(float checkDist)
{
    local Actor target;
    local Vector HitLoc, HitNormal, StartTrace, EndTrace;
    local DXRHoverHint hoverHint;
    local float dist;

    target = None;

    // figure out how far ahead we should trace
    StartTrace = Player.Location;
    EndTrace = Player.Location + (Vector(Player.ViewRotation) * checkDist);

    // adjust for the eye height
    StartTrace.Z += Player.BaseEyeHeight;
    EndTrace.Z += Player.BaseEyeHeight;

    // find the object that we are looking at
    foreach Player.TraceActors(class'Actor', target, HitLoc, HitNormal, EndTrace, StartTrace){
        if (target == Player.CarriedDecoration){
           continue;
        } else if (Player.IsFrobbable(target)){
            return None;
        } else if (DXRHoverHint(target) != None){
            hoverHint = DXRHoverHint(target);
            if (hoverHint.ShouldSelfDestruct()){
                hoverHint.Destroy();
                continue;
            }
            dist = VSize(player.Location-hoverHint.Location);
            if (hoverHint.ShouldDisplay(dist)==False){
                continue;
            }
            break;
        } else if (Teleporter(target) != None && !target.bHidden) {
            break;
        } else if (target.bHidden) {
            continue;
        } else {
            break;
        }
    }

    return target;
}

function string formatMapName(string mapName)
{
    local string mapNameOnly,teleName;
    local int hashPos;

    hashPos = InStr(mapName,"#");

    if (hashPos+1 == Len(mapName)) {
        // # is the last character, leave it out
        return class'DXRMapInfo'.static.GetTeleporterName(Left(mapName, Len(mapName)-1),"");
    }
    if (hashPos==-1){
        //No # in map name, so it's probably just the map name?
        return class'DXRMapInfo'.static.GetTeleporterName(mapName, "");
    }

    mapNameOnly = Left(mapName, hashPos);

    teleName = Mid(mapName,hashPos+1);

    return class'DXRMapInfo'.static.GetTeleporterName(mapNameOnly,teleName);
}

// ----------------------------------------------------------------------
// DrawTargetAugmentation()
// RANDO: Changed the targeting reticule to not draw if the crosshairs are hidden
// ----------------------------------------------------------------------
function DrawTargetAugmentation(GC gc)
{
    local Actor target;
    local #var(prefix)Teleporter tgtTeleporter;
    local DXRHoverHint hoverHint;
    local vector AimLocation;
    local string str,teleDest;
    local float x,y,h,w, boxCX,boxCY;
    local DynamicTeleporter dynTele;

    gc.SetFont(Font'FontMenuSmall_DS'); //This font is so much better for everything

    SuperDrawTargetAugmentation(gc);

    // check 500 feet in front of the player
    target = TraceHoverHint(8000);
    if(class'MenuChoice_ShowTeleporters'.static.ShowDescriptions()) {
        tgtTeleporter = #var(prefix)Teleporter(target);
    }

    // display teleporter destinations
	if (tgtTeleporter!=None && tgtTeleporter.URL!="")
	{
        ConvertVectorToCoordinates(tgtTeleporter.Location, boxCX, boxCY);

        teleDest = tgtTeleporter.URL;
        dynTele = DynamicTeleporter(tgtTeleporter);
        if (dynTele!=None && dynTele.destName != ''){
            if (InStr(teleDest,"#")==-1){
                teleDest = teleDest $ "#";
            }
            teleDest = teleDest $ dynTele.destName;

        }

        str = "To: "$formatMapName(teleDest);
        gc.SetTextColor(colWhite);
        gc.GetTextExtent(0, w, h, str);
        x = boxCX - w/2;
        y=boxCY;

        gc.DrawText(x, y, w, h, str);
	}

    //Look for any hover hints
    hoverHint = DXRHoverHint(target);
    if (hoverHint!=None){
        ConvertVectorToCoordinates(hoverHint.Location + hoverHint.TextOffset, boxCX, boxCY);

        str = hoverHint.GetHintText();
        gc.SetTextColor(colWhite);
        gc.GetTextExtent(0, w, h, str);
        x = boxCX - w/2;
        y=boxCY;

        gc.DrawText(x, y, w, h, str);
    }

    //Font is immediately changed after DrawTargetAugmentation gets called,
    //So not necessary to "change it back" to the old font

}

// DXRando mostly copied from Super, but we want to hide aiming reticles when !bCrosshairVisible, and don't show the dumb "No Image" black rectangle on low levels of AugTarget
function SuperDrawTargetAugmentation(GC gc)
{
    local String str;
    local Actor target;
    local float boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
    local float x, y, w, h, mult;
    local Vector v1, v2;
    local int i, j, k;
    local DeusExWeapon weapon;
    local bool bUseOldTarget;
    local Color crossColor;
    local DeusExPlayer own;
    local vector AimLocation;
    local int AimBodyPart;

    crossColor.R = 255; crossColor.G = 255; crossColor.B = 255;

    // check 1000 feet instead of 500 feet in front of the player, to spot Leo from the top of the statue
    target = TraceLOS(16000,AimLocation);

    targetplayerhealthstring = "";
    targetplayerlocationstring = "";

    if ( target != None )
    {
        GetTargetReticleColor( target, crossColor );

        if ((DeusExPlayer(target) != None) && (bTargetActive))
        {
            AimBodyPart = DeusExPlayer(target).GetMPHitLocation(AimLocation);
            if (AimBodyPart == 1)
                TargetPlayerLocationString = "("$msgHead$")";
            else if ((AimBodyPart == 2) || (AimBodyPart == 5) || (AimBodyPart == 6))
                TargetPlayerLocationString = "("$msgTorso$")";
            else if ((AimBodyPart == 3) || (AimBodyPart == 4))
                TargetPlayerLocationString = "("$msgLegs$")";
        }

        weapon = DeusExWeapon(Player.Weapon);
        // DXRando: added && Player.bCrosshairVisible
        if (weapon != None && Player.bCrosshairVisible && !weapon.bHandToHand && !bUseOldTarget)
        {
            // if the target is out of range, don't draw the reticle
            if (weapon.MaxRange >= VSize(target.Location - Player.Location))
            {
                w = width;
                h = height;
                x = int(w * 0.5)-1;
                y = int(h * 0.5)-1;

                // scale based on screen resolution - default is 640x480
                mult = FClamp(weapon.currentAccuracy * 80.0 * (width/640.0), corner, 80.0);

                // make sure it's not too close to the center unless you have a perfect accuracy
                mult = FMax(mult, corner+4.0);
                if (weapon.currentAccuracy == 0.0)
                    mult = corner;

                // draw the drop shadowed reticle
                gc.SetTileColorRGB(0,0,0);
                for (i=1; i>=0; i--)
                {
                    gc.DrawBox(x+i, y-mult+i, 1, corner, 0, 0, 1, Texture'Solid');
                    gc.DrawBox(x+i, y+mult-corner+i, 1, corner, 0, 0, 1, Texture'Solid');
                    gc.DrawBox(x-(corner-1)/2+i, y-mult+i, corner, 1, 0, 0, 1, Texture'Solid');
                    gc.DrawBox(x-(corner-1)/2+i, y+mult+i, corner, 1, 0, 0, 1, Texture'Solid');

                    gc.DrawBox(x-mult+i, y+i, corner, 1, 0, 0, 1, Texture'Solid');
                    gc.DrawBox(x+mult-corner+i, y+i, corner, 1, 0, 0, 1, Texture'Solid');
                    gc.DrawBox(x-mult+i, y-(corner-1)/2+i, 1, corner, 0, 0, 1, Texture'Solid');
                    gc.DrawBox(x+mult+i, y-(corner-1)/2+i, 1, corner, 0, 0, 1, Texture'Solid');

                    gc.SetTileColor(crossColor);
                }
            }
        }
        // movers are invalid targets for the aug
        if (target.IsA('DeusExMover'))
            target = None;
    }

    // let there be a 0.5 second delay before losing a target
    if (target == None)
    {
        if ((Player.Level.TimeSeconds - lastTargetTime < 0.5) && IsActorValid(lastTarget))
        {
            target = lastTarget;
            bUseOldTarget = True;
        }
        else
        {
            RemoveActorRef(lastTarget);
            lastTarget = None;
        }
    }
    else
    {
        lastTargetTime = Player.Level.TimeSeconds;
        bUseOldTarget = False;
        if (lastTarget != target)
        {
            RemoveActorRef(lastTarget);
            lastTarget = target;
            AddActorRef(lastTarget);
        }
    }

    if (target != None)
    {
        // draw a cornered targetting box
        v1.X = target.CollisionRadius;
        v1.Y = target.CollisionRadius;
        v1.Z = target.CollisionHeight;

        if (ConvertVectorToCoordinates(target.Location, boxCX, boxCY))
        {
            boxTLX = boxCX;
            boxTLY = boxCY;
            boxBRX = boxCX;
            boxBRY = boxCY;

            // get the smallest box to enclose actor
            // modified from Scott's ActorDisplayWindow
            for (i=-1; i<=1; i+=2)
            {
                for (j=-1; j<=1; j+=2)
                {
                    for (k=-1; k<=1; k+=2)
                    {
                        v2 = v1;
                        v2.X *= i;
                        v2.Y *= j;
                        v2.Z *= k;
                        v2.X += target.Location.X;
                        v2.Y += target.Location.Y;
                        v2.Z += target.Location.Z;

                        if (ConvertVectorToCoordinates(v2, x, y))
                        {
                            boxTLX = FMin(boxTLX, x);
                            boxTLY = FMin(boxTLY, y);
                            boxBRX = FMax(boxBRX, x);
                            boxBRY = FMax(boxBRY, y);
                        }
                    }
                }
            }

            boxTLX = FClamp(boxTLX, margin, width-margin);
            boxTLY = FClamp(boxTLY, margin, height-margin);
            boxBRX = FClamp(boxBRX, margin, width-margin);
            boxBRY = FClamp(boxBRY, margin, height-margin);

            boxW = boxBRX - boxTLX;
            boxH = boxBRY - boxTLY;

            if ((bTargetActive) && (Player.Level.Netmode == NM_Standalone))
            {
                // set the coords of the zoom window, and draw the box
                // even if we don't have a zoom window
                x = width/8 + margin;
                y = height/2;
                w = width/4;
                h = height/4;

                // DXRando move drop shadow down into if targetLevel >2 && winZoom != None
                //DrawDropShadowBox(gc, x-w/2, y-h/2, w, h);

                boxCX = width/8 + margin;
                boxCY = height/2;
                boxTLX = boxCX - width/8;
                boxTLY = boxCY - height/8;
                boxBRX = boxCX + width/8;
                boxBRY = boxCY + height/8;

                if(d3d11 && winZoom!=None) {
                    winZoom.Hide();
                }
                else if (targetLevel > 2)
                {
                    if (winZoom != None)
                    {
                        DrawDropShadowBox(gc, x-w/2, y-h/2, w, h); // DXRando: moved this here
                        mult = (target.CollisionRadius + target.CollisionHeight);
                        v1 = Player.Location;
                        v1.Z += Player.BaseEyeHeight;
                        v2 = 1.5 * Player.Normal(target.Location - v1);
                        winZoom.SetViewportLocation(target.Location - mult * v2);
                        winZoom.SetWatchActor(target);
                    }
                    // window construction now happens in Tick()
                }
                else
                {
                    // DXRando: this is dumb
                    // black out the zoom window and draw a "no image" message
                    /*gc.SetStyle(DSTY_Normal);
                    gc.SetTileColorRGB(0,0,0);
                    gc.DrawPattern(boxTLX, boxTLY, w, h, 0, 0, Texture'Solid');

                    gc.SetTextColorRGB(255,255,255);
                    gc.GetTextExtent(0, w, h, msgNoImage);
                    x = boxCX - w/2;
                    y = boxCY - h/2;
                    gc.DrawText(x, y, w, h, msgNoImage);*/
                }

                // print the name of the target above the box
                if (target.IsA('Pawn')){
                    //str = target.BindName;
                    str = Player.GetDisplayName(target);
                    if (Player.GetDisplayName(target) != Pawn(target).Default.UnfamiliarName){
                        str = str @ "(" $ Pawn(target).Default.UnfamiliarName $ ")";
                    }
                } else if (target.IsA('DeusExDecoration')) {
                    if (InStr(DeusExDecoration(target).itemName,"DEFAULT")==-1){
                        str = DeusExDecoration(target).itemName;
                    } else {
                        str = target.GetItemName(String(target.Class));
                    }
                } else if (target.IsA('DeusExProjectile')){
                    str = DeusExProjectile(target).itemName;
                } else {
                    str = target.GetItemName(String(target.Class));
                }

                // print disabled robot info
                if (target.IsA('Robot') && (Robot(target).EMPHitPoints == 0))
                    str = str $ " (" $ msgDisabled $ ")";
                gc.SetTextColor(crossColor);

                // print the range to target
                mult = VSize(target.Location - Player.Location);
                str = str $ CR() $ msgRange @ Int(class'DXRActorsBase'.static.GetRealDistance(mult)) @ class'DXRActorsBase'.static.GetDistanceUnit(); //Rando: Use the appropriate units

                gc.GetTextExtent(0, w, h, str);
                x = boxTLX + margin;
                y = boxTLY - h - margin;
                gc.DrawText(x, y, w, h, str);

                // level zero gives very basic health info
                if (target.IsA('Pawn'))
                    mult = Float(Pawn(target).Health) / Float(Pawn(target).Default.Health);
                else if (target.IsA('DeusExDecoration'))
                    mult = Float(DeusExDecoration(target).HitPoints) / Float(DeusExDecoration(target).Default.HitPoints);
                else
                    mult = 1.0;

                if (targetLevel == 0)
                {
                    // level zero only gives us general health readings
                    if (mult >= 0.66)
                    {
                        str = msgHigh;
                        mult = 1.0;
                    }
                    else if (mult >= 0.33)
                    {
                        str = msgMedium;
                        mult = 0.5;
                    }
                    else
                    {
                        str = msgLow;
                        mult = 0.05;
                    }

                    str = str @ msgHealth;
                }
                else
                {
                    // level one gives exact health readings
                    str = Int(mult * 100.0) $ msgPercent;
                    if (target.IsA('Pawn') && !target.IsA('Robot') && !target.IsA('Animal'))
                    {
                        x = mult;		// save this for color calc
                        str = str @ msgOverall;
                        mult = Float(Pawn(target).HealthHead) / Float(Pawn(target).Default.HealthHead);
                        str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgHead;
                        mult = Float(Pawn(target).HealthTorso) / Float(Pawn(target).Default.HealthTorso);
                        str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgTorso;
                        mult = Float(Pawn(target).HealthArmLeft) / Float(Pawn(target).Default.HealthArmLeft);
                        str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgLeftArm;
                        mult = Float(Pawn(target).HealthArmRight) / Float(Pawn(target).Default.HealthArmRight);
                        str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgRightArm;
                        mult = Float(Pawn(target).HealthLegLeft) / Float(Pawn(target).Default.HealthLegLeft);
                        str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgLeftLeg;
                        mult = Float(Pawn(target).HealthLegRight) / Float(Pawn(target).Default.HealthLegRight);
                        str = str $ CR() $ Int(mult * 100.0) $ msgPercent @ msgRightLeg;
                        mult = x;
                    }
                    else
                    {
                        str = str @ msgHealth;
                    }
                }

                gc.GetTextExtent(0, w, h, str);
                x = boxTLX + margin;
                y = boxTLY + margin;
                gc.SetTextColor(GetColorScaled(mult));
                gc.DrawText(x, y, w, h, str);
                gc.SetTextColor(colHeaderText);

                if (targetLevel > 1)
                {
                    // level two gives us weapon info as well
                    if (target.IsA('Pawn'))
                    {
                        str = msgWeapon;

                        if (Pawn(target).Weapon != None){
                            //str = str @ target.GetItemName(String(Pawn(target).Weapon.Class));
                            if (InStr(Pawn(target).Weapon.ItemName,"DEFAULT")==-1){
                                str = str @ Pawn(target).Weapon.ItemName;
                            } else {
                                str = str @ target.GetItemName(String(Pawn(target).Weapon.Class));
                            }
                        } else {
                            str = str @ msgNone;
                        }

                        gc.GetTextExtent(0, w, h, str);
                        x = boxTLX + margin;
                        y = boxBRY - h - margin;
                        gc.DrawText(x, y, w, h, str);
                    }
                }
            }
            else
            {
                // display disabled robots
                if (target.IsA('Robot') && (Robot(target).EMPHitPoints == 0))
                {
                    str = msgDisabled;
                    gc.SetTextColor(crossColor);
                    gc.GetTextExtent(0, w, h, str);
                    x = boxCX - w/2;
                    y = boxTLY - h - margin;
                    gc.DrawText(x, y, w, h, str);
                }
            }
        }
    }
    else if ((bTargetActive) && (Player.Level.NetMode == NM_Standalone))
    {
        if (Player.Level.TimeSeconds % 1.5 > 0.75)
            str = msgScanning1;
        else
            str = msgScanning2;
        gc.GetTextExtent(0, w, h, str);
        x = width/2 - w/2;
        y = (height/2 - h) - 20;
        gc.DrawText(x, y, w, h, str);
    }

    // set the crosshair colors
    DeusExRootWindow(player.rootWindow).hud.cross.SetCrosshairColor(crossColor);
}

// DXRando: TraceLOS mostly vanilla, except ignore DeathMarkers
function Actor TraceLOS(float checkDist, out vector HitLocation)
{
    local Actor target;
    local Vector HitLoc, HitNormal, StartTrace, EndTrace;

    target = None;

    // figure out how far ahead we should trace
    StartTrace = Player.Location;
    EndTrace = Player.Location + (Vector(Player.ViewRotation) * checkDist);

    // adjust for the eye height
    StartTrace.Z += Player.BaseEyeHeight;
    EndTrace.Z += Player.BaseEyeHeight;

    // find the object that we are looking at
    // make sure we don't select the object that we're carrying
    foreach Player.TraceActors(class'Actor', target, HitLoc, HitNormal, EndTrace, StartTrace)
    {
        //DXRando: just ignore death markers
        if(DeathMarker(target) != None) continue;
        // back to vanilla code
        if (target.IsA('Pawn') || target.IsA('DeusExDecoration') || target.IsA('ThrownProjectile') ||
            (target.IsA('DeusExMover') && DeusExMover(target).bBreakable))
        {
            if (target != Player.CarriedDecoration)
            {
                if ( (Player.Level.NetMode != NM_Standalone) && target.IsA('DeusExPlayer') )
                {
                    if ( DeusExPlayer(target).AdjustHitLocation( HitLoc, EndTrace - StartTrace ) )
                        break;
                    else
                        target = None;
                }
                else
                    break;
            }
        }
    }

    HitLocation = HitLoc;

    return target;
}


function GetTargetReticleColor( Actor target, out Color xcolor )
{
    local AutoTurret turret;
    local AutoTurretGun gun;
    local SecurityCamera sc;
    local ThrownProjectile tp;

    if(target == None) {
        xcolor = colWhite;
        return;
    }
    Super.GetTargetReticleColor(target,xcolor);

    if ( Player.Level.NetMode == NM_Standalone ) {
        if ( target.IsA('AutoTurret') || target.IsA('AutoTurretGun') ) {
                if (target.IsA('AutoTurret')){
                    turret = AutoTurret(target);
                } else {
                    gun = AutoTurretGun(target);
                    turret = AutoTurret(gun.Owner);
                }

                if (turret.bTrackPlayersOnly==True){
                    //Hostile
                    xcolor = colRed;
                } else if (turret.bTrackPawnsOnly==True){
                    //bTrackPlayersOnly=False is implied because of first condition
                    //Allied
                    xcolor = colGreen;
                } else {
                    //Neutral
                    xcolor = colWhite;
                }

        } else if (target.IsA('SecurityCamera')) {
            sc = SecurityCamera(target);
            if (!sc.bActive) {
                //Disabled
                xcolor = colWhite;
            } else if (sc.bNoAlarm){
                //Will not set off an alarm (friendly)
                xcolor = colGreen;
            } else {
                //Will trigger an alarm (hostile)
                xcolor = colRed;
            }
        } else if (target.IsA('ThrownProjectile')) {
            tp = ThrownProjectile(target);
            if (tp.bDisabled){
                xcolor = colWhite;
            } else if (tp.Owner!=None) { //The game only considers unowned grenades to be hostile (in single player)
                xcolor = colGreen;
            } else {
                xcolor = colRed;
            }
        }
    }
}

function DrawSpyDroneAugmentation(GC gc)
{
    local String str;
    local float boxCX, boxCY, boxTLY, boxH;
    local float x, y, w, h;

    Super.DrawSpyDroneAugmentation(gc);

#ifdef injections
    if (winDrone!=None){
        //Balanced SpyDrone costs 10 energy to detonate.  Display a message if you don't have enough
        //See "DroneExplode" in DXRBalance/BalancePlayer.uc
        if (Player.Energy < 10 && class'MenuChoice_BalanceAugs'.static.IsEnabled()){

            //Find the useful coords of the drone window
            boxH = height/4;
            boxCX = width/8 + margin;
            boxCY = height/2;
            boxTLY = boxCY - boxH/2;

            str = "Not enough energy to detonate!";
            gc.GetTextExtent(0, w, h, str);
            x = boxCX - w/2;
            y = boxTLY + margin + h + margin;
            gc.SetTextColorRGB(255,0,0);
            gc.DrawText(x, y, w, h, str);
            gc.SetTextColor(colHeaderText);
        }
    }
#endif
}

//Duped from vanilla to allow changing the units
function DrawDefenseAugmentation(GC gc)
{
    local String str;
    local float boxCX, boxCY;
    local float x, y, w, h, mult;
    local bool bDrawLine;

    if (defenseTarget != None)
    {
        bDrawLine = False;

        if (defenseTarget.IsInState('Exploding'))
        {
            str = msgADSDetonating;
            bDrawLine = True;
        }
        else
            str = msgADSTracking;

        mult = VSize(defenseTarget.Location - Player.Location);

        str = str $ CR() $ msgRange @ Int(class'DXRActorsBase'.static.GetRealDistance(mult)) @ class'DXRActorsBase'.static.GetDistanceUnit(); //Rando: Use the appropriate units
        //str = str $ CR() $ msgRange @ Int(mult/16) @ msgRangeUnits;

        if (!ConvertVectorToCoordinates(defenseTarget.Location, boxCX, boxCY))
            str = str @ msgBehind;

        gc.GetTextExtent(0, w, h, str);
        x = boxCX - w/2;
        y = boxCY - h;
        gc.SetTextColorRGB(255,0,0);
        gc.DrawText(x, y, w, h, str);
        gc.SetTextColor(colHeaderText);

        if (bDrawLine)
        {
            gc.SetTileColorRGB(255,0,0);
            Interpolate(gc, width/2, height/2, boxCX, boxCY, 64);
            gc.SetTileColor(colHeaderText);
        }
    }
}
