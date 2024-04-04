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

// vanilla is -0.1, -0.25, -0.5 (100%, 120%, 150%, 200% like the other weapon skills), this is 100%, 120%, 145%, 180%
defaultproperties
{
    LevelValues(1)=-0.1
    LevelValues(2)=-0.225
    LevelValues(3)=-0.4
}
