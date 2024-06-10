class DXRCigaretteMachine injects CigaretteMachine;

function Frob(Actor frobber, Inventory frobWith)
{
    local int usesBefore;
    local DXRando dxr;

    usesBefore = numUses;

    Super.Frob(frobber, frobWith);

    if (numUses == 0 && usesBefore != 0) {
        foreach AllActors(class'DXRando', dxr) {
            class'DXREvents'.static.MarkBingo(dxr, "VendingMachineEmpty");
            break;
        }
    }
}
