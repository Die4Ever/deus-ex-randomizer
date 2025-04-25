#dontcompileif vmd
class AugJump extends Augmentation;

#ifndef injections
var float Level5Value; // does nothing outside of vanilla, just a placeholder
simulated function float GetAugLevelValue()
{
    if(!bIsActive) return -1;
    return LevelValues[CurrentLevel];
}
simulated function float PreviewAugLevelValue()
{
    return GetAugLevelValue();
}
#endif

state Active
{
Begin:
    DoActivate();
}

simulated function DoActivate()
{
    Reset();
}

function Reset()
{
    //Don't actually reset if the aug is already inactive
    if (!bIsActive) return;

    // reset without burning 1 energy
    if(class'MenuChoice_FixGlitches'.default.enabled) {
        Player.JumpZ = Player.default.JumpZ * PreviewAugLevelValue();
    } else {
        Player.JumpZ *= PreviewAugLevelValue();
    }
}

function Deactivate()
{
    Super.Deactivate();

    Player.JumpZ = Player.Default.JumpZ;
}

function UpdateBalance()
{
    local int i;
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        LevelValues[0] = 1.2;
        LevelValues[1] = 1.35;
        LevelValues[2] = 1.5;
        LevelValues[3] = 1.7;
        Level5Value = 1.8;
    } else {
        LevelValues[0] = 1.2;
        LevelValues[1] = 1.4;
        LevelValues[2] = 1.6;
        LevelValues[3] = 1.8;
        Level5Value = -1;
    }
    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
    default.Level5Value = Level5Value;
}

defaultproperties
{
    LevelValues(0)=1.2
    LevelValues(1)=1.35
    LevelValues(2)=1.5
    LevelValues(3)=1.7
    Level5Value=1.8
    EnergyRate=30
#ifdef injections
    bAutomatic=true
    AutoLength=2
    AutoEnergyMult=2
#endif

    Icon=Texture'AugIconJumpOnly'
    smallIcon=Texture'AugIconJumpOnly_Small'
    AugmentationName="Jump Enhancement"
    Description="Ionic polymeric gel myofibrils are woven into the leg muscles, increasing the height they can jump, and reducing the damage they receive from falls.|n|nTECH ONE: Jumping is increased slightly, while falling damage is reduced.|n|nTECH TWO: Jumping is increased moderately, while falling damage is further reduced.|n|nTECH THREE: Jumping is increased significantly, while falling damage is substantially reduced.|n|nTECH FOUR: An agent can leap from the tallest building."
    MPInfo="When active, you jump higher.  Energy Drain: Very High"
    AugmentationLocation=LOC_Leg
    MPConflictSlot=5
}
