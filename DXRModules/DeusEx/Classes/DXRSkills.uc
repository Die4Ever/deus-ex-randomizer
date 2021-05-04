class DXRSkills extends DXRBase transient;

struct SkillCostMultiplier {
    var string type;//you can use "Skill" to make it apply to all skills
    var int percent;//percent to multiply, stacks
    var int minLevel;//the first skill level this adjustment will apply to
    var int maxLevel;//the highest skill level this adjustment will apply to
};

var config SkillCostMultiplier SkillCostMultipliers[16];

var config float min_skill_str;
var config float max_skill_str;
var config float skill_cost_curve;

replication
{
    reliable if( Role==ROLE_Authority )
        SkillCostMultipliers, min_skill_str, max_skill_str, skill_cost_curve;
}

function CheckConfig()
{
    local int i;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,5) ) {
        for(i=0; i < ArrayCount(SkillCostMultipliers); i++) {
            SkillCostMultipliers[i].type = "";
            SkillCostMultipliers[i].percent = 100;
            SkillCostMultipliers[i].minLevel = 1;
            SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        }
        min_skill_str = default.min_skill_str;
        max_skill_str = default.max_skill_str;
        skill_cost_curve = default.skill_cost_curve;
        
        i=0;
#ifdef balance
        SkillCostMultipliers[i].type = "SkillDemolition";
        SkillCostMultipliers[i].percent = 80;
        SkillCostMultipliers[i].minLevel = 1;
        SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        i++;

        SkillCostMultipliers[i].type = "SkillSwimming";
        SkillCostMultipliers[i].percent = 80;
        SkillCostMultipliers[i].minLevel = 1;
        SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        i++;

        SkillCostMultipliers[i].type = "SkillEnviro";
        SkillCostMultipliers[i].percent = 80;
        SkillCostMultipliers[i].minLevel = 1;
        SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        i++;
#endif
    }
    Super.CheckConfig();
}

simulated function Login(DeusExPlayer player)
{
    Super.Login(player);
    RandoSkills(player.SkillSystem.FirstSkill);
}

simulated function RandoSkills(Skill aSkill)
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

simulated function RandoSkill(Skill aSkill)
{
    local float percent;
    local int i;
    local bool banned;
    if( dxr == None ) return;

    percent = rngexp(dxr.flags.minskill, dxr.flags.maxskill, skill_cost_curve);
    banned = chance_single(dxr.flags.banned_skills);
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

simulated function RandoSkillLevelValues(Skill a)
{
    local string add_desc;
    RandoLevelValues(a, min_skill_str, max_skill_str, a.Description);

    if( #var prefix SkillDemolition(a) != None ) {
        add_desc = "Each level increases the number of grenades you can carry by 1.";
    }

    if( add_desc != "" && InStr(a.Description, add_desc) == -1 ) {
        a.Description = a.Description $ "|n|n" $ add_desc;
    }
}

simulated function string DescriptionLevel(Actor act, int i, out string word)
{
    local Skill s;
    local float f;
    
    s = Skill(act);
    if( s == None ) {
        err("DescriptionLevel failed for skill "$act);
        return "err";
    }

    if( s.Class == class'#var prefix SkillDemolition' || InStr(String(s.Class.Name), "#var prefix SkillWeapon") == 0 ) {
        word = "Damage";
        f = -2.0 * s.LevelValues[i] + 1.0;
        return int(f * 100.0) $ "%";
    }
    else if( s.Class == class'#var prefix SkillLockpicking' || s.Class == class'#var prefix SkillTech' ) {
        word = "Efficiency";
        return int(s.LevelValues[i] * 100.0) $ "%";
    }
    else if( s.Class == class'#var prefix SkillEnviro' ) {
        word = "Damage Reduction";
        return int( (1 - s.LevelValues[i] * 0.66) * 100.0 ) $ "%";//hazmat is * 0.75, ballistic armor is * 0.5...
    }
    else if( s.Class == class'#var prefix SkillMedicine') {
        word = "Healing";
        return int( s.LevelValues[i] * 30.0 ) $ " HP";
    }
    else if( s.Class == class'#var prefix SkillComputer') {
        word = "Hack Time";
        if( i == 0 ) return "--";
        f = 15.0 / (s.LevelValues[i] * 1.5);
        return int(f) $ " sec";
    }
    else if( s.Class == class'#var prefix SkillSwimming') {
        word = "Swimming Speed";
        return int(s.LevelValues[i] * 100.0) $ "%";
    }
    else {
        err("DescriptionLevel failed for skill "$act);
        return "err";
    }
}

simulated function RandoSkillLevel(Skill aSkill, int i, float parent_percent)
{
    local float percent;
    local int m;
    local float f;
    local SkillCostMultiplier scm;
    local class<Skill> c;

    if( chance_single(dxr.flags.banned_skill_levels) ) {
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
    min_skill_str=0.5
    max_skill_str=1.5
    skill_cost_curve=2
}
