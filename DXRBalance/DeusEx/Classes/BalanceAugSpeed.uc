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
    useEnergy = 1;
    if(Player.Energy < useEnergy) {
        Deactivate();
    } else {
        if(Level.LevelAction == LEVACT_None) {
            Player.Energy -= useEnergy;
        }
        Player.GroundSpeed *= GetAugLevelValue();
        Player.JumpZ *= GetAugLevelValue();
        if ( Level.NetMode != NM_Standalone )
        {
            if ( Human(Player) != None )
                Human(Player).UpdateAnimRate( GetAugLevelValue() );
        }
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
    Level5Value=1.8
}
