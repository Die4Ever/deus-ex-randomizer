class DXRWaterFountain injects #var(prefix)WaterFountain;

var float firstUse;
var int timesUsed;

function Frob(Actor Frobber, Inventory frobWith)
{
    local bool oldUsing, newUsing;
    local int oldNumUses;
    local bool chugged;
    local float cooldown;

    oldUsing = #switch(hx: BubbleTime > 0.0, bUsing);
    oldNumUses = numUses;

    Super.Frob(Frobber, frobWith);
    newUsing = #switch(hx: BubbleTime > 0.0, bUsing);

    if (newUsing && !oldUsing) {
        if(class'MenuChoice_BalanceEtc'.static.IsEnabled() || #defined(vmd)) {
            cooldown = 0.4;
        } else {
            cooldown = 2;
        }

        if(!#defined(vmd))
            SetTimer(cooldown, False);
        if( oldNumUses == default.numUses || (#defined(vmd) && timesUsed==0) )
            firstUse = Level.TimeSeconds;
        timesUsed++;
        chugged = numUses <= 0 && oldNumUses > 0 && firstUse > 0 && Level.TimeSeconds - firstUse < cooldown*15;
        if(#defined(vmd)) {
            chugged = timesUsed == 5 && firstUse > 0 && Level.TimeSeconds - firstUse < 15;
        }
        if (chugged)
        {
            class'#var(injectsprefix)WaterCooler'.static.PlayDrown(Frobber);
            class'DXREvents'.static.MarkBingo("ChugWater");
        }
    }
}

function Destroyed()
{
    class'DXREvents'.static.MarkBingo("Dehydrated");

    Super.Destroyed();
}

defaultproperties
{
#ifdef hx
    ReuseDelay=0.4
#endif
}
