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

simulated function PlayerLogin(#var(PlayerPawn) player)
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
    local #var(PlayerPawn) p;
    Super.PreTravel();
#ifdef multiplayer
    foreach AllActors(class'#var(PlayerPawn)', p) {
        l("PreTravel "$p);
        data = class'PlayerDataItem'.static.GiveItem(p);
        data.SkillPointsAvail = p.SkillPointsAvail;
        data.SkillPointsTotal = p.SkillPointsTotal;
    }
#endif
}

simulated function PlayerAnyEntry(#var(PlayerPawn) player)
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
    local float skill_value_wet_dry;

#ifdef injections
    if( #var(prefix)SkillDemolition(a) != None ) {
        add_desc = "Each level increases the number of grenades you can carry by 1.";
    }
    else if( #var(prefix)SkillComputer(a) != None ) {
        add_desc = "Hacking uses 5 bioelectric energy per second.";
    }
#endif

    skill_value_wet_dry = float(dxr.flags.settings.skill_value_rando) / 100.0;
    RandoLevelValues(a, min_skill_weaken, max_skill_str, skill_value_wet_dry, a.Description, add_desc);
}

simulated function string DescriptionLevel(Actor act, int i, out string word)
{
    local Skill s;
    local float f;
    local string r;
    local string p;

    s = Skill(act);
    if( s == None ) {
        err("DescriptionLevel failed for skill "$act);
        return "err";
    }

    // GMDXv10 uses sprintf
    p = "%";
    if( InStr(s.default.description, "%d") != -1 ) {
        p = "%%";
    }

    if( s.Class == class'#var(prefix)SkillDemolition' || InStr(String(s.Class.Name), "#var(prefix)SkillWeapon") == 0 ) {
        word = "Damage";
        f = -1.0 * s.LevelValues[i] + 1.0;
        return int(f * 100.0) $ p;
    }
    else if( s.Class == class'#var(prefix)SkillLockpicking' || s.Class == class'#var(prefix)SkillTech' ) {
        word = "Efficiency";
        return int(s.LevelValues[i] * 100.0) $ p;
    }
    else if( s.Class == class'#var(prefix)SkillEnviro' ) {
        f = s.LevelValues[i];
        if(i>0) r="|n    ";

#ifdef vanilla
        word = "Damage Reduction (Passive/HazMat/Armor)";
        f = FClamp(f, 0, 1.1);
#else
        word = "Damage Reduction (HazMat/Armor)";
#endif

#ifdef vanilla
        r = r $ int( (1 - (f * 1.25 + 0.25)) * 100.0 ) $ p $ " / "; // passive is * 1.25 + 0.25
        r = r $ int( (1 - f * 0.75) * 100.0 ) $ p $ " / ";// hazmat is * 0.75
        r = r $ int( (1 - f * 0.5) * 100.0 ) $ p;//  ballistic armor is * 0.5
#elseif vmd
        f = (f + 1) / 2;// VMD nerfed enviro skill
        r = r $ int( (1 - f * 0.75) * 100.0 ) $ p $ " / ";// hazmat is * 0.75
        r = r $ int( (1 - f * 0.5) * 100.0 ) $ p;//  ballistic armor is * 0.5
#else
        r = r $ int( (1 - f * 0.75) * 100.0 ) $ p $ " / ";// hazmat is * 0.75
        r = r $ int( (1 - f * 0.5) * 100.0 ) $ p;//  ballistic armor is * 0.5
#endif

        return r;
    }
    else if( s.Class == class'#var(prefix)SkillMedicine') {
        word = "Healing";
        return int( s.LevelValues[i] * 30.0 ) $ " HP";
    }
    else if( s.Class == class'#var(prefix)SkillComputer') {
        word = "Hack Time";
        if( i == 0 ) return "--";
        f = 15.0 / (s.LevelValues[i] * 1.5);
        return FloatToString(f, 1) $ " sec";
    }
    else if( s.Class == class'#var(prefix)SkillSwimming') {
        word = "Swimming Speed";
        return int(s.LevelValues[i] * 100.0) $ p;
    }
#ifdef gmdx
    else if( s.Class == class'SkillStealth' ) {
        // TODO: improve description
        word = "Values";
        return string(s.LevelValues[i]);
    }
#endif
    else {
        return Super.DescriptionLevel(act, i, word);
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
    l( aSkill.Class.Name $ " lvl: "$(i+1)$" cost: "$aSkill.Cost[i]);
#ifdef gmdx
    if( chance_single(dxr.flags.settings.banned_skill_levels) ) {
        perk = 99999;
        l( aSkill.Class.Name $ " perk "$(i+1)$" is banned");
    }
    aSkill.PerkCost[i] = int(perk);
#endif
}

simulated function Skill GetRandomPlayerSkill(#var(PlayerPawn) p)
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

simulated function DowngradeRandomSkill(#var(PlayerPawn) p)
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

simulated function RemoveRandomSkill(#var(PlayerPawn) p)
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

function ExtendedTests()
{
    local float f;
    local class<FrobDisplayWindow> FrobDisplayWindow;

    Super.ExtendedTests();

    TestWeightedLevelValues(0.008089, 0.052143);

    for(f=0.01; f<2; f+=0.02) {
        TestWeightedLevelValues(f, f+0.01);
    }


    FrobDisplayWindow = class'FrobDisplayWindow';
#ifndef injections
    FrobDisplayWindow = class'DXRFrobDisplayWindow';
#endif
    testint(FrobDisplayWindow.static.GetNumTools(0.190000, 0.188827), 2, "GetNumTools for lockpicks/multitools test 1");
    testint(FrobDisplayWindow.static.GetNumTools(0.070000, 0.010000), 7, "GetNumTools for lockpicks/multitools test 2");
    testint(FrobDisplayWindow.static.GetNumTools(0.060000, 0.010000), 6, "GetNumTools for lockpicks/multitools test 3");
    testint(FrobDisplayWindow.static.GetNumTools(0.050000, 0.010000), 5, "GetNumTools for lockpicks/multitools test 4");
    testint(FrobDisplayWindow.static.GetNumTools(0.040000, 0.010000), 4, "GetNumTools for lockpicks/multitools test 5");
    testint(FrobDisplayWindow.static.GetNumTools(0.030000, 0.010000), 3, "GetNumTools for lockpicks/multitools test 6");
    testint(FrobDisplayWindow.static.GetNumTools(0.020000, 0.010000), 2, "GetNumTools for lockpicks/multitools test 7");
    testint(FrobDisplayWindow.static.GetNumTools(0.010001, 0.010000), 1, "GetNumTools for lockpicks/multitools test 8");
    testint(FrobDisplayWindow.static.GetNumTools(0.0100001, 0.010000), 1, "GetNumTools for lockpicks/multitools test 9");
    testint(FrobDisplayWindow.static.GetNumTools(0.010001, 0.010001), 1, "GetNumTools for lockpicks/multitools test 10");
    testint(FrobDisplayWindow.static.GetNumTools(0.010000, 0.010000), 1, "GetNumTools for lockpicks/multitools test 11");
}

function bool TestWeightedLevelValues(float f1, float f2)
{
    local float r1, r2;
    test(f1 < f2, "TestWeightedLevelValues "$f1$" < "$f2);

    r1 = WeightedLevelValue(1, f1, 3.5, 1, 1, 0, 4);
    r2 = WeightedLevelValue(2, f2, 3.5, 1, 1, 1, 4);
    test(r1 < r2, "WeightedLevelValue "$f1@f2$", wet==1, "$r1$" < "$r2);

    r1 = WeightedLevelValue(1, f1, 3.5, 1, 0.5, 0, 4);
    r2 = WeightedLevelValue(2, f2, 3.5, 1, 0.5, 1, 4);
    test(r1 < r2, "WeightedLevelValue "$f1@f2$", wet==0.5, "$r1$" < "$r2);

    r1 = WeightedLevelValue(1, f1, 3.5, 1, 0.75, 0, 4);
    r2 = WeightedLevelValue(2, f2, 3.5, 1, 0.75, 1, 4);
    return test(r1 < r2, "WeightedLevelValue "$f1@f2$", wet=0.75, "$r1$" < "$r2);
}

defaultproperties
{
    min_skill_weaken=0.3
    max_skill_str=1.0
    skill_cost_curve=2
}
