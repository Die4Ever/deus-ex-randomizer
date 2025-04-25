class DXRHUDAmmoDisplay injects HUDAmmoDisplay;
// DXRando: don't just show ammo, also show DeusExPickups

event Tick(float deltaSeconds)
{
    local bool bGoodItem;
    local DeusExPickup pickup;

    pickup = DeusExPickup(player.InHand);
    bGoodItem = player.Weapon != None || (pickup != None && pickup.maxCopies > 1);

    if (bGoodItem && bVisible)
        Show();
    else
        Hide();
}


event DrawWindow(GC gc)
{
    local Inventory item;
    local DeusExWeapon weapon;
    local DeusExPickup pickup;
    local int ammoRemaining, LowAmmoWaterMark, clipsRemaining, ammoInClip, ReloadCount;
    local bool bIsReloading, bCanTrack;

    Super(HUDBaseWindow).DrawWindow(gc);

    // No need to draw anything if the player doesn't have
    // a weapon selected

    if(player==None) return;
    weapon = DeusExWeapon(player.Weapon);
    pickup = DeusExPickup(player.InHand);

    if(weapon != None) {
        item = weapon;
        if (weapon.AmmoType != None)
            ammoRemaining = weapon.AmmoType.AmmoAmount;
        LowAmmoWaterMark = weapon.LowAmmoWaterMark;
        ReloadCount = weapon.ReloadCount;
        if (ReloadCount > 1 )
        {
            ammoInClip = weapon.AmmoLeftInClip();
            clipsRemaining = weapon.NumClips();
        }
        bIsReloading = weapon.IsInState('Reload');
        bCanTrack = weapon.bCanTrack;
    } else if(pickup != None) {
        item = pickup;
        ammoRemaining = pickup.numCopies;
        ammoInClip = ammoRemaining;
        ReloadCount = pickup.maxCopies;
        clipsRemaining = ReloadCount;
        LowAmmoWaterMark = 2;
    } else {
        return;
    }

    // Draw the weapon icon
    gc.SetStyle(DSTY_Masked);
    gc.SetTileColorRGB(255, 255, 255);
    gc.DrawTexture(22, 20, 40, 35, 0, 0, item.icon);

    // Draw the ammo count
    gc.SetFont(Font'FontTiny');
    gc.SetAlignments(HALIGN_Center, VALIGN_Center);
    gc.EnableWordWrap(false);

    if ( ammoRemaining < LowAmmoWaterMark )
        gc.SetTextColor(colAmmoLowText);
    else
        gc.SetTextColor(colAmmoText);

    // Ammo count drawn differently depending on user's setting
    if (ReloadCount > 1 )
    {
        if (bIsReloading)
            gc.DrawText(infoX, 26, 20, 9, msgReloading);
        else
            gc.DrawText(infoX, 26, 20, 9, ammoInClip);

        // if there are no clips (or a partial clip) remaining, color me red
        if (( clipsRemaining == 0 ) || (( clipsRemaining == 1 ) && ( ammoRemaining < 2 * ReloadCount )))
            gc.SetTextColor(colAmmoLowText);
        else
            gc.SetTextColor(colAmmoText);

        if (bIsReloading)
            gc.DrawText(infoX, 38, 20, 9, msgReloading);
        else
            gc.DrawText(infoX, 38, 20, 9, clipsRemaining);
    }
    else
    {
        gc.DrawText(infoX, 38, 20, 9, NotAvailable);

        if (ReloadCount == 0)
        {
            gc.DrawText(infoX, 26, 20, 9, NotAvailable);
        }
        else
        {
            if (bIsReloading)
                gc.DrawText(infoX, 26, 20, 9, msgReloading);
            else
                gc.DrawText(infoX, 26, 20, 9, ammoRemaining);
        }
    }

    // Now, let's draw the targetting information
    if (bCanTrack)
    {
        if (weapon.LockMode == LOCK_Locked)
            gc.SetTextColor(colLockedText);
        else if (weapon.LockMode == LOCK_Acquire)
            gc.SetTextColor(colTrackingText);
        else
            gc.SetTextColor(colNormalText);
        gc.DrawText(25, 56, 65, 8, weapon.TargetMessage);
    }
}

function DrawBackground(GC gc)
{
    local string tAmmoLabel, tClipsLabel;
    local DeusExWeapon weapon;
    local DeusExPickup pickup;

    if(player != None) {
        weapon = DeusExWeapon(player.Weapon);
        pickup = DeusExPickup(player.InHand);
    }
    if(weapon != None) {
        tAmmoLabel = AmmoLabel;
        tClipsLabel = ClipsLabel;
    } else if(pickup != None) {
        tAmmoLabel = "COUNT";
        tClipsLabel = "MAX";
    }

    gc.SetStyle(backgroundDrawStyle);
    gc.SetTileColor(colBackground);
    gc.DrawTexture(13, 13, 80, 54, 0, 0, texBackground);

    // Draw the Ammo and Clips text labels
    gc.SetFont(Font'FontTiny');
    gc.SetTextColor(colText);
    gc.SetAlignments(HALIGN_Center, VALIGN_Top);

    gc.DrawText(66, 17, 21, 8, tAmmoLabel);
    gc.DrawText(66, 48, 21, 8, tClipsLabel);
}
