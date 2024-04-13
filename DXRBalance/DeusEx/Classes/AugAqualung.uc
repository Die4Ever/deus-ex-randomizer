class DXRAugAqualung injects AugAqualung;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    // description gets overwritten by language file, also DXRAugmentations reads from the default.Description
    // use the vanilla Level 3 description for our max level even though we're using level 4 strength, because the level 4 description makes no sense
    default.Description = "Soda lime exostructures imbedded in the alveoli of the lungs convert CO2 to O2, extending the time an agent can remain underwater."
                            $ "|n|nTECH ONE: Lung capacity is extended moderately.|n|nTECH TWO: Lung capacity is extended significantly.";
    Description = default.Description;
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
    AutoLength=0
    AutoEnergyMult=1// no penalty, it's a gift
    MaxLevel=1
    LevelValues(0)=60.000000
    LevelValues(1)=240.000000
}
