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
{// aqualung is, conceptually, always on
    return bIsActive && Player != None && Player.HeadRegion.Zone.bWaterZone;
}

function Tick(float deltaTime)
{
    if (IsTicked()) {
        player.swimTimer = player.swimDuration;
    }
    Super.Tick(deltaTime);
}

defaultproperties
{
    bAlwaysActive=true
    EnergyRate=0
    MaxLevel=0
}
