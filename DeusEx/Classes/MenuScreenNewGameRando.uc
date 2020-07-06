class MenuScreenNewGameRando extends MenuScreenNewGame;

var MissionNewGame ms;

function SetMs(MissionNewGame m)
{
    ms=m;
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
	local Skill aSkill;
	local int skillIndex;
    
    if(ms!=None)
        ms.RandoSkills();

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
    ms.SaveFlags();
    ms.Destroy();
}

defaultproperties
{
}
