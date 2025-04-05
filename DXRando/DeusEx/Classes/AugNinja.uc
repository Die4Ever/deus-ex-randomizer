class AugNinja extends Augmentation;
// both speed and stealth!
// needed to modify function GetCurrentGroundSpeed() in DeusExPlayer

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

    Player.RunSilentValue = 0;
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
}

defaultproperties
{
    EnergyRate=40.000000
    Icon=Texture'AugIconNinja'
    smallIcon=Texture'AugIconNinja_Small'
    AugmentationName="Ninja"
    Description="I AM NINJA!"
    MPInfo="I AM NINJA!"
    LevelValues(0)=1.4
    LevelValues(1)=1.5
    LevelValues(2)=1.6
    LevelValues(3)=1.7
    Level5Value=1.8
    activationCost=1
    AugmentationLocation=LOC_Leg
    MPConflictSlot=5
}
