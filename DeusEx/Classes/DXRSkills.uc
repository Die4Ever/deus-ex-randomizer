class DXRSkills extends DXRBase;

function FirstEntry()
{
    Super.FirstEntry();
    RandoSkills();
}

function RandoSkills()
{
    local Skill aSkill;
    local int i;
    local int percent;

    l("randomizing skills with seed " $ dxr.seed);
    dxr.SetSeed(dxr.seed);

    if( dxr.flags.minskill > dxr.flags.maxskill ) dxr.flags.maxskill = dxr.flags.minskill;

    aSkill = dxr.Player.SkillSystem.FirstSkill;
	while(aSkill != None)
	{
        percent = rng(dxr.flags.maxskill - dxr.flags.minskill) + dxr.flags.minskill;
        l("percent: "$percent$", min: "$dxr.flags.minskill$", max: "$dxr.flags.maxskill);
        for(i=0; i<arrayCount(aSkill.Cost); i++)
        {
    		aSkill.Cost[i] = aSkill.default.Cost[i] * percent / 100;
        }
		aSkill = aSkill.next;
	}
}
