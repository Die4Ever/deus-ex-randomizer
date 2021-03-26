class FrobDisplayWindow injects FrobDisplayWindow;

var localized string msgDamageThreshold;
var localized string msgShot;
var localized string msgShots;

function DrawWindow(GC gc)
{
    local actor frobTarget;

    if (player != None)
    {
        frobTarget = player.FrobTarget;
        if (frobTarget != None)
            if (!player.IsHighlighted(frobTarget))
                frobTarget = None;
    }

    if( frobTarget != None ) DrawWindowBase(gc, frobTarget);
}

function DrawWindowBase(GC gc, actor frobTarget)
{
    local float     infoX, infoY, infoW, infoH;
    local string    strInfo;
    local Mover     M;
    local Vector    centerLoc, v1, v2;
    local float     boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
    local float     corner, x, y;
    local int       i, j, k, offset;
    local Color     col;

    // move the box in and out based on time
    offset = (24.0 * (frobTarget.Level.TimeSeconds % 0.3));

    // draw a cornered targetting box
    // get the center of the object
    M = Mover(frobTarget);
    if (M != None)
    {
        M.GetBoundingBox(v1, v2, False, M.KeyPos[M.KeyNum]+M.BasePos, M.KeyRot[M.KeyNum]+M.BaseRot);
        centerLoc = v1 + (v2 - v1) * 0.5;
        v1.X = 16;
        v1.Y = 16;
        v1.Z = 16;
    }
    else
    {
        centerLoc = frobTarget.Location;
        v1.X = frobTarget.CollisionRadius;
        v1.Y = frobTarget.CollisionRadius;
        v1.Z = frobTarget.CollisionHeight;
    }

    ConvertVectorToCoordinates(centerLoc, boxCX, boxCY);

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
                v2.X += centerLoc.X;
                v2.Y += centerLoc.Y;
                v2.Z += centerLoc.Z;

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

    if (!frobTarget.IsA('Mover'))
    {
        boxTLX += frobTarget.CollisionRadius / 4.0;
        boxTLY += frobTarget.CollisionHeight / 4.0;
        boxBRX -= frobTarget.CollisionRadius / 4.0;
        boxBRY -= frobTarget.CollisionHeight / 4.0;
    }

    boxTLX = FClamp(boxTLX, margin, width-margin);
    boxTLY = FClamp(boxTLY, margin, height-margin);
    boxBRX = FClamp(boxBRX, margin, width-margin);
    boxBRY = FClamp(boxBRY, margin, height-margin);

    boxW = boxBRX - boxTLX;
    boxH = boxBRY - boxTLY;

    // scale the corner based on the size of the box
    corner = FClamp((boxW + boxH) * 0.1, 4.0, 40.0);

    // make sure the box doesn't invert itself
    if (boxBRX - boxTLX < corner)
    {
        boxTLX -= (corner+4);
        boxBRX += (corner+4);
    }
    if (boxBRY - boxTLY < corner)
    {
        boxTLY -= (corner+4);
        boxBRY += (corner+4);
    }

    // draw the drop shadow first, then normal
    gc.SetTileColorRGB(0,0,0);
    for (i=1; i>=0; i--)
    {
        gc.DrawBox(boxTLX+i+offset, boxTLY+i+offset, corner, 1, 0, 0, 1, Texture'Solid');
        gc.DrawBox(boxTLX+i+offset, boxTLY+i+offset, 1, corner, 0, 0, 1, Texture'Solid');

        gc.DrawBox(boxBRX+i-corner-offset, boxTLY+i+offset, corner, 1, 0, 0, 1, Texture'Solid');
        gc.DrawBox(boxBRX+i-offset, boxTLY+i+offset, 1, corner, 0, 0, 1, Texture'Solid');

        gc.DrawBox(boxTLX+i+offset, boxBRY+i-offset, corner, 1, 0, 0, 1, Texture'Solid');
        gc.DrawBox(boxTLX+i+offset, boxBRY+i-corner-offset, 1, corner, 0, 0, 1, Texture'Solid');

        gc.DrawBox(boxBRX+i-corner+1-offset, boxBRY+i-offset, corner, 1, 0, 0, 1, Texture'Solid');
        gc.DrawBox(boxBRX+i-offset, boxBRY+i-corner-offset, 1, corner, 0, 0, 1, Texture'Solid');

        gc.SetTileColor(colText);
    }

    // draw object-specific info
    strInfo = GetStrInfo(frobTarget);

    infoX = boxTLX + 10;
    infoY = boxTLY + 10;

    gc.SetFont(Font'FontMenuSmall_DS');
    gc.GetTextExtent(0, infoW, infoH, strInfo);
    infoW += 8;

    if( ActorHasBars(frobTarget) )
        infoW += barLength + 2;
    infoH += 8;
    infoX = FClamp(infoX, infoW/2+10, width-10-infoW/2);
    infoY = FClamp(infoY, infoH/2+10, height-10-infoH/2);

    // draw a dark background
    gc.SetStyle(DSTY_Modulated);
    gc.SetTileColorRGB(0, 0, 0);
    gc.DrawPattern(infoX, infoY, infoW, infoH, 0, 0, Texture'ConWindowBackground');

    gc.SetTextColor(colText);

    DrawActorBars(gc, frobTarget, infoX, infoY, infoW, infoH);

    // draw the text
    gc.DrawText(infoX+4, infoY+4, infoW-8, infoH-8, strInfo);

    // draw the two highlight boxes
    gc.SetStyle(DSTY_Translucent);
    gc.SetTileColor(colBorder);
    gc.DrawBox(infoX, infoY, infoW, infoH, 0, 0, 1, Texture'Solid');
    gc.SetTileColor(colBackground);
    gc.DrawBox(infoX+1, infoY+1, infoW-2, infoH-2, 0, 0, 1, Texture'Solid');
}

function int Ceil(float f)
{
    local int ret;
    ret = f;
    if( float(ret) < f )
        ret++;
    return ret;
}

function string GetStrInfo(Actor a)
{
    if ( Mover(a) != None )
        return MoverStrInfo(Mover(a));
    else if ( HackableDevices(a) != None )
        return DeviceStrInfo(HackableDevices(a));
    else if (!a.bStatic && player.bObjectNames)
        return OtherStrInfo(a);

    return "";
}

function string MoverStrInfo(Mover m)
{
    local string strInfo;
    local DeusExMover dxMover;

    dxMover = DeusExMover(m);
    if ((dxMover != None) && dxMover.bLocked)
    {
        strInfo = msgLocked $ CR() $ msgLockStr;
        if (dxMover.bPickable)
            strInfo = strInfo $ FormatString(dxMover.lockStrength * 100.0) $ "%";
        else
            strInfo = strInfo $ msgInf;

        strInfo = strInfo $ CR() $ msgDoorStr;
        if (dxMover.bBreakable)
            strInfo = strInfo $ FormatString(dxMover.doorStrength * 100.0) $ "%";
        else
            strInfo = strInfo $ msgInf;

        if ( dxMover.bBreakable )
            strInfo = strInfo $ CR() $ msgDamageThreshold @ dxMover.minDamageThreshold;
        else
            strInfo = strInfo $ CR() $ msgDamageThreshold @ msgInf;
    }
    else
    {
        strInfo = msgUnlocked;
    }

    return strInfo;
}

function string DeviceStrInfo(HackableDevices device)
{
    local string strInfo;

    strInfo = device.itemName $ CR() $ msgHackStr;
    if (device.bHackable)
    {
        if (device.hackStrength != 0.0)
            strInfo = strInfo $ FormatString(device.hackStrength * 100.0) $ "%";
        else
            strInfo = device.itemName $ ": " $ msgHacked;
    }
    else
        strInfo = strInfo $ msgInf;

    return strInfo;
}

function string OtherStrInfo(Actor frobTarget)
{
    local string strInfo;

    // TODO: Check familiar vs. unfamiliar flags
    if (frobTarget.IsA('Pawn'))
        strInfo = player.GetDisplayName(frobTarget);
    else if (frobTarget.IsA('DeusExCarcass'))
        strInfo = DeusExCarcass(frobTarget).itemName;
    else if (frobTarget.IsA('Inventory'))
        strInfo = Inventory(frobTarget).itemName;
    else if (frobTarget.IsA('DeusExDecoration'))
        strInfo = player.GetDisplayName(frobTarget);
    else if (frobTarget.IsA('DeusExProjectile'))
        strInfo = DeusExProjectile(frobTarget).itemName;
    else
        strInfo = "DEFAULT ACTOR NAME - REPORT THIS AS A BUG - " $ frobTarget.GetItemName(String(frobTarget.Class));

    return strInfo;
}

function bool ActorHasBars(Actor frobTarget)
{
    local DeusExMover dxMover;
    local HackableDevices device;

    dxMover = DeusExMover(frobTarget);
    device = HackableDevices(frobTarget);

    if ( dxMover != None && dxMover.bLocked )
        return true;
    if ( device != None && device.hackStrength != 0.0 )
        return true;

    return false;
}

function DrawActorBars(GC gc, Actor a, float infoX, float infoY, float infoW, float infoH)
{
    if ( Mover(a) != None )
        MoverDrawBars(gc, Mover(a), infoX, infoY, infoW, infoH);
    else if ( HackableDevices(a) != None )
        DeviceDrawBars(gc, HackableDevices(a), infoX, infoY, infoW, infoH);
}

function MoverDrawBars(GC gc, Mover m, float infoX, float infoY, float infoW, float infoH)
{
    local DeusExMover dxMover;
    local string strInfo;
    local color col;
    local int numTools, numLines, numShots;
    local float damage;
    local name damageType;
    local DeusExWeapon w;

    numLines = 4;

    dxMover = DeusExMover(m);
    // draw colored bars for each value
    if ((dxMover != None) && dxMover.bLocked)
    {
        gc.SetStyle(DSTY_Translucent);
        col = GetColorScaled(dxMover.lockStrength);
        gc.SetTileColor(col);
        gc.DrawPattern(infoX+(infoW-barLength-4), infoY+4+(infoH-8)/numLines, barLength*dxMover.lockStrength, ((infoH-8)/numLines)-2, 0, 0, Texture'ConWindowBackground');
        col = GetColorScaled(dxMover.doorStrength);
        gc.SetTileColor(col);
        gc.DrawPattern(infoX+(infoW-barLength-4), infoY+4+2*(infoH-8)/numLines, barLength*dxMover.doorStrength, ((infoH-8)/numLines)-2, 0, 0, Texture'ConWindowBackground');
    }

    // draw the absolute number of lockpicks on top of the colored bar
    if ((dxMover != None) && dxMover.bLocked && dxMover.bPickable)
    {
        numTools = Ceil((dxMover.lockStrength / player.SkillSystem.GetSkillLevelValue(class'SkillLockpicking')));
        if (numTools == 1)
            strInfo = numTools @ msgPick;
        else
            strInfo = numTools @ msgPicks;
    }

    if ((dxMover != None) && dxMover.bLocked && dxMover.bBreakable)
    {
        w = DeusExWeapon(player.inHand);
        if( w != None ) {
            damageType = w.WeaponDamageType();
            damage = dxMover.CalcDamage(w.GetDamage(), damageType) * w.GetNumHits();
            if( damage > 0 ) {
                numshots = Ceil((dxMover.doorStrength / damage));
                if( numshots == 1 )
                    strInfo = strInfo $ CR() $ numshots @ msgShot;
                else
                    strInfo = strInfo $ CR() $ numshots @ msgShots;
            } else {
                strInfo = strInfo $ CR() $ msgInf @ msgShots;
            }
        }
    }

    gc.DrawText(infoX+(infoW-barLength-2), infoY+4+(infoH-8)/numLines, barLength, ((infoH-8)/numLines)*2-2, strInfo);
}

function DeviceDrawBars(GC gc, HackableDevices device, float infoX, float infoY, float infoW, float infoH)
{
    local string strInfo;
    local int numTools, numLines;
    local float hackStrength;
    local color col;

    numLines = 2;

    // draw a colored bar
    if (device.hackStrength != 0.0)
    {
        gc.SetStyle(DSTY_Translucent);
        col = GetColorScaled(device.hackStrength);
        gc.SetTileColor(col);
        gc.DrawPattern(infoX+(infoW-barLength-4), infoY+infoH/numLines, barLength*device.hackStrength, infoH/numLines-6, 0, 0, Texture'ConWindowBackground');
    }

    // draw the absolute number of multitools on top of the colored bar
    if ((device.bHackable) && (device.hackStrength != 0.0))
    {
        // do to the way HackableDevices uses a timer, it seems to use very slightly more tools than it's supposed to sometimes, rounding up to the next 100th of a hackStrength
        hackStrength = Ceil(device.hackStrength*100)/100.0;
        numTools = Ceil((hackStrength / player.SkillSystem.GetSkillLevelValue(class'SkillTech')));
        if (numTools == 1)
            strInfo = numTools @ msgTool;
        else
            strInfo = numTools @ msgTools;
        gc.DrawText(infoX+(infoW-barLength-2), infoY+infoH/numLines, barLength, infoH/numLines-6, strInfo);
    }
}

defaultproperties
{
    msgDamageThreshold="Min Dmg:"
    msgShot="shot"
    msgShots="shots"
}
