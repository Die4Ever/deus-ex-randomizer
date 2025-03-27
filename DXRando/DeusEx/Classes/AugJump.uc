class AugJump extends Augmentation;

#ifndef injections
var float Level5Value; // does nothing outside of vanilla, just a placeholder
simulated function float GetAugLevelValue()
{
    return LevelValues[CurrentLevel];
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
        //Player.GroundSpeed = Player.default.GroundSpeed * GetAugLevelValue();
        Player.JumpZ = Player.default.JumpZ * GetAugLevelValue();
    } else {
        //Player.GroundSpeed *= GetAugLevelValue();
        Player.JumpZ *= GetAugLevelValue();
    }
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

//original went from 1.2 up to 1.8, I've thought about nerfing the max speed so you can't just run past all enemies, but I think that would require an unreasonably large nerf
//original EnergyRate is 40, might nerf it if people use it too much?
defaultproperties
{
    LevelValues(0)=1.2
    LevelValues(1)=1.35
    LevelValues(2)=1.5
    LevelValues(3)=1.7
    Level5Value=1.8
    EnergyRate=30

    Icon=Texture'DeusExUI.UserInterface.AugIconSpeedJump'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconSpeedJump_Small'
    AugmentationName="Jump Enhancement"
    Description="Ionic polymeric gel myofibrils are woven into the leg muscles, increasing the height they can jump, and reducing the damage they receive from falls.|n|nTECH ONE: Jumping is increased slightly, while falling damage is reduced.|n|nTECH TWO: Jumping is increased moderately, while falling damage is further reduced.|n|nTECH THREE: Jumping is increased significantly, while falling damage is substantially reduced.|n|nTECH FOUR: An agent can leap from the tallest building."
    MPInfo="When active, you jump higher.  Energy Drain: Very High"
    AugmentationLocation=LOC_Leg
    MPConflictSlot=5
}
