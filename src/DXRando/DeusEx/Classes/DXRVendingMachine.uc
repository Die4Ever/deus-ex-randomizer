class DXRVendingMachine injects #var(prefix)VendingMachine;

function DoSpawn(actor Frobber, Inventory frobWith)
{
    Super.Frob(Frobber, frobWith);
}

function int GetNumUses()
{
#ifndef vmd
    return numUses;
#else
    local int totalUses,i;

    if (!bAdvancedUse) return numUses;

    totalUses = 0;

    for (i=0;i<ArrayCount(AdvancedUses);i++){
        totalUses += AdvancedUses[i];
    }

    return totalUses;
#endif
}

function Frob(actor Frobber, Inventory frobWith)
{
    local int usesBefore,usesAfter;
    local String vendType;

    usesBefore = GetNumUses();

    DoSpawn(Frobber,frobWith);

    if (usesBefore==0){
        return;
    }

    usesAfter = GetNumUses();

    //If you actually succeeded in buying something, mark purchase for the specific type and in general
    if (usesBefore!=0 && usesAfter!=usesBefore){
        if (SkinColor==SC_Drink){
            vendType="Drink";
        } else if (SkinColor==SC_Snack){
            vendType="Candy";
        }
        class'DXREvents'.static.MarkBingo("VendingMachineDispense_"$vendType);
        class'DXREvents'.static.MarkBingo("VendingMachineDispense");
        //Mark if you actually empty a machine
        if (usesAfter==0){
            class'DXREvents'.static.MarkBingo("VendingMachineEmpty_"$vendType);
            class'DXREvents'.static.MarkBingo("VendingMachineEmpty");
        }
    }
}
