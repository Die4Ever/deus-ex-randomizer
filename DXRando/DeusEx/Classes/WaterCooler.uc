class DXRWaterCooler injects #var(prefix)WaterCooler;

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
            PlayDrown(Frobber);
            foreach AllActors(class'DXRando', dxr) {
                class'DXREvents'.static.MarkBingo(dxr,"ChugWater");
            }
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

defaultproperties
{
#ifdef hx
    ReuseDelay=0.4
#endif
}
