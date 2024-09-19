class DXRCigaretteMachine injects CigaretteMachine;

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
