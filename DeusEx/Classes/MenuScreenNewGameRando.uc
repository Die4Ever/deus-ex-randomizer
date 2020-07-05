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
    ms.seed = Rand(10000000);
    Player.FlagBase.SetInt('Rando_seed', ms.seed,, 999);
    ms.Player = player;
    ms.RandoSkills();
    ms.Destroy();
    ms = None;

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
