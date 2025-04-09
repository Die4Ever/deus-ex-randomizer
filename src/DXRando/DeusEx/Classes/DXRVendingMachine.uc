class DXRVendingMachine injects #var(prefix)VendingMachine;

function DoSpawn(actor Frobber, Inventory frobWith)
{
    Super.Frob(Frobber, frobWith);
}

function Frob(actor Frobber, Inventory frobWith)
{
    local int usesBefore;
    local String vendType;

    usesBefore = numUses;

    DoSpawn(Frobber,frobWith);

    if (usesBefore==0){
        return;
    }

    //If you actually succeeded in buying something, mark purchase for the specific type and in general
    if (usesBefore!=0 && numUses!=usesBefore){
        if (SkinColor==SC_Drink){
            vendType="Drink";
        } else if (SkinColor==SC_Snack){
            vendType="Candy";
        }
        class'DXREvents'.static.MarkBingo("VendingMachineDispense_"$vendType);
        class'DXREvents'.static.MarkBingo("VendingMachineDispense");
        //Mark if you actually empty a machine
        if (numUses==0){
            class'DXREvents'.static.MarkBingo("VendingMachineEmpty_"$vendType);
            class'DXREvents'.static.MarkBingo("VendingMachineEmpty");
        }
    }
}
