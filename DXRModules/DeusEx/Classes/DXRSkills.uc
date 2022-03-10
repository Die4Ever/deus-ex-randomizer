class DXRSkills extends DXRBase transient;

struct SkillCostMultiplier {
    var string type;//you can use "Skill" to make it apply to all skills
    var int percent;//percent to multiply, stacks
    var int minLevel;//the first skill level this adjustment will apply to
    var int maxLevel;//the highest skill level this adjustment will apply to
};

var config SkillCostMultiplier SkillCostMultipliers[16];

var config float min_skill_weaken, max_skill_str;
var config float skill_cost_curve;

replication
{
    reliable if( Role==ROLE_Authority )
        SkillCostMultipliers, min_skill_weaken, max_skill_str, skill_cost_curve;
}

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(1,6,0,5) ) {
        for(i=0; i < ArrayCount(SkillCostMultipliers); i++) {
            SkillCostMultipliers[i].type = "";
            SkillCostMultipliers[i].percent = 100;
            SkillCostMultipliers[i].minLevel = 1;
            SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        }
        min_skill_weaken = default.min_skill_weaken;
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

simulated function PlayerLogin(#var PlayerPawn  player)
{
    local PlayerDataItem data;
    Super.PlayerLogin(player);
#ifdef multiplayer
    data = class'PlayerDataItem'.static.GiveItem(player);
    data.SkillPointsAvail = player.SkillPointsAvail;
    data.SkillPointsTotal = player.SkillPointsTotal;
#endif
}

event PreTravel()
{
    local PlayerDataItem data;
    local #var PlayerPawn  p;
    Super.PreTravel();
#ifdef multiplayer
    foreach AllActors(class'#var PlayerPawn ', p) {
        l("PreTravel "$p);
        data = class'PlayerDataItem'.static.GiveItem(p);
        data.SkillPointsAvail = p.SkillPointsAvail;
        data.SkillPointsTotal = p.SkillPointsTotal;
    }
#endif
}

simulated function PlayerAnyEntry(#var PlayerPawn  player)
{
    local PlayerDataItem data;
    Super.PlayerAnyEntry(player);
    RandoSkills(player.SkillSystem.FirstSkill);
#ifdef multiplayer
    data = class'PlayerDataItem'.static.GiveItem(player);
    player.SkillPointsAvail = data.SkillPointsAvail;
    player.SkillPointsTotal = data.SkillPointsTotal;
#endif
}

simulated function RandoSkills(Skill aSkill)
{
    local int mission_group;
    if( dxr == None ) {
        warning("RandoSkills dxr is None");
        return;
    }

    l("randomizing skills with seed " $ dxr.seed $ ", min: "$dxr.flags.settings.minskill$", max: "$dxr.flags.settings.maxskill $", reroll_missions: "$ dxr.flags.settings.skills_reroll_missions $", independent_levels: "$ dxr.flags.settings.skills_independent_levels );
    if( dxr.flags.settings.skills_reroll_missions == 0 )
        SetGlobalSeed("RandoSkills");
    else {
        if( dxr.dxInfo != None )
            mission_group = dxr.dxInfo.missionNumber;
        mission_group = Clamp(mission_group, 1, 1000) / dxr.flags.settings.skills_reroll_missions;
        SetGlobalSeed("RandoSkills " $ mission_group);
    }

    if( dxr.flags.settings.minskill > dxr.flags.settings.maxskill ) dxr.flags.settings.maxskill = dxr.flags.settings.minskill;

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

    percent = rngexp(dxr.flags.settings.minskill, dxr.flags.settings.maxskill, skill_cost_curve);
    banned = chance_single(dxr.flags.settings.banned_skills);
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
    local float skill_value_rando;

    skill_value_rando = float(dxr.flags.settings.skill_value_rando) / 100.0;
    RandoLevelValues(a, min_skill_weaken, max_skill_str, skill_value_rando, a.Description);

#ifdef injections
    if( #var prefix SkillDemolition(a) != None ) {
        add_desc = "Each level increases the number of grenades you can carry by 1.";
    }
    else if( #var prefix SkillComputer(a) != None ) {
        add_desc = "Hacking uses 5 bioelectric energy per second.";
    }
#endif

    if( add_desc != "" && InStr(a.Description, add_desc) == -1 ) {
        a.Description = a.Description $ "|n|n" $ add_desc;
    }
}

simulated function string DescriptionLevel(Actor act, int i, out string word)
{
    local Skill s;
    local float f;
    local string r;

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
        word = "Damage Reduction (Passive/HazMat/Armor)";
        f = s.LevelValues[i];
        f = FClamp(f, 0, 1.1);
        if(i>0) r="|n    ";
        r = r $ int( (1 - (f * 1.25 + 0.25)) * 100.0 ) $ "% / "; // passive is * 1.25 + 0.25
        r = r $ int( (1 - f * 0.75) * 100.0 ) $ "% / ";// hazmat is * 0.75
        r = r $ int( (1 - f * 0.5) * 100.0 ) $ "%";//  ballistic armor is * 0.5
        return r;
    }
    else if( s.Class == class'#var prefix SkillMedicine') {
        word = "Healing";
        return int( s.LevelValues[i] * 30.0 ) $ " HP";
    }
    else if( s.Class == class'#var prefix SkillComputer') {
        word = "Hack Time";
        if( i == 0 ) return "--";
        f = 15.0 / (s.LevelValues[i] * 1.5);
        return FloatToString(f, 1) $ " sec";
    }
    else if( s.Class == class'#var prefix SkillSwimming') {
        word = "Swimming Speed";
        return int(s.LevelValues[i] * 100.0) $ "%";
    }
#ifdef gmdx
    else if( s.Class == class'SkillStealth' ) {
        // TODO: improve description
        word = "Values";
        return string(int(s.LevelValues[i]));
    }
#endif
    else {
        err("DescriptionLevel failed for skill "$act);
        return "err";
    }
}

simulated function RandoSkillLevel(Skill aSkill, int i, float parent_percent)
{
    local float percent;
    local int m;
    local float f, perk;
    local SkillCostMultiplier scm;
    local class<Skill> c;

    if( chance_single(dxr.flags.settings.banned_skill_levels) ) {
        l( aSkill.Class.Name $ " lvl: "$(i+1)$" is banned");
        aSkill.Cost[i] = 99999;
#ifdef gmdx
        aSkill.PerkCost[i] = 99999;
#endif
        return;
    }

    if( dxr.flags.settings.skills_independent_levels > 0 ) {
        percent = rngexp(dxr.flags.settings.minskill, dxr.flags.settings.maxskill, skill_cost_curve);
        l( aSkill.Class.Name $ " lvl: "$(i+1)$", percent: "$percent$"%");
    } else {
        percent = parent_percent;
    }

    f = float(aSkill.default.Cost[i]) * percent / 100.0;
#ifdef gmdx
    perk = rngexp(dxr.flags.settings.minskill, dxr.flags.settings.maxskill, skill_cost_curve);
    l( aSkill.Class.Name $ " lvl: "$(i+1)$", perk percent: "$perk$"%");
    perk = float(aSkill.default.PerkCost[i]) * perk / 100.0;
#endif
    for(m=0; m < ArrayCount(SkillCostMultipliers); m++) {
        scm = SkillCostMultipliers[m];
        if( scm.type == "" ) continue;
        c = class<Skill>(GetClassFromString(scm.type, class'Skill'));
        if( aSkill.IsA(c.name) && i+1 >= scm.minLevel && i < scm.maxLevel ) {
            f *= float(scm.percent) / 100.0;
            perk *= float(scm.percent) / 100.0;
        }
    }

    f = Clamp(f, 0, 99999);
    perk = Clamp(perk, 0, 99999);
    aSkill.Cost[i] = int(f);
#ifdef gmdx
    aSkill.PerkCost[i] = int(perk);
#endif
}

simulated function Skill GetRandomPlayerSkill(#var PlayerPawn  p)
{
    local Skill skills[64], t;
    local int numSkills, slot, numLevels;

    for( t = p.SkillSystem.FirstSkill; t != None; t = t.next ) {
        if( t.CurrentLevel <= 0 ) continue;
        numLevels += t.CurrentLevel;
        skills[numSkills++] = t;
    }

    if( numSkills == 0 ) return None;

    SetSeed( "GetRandomPlayerSkill " $ numLevels );

    slot = rng(numSkills);
    return skills[slot];
}

simulated function DowngradeRandomSkill(#var PlayerPawn  p)
{
    local Skill skill;

    skill = GetRandomPlayerSkill(p);
    if( skill == None ) {
        info("DowngradeRandomSkill("$p$") no skills found");
        return;
    }
    info("DowngradeRandomSkill("$p$") Downgrading skill "$skill);
    skill.CurrentLevel--;
}

simulated function RemoveRandomSkill(#var PlayerPawn  p)
{
    local Skill skill;

    skill = GetRandomPlayerSkill(p);
    if( skill == None ) {
        info("RemoveRandomSkill("$p$") no skills found");
        return;
    }
    info("RemoveRandomSkill("$p$") Removing skill "$skill);
    skill.CurrentLevel = 0;
}

defaultproperties
{
    min_skill_weaken=0.3
    max_skill_str=1.0
    skill_cost_curve=2
}
