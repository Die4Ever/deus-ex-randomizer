class AugDisplayWindow injects AugmentationDisplayWindow;

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

    class'FrobDisplayWindow'.static.GetActorBoundingBox(a, centerLoc, radius);
    class'FrobDisplayWindow'.static.BoxToWindowCoords(self, 0, centerLoc, radius, boxTLX, boxTLY, boxBRX, boxBRY);
    width = boxBRX - boxTLX;
    height = boxBRY - boxTLY;
    gc.DrawPattern(boxTLX, boxTLY, width, height, 0, 0, Texture'Virus_SFX');
}

function DrawVisionAugmentation(GC gc)
{
    local Vector loc;
    local float x, y, w, h;
    local Actor A;

    // brighten and tint the screen
    gc.SetStyle(DSTY_Modulated);
    gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');
    gc.DrawPattern(0, 0, width, height, 0, 0, Texture'SolidGreen');
    //gc.DrawPattern(0, 0, width, height, 0, 0, Texture'VisionBlue');
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

    if( Inventory(A) != None || InformationDevices(A) != None || ElectronicDevices(A) != None || Containers(A) != None || Vehicles(A) != None )
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

    return dist <= maxDist;
}

function _DrawActor(GC gc, Actor A, float DrawGlow)
{
    local Texture oldSkins[9];

    if(A.Mesh == None) {
        DrawBrush(gc, A);
    }
    else {
        SetSkins(A, oldSkins);
        gc.DrawActor(A, False, False, True, 1.0, DrawGlow, None);
        ResetSkins(A, oldSkins);
    }
}

function DrawActor(GC gc, Actor A, vector loc)
{
    local float dist, DrawGlow;

    dist = VSize(A.Location - loc);
    //If within range of vision aug bit
    if ( ShouldDrawActorDist(A, dist) )
    {
        VisionTargetStatus = GetVisionTargetStatus(A);
        _DrawActor(gc, A, 2.0);
    }
    else if ((Player.Level.Netmode != NM_Standalone) && (GetVisionTargetStatus(A) == VISIONENEMY) && (A.Style == STY_Translucent))
    {
        //DEUS_EX AMSD In multiplayer, if looking at a cloaked enemy player within range (greater than see through walls)
        //(If within walls radius he'd already have been seen.
        if ( (dist <= (visionLevelvalue)) && (Player.LineOfSightTo(A,true)) )
        {
            VisionTargetStatus = GetVisionTargetStatus(A);
            _DrawActor(gc, A, 2.0);
        }
    }
    else if (Player.LineOfSightTo(A,true))
    {
        VisionTargetStatus = GetVisionTargetStatus(A);

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

function #var(prefix)Teleporter TraceTeleporter(float checkDist, out vector HitLocation)
{
	local Actor target;
	local Vector HitLoc, HitNormal, StartTrace, EndTrace;

	target = TraceActorType(class'#var(prefix)Teleporter',checkDist);

    if (#var(prefix)Teleporter(target)!=None)
    {
        HitLocation = HitLoc;
        return #var(prefix)Teleporter(target);
    }

	return None;
}

function DXRHoverHint TraceHoverHint(float checkDist, out vector HitLocation)
{
    local Actor target;
    local Vector HitLoc;
    local DXRHoverHint hoverHint;
    local float dist;

    target = TraceActorType(class'DXRHoverHint',checkDist);

    hoverHint = DXRHoverHint(target);
    if (hoverHint!=None)
    {
        if (hoverHint.ShouldSelfDestruct()){
            hoverHint.Destroy();
            return None;
        }

        dist = VSize(player.Location-hoverHint.Location);
        if (hoverHint.ShouldDisplay(dist)==False){
            return None;
        }

        HitLocation = HitLoc;
        return hoverHint;
    }

    return None;
}

function Actor TraceActorType(class<Actor> actType,float checkDist)
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
    foreach Player.TraceActors(class'Actor', target, HitLoc, HitNormal, EndTrace, StartTrace){
        if (target == Player.CarriedDecoration){
           continue;
        } else if (Player.IsFrobbable(target)){
            return None;
        } else if (target.bHidden && !target.IsA(actType.name)){
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
    local Weapon oldWeapon;
    local #var(prefix)Teleporter tgtTeleporter;
    local DXRHoverHint hoverHint;
    local vector AimLocation;
    local string str,teleDest;
    local float x,y,h,w, boxCX,boxCY;
    local DynamicTeleporter dynTele;
    local int show_teleporters;

    gc.SetFont(Font'FontMenuSmall_DS'); //This font is so much better for everything

    oldWeapon = Player.Weapon;
    if(!Player.bCrosshairVisible)
        Player.Weapon = None;
    Super.DrawTargetAugmentation(gc);
    Player.Weapon = oldWeapon;

    // check 500 feet in front of the player
    show_teleporters = int(Player.ConsoleCommand("get #var(package).MenuChoice_ShowTeleporters show_teleporters"));
    if(show_teleporters > 1) {
	    tgtTeleporter = TraceTeleporter(8000,AimLocation);
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
    hoverHint = TraceHoverHint(8000,AimLocation);
    if (hoverHint!=None){
        ConvertVectorToCoordinates(hoverHint.Location, boxCX, boxCY);

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

function GetTargetReticleColor( Actor target, out Color xcolor )
{
    local AutoTurret turret;
    local AutoTurretGun gun;
    local SecurityCamera sc;
    local ThrownProjectile tp;

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
            } else if (tp.Owner==Player) {
                xcolor = colGreen;
            } else {
                xcolor = colRed;
            }
        }
    }
}
