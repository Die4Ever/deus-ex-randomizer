class DXRHUDHitDisplay merges HUDHitDisplay;

function SetHitColor(out BodyPart part, float deltaSeconds, bool bHide, int hitValue)
{
    deltaSeconds = FClamp(deltaSeconds, 0, 0.05); // limit delta, so numbers don't go crazy
    _SetHitColor(part, deltaSeconds, bHide, hitValue);
}
