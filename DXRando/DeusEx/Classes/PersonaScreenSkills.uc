#ifdef injections
class DXRPersonaScreenSkills injects PersonaScreenSkills;
#else
class DXRPersonaScreenSkills extends #var prefix PersonaScreenSkills;
#endif

function UpdateSkillBanned(PersonaSkillButtonWindow b)
{
    local Skill s;
    if( b == None || b.skill == None )
        return;
    s = b.skill;
    b.winPointsNeeded.SetPos(260, 0);
    b.winPointsNeeded.SetSize(38, 27);
    b.winPointsNeeded.SetTextAlignments(HALIGN_Left, VALIGN_Center);
    if( s.GetCost() >= 99999 ) {
        //b.winPointsNeeded.SetText(b.NotAvailableLabel);
        b.winPointsNeeded.SetText("BANNED");
    }
}

function CreateSkillsList()
{
    local int i;

    Super.CreateSkillsList();

    for(i=0; i<ArrayCount(skillButtons); i++) {
        UpdateSkillBanned(skillButtons[i]);
    }
}

function UpgradeSkill()
{
    Super.UpgradeSkill();
    UpdateSkillBanned(selectedSkillButton);
}
