#compileif vmd
class AugOnlySpeed extends VMDBufferAugmentation;

function float VMDConfigureSpeedMult(bool bWater)
{
     if (!bWater) return LevelValues[CurrentLevel];
     return 1.0;
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

//original went from 1.2 up to 1.8, I've thought about nerfing the max speed so you can't just run past all enemies, but I think that would require an unreasonably large nerf
//original EnergyRate is 40, might nerf it if people use it too much?
defaultproperties
{
    LevelValues(0)=1.2
    LevelValues(1)=1.35
    LevelValues(2)=1.5
    LevelValues(3)=1.7
    EnergyRate=40

    Icon=Texture'AugIconSpeedOnly'
    smallIcon=Texture'AugIconSpeedOnly_Small'
    AugmentationName="Running Enhancement"
    Description="Ionic polymeric gel myofibrils are woven into the leg muscles, increasing the speed at which an agent can run.|n|nTECH ONE: Speed is increased slightly.|n|nTECH TWO: Speed is increased moderately.|n|nTECH THREE: Speed is increased significantly.|n|nTECH FOUR: An agent can run like the wind."
    MPInfo="When active, you run faster.  Energy Drain: Very High"
    AugmentationLocation=LOC_Leg
    MPConflictSlot=5
}
