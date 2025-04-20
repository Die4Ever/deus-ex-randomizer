#compileif vmd
class AugNinja extends VMDBufferAugmentation;

function float VMDConfigureNoiseMult()
{
    return 0;
}

function float VMDConfigureJumpMult()
{
    return LevelValues[CurrentLevel];
}

function float VMDConfigureSpeedMult(bool bWater)
{
     if (!bWater) return LevelValues[CurrentLevel];
     return 1.0;
}

defaultproperties
{
    EnergyRate=40.000000
    Icon=Texture'AugIconNinja'
    smallIcon=Texture'AugIconNinja_Small'
    AugmentationName="Ninja"
    Description="I AM NINJA!"
    MPInfo="I AM NINJA!"
    LevelValues(0)=1.4
    LevelValues(1)=1.5
    LevelValues(2)=1.6
    LevelValues(3)=1.7
    AugmentationLocation=LOC_Leg
    MPConflictSlot=5
}
