class DXRAugAqualung injects AugAqualung;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    Description = default.Description;
}

simulated function SetAutomatic()
{
    Super.SetAutomatic();
    // aqualung doesn't take the penalty for being automatic, this one is just a gift
    energyRate = default.energyRate;
}

simulated function bool IsTicked()
{// aqualung is perfectly automatic
    local bool bWater;

    if(Player == None) return false;
    bWater = Player.HeadRegion.Zone.bWaterZone && Player.swimTimer > 0;

    return (bAutomatic==false && bIsActive)
        || (bAutomatic && bIsActive && bWater && Player.Energy > 0);
}

defaultproperties
{
    bAutomatic=true
    MaxLevel=1
    Description="Soda lime exostructures imbedded in the alveoli of the lungs convert CO2 to O2, extending the time an agent can remain underwater.|n|nTECH ONE: Lung capacity is extended moderately.|n|nTECH TWO: An agent can stay underwater indefinitely."
    LevelValues(0)=60.000000
    LevelValues(1)=240.000000
}
