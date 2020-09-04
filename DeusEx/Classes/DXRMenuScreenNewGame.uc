class DXRMenuScreenNewGame extends MenuScreenNewGame;

var DXRando dxr;

function SetDxr(DXRando d)
{
    dxr=d;
    CopySkills();
    PopulateSkillsList();
    UpdateSkillPoints();
    EnableButtons();
}

// ----------------------------------------------------------------------
// CopySkills()
//
// Makes a local copy of the skills so we can manipulate them without
// actually making changes to the ones attached to the player.
// ----------------------------------------------------------------------

function CopySkills()
{
    local DXRSkills dxrs;
    local Skill aSkill;
    local int skillIndex;
    
    if(dxr!=None) {
        dxrs = DXRSkills(dxr.FindModule(class'DXRSkills'));
        if( dxrs != None )
            dxrs.RandoSkills();
    }

    skillIndex = 0;

    aSkill = player.SkillSystem.FirstSkill;
    while(aSkill != None)
    {
        localSkills[skillIndex] = player.Spawn(aSkill.Class);
        localSkills[skillIndex].Cost[0] = aSkill.Cost[0];
        localSkills[skillIndex].Cost[1] = aSkill.Cost[1];
        localSkills[skillIndex].Cost[2] = aSkill.Cost[2];

        skillIndex++;
        aSkill = aSkill.next;
    }
}

function SaveSettings()
{
    Super.SaveSettings();
    dxr.flags.SaveFlags();
    dxr.Destroy();

    foreach player.AllActors(class'DXRando', dxr)
        dxr.Destroy();
}

defaultproperties
{
}
