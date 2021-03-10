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
