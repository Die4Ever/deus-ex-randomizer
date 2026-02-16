class DXRHUDHitDisplay merges HUDHitDisplay;

function SetHitColor(out BodyPart part, float deltaSeconds, bool bHide, int hitValue)
{
    local Color col;
    local float mult;
    local float maxHealth;
    local DXRando dxr;

    deltaSeconds = FClamp(deltaSeconds, 0, 0.05); // limit delta, so numbers don't go crazy

    // if going from dead to alive, immediately put the body part at 1 health so it draws red right away, great for drinking alcohol when it would take multiple seconds to fade from 0 health to 1 health
    if(hitValue > 0 && part.displayedHealth <= 0) {
        part.displayedHealth = 1;
    }
    _SetHitColor(part, deltaSeconds, bHide, hitValue);

    //Draw colours relative to your maximum health, rather than always being relative to 100 health
    maxHealth = 100.0;
    dxr = class'DXRando'.Default.dxr;
    if (dxr!=None && dxr.flags!=None){
        maxHealth = dxr.flags.settings.health;
    }

    col = class'MenuChoice_ColorVision'.static.GetVisionColorScaled(part.displayedHealth/maxHealth);

    if (part.damageCounter > 0)
    {
        mult = part.damageCounter/damageFlash;
        col.r += (255-col.r)*mult;
        col.g += (255-col.g)*mult;
        col.b += (255-col.b)*mult;
    }

    if (part.partWindow != None)
    {
        part.partWindow.SetTileColor(col);
    }
}

function CreateBodyPart(out BodyPart part, texture tx, float newX, float newY,
                        float newWidth, float newHeight)
{
    _CreateBodyPart(part,tx,newX,newY,newWidth,newHeight);
    //part.partWindow.SetBackgroundStyle(DSTY_Masked);
}
