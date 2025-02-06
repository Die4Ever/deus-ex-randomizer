class DXRAugAqualung injects AugAqualung;

function UpdateBalance()
{
    // description gets overwritten by language file, also DXRAugmentations reads from the default.Description
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        Description = "Soda lime exostructures imbedded in the alveoli of the lungs convert CO2 to O2, allowing an agent to remain underwater indefinitely.";
        MaxLevel = 0;
        EnergyRate = 0;
        bAlwaysActive = true;
    } else {
        Description = "Soda lime exostructures imbedded in the alveoli of the lungs convert CO2 to O2, extending the time an agent can remain underwater."
                        $ "|n|nTECH ONE: Lung capacity is extended slightly.|n|nTECH TWO: Lung capacity is extended moderately."
                        $ "|n|nTECH THREE: Lung capacity is extended significantly.|n|nTECH FOUR: An agent can stay underwater indefinitely.";
        MaxLevel = 3;
        EnergyRate = 10;
        bAlwaysActive = false;
    }
    default.Description = Description;
    default.MaxLevel = MaxLevel;
    default.EnergyRate = EnergyRate;
    default.bAlwaysActive = bAlwaysActive;
}

function Tick(float deltaTime)
{
    Super.Tick(deltaTime);
    if (IsTicked() && EnergyRate==0) {
        player.swimTimer = player.swimDuration;
    }
    if(bIsActive) {
        player.swimBubbleTimer = 0;
    }
}

defaultproperties
{
    bAlwaysActive=true
    EnergyRate=0
    MaxLevel=0
}
