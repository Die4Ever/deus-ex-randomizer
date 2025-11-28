class DXRComputerScreenATMWithdraw injects ComputerScreenATMWithdraw;

function SetCompOwner(ElectronicDevices newCompOwner)
{
    Super.SetCompOwner(newCompOwner);

    //Set the withdraw field to the same amount as the available balance
    editWithdraw.SetText(editBalance.GetText());
}

function WithdrawCredits()
{
    local int balance,userIdx;
    local bool wasEmpty,emptyAfter;

    if (winTerm.bHacked)
        userIdx = -1;
    else
        userIdx = winTerm.GetUserIndex();

    wasEmpty=(atmOwner.GetBalance(userIdx, balanceModifier)==0);

    Super.WithdrawCredits();

    emptyAfter=(atmOwner.GetBalance(userIdx, balanceModifier)==0);

    if (!wasEmpty && emptyAfter) {
        class'DXREvents'.static.MarkBingo("CivilForfeiture");
    }
}
