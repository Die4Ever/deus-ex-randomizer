class DXRSkills extends DXRBase transient;

struct SkillCostMultiplier {
    var string type;//you can use "Skill" to make it apply to all skills
    var int percent;//percent to multiply, stacks
    var int minLevel;//the first skill level this adjustment will apply to
    var int maxLevel;//the highest skill level this adjustment will apply to
};

var SkillCostMultiplier SkillCostMultipliers[12];

var float min_skill_weaken, max_skill_str;
var float skill_cost_curve;

replication
{
    reliable if( Role==ROLE_Authority )
        SkillCostMultipliers, min_skill_weaken, max_skill_str, skill_cost_curve;
}

function CheckConfig()
{
    local int i;

        for(i=0; i < ArrayCount(SkillCostMultipliers); i++) {
            SkillCostMultipliers[i].type = "";
            SkillCostMultipliers[i].percent = 100;
            SkillCostMultipliers[i].minLevel = 1;
            SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        }
        min_skill_weaken = 0.3;
        max_skill_str = 1.0;
        skill_cost_curve = 2;

#ifdef balance
    i=0;
    if(!dxr.flags.IsZeroRandoPure()) {
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
        SkillCostMultipliers[i].percent = 90;
        SkillCostMultipliers[i].minLevel = 1;
        SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        i++;

        SkillCostMultipliers[i].type = "SkillComputer";
        SkillCostMultipliers[i].percent = 140;
        SkillCostMultipliers[i].minLevel = 1;
        SkillCostMultipliers[i].maxLevel = 1;
        i++;
    }
#endif

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

event _PreTravel()
{
    local PlayerDataItem data;
    local #var(PlayerPawn) p;

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
    local int mission_group, old_mission_group, mission_num, old_mission_num;

    if( dxr == None ) {
        warning("RandoSkills dxr is None");
        return;
    }

    l("randomizing skills with seed " $ dxr.seed $ ", min: "$dxr.flags.settings.minskill$", max: "$dxr.flags.settings.maxskill $", reroll_missions: "$ dxr.flags.settings.skills_reroll_missions $", independent_levels: "$ dxr.flags.settings.skills_independent_levels );

    //Check if the skills are going to be randomized to new values (we've crossed the reroll point)
    //Don't show the message at the start of the game though
    if( dxr.dxInfo != None && dxr.dxInfo.missionNumber > 0 ) {
        mission_num = dxr.dxInfo.missionNumber;
        old_mission_num = dxr.flagbase.GetInt('Rando_lastmission');
        if (old_mission_num>0){
            mission_group = Clamp(mission_num, 1, 1000) / dxr.flags.settings.skills_reroll_missions;
            old_mission_group = Clamp(old_mission_num, 1, 1000) / dxr.flags.settings.skills_reroll_missions;
            if (mission_group>old_mission_group){
                player().ClientMessage("Skill costs have been rerolled!");
            }
        }
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
    local int i, mission_group;
    local bool banned;
    if( dxr == None ) return;

    if( dxr.dxInfo != None && dxr.dxInfo.missionNumber > 0 ) {
        // TODO: new game screen should use the starting mission if it isn't 1, but it needs to work even when doing a new game while already in a game
        i = dxr.dxInfo.missionNumber;
    }
    mission_group = Clamp(i, 1, 1000) / dxr.flags.settings.skills_reroll_missions;
    SetGlobalSeed("RandoSkills " $ mission_group @ aSkill.class.name);

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

    if( #var(prefix)SkillWeaponHeavy(a) != None ) {
        add_desc = "Over 100% will allow you to move more quickly while carrying a heavy weapon, up to full speed at 160%.";
    }
#ifdef injections
    else if( #var(prefix)SkillDemolition(a) != None ) {
        add_desc = "Each level increases the number of grenades you can carry by 1. Animation speeds, defusing times, and fuse lengths are also affected by skill level. For attached greandes, this skill also improves the blast radius and damage slightly.";
    }
    else if( #var(prefix)SkillComputer(a) != None && !dxr.flags.IsZeroRandoPure() ) {
        add_desc = "Hacking uses 5 bioelectric energy per second.";
    }
    else if( #var(prefix)SkillEnviro(a)!=None ) {
        add_desc = "Each level increases the number of fire extinguishers you can carry by 1.";
    }
#endif

    skill_value_wet_dry = float(dxr.flags.settings.skill_value_rando) / 100.0;
    RandoLevelValues(a, min_skill_weaken, max_skill_str, skill_value_wet_dry, a.Description, add_desc);
}

static simulated function string DescriptionLevelExtended(Actor act, int i, out string word, out float val, float defaultval, out string shortDisplay)
{
    local Skill s;
    local float f;
    local string r;
    local string p;

    s = Skill(act);
    if( s == None ) {
        log("ERROR: DescriptionLevel failed for skill "$act);
        return "err";
    }

    // GMDXv10 uses sprintf
    p = "%";
    if( InStr(s.default.description, "%d") != -1 ) {
        p = "%%";
    }

    if( s.Class == class'#var(prefix)SkillDemolition' || InStr(String(s.Class.Name), "#var(prefix)SkillWeapon") == 0 ) {
        word = "Damage";
        f = -2.0 * val + 1.0;
        shortDisplay = string(int(f * 100.0));
        return shortDisplay $ p;
    }
    else if( s.Class == class'#var(prefix)SkillLockpicking' || s.Class == class'#var(prefix)SkillTech' ) {
        word = "Efficiency";
        shortDisplay = string(int(val * 100.0));
        return shortDisplay $ p;
    }
    else if( s.Class == class'#var(prefix)SkillEnviro' ) {
        if(#bool(vanilla) || #bool(revision)) {
            if(class'DXRFlags'.default.bZeroRandoPure)
                word = "Damage Reduction (HazMat/Armor)";
            else
                word = "Damage Reduction (Passive/HazMat/Armor)";
            val = FClamp(val, 0, 1.1);
        }
        else {
            word = "Damage Reduction (HazMat/Armor)";
        }

        f = val;

        switch(i) {
        case 0: r =       "                Untrained: "; break;
        case 1: r = "|n                    Trained:   "; break;
        case 2: r = "|n                    Advanced: "; break;
        case 3: r = "|n                    Master:    "; break;
        }

        if(#bool(vanilla) || #bool(revision)) {
            if(!class'DXRFlags'.default.bZeroRandoPure) {
                shortDisplay = string(int( (1 - (f * 1.1 + 0.3)) * 100.0 ));
                r = r $ shortDisplay $ p $ " / "; // passive is * 1.1 + 0.3
            }
            r = r $ int( (1 - f * 0.75) * 100.0 ) $ p $ " / ";// hazmat is * 0.75
            r = r $ int( (1 - f * 0.5) * 100.0 ) $ p;//  ballistic armor is * 0.5
        } else if(#bool(vmd)) {
            f = (f + 1) / 2;// VMD nerfed enviro skill
            shortDisplay = string(int( (1 - f * 0.75) * 100.0 ));
            r = r $ shortDisplay $ p $ " / ";// hazmat is * 0.75
            r = r $ int( (1 - f * 0.5) * 100.0 ) $ p;//  ballistic armor is * 0.5
        } else {
            shortDisplay = string(int( (1 - f * 0.75) * 100.0 ));
            r = r $ shortDisplay $ p $ " / ";// hazmat is * 0.75
            r = r $ int( (1 - f * 0.5) * 100.0 ) $ p;//  ballistic armor is * 0.5
        }

        return r;
    }
    else if( s.Class == class'#var(prefix)SkillMedicine') {
        word = "Healing";
        shortDisplay = string(int( val * 30.0 ));
        return shortDisplay $ " HP";
    }
    else if( s.Class == class'#var(prefix)SkillComputer') {
        word = "Hack Time";
        if( i == 0 )
        {
            shortDisplay = "--";
            return "--";
        }
        f = 15.0 / (val * 1.5);
        shortDisplay = FloatToString(f, 1);
        return shortDisplay $ " sec";
    }
    else if( s.Class == class'#var(prefix)SkillSwimming') {
        word = "Swimming Speed";
        shortDisplay = string(int(val * 100.0));
        return shortDisplay $ p;
    }
#ifdef gmdx
    else if( s.Class == class'SkillStealth' ) {
        // TODO: improve description
        word = "Values";
        shortDisplay = string(val);
        return shortDisplay;
    }
#endif
    else {
        return Super.DescriptionLevel(act, i, word, val, defaultval);
    }
}

simulated function RandoSkillLevel(Skill aSkill, int i, float parent_percent)
{
    local float percent;
    local int m;
    local float f, perk;
    local SkillCostMultiplier scm;

    if( i>0 && chance_single(dxr.flags.settings.banned_skill_levels) ) {
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
        if( scm.type != string(aSkill.class.name) ) continue;
        if( i+1 >= scm.minLevel && i < scm.maxLevel ) {
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
#ifdef injections
    local class<FrobDisplayWindow> FrobDisplayWindow;
    FrobDisplayWindow = class'FrobDisplayWindow';
#else
    local class<DXRFrobDisplayWindow> FrobDisplayWindow;
    FrobDisplayWindow = class'DXRFrobDisplayWindow';
#endif

    Super.ExtendedTests();

    TestWeightedLevelValues(0.008089, 0.052143);

    testint(10/0, 0, "divide by 0? 10/0 == 0");

    for(f=0.01; f<2; f+=0.02) {
        TestWeightedLevelValues(f, f+0.01);
    }

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

    testint(FrobDisplayWindow.static.GetNumHits(0.010000, 0.010000), 1, "GetNumHits for doors test 1");

    testint(FrobDisplayWindow.static.GetNumHits(0.510000, 0.028000), 19, "GetNumHits for doors test 2");
    testint(FrobDisplayWindow.static.GetNumHits(0.482000, 0.028000), 18, "GetNumHits for doors test 3");
    testint(FrobDisplayWindow.static.GetNumHits(0.454000, 0.028000), 17, "GetNumHits for doors test 4");
    testint(FrobDisplayWindow.static.GetNumHits(0.426000, 0.028000), 16, "GetNumHits for doors test 5");
    testint(FrobDisplayWindow.static.GetNumHits(0.398000, 0.028000), 15, "GetNumHits for doors test 6");
    testint(FrobDisplayWindow.static.GetNumHits(0.370000, 0.028000), 14, "GetNumHits for doors test 7");
    testint(FrobDisplayWindow.static.GetNumHits(0.342000, 0.028000), 13, "GetNumHits for doors test 8");
    testint(FrobDisplayWindow.static.GetNumHits(0.314000, 0.028000), 12, "GetNumHits for doors test 9");
    testint(FrobDisplayWindow.static.GetNumHits(0.286000, 0.028000), 11, "GetNumHits for doors test 10");
    testint(FrobDisplayWindow.static.GetNumHits(0.258000, 0.028000), 10, "GetNumHits for doors test 11");
    testint(FrobDisplayWindow.static.GetNumHits(0.230000, 0.028000), 9, "GetNumHits for doors test 12");
    testint(FrobDisplayWindow.static.GetNumHits(0.202000, 0.028000), 8, "GetNumHits for doors test 13");
    testint(FrobDisplayWindow.static.GetNumHits(0.174000, 0.028000), 7, "GetNumHits for doors test 14");
    testint(FrobDisplayWindow.static.GetNumHits(0.146000, 0.028000), 6, "GetNumHits for doors test 15");
    testint(FrobDisplayWindow.static.GetNumHits(0.118000, 0.028000), 5, "GetNumHits for doors test 16");
    testint(FrobDisplayWindow.static.GetNumHits(0.090000, 0.028000), 4, "GetNumHits for doors test 17");
    testint(FrobDisplayWindow.static.GetNumHits(0.062000, 0.028000), 3, "GetNumHits for doors test 18");
    testint(FrobDisplayWindow.static.GetNumHits(0.034000, 0.028000), 2, "GetNumHits for doors test 19");
    testint(FrobDisplayWindow.static.GetNumHits(0.006000, 0.028000), 1, "GetNumHits for doors test 20");
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
