class DXRCigaretteMachine injects CigaretteMachine;

function Frob(Actor frobber, Inventory frobWith)
{
    local int usesBefore;
    local DXRando dxr;

    usesBefore = numUses;

    Super.Frob(frobber, frobWith);

    if (usesBefore != 0 && numUses != usesBefore) {
        foreach AllActors(class'DXRando', dxr) {
            class'DXREvents'.static.MarkBingo(dxr,"VendingMachineDispense_Cigs");
            class'DXREvents'.static.MarkBingo(dxr,"VendingMachineDispense");
            if (numUses == 0) {
                class'DXREvents'.static.MarkBingo(dxr, "VendingMachineEmpty");
            }
            break;
        }
    }
}
