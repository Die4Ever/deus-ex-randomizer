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
var config float skill_cost_curve;

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
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,1) ) {
        skill_cost_curve = 2;
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
    if( dxr == None ) {
        warning("RandoSkills dxr is None");
        return;
    }

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
    local float percent;
    local int i;
    local bool banned;
    if( dxr == None ) return;

    percent = rngexp(dxr.flags.minskill, dxr.flags.maxskill, skill_cost_curve);
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
    RandoLevelValues(a, min_skill_str, max_skill_str, a.Description);
}

function string DescriptionLevel(Actor act, int i, out string word)
{
    local Skill s;
    local float f;
    
    s = Skill(act);
    if( s == None ) {
        err("DescriptionLevel failed for skill "$act);
        return "err";
    }

    if( s.Class == class'SkillDemolition' || InStr(String(s.Class.Name), "SkillWeapon") == 0 ) {
        word = "Damage";
        f = -2.0 * s.LevelValues[i] + 1.0;
        return int(f * 100.0) $ "%";
    }
    else if( s.Class == class'SkillLockpicking' || s.Class == class'SkillTech' ) {
        word = "Efficiency";
        return int(s.LevelValues[i] * 100.0) $ "%";
    }
    else if( s.Class == class'SkillEnviro' ) {
        word = "Damage Reduction";
        return int( 1.0 / s.LevelValues[i] * 0.66 * 100.0 ) $ "%";//hazmat is * 0.75, ballistic armor is * 0.5...
    }
    else if( s.Class == class'SkillMedicine') {
        word = "Healing";
        return int( s.LevelValues[i] * 30.0 ) $ " HP";
    }
    else if( s.Class == class'SkillComputer') {
        word = "Hack Time";
        if( i == 0 ) return "--";
        f = 15.0 / (s.LevelValues[i] * 1.5);
        return int(f) $ " sec";
    }
    else if( s.Class == class'SkillSwimming') {
        word = "Swimming Speed";
        return int(s.LevelValues[i] * 100.0) $ "%";
    }
    else {
        err("DescriptionLevel failed for skill "$act);
        return "err";
    }
}

function RandoSkillLevel(Skill aSkill, int i, float parent_percent)
{
    local float percent;
    local int m;
    local float f;
    local SkillCostMultiplier scm;
    local class<Skill> c;

    if( chance_single(banned_skill_level_chances) ) {
        l( aSkill.Class.Name $ " lvl: "$(i+1)$" is banned");
        aSkill.Cost[i] = 99999;
        return;
    } 

    if( dxr.flags.skills_independent_levels > 0 ) {
        percent = rngexp(dxr.flags.minskill, dxr.flags.maxskill, skill_cost_curve);
        l( aSkill.Class.Name $ " lvl: "$(i+1)$", percent: "$percent$"%");
    } else {
        percent = parent_percent;
    }

    f = float(aSkill.default.Cost[i]) * percent / 100.0;
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
