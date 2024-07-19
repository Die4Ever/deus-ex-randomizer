class BalanceAugSpeed injects AugSpeed;

state Active
{
Begin:
    // DXRando: instantly use 1 energy to prevent abuse
    Player.Energy -= 1;
    if(Player.Energy <= 0) {
        Player.Energy = 0;
        Deactivate();
    } else {
        Player.GroundSpeed *= GetAugLevelValue();
        Player.JumpZ *= GetAugLevelValue();
        if ( Level.NetMode != NM_Standalone )
        {
            if ( Human(Player) != None )
                Human(Player).UpdateAnimRate( GetAugLevelValue() );
        }
    }
}

simulated function float GetAugLevelValue()
{
    if (bHasIt && bIsActive) {
        TickUse();
        if(CurrentLevel >= 4) return 1.8;// Level 5 is the same as vanilla level 4
        return LevelValues[CurrentLevel];
    }
    else
        return -1.0;
}

function BoostAug(bool bBoostEnabled)
{
    // DXRando: don't boost free augs because (0 * synth_heart_strength) == 0
    if (bBoostEnabled && energyRate > 0)
    {
        if (bIsActive && !bBoosted && CurrentLevel < MaxLevel+1)// we allow boosting speed to level 5
        {
            CurrentLevel++;
            bBoosted = True;
            Reset();
        }
    }
    else if (bBoosted)
    {
        CurrentLevel--;
        bBoosted = False;
        Reset();
    }
}

//original went from 1.2 up to 1.8, I've thought about nerfing the max speed so you can't just run past all enemies, but I think that would require an unreasonably large nerf
//original EnergyRate is 40, might nerf it if people use it too much?
defaultproperties
{
    EnergyRate=40
    LevelValues(0)=1.2
    LevelValues(1)=1.35
    LevelValues(2)=1.5
    LevelValues(3)=1.7
}
