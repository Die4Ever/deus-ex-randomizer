class LavaFire extends Fire;

simulated function SpawnSmokeEffects()
{
    //Don't generate smoke
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    // randomize the lifespan a bit so things don't all disappear at once (1-2 seconds)
    LifeSpan += FRand();
}

defaultproperties
{
    bAlwaysRelevant=True
    LifeSpan=1
}
