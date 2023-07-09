class DXRWaterFountain injects #var(prefix)WaterFountain;

var float firstUse;
var int timesUsed;

function Frob(Actor Frobber, Inventory frobWith)
{
    local bool oldUsing, newUsing;
    local int oldNumUses;
    local DXRando dxr;
    local bool chugged;

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
        if(!#defined(vmd))
            SetTimer(0.4, False);
        if( oldNumUses == default.numUses || (#defined(vmd) && timesUsed==0) )
            firstUse = Level.TimeSeconds;
        timesUsed++;
        chugged = numUses <= 0 && oldNumUses > 0 && firstUse > 0 && Level.TimeSeconds - firstUse < 6;
        if(#defined(vmd)) {
            chugged = timesUsed == 5 && firstUse > 0 && Level.TimeSeconds - firstUse < 15;
        }
        if (chugged)
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

defaultproperties
{
#ifdef hx
    ReuseDelay=0.4
#endif
}
