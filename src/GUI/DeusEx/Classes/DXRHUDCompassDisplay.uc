class DXRHUDCompassDisplay injects HUDCompassDisplay;

var transient bool inited;
var vector coords_mult;

event Tick(float deltaSeconds)
{
    local Rotator playerRot;

    if (player==None) return;

    if (!inited){
        coords_mult = class'DXRMapVariants'.static.GetCoordsMult(player.GetURLMap());
        inited = true;
    }

    //Mirror the players rotation if on mirrored maps (so it goes back to unmirrored rotation)
    playerRot = class'DXRBase'.static.rotm_static(player.Rotation.Pitch,
                                                  player.Rotation.Yaw,
                                                  player.Rotation.Roll,
                                                  class'DXRActorsBase'.static.GetRotationOffset(player.class),
                                                  coords_mult);

    // Only continue if we moved
    //Duplicated from HUDCompassDisplay, but using playerRot instead of player.Rotation
    if (lastPlayerYaw != playerRot.Yaw)
    {
        lastPlayerYaw = playerRot.Yaw;

        // Based on the player's rotation and the map's True North, calculate
        // where to draw the tick marks and letters
        drawPos = clipWidthHalf - (((lastPlayerYaw - mapNorth) & 65535) / UnitsPerPixel);

        // We have two tickmark windows to compensate what happens with
        // the wrap condition.

        if ((drawPos > 0) && (drawPos < clipWidth))
            wrapPos = drawPos - tickWidth;
        else if (drawPos - tickWidth < (clipWidthHalf))
            wrapPos = drawPos + tickWidth;
        else
            wrapPos = 100;

        winCompass1.SetPos(drawPos, 0);
        winCompass2.SetPos(wrapPos, 0);
    }
}
