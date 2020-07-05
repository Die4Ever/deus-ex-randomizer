class MenuScreenNewGameRando extends MenuScreenNewGame;

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
    local MissionNewGame ms;

    ms = player.Spawn(class'MissionNewGame');
    ms.Player = player;
    ms.flags = player.FlagBase;
    ms.LoadSeed();
    ms.RandoSkills();
    ms.Destroy();

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

defaultproperties
{
}
