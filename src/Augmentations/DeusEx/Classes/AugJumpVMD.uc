#compileif vmd
class AugJump extends VMDBufferAugmentation;

function float VMDConfigureJumpMult()
{
    return LevelValues[CurrentLevel];
}

function UpdateBalance()
{
    local int i;
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        LevelValues[0] = 1.2;
        LevelValues[1] = 1.35;
        LevelValues[2] = 1.5;
        LevelValues[3] = 1.7;
    } else {
        LevelValues[0] = 1.2;
        LevelValues[1] = 1.4;
        LevelValues[2] = 1.6;
        LevelValues[3] = 1.8;
    }
    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
}

defaultproperties
{
    LevelValues(0)=1.2
    LevelValues(1)=1.35
    LevelValues(2)=1.5
    LevelValues(3)=1.7
    EnergyRate=30

    Icon=Texture'AugIconJumpOnly'
    smallIcon=Texture'AugIconJumpOnly_Small'
    AugmentationName="Jump Enhancement"
    Description="Ionic polymeric gel myofibrils are woven into the leg muscles, increasing the height they can jump, and reducing the damage they receive from falls.|n|nTECH ONE: Jumping is increased slightly, while falling damage is reduced.|n|nTECH TWO: Jumping is increased moderately, while falling damage is further reduced.|n|nTECH THREE: Jumping is increased significantly, while falling damage is substantially reduced.|n|nTECH FOUR: An agent can leap from the tallest building."
    MPInfo="When active, you jump higher.  Energy Drain: Very High"
    AugmentationLocation=LOC_Leg
    MPConflictSlot=5
}
