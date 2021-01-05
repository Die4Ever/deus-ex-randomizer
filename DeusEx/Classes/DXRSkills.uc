class DXRSkills extends DXRBase transient;

struct SkillCostMultiplier {
    var string type;//you can use "Skill" to make it apply to all skills
    var int percent;//percent to multiply, stacks
    var int minLevel;//the first skill level this adjustment will apply to
    var int maxLevel;//the highest skill level this adjustment will apply to
};

var config SkillCostMultiplier SkillCostMultipliers[16];
var config int banned_skill_chances;
var config int banned_skill_level_chances;

var config float min_skill_str;
var config float max_skill_str;

function CheckConfig()
{
    local int i;
    if( config_version < 4 ) {
        for(i=0; i < ArrayCount(SkillCostMultipliers); i++) {
            SkillCostMultipliers[i].type = "";
            SkillCostMultipliers[i].percent = 100;
            SkillCostMultipliers[i].minLevel = 1;
            SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        }
    }
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,8) ) {
        min_skill_str = 0.5;
        max_skill_str = 1.5;
    }
    Super.CheckConfig();
}

function AnyEntry()
{
    Super.AnyEntry();
    RandoSkills(dxr.Player.SkillSystem.FirstSkill);
}

function RandoSkills(Skill aSkill)
{
    local int i;
    local int mission_group;

    l("randomizing skills with seed " $ dxr.seed $ ", min: "$dxr.flags.minskill$", max: "$dxr.flags.maxskill $", reroll_missions: "$ dxr.flags.skills_reroll_missions $", independent_levels: "$ dxr.flags.skills_independent_levels );
    if( dxr.flags.skills_reroll_missions == 0 )
        dxr.SetSeed(dxr.seed);
    else {
        if( dxr.dxInfo != None )
            mission_group = dxr.dxInfo.missionNumber;
        mission_group = Clamp(mission_group, 1, 1000) / dxr.flags.skills_reroll_missions;
        i = dxr.Crc(dxr.seed $"M"$ mission_group);
        dxr.SetSeed( i );
    }

    if( dxr.flags.minskill > dxr.flags.maxskill ) dxr.flags.maxskill = dxr.flags.minskill;

    while(aSkill != None)
    {
        RandoSkill(aSkill);
        aSkill = aSkill.next;
    }
}

function RandoSkill(Skill aSkill)
{
    local int percent, i;
    local bool banned;

    percent = rng(dxr.flags.maxskill - dxr.flags.minskill + 1) + dxr.flags.minskill;
    banned = chance_single(banned_skill_chances);
    l( aSkill.Class.Name $ " percent: "$percent$"%, banned: " $ banned );
    for(i=0; i<arrayCount(aSkill.Cost); i++)
    {
        if( banned ) {
            aSkill.Cost[i] = 99999;
        } else {
            RandoSkillLevel(aSkill, i, percent);
        }
    }

    RandoSkillLevelValues(aSkill);
}

function RandoSkillLevelValues(Skill a)
{
    local string s;
    s = RandoLevelValues(a.LevelValues, a.default.LevelValues, min_skill_str, max_skill_str);
    a.Description = a.Description $ "|n|n" $ s;
}

function RandoSkillLevel(Skill aSkill, int i, int parent_percent)
{
    local int percent, m;
    local float f;
    local SkillCostMultiplier scm;
    local class<Skill> c;

    if( chance_single(banned_skill_level_chances) ) {
        l( aSkill.Class.Name $ " lvl: "$(i+1)$" is banned");
        aSkill.Cost[i] = 99999;
        return;
    } 

    if( dxr.flags.skills_independent_levels > 0 ) {
        percent = rng(dxr.flags.maxskill - dxr.flags.minskill + 1) + dxr.flags.minskill;
        l( aSkill.Class.Name $ " lvl: "$(i+1)$", percent: "$percent$"%");
    } else {
        percent = parent_percent;
    }

    f = float(aSkill.default.Cost[i]) * float(percent) / 100.0;
    for(m=0; m < ArrayCount(SkillCostMultipliers); m++) {
        scm = SkillCostMultipliers[m];
        if( scm.type == "" ) continue;
        c = class<Skill>(GetClassFromString(scm.type, class'Skill'));
        if( aSkill.IsA(c.name) && i+1 >= scm.minLevel && i < scm.maxLevel ) {
            f *= float(scm.percent) / 100.0;
        }
    }

    f = Clamp(f, 0, 99999);
    aSkill.Cost[i] = int(f);
}

defaultproperties
{
    banned_skill_chances=5
    banned_skill_level_chances=5
}
