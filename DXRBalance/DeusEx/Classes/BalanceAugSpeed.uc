class BalanceAugSpeed injects AugSpeed;

state Active
{
Begin:
    DoActivate();
}

simulated function DoActivate()
{
    local float useEnergy;

    // DXRando: instantly use 1 energy to prevent abuse
    if(Level.LevelAction == LEVACT_None && class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        useEnergy = 1;
    }
    if(Player.Energy < useEnergy) {
        Deactivate();
    } else {
        Player.Energy -= useEnergy;
        Reset();
    }
}

function Reset()
{
    //Don't actually reset if the aug is already inactive
    if (!bIsActive) return;

    // reset without burning 1 energy
    if(class'MenuChoice_FixGlitches'.default.enabled) {
        Player.GroundSpeed = Player.default.GroundSpeed * GetAugLevelValue();
        Player.JumpZ = Player.default.JumpZ * GetAugLevelValue();
    } else {
        Player.GroundSpeed *= GetAugLevelValue();
        Player.JumpZ *= GetAugLevelValue();
    }
    if ( Level.NetMode != NM_Standalone )
    {
        if ( Human(Player) != None )
            Human(Player).UpdateAnimRate( GetAugLevelValue() );
    }
}

function BeginPlay()
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
    Super.BeginPlay();
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
}
