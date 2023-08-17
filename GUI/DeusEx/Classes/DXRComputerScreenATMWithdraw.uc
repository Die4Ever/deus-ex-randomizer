class DXRComputerScreenATMWithdraw injects ComputerScreenATMWithdraw;

function SetCompOwner(ElectronicDevices newCompOwner)
{
    Super.SetCompOwner(newCompOwner);

    //Set the withdraw field to the same amount as the available balance
    editWithdraw.SetText(editBalance.GetText());
}
