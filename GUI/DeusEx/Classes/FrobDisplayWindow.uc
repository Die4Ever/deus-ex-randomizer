class DXRFrobDisplayWindow injects FrobDisplayWindow;

var localized string msgDamageThreshold;
var localized string msgShot;
var localized string msgShots;

var transient bool inited;
var transient bool auto_codes;
var transient bool known_codes;
var transient bool show_keys;

function DrawWindow(GC gc)
{
    local actor frobTarget;

    InitFlags();

    if (player != None)
    {
        frobTarget = player.FrobTarget;
        if (frobTarget != None)
            if (!player.IsHighlighted(frobTarget))
                frobTarget = None;
    }

    if( frobTarget != None ) DrawWindowBase(gc, frobTarget);
}

function CheckAutofillSettings()
{
    local int codes_mode;
    local DXRFlags flags;
    if( player == None || player.FlagBase == None ) return;
    inited = true;

    codes_mode = int(player.ConsoleCommand("get #var(package).MenuChoice_PasswordAutofill codes_mode"));
    if( codes_mode == 2 ) {
        auto_codes = true;
    } else {
        auto_codes = false;
    }
    if( codes_mode >= 1 ) {
        known_codes = true;
    } else {
        known_codes = false;
    }

    if(player.FlagBase.GetInt('Rando_passwordsrandomized') <= 0) {
        auto_codes = false;
        known_codes = false;
    }

    show_keys = bool(player.ConsoleCommand("get #var(package).MenuChoice_ShowKeys enabled"));
}

function InitFlags()
{
    if( inited ) return;
    CheckAutofillSettings();
}

//MenuChoice_PasswordAutofill sends out a ChangeStyle message when adjusted
event StyleChanged()
{
    Super.StyleChanged();
    CheckAutofillSettings();
}

static function GetActorBoundingBox(actor frobTarget, out vector centerLoc, out vector radius)
{
    local Mover     M;
    local Vector    TopLeft, BottomRight;

    // get the center of the object
    M = Mover(frobTarget);
    if (M != None)
    {
        M.GetBoundingBox(TopLeft, BottomRight, False, M.KeyPos[M.KeyNum]+M.BasePos, M.KeyRot[M.KeyNum]+M.BaseRot);
        radius = (BottomRight - TopLeft) * 0.5;
        centerLoc = BottomRight - radius;
    }
    else
    {
        centerLoc = frobTarget.Location;
        radius.X = frobTarget.CollisionRadius;
        radius.Y = frobTarget.CollisionRadius;
        radius.Z = frobTarget.CollisionHeight;
    }
}

static function BoxToWindowCoords(Window w, float margin, vector centerLoc, vector radius, out float boxTLX, out float boxTLY, out float boxBRX, out float boxBRY)
{
    local vector    v;
    local float     boxCX, boxCY;
    local float     x, y;
    local int       i, j, k;

    radius *= 0.9;// is this similar to vanilla? seems close enough
    w.ConvertVectorToCoordinates(centerLoc, boxCX, boxCY);

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
                v = radius;
                v.X *= i;
                v.Y *= j;
                v.Z *= k;
                v.X += centerLoc.X;
                v.Y += centerLoc.Y;
                v.Z += centerLoc.Z;

                if (w.ConvertVectorToCoordinates(v, x, y))
                {
                    boxTLX = FMin(boxTLX, x-1);
                    boxTLY = FMin(boxTLY, y-1);
                    boxBRX = FMax(boxBRX, x+1);
                    boxBRY = FMax(boxBRY, y+1);
                }
            }
        }
    }

    boxTLX = FClamp(boxTLX, margin, w.width-margin);
    boxTLY = FClamp(boxTLY, margin, w.height-margin);
    boxBRX = FClamp(boxBRX, margin, w.width-margin);
    boxBRY = FClamp(boxBRY, margin, w.height-margin);
}

static function GetActorBox(Window w, actor frobTarget, float margin, out float boxTLX, out float boxTLY, out float boxBRX, out float boxBRY)
{
    local Vector    centerLoc, radius;

    GetActorBoundingBox(frobTarget, centerLoc, radius);
    if(Mover(frobTarget) != None) {
        radius.X = 18;// vanilla uses 16 for 1 foot, but then we multiply by 0.9 in BoxToWindowCoords
        radius.Y = 18;
        radius.Z = 18;
    }
    BoxToWindowCoords(w, margin, centerLoc, radius, boxTLX, boxTLY, boxBRX, boxBRY);
}

function DrawWindowBase(GC gc, actor frobTarget)
{
    local float     infoX, infoY, infoW, infoH;
    local string    strInfo;
    local float     boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
    local float     corner;
    local int       i, offset, numLines;
    local Color     col;

    // move the box in and out based on time
    offset = (24.0 * (frobTarget.Level.TimeSeconds % 0.3));

    // draw a cornered targetting box
    GetActorBox(self, frobTarget, margin, boxTLX, boxTLY, boxBRX, boxBRY);

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
    strInfo = GetStrInfo(frobTarget, numLines);

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

    DrawActorBars(gc, frobTarget, infoX, infoY, infoW, infoH, numLines);

    // draw the text
    gc.DrawText(infoX+4, infoY+4, infoW-8, infoH-8, strInfo);

    // draw the two highlight boxes
    gc.SetStyle(DSTY_Translucent);
    gc.SetTileColor(colBorder);
    gc.DrawBox(infoX, infoY, infoW, infoH, 0, 0, 1, Texture'Solid');
    gc.SetTileColor(colBackground);
    gc.DrawBox(infoX+1, infoY+1, infoW-2, infoH-2, 0, 0, 1, Texture'Solid');
}

function string GetStrInfo(Actor a, out int numLines)
{
    if ( Mover(a) != None )
        return MoverStrInfo(Mover(a), numLines);
    else if ( HackableDevices(a) != None )
        return DeviceStrInfo(HackableDevices(a), numLines);
    else if ( Computers(a) != None || ATM(a) != None )
        return ComputersStrInfo(ElectronicDevices(a), numLines);
    else if (!a.bStatic && player.bObjectNames)
        return OtherStrInfo(a, numLines);

    return "";
}

function string MoverStrInfo(Mover m, out int numLines)
{
    local string strInfo;
    local DeusExMover dxMover;

    numLines = 4;

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

        if ( show_keys ){
            if (dxMover.KeyIDNeeded != ''){
                numLines++;
                if (player!=None && Player.KeyRing.HasKey(dxMover.KeyIDNeeded)){
                    strInfo = strInfo $ CR() $ "Key acquired";
                } else {
                    strInfo = strInfo $ CR() $ "Key unacquired";
                }
            }
        }
    }
    else
    {
        strInfo = msgUnlocked;
    }

    return strInfo;
}

function string DeviceStrInfo(HackableDevices device, out int numLines)
{
    local string strInfo;

#ifdef injections
    local Keypad k;
#else
    local DXRKeypad k;
#endif

    numLines = 2;

    strInfo = device.itemName $ CR() $ msgHackStr;
    if (device.bHackable)
    {
        if (device.hackStrength != 0.0)
            strInfo = strInfo $ FormatString(device.hackStrength * 100.0) $ "%";
        else {
            //Should try to track if the player knew the code before hacking it
            //if (codeKnown) {
            //    strInfo = device.itemName $ ": " $ msgHacked $ " (YOU KNEW THE CODE THOUGH!)";
            //} else {
                strInfo = device.itemName $ ": " $ msgHacked;
            //}
            return strInfo;
        }
    }
    else
        strInfo = strInfo $ msgInf;

#ifdef injections
    k=Keypad(device);
#else
    k=DXRKeypad(device);
#endif

    if( k!=None && (k.bCodeKnown) )
    {
        if( auto_codes ) {
            numLines = 3;
            strInfo = strInfo $ CR() $ "Code Known ("$Keypad(device).validCode$")";
        }
        else if( known_codes ) {
            numLines = 3;
            strInfo = strInfo $ CR() $ "Code Known";
        }
    }
    else if( device.IsA('Keypad') && known_codes )
    {
        numLines = 3;
        strInfo = strInfo $ CR() $ "Unknown Code";
    }

    return strInfo;
}

function string ComputersStrInfo(ElectronicDevices d, out int numLines)
{
    local Computers c;
    local ATM a;
    local string strInfo;

    strInfo = player.GetDisplayName(d);

    c = Computers(d);
    a = ATM(d);
#ifdef vanilla
    if( known_codes && c != None )
    {
        if( c.HasKnownAccounts() )
            strInfo = strInfo $ CR() $ "Password Known";
        else
            strInfo = strInfo $ CR() $ "Unknown Password";
    }
    else if( known_codes && a != None )
    {
        if( a.HasKnownAccounts() )
            strInfo = strInfo $ CR() $ "PIN Known";
        else
            strInfo = strInfo $ CR() $ "Unknown PIN";
    }
#endif
    return strInfo;
}

function string OtherStrInfo(Actor frobTarget, out int numLines)
{
    local string strInfo;

    // TODO: Check familiar vs. unfamiliar flags
    if (frobTarget.IsA('Pawn'))
        strInfo = player.GetDisplayName(frobTarget);
    else if (frobTarget.IsA('#var(DeusExPrefix)Carcass'))
        strInfo = #var(DeusExPrefix)Carcass(frobTarget).itemName;
    else if (frobTarget.IsA('Inventory')) {
        strInfo = Inventory(frobTarget).itemName;
        if (frobTarget.IsA('Ammo'))
            strInfo = Inventory(frobTarget).itemName $ " (" $ Ammo(frobTarget).AmmoAmount $ ")";
        else if (frobTarget.IsA('Pickup') && Pickup(frobTarget).NumCopies > 1)
            strInfo = Inventory(frobTarget).itemName $ " (" $ Pickup(frobTarget).NumCopies $ ")";
        else if (frobTarget.IsA('Weapon') && Weapon(frobTarget).AmmoName != Class'DeusEx.AmmoNone' )
            strInfo = Inventory(frobTarget).itemName $ " (" $ Weapon(frobTarget).PickupAmmoCount $ ")";
    }
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

function DrawActorBars(GC gc, Actor a, float infoX, float infoY, float infoW, float infoH, int numLines)
{
    if ( Mover(a) != None )
        MoverDrawBars(gc, Mover(a), infoX, infoY, infoW, infoH, numLines);
    else if ( HackableDevices(a) != None )
        DeviceDrawBars(gc, HackableDevices(a), infoX, infoY, infoW, infoH, numLines);
}

function MoverDrawBars(GC gc, Mover m, float infoX, float infoY, float infoW, float infoH, int numLines)
{
    local DeusExMover dxMover;
    local string strInfo;
    local color col;
    local int numTools, numShots;
    local float damage;
#ifdef vanilla
    local DXRWeapon w;
#endif

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
        numTools = GetNumTools(dxMover.lockStrength, player.SkillSystem.GetSkillLevelValue(class'SkillLockpicking'));
        if (numTools == 1)
            strInfo = numTools @ msgPick;
        else
            strInfo = numTools @ msgPicks;
    }

#ifdef vanilla
    if ((dxMover != None) && dxMover.bLocked && dxMover.bBreakable)
    {
        w = DXRWeapon(player.inHand);
        if( w != None ) {
            damage = dxMover.CalcDamage(w.GetDamage(), w.WeaponDamageType()) * float(w.GetNumHits());
            if( damage > 0 ) {
                numshots = GetNumHits(dxMover.doorStrength, damage);
                if( numshots == 1 )
                    strInfo = strInfo $ CR() $ numshots @ msgShot;
                else
                    strInfo = strInfo $ CR() $ numshots @ msgShots;
            } else {
                strInfo = strInfo $ CR() $ msgInf @ msgShots;
            }
        }
    }
#endif
    gc.DrawText(infoX+(infoW-barLength-2), infoY+4+(infoH-8)/numLines, barLength, ((infoH-8)/numLines)*2-2, strInfo);
}

function DeviceDrawBars(GC gc, HackableDevices device, float infoX, float infoY, float infoW, float infoH, int numLines)
{
    local string strInfo;
    local int numTools;
    local color col;

    // idk why this is slightly misaligned
    infoY += 2;

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
        numTools = GetNumTools(device.hackStrength, player.SkillSystem.GetSkillLevelValue(class'SkillTech'));
        if (numTools == 1)
            strInfo = numTools @ msgTool;
        else
            strInfo = numTools @ msgTools;
        gc.DrawText(infoX+(infoW-barLength-2), infoY+infoH/numLines, barLength, infoH/numLines-6, strInfo);
    }
}

static function int GetNumHits(float strength, float damage)
{
    local int numHits;
    for(numHits=0; !(strength~=0.0) && numHits<1000; numHits++) {
        strength -= damage;
        strength = FClamp(strength, 0.0, 1.0);
    }
    return numHits;
}

static function int GetNumTools(float strength, float skill)
{
    local int numTools, numTicks, i;

    numTicks = skill * 100;
    for(numTools=0; !(strength ~= 0.0) && numTools<100; numTools++) {
        for(i=0; i<numTicks; i++) {
            strength -= 0.01;
            strength = FClamp(strength, 0.0, 1.0);
        }
    }
    return numTools;
}

defaultproperties
{
    msgDamageThreshold="Min Dmg:"
    msgShot="shot"
    msgShots="shots"
}
