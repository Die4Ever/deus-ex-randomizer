#ifdef injections
class WaterFountain injects WaterFountain;
#else
class DXRWaterFountain extends #var(prefix)WaterFountain;
#endif

var float firstUse;

function Frob(Actor Frobber, Inventory frobWith)
{
    local bool oldUsing;
    local int oldNumUses;
    local DXRando dxr;
    oldUsing = bUsing;
    oldNumUses = numUses;

    Super.Frob(Frobber, frobWith);
    if (bUsing && !oldUsing) {
        SetTimer(0.4, False);
        if( oldNumUses == default.numUses )
            firstUse = Level.TimeSeconds;
        if (numUses <= 0 && oldNumUses > 0 && firstUse > 0 && Level.TimeSeconds - firstUse < 6)
        {
#ifdef injections
            class'WaterCooler'.static.PlayDrown(Frobber);
#else
            class'DXRWaterCooler'.static.PlayDrown(Frobber);
#endif
            foreach AllActors(class'DXRando', dxr) {
                class'DXREvents'.static.MarkBingo(dxr,"ChugWater");
            }
        }
    }
}
