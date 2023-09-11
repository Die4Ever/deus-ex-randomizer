class DXRVendingMachine injects #var(prefix)VendingMachine;

function Frob(actor Frobber, Inventory frobWith)
{
    local int usesBefore;
    local DXRando dxr;
    local String vendType;

    usesBefore = numUses;

    Super.Frob(Frobber,frobWith);

    if (usesBefore==0){
        return;
    }

    //If you actually succeeded in buying something, mark purchase for the specific type and in general
    foreach AllActors(class'DXRando', dxr) {
        if (usesBefore!=0 && numUses!=usesBefore){
            if (SkinColor==SC_Drink){
                vendType="Drink";
            } else if (SkinColor==SC_Snack){
                vendType="Candy";
            }
            class'DXREvents'.static.MarkBingo(dxr,"VendingMachineDispense_"$vendType);
            class'DXREvents'.static.MarkBingo(dxr,"VendingMachineDispense");
            //Mark if you actually empty a machine
            if (numUses==0){
                class'DXREvents'.static.MarkBingo(dxr,"VendingMachineEmpty_"$vendType);
                class'DXREvents'.static.MarkBingo(dxr,"VendingMachineEmpty");
            }
        }
    }
}
