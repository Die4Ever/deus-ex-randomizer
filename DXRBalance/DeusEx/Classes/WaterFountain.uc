class WaterFountain injects WaterFountain;

var float firstUse;

function Frob(Actor Frobber, Inventory frobWith)
{
    local bool oldUsing;
    local int oldNumUses;
    oldUsing = bUsing;
    oldNumUses = numUses;

    Super.Frob(Frobber, frobWith);
    if (bUsing && !oldUsing) {
        SetTimer(0.4, False);
        if( oldNumUses == default.numUses )
            firstUse = Level.TimeSeconds;
        if (numUses <= 0 && oldNumUses > 0 && firstUse > 0 && Level.TimeSeconds - firstUse < 6)
        {
            class'WaterCooler'.static.PlayDrown(Frobber);
        }
    }
}
