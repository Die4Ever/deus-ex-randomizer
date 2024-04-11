class DXRHUDHitDisplay merges HUDHitDisplay;

function SetHitColor(out BodyPart part, float deltaSeconds, bool bHide, int hitValue)
{
    deltaSeconds = FClamp(deltaSeconds, 0, 0.05); // limit delta, so numbers don't go crazy

    // if going from dead to alive, immediately put the body part at 1 health so it draws red right away, great for drinking alcohol when it would take multiple seconds to fade from 0 health to 1 health
    if(hitValue > 0 && part.displayedHealth <= 0) {
        part.displayedHealth = 1;
    }
    _SetHitColor(part, deltaSeconds, bHide, hitValue);
}
