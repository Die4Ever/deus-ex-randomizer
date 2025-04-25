class DXRCigaretteMachine injects #var(prefix)CigaretteMachine;

function Frob(Actor frobber, Inventory frobWith)
{
    local int usesBefore;

    usesBefore = numUses;

    Super.Frob(frobber, frobWith);

    if (numUses != usesBefore) {
        class'DXREvents'.static.MarkBingo("VendingMachineDispense_Cigs");
        class'DXREvents'.static.MarkBingo("VendingMachineDispense");
        if (numUses == 0) {
            class'DXREvents'.static.MarkBingo("VendingMachineEmpty");
        }
    }
}

//This is interesting, but it (theoretically) encourages just destroying the
//machine instead of even considering buying from it.  Of course, this is
//not wildly relevant here since cigarettes are (mostly) useless, but still...
/*
function Destroyed()
{
    local int i;
    local #var(prefix)Cigarettes cigs;

    if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) {
        for (i=0;i<numUses;i++){
            cigs = Spawn(class'#var(prefix)Cigarettes',,,Location);
            class'DXRActorsBase'.static.ThrowItem(cigs, 0.3);
        }
    }

    Super.Destroyed();
}
*/
