class DXRWaterCooler injects #var(prefix)WaterCooler;

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
            PlayDrown(Frobber);
            class'DXREvents'.static.MarkBingo("ChugWater");
        }
    }
}

simulated static function PlayDrown(Actor a)
{
    local sound TSound;
    local DeusExPlayer p;
    p = DeusExPlayer(a);

    if (p != None && p.FlagBase != None && p.FlagBase.GetBool('LDDPJCIsFemale')) {
        if (FRand() < 0.5)
            TSound = Sound(DynamicLoadObject("FemJC.FJCDrown", class'Sound', false));
        else
            TSound = Sound(DynamicLoadObject("FemJC.FJCGasp", class'Sound', false));
    }
    if(TSound == None) {
        if (FRand() < 0.5)
            TSound = sound'MaleDrown';
        else
            TSound = sound'MaleGasp';
    }

    a.PlaySound(TSound, SLOT_Pain, 100,,, 1);
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
