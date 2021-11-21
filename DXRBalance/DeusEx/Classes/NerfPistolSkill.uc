//=============================================================================
// SkillWeaponPistol.
//=============================================================================
class DXRSkillWeaponPistol injects SkillWeaponPistol;

simulated function PreBeginPlay()
{
    local int oldlevel;
    oldlevel = CurrentLevel;

    Super.PreBeginPlay();

    if ( Level.NetMode == NM_Standalone )
        CurrentLevel = oldlevel;
}

defaultproperties
{
    LevelValues(1)=-0.100000
    LevelValues(2)=-0.230000
    LevelValues(3)=-0.400000
}
