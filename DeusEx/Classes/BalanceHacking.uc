class BalanceHacking injects ComputerScreenHack;

function Tick(float deltaTime)
{
    local DeusExPlayer p;
    if (bHacking)
    {
        p = DeusExPlayer(winTerm.compOwner.Owner);
        if( p != None ) {
            p.Energy -= deltaTime * 3.0;
            if( p.Energy <= 0 ) {
                p.Energy = 0;
                detectionTime = -1;
                bHackDetected = true;
            }
        }
    }

    Super.Tick(deltaTime);
}
