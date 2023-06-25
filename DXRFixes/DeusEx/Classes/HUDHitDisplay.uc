class DXRHUDHitDisplay merges HUDHitDisplay;

function SetHitColor(out BodyPart part, float deltaSeconds, bool bHide, int hitValue)
{
    deltaSeconds = FMin(deltaSeconds, 0.05); // maximum delta, so numbers don't go crazy
    _SetHitColor(part, deltaSeconds, bHide, hitValue);
}
