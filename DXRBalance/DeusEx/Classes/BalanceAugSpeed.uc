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
        Player.GroundSpeed *= LevelValues[CurrentLevel];
        Player.JumpZ *= LevelValues[CurrentLevel];
        if ( Level.NetMode != NM_Standalone )
        {
            if ( Human(Player) != None )
                Human(Player).UpdateAnimRate( LevelValues[CurrentLevel] );
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
}
