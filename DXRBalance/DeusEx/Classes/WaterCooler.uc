class WaterCooler injects WaterCooler;

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
            PlayDrown(Frobber);
        }
    }
}

function PlayDrown(Actor a)
{
    local sound TSound;
    local DeusExPlayer p;
    p = DeusExPlayer(a);

    if (p != None && p.FlagBase != None && p.FlagBase.GetBool('LDDPJCIsFemale'))
        TSound = Sound(DynamicLoadObject("FemJC.FJCDrown", class'Sound', false));
    if(TSound == None)
        TSound = sound'MaleDrown';
    
    a.PlaySound(TSound, SLOT_Pain, 100,,, 1);
}
