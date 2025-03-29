class AugOnlySpeed extends Augmentation;

#ifndef injections
var float Level5Value; // does nothing outside of vanilla, just a placeholder
var float activationCost;
simulated function float GetAugLevelValue()
{
    if(!bIsActive) return -1;
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
        Player.GroundSpeed = Player.default.GroundSpeed * GetAugLevelValue();
        //Player.JumpZ = Player.default.JumpZ * GetAugLevelValue();
    } else {
        Player.GroundSpeed *= GetAugLevelValue();
        //Player.JumpZ *= GetAugLevelValue();
    }
    if ( Level.NetMode != NM_Standalone )
    {
        if ( Human(Player) != None )
            Human(Player).UpdateAnimRate( GetAugLevelValue() );
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
        activationCost = 1;
    } else {
        LevelValues[0] = 1.2;
        LevelValues[1] = 1.4;
        LevelValues[2] = 1.6;
        LevelValues[3] = 1.8;
        Level5Value = -1;
        activationCost = 0;
    }
    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
    default.Level5Value = Level5Value;
    default.activationCost = activationCost;
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
    activationCost=1
    EnergyRate=30

    Icon=Texture'AugIconSpeedOnly'
    smallIcon=Texture'AugIconSpeedOnly_Small'
    AugmentationName="Speed Enhancement"
    Description="Ionic polymeric gel myofibrils are woven into the leg muscles, increasing the speed at which an agent can run.|n|nTECH ONE: Speed is increased slightly.|n|nTECH TWO: Speed is increased moderately.|n|nTECH THREE: Speed is increased significantly.|n|nTECH FOUR: An agent can run like the wind."
    MPInfo="When active, you run faster.  Energy Drain: Very High"
    AugmentationLocation=LOC_Leg
    MPConflictSlot=5
}
