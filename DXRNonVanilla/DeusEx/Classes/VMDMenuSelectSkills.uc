#ifndef vmd
class DXRVMDMenuSelectSkillsDummy extends Object;
#else
class DXRVMDMenuSelectSkills extends VMDMenuSelectSkills;

function String BuildSkillString( Skill aSkill )
{
    local String skillString;
    local String levelCost, AddStr;
    local VMDBufferPlayer VMP;

    if ( aSkill.GetCurrentLevel() == 3 )
        levelCost = "--";
    else if( aSkill.GetCost() > 98999 )// VMD adjusts skill costs so we need to be more lenient
        levelCost = "BANNED";
    else
        levelCost = String(aSkill.GetCost());

    VMP = VMDBufferPlayer(GetPlayerPawn());
    if ((VMP != None) && (VMP.IsSpecializedInSkill(aSkill.Class)))
    {
        AddStr = " (*)";
    }

    skillString = aSkill.skillName $ AddStr$ ";" $
                    aSkill.GetCurrentLevelString() $ ";" $
                    levelCost;

    return skillString;
}

#endif
