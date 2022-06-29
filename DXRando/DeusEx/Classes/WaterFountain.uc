class DXRWaterFountain injects #var(prefix)WaterFountain;

var float firstUse;

function Frob(Actor Frobber, Inventory frobWith)
{
    local bool oldUsing, newUsing;
    local int oldNumUses;
    local DXRando dxr;

#ifdef hx
    oldUsing = BubbleTime > 0.0;
#else
    oldUsing = bUsing;
#endif
    oldNumUses = numUses;

    Super.Frob(Frobber, frobWith);
#ifdef hx
    newUsing = BubbleTime > 0.0;
#else
    newUsing = bUsing;
#endif

    if (newUsing && !oldUsing) {
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
