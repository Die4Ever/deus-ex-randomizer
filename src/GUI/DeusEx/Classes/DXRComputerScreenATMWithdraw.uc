class DXRComputerScreenATMWithdraw injects ComputerScreenATMWithdraw;

function SetCompOwner(ElectronicDevices newCompOwner)
{
    Super.SetCompOwner(newCompOwner);

    //Set the withdraw field to the same amount as the available balance
    editWithdraw.SetText(editBalance.GetText());
}

function bool IsDuplicateATM(ATM a1, ATM a2)
{
    local int i;
    for(i=0;i<ArrayCount(a1.UserList);i++){
        if (a1.GetAccountNumber(i)!=a2.GetAccountNumber(i)) return false;
        if (a1.GetPIN(i)!=a2.GetPIN(i)) return false;
    }
    return true;
}

function bool IsATMEmpty(ATM a)
{
    local int i;

    return a.GetBalance(-1,1.0) <= 0;
}


function WithdrawCredits(#switch(gmdx: optional bool bWithdrawAll))
{
    local int balance,userIdx;
    local bool wasEmpty,emptyAfter;
    local ATM a;

    if (winTerm.bHacked)
        userIdx = -1;
    else
        userIdx = winTerm.GetUserIndex();

    wasEmpty=(atmOwner.GetBalance(userIdx, balanceModifier)==0);

    Super.WithdrawCredits(#switch(gmdx: bWithdrawAll));

    emptyAfter=(atmOwner.GetBalance(userIdx, balanceModifier)==0);

    if (!wasEmpty && emptyAfter) {
        class'DXREvents'.static.MarkBingo("CivilForfeiture");
    }

    if (atmOwner!=None && atmOwner.bSuckedDryByHack){
        //Sync suckage across ATMs, as long as the other one was drained by the hack
        foreach atmOwner.AllActors(class'ATM',a){
            if (a==atmOwner) continue;
            if (IsDuplicateATM(atmOwner,a) && IsATMEmpty(a)){
                a.bSuckedDryByHack=atmOwner.bSuckedDryByHack;
            }
        }
    }
}
