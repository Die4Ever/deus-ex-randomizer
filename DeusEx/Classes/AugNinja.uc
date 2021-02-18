class AugNinja extends Augmentation;
//both speed and stealth!
//will need to modify function GetCurrentGroundSpeed() in DeusExPlayer and probably some other things, just ctrl+f for AugSpeed...

state Active
{
Begin:
    log(Self$" Active state! CurrentLevel: "$CurrentLevel$", LevelValue: "$LevelValues[CurrentLevel]);
    Player.GroundSpeed *= LevelValues[CurrentLevel];
    Player.JumpZ *= LevelValues[CurrentLevel];
    if ( Level.NetMode != NM_Standalone )
    {
        if ( Human(Player) != None )
            Human(Player).UpdateAnimRate( LevelValues[CurrentLevel] );
    }

    Player.RunSilentValue = 1.0 / (LevelValues[CurrentLevel] * LevelValues[CurrentLevel]);
    if ( Player.RunSilentValue == -1.0 )
        Player.RunSilentValue = 1.0;
}

function Deactivate()
{
    log(Self$" Deactivate!");
    Super.Deactivate();

    if (( Level.NetMode != NM_Standalone ) && Player.IsA('Human') )
        Player.GroundSpeed = Human(Player).Default.mpGroundSpeed;
    else
        Player.GroundSpeed = Player.Default.GroundSpeed;

    Player.JumpZ = Player.Default.JumpZ;
    if ( Level.NetMode != NM_Standalone )
    {
        if ( Human(Player) != None )
            Human(Player).UpdateAnimRate( -1.0 );
    }

    Player.RunSilentValue = 1.0;
    /*Player.RunSilentValue = 1.0 / (LevelValues[CurrentLevel] * LevelValues[CurrentLevel]);
    if ( Player.RunSilentValue == -1.0 )
        Player.RunSilentValue = 1.0;*/
}

defaultproperties
{
    EnergyRate=40.000000
    Icon=Texture'DeusExUI.UserInterface.AugIconSpeedJump'
    smallIcon=Texture'DeusExUI.UserInterface.AugIconSpeedJump_Small'
    AugmentationName="Ninja"
    Description="I AM NINJA!"
    MPInfo="I AM NINJA!"
    LevelValues(0)=1.5
    LevelValues(1)=1.6
    LevelValues(2)=1.7
    LevelValues(3)=1.8
    AugmentationLocation=LOC_Leg
    MPConflictSlot=5
}
