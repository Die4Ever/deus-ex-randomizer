class DXRFlags extends DXRFlagsNGPMaxRando transient;

const EntranceRando = 1;
const HordeMode = 2;
const RandoLite = 3;
const ZeroRando = 4;
const SeriousSam = 5;
const SpeedrunMode = 6;
const WaltonWare = 7;
const WaltonWareEntranceRando = 8;
const RandoMedium = 9;
const WaltonWareHardcore = 10;
const WaltonWarex3 = 11;

#ifdef hx
var string difficulty_names[4];// Easy, Medium, Hard, DeusEx
var FlagsSettings difficulty_settings[4];
var MoreFlagsSettings more_difficulty_settings[4];
#else
var string difficulty_names[5];// Super Easy QA, Easy, Normal, Hard, Extreme
var FlagsSettings difficulty_settings[5];
var MoreFlagsSettings more_difficulty_settings[5];
#endif

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
#ifdef injections
    local DXRAutosave autosave;
#endif

    Super.PlayerAnyEntry(p);
#ifdef injections
    p.bZeroRando = IsZeroRando();
    p.bReducedRando = IsReducedRando();
#endif

    if(!VersionIsStable() || #defined(debug))
        p.bCheatsEnabled = true;

    if(difficulty_names[difficulty] == "Super Easy QA" && dxr.dxInfo.missionNumber > 0 && dxr.dxInfo.missionNumber < 99) {
        p.bCheatsEnabled = true;
        p.ReducedDamageType = 'All';// god mode
        //p.AllWeapons();
        p.AllAmmo();

#ifdef injections
        autosave = DXRAutosave(dxr.FindModule(class'DXRAutosave'));
        if(autosave == None || !autosave.bNeedSave) {
            p.ServerSetSloMo(2);
        } else {
            autosave.old_game_speed = 2;
        }
#else
        p.ServerSetSloMo(2);
#endif
    }

    //Disable achievements for Revision Rando, as requested
    if(#defined(revision)){
        f.SetBool('AchievementsDisabled', true,, 999);
    }

    l("starting map is set to "$settings.starting_map);
}

function InitDefaults()
{
    InitVersion();
    if(!#defined(hx)) {
        seed = 0;
        NewPlaythroughId();
        if( dxr != None) {
            RollSeed();
        }
        crowdcontrol = 0;
    }
    bingo_duration=0;
    bingo_scale=100;
    newgameplus_loops = 0;
    bingoBoardRoll = 0;

    newgameplus_max_item_carryover = 5;
    newgameplus_num_skill_downgrades = 3;
    newgameplus_num_removed_augs = 1;
    newgameplus_num_removed_weapons = 1;


#ifdef hx
    difficulty = 1;
    maxrando = 1;
#else
    maxrando = 0;
#endif

#ifndef vanilla
    autosave = 0;
#endif
    SetDifficulty(difficulty);

    switch(dxr.localURL) {
    case "00_Training":
    case "00_TrainingCombat":
    case "00_TrainingFinal":
        SetDifficulty(1);
        TutorialDisableRandomization(dxr.localURL ~= "00_TrainingFinal");
        SaveFlags();
        break;
    }
}

function CheckConfig()
{
    local int i;
    // setup default difficulties
    i=0;
#ifndef hx
    difficulty_names[i] = "Super Easy QA";
    difficulty_settings[i].CombatDifficulty = 0;
    difficulty_settings[i].doorsmode = alldoors + doormutuallyinclusive;
    difficulty_settings[i].doorsdestructible = 100;
    difficulty_settings[i].doorspickable = 100;
    difficulty_settings[i].keysrando = 4;
    difficulty_settings[i].keys_containers = 0;
    difficulty_settings[i].infodevices_containers = 0;
    difficulty_settings[i].deviceshackable = 100;
    difficulty_settings[i].passwordsrandomized = 100;
    difficulty_settings[i].infodevices = 100;
    difficulty_settings[i].enemiesrandomized = 20;
    difficulty_settings[i].enemystats = 40;
    difficulty_settings[i].hiddenenemiesrandomized = 20;
    difficulty_settings[i].enemiesshuffled = 100;
    difficulty_settings[i].enemies_nonhumans = 40;
    difficulty_settings[i].bot_weapons = 50;
    difficulty_settings[i].bot_stats = 100;
    difficulty_settings[i].enemyrespawn = 0;
    difficulty_settings[i].skills_disable_downgrades = 0;
    difficulty_settings[i].skills_reroll_missions = 1;
    difficulty_settings[i].skills_independent_levels = 0;
    difficulty_settings[i].banned_skills = 10;
    difficulty_settings[i].banned_skill_levels = 5;
    difficulty_settings[i].minskill = 1;
    difficulty_settings[i].maxskill = 5;
    difficulty_settings[i].ammo = 90;
    difficulty_settings[i].medkits = 90;
    difficulty_settings[i].biocells = 90;
    difficulty_settings[i].lockpicks = 90;
    difficulty_settings[i].multitools = 90;
    difficulty_settings[i].speedlevel = 4;
    difficulty_settings[i].startinglocations = 100;
    difficulty_settings[i].goals = 100;
    difficulty_settings[i].equipment = 5;
    difficulty_settings[i].medbots = 100;
    more_difficulty_settings[i].empty_medbots = 100;
    difficulty_settings[i].repairbots = 100;
    difficulty_settings[i].medbotuses = 20;
    difficulty_settings[i].repairbotuses = 20;
    difficulty_settings[i].medbotcooldowns = 1;
    difficulty_settings[i].repairbotcooldowns = 1;
    difficulty_settings[i].medbotamount = 1;
    difficulty_settings[i].repairbotamount = 1;
    difficulty_settings[i].turrets_move = 100;
    difficulty_settings[i].turrets_add = 50;
    difficulty_settings[i].merchants = 100;
    difficulty_settings[i].dancingpercent = 25;
    difficulty_settings[i].swapitems = 100;
    difficulty_settings[i].swapcontainers = 100;
    difficulty_settings[i].augcans = 100;
    difficulty_settings[i].aug_value_rando = 100;
    difficulty_settings[i].skill_value_rando = 100;
    difficulty_settings[i].min_weapon_dmg = 50;
    difficulty_settings[i].max_weapon_dmg = 150;
    difficulty_settings[i].min_weapon_shottime = 50;
    difficulty_settings[i].max_weapon_shottime = 150;
    difficulty_settings[i].bingo_win = 0;
    difficulty_settings[i].bingo_freespaces = 1;
    difficulty_settings[i].spoilers = 1;
    difficulty_settings[i].health = 200;
    difficulty_settings[i].energy = 200;
    difficulty_settings[i].starting_map = 0;
    more_difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;
#endif

#ifdef hx
    difficulty_names[i] = "Easy";
#else
    difficulty_names[i] = "Normal";
    difficulty_settings[i].CombatDifficulty = 1.3;
#endif
    difficulty_settings[i].doorsmode = undefeatabledoors + doormutuallyinclusive;
    difficulty_settings[i].doorsdestructible = 100;
    difficulty_settings[i].doorspickable = 100;
    difficulty_settings[i].keysrando = 4;
    difficulty_settings[i].keys_containers = 0;
    difficulty_settings[i].infodevices_containers = 0;
    difficulty_settings[i].deviceshackable = 100;
    difficulty_settings[i].passwordsrandomized = 100;
    difficulty_settings[i].infodevices = 100;
    difficulty_settings[i].enemiesrandomized = 20;
    difficulty_settings[i].enemystats = 40;
    difficulty_settings[i].hiddenenemiesrandomized = 20;
    difficulty_settings[i].enemiesshuffled = 100;
    difficulty_settings[i].enemies_nonhumans = 40;
    difficulty_settings[i].bot_weapons = 10;
    difficulty_settings[i].bot_stats = 100;
    difficulty_settings[i].enemyrespawn = 0;
    difficulty_settings[i].skills_disable_downgrades = 0;
    difficulty_settings[i].skills_reroll_missions = 5;
    difficulty_settings[i].skills_independent_levels = 0;
    difficulty_settings[i].banned_skills = 5;
    difficulty_settings[i].banned_skill_levels = 3;
    difficulty_settings[i].minskill = 50;
    difficulty_settings[i].maxskill = 150;
    difficulty_settings[i].ammo = 90;
    difficulty_settings[i].medkits = 90;
    difficulty_settings[i].biocells = 90;
    difficulty_settings[i].lockpicks = 90;
    difficulty_settings[i].multitools = 90;
    difficulty_settings[i].speedlevel = 2;
    difficulty_settings[i].startinglocations = 100;
    difficulty_settings[i].goals = 100;
    difficulty_settings[i].equipment = 4;
    difficulty_settings[i].medbots = 35;
    more_difficulty_settings[i].empty_medbots = 20;
    difficulty_settings[i].repairbots = 35;
    difficulty_settings[i].medbotuses = 10;
    difficulty_settings[i].repairbotuses = 10;
    difficulty_settings[i].medbotcooldowns = 1;
    difficulty_settings[i].repairbotcooldowns = 1;
    difficulty_settings[i].medbotamount = 1;
    difficulty_settings[i].repairbotamount = 1;
    difficulty_settings[i].turrets_move = 50;
    difficulty_settings[i].turrets_add = 30;
    difficulty_settings[i].merchants = 25;
    difficulty_settings[i].dancingpercent = 25;
    difficulty_settings[i].swapitems = 100;
    difficulty_settings[i].swapcontainers = 100;
    difficulty_settings[i].augcans = 100;
    difficulty_settings[i].aug_value_rando = 100;
    difficulty_settings[i].skill_value_rando = 100;
    difficulty_settings[i].min_weapon_dmg = 50;
    difficulty_settings[i].max_weapon_dmg = 150;
    difficulty_settings[i].min_weapon_shottime = 50;
    difficulty_settings[i].max_weapon_shottime = 150;
    difficulty_settings[i].bingo_win = 0;
    difficulty_settings[i].bingo_freespaces = 1;
    difficulty_settings[i].spoilers = 1;
    difficulty_settings[i].health = 100;
    difficulty_settings[i].energy = 100;
    difficulty_settings[i].starting_map = 0;
    more_difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;

#ifdef hx
    difficulty_names[i] = "Medium";
#else
    difficulty_names[i] = "Hard";
    difficulty_settings[i].CombatDifficulty = 2;
#endif
    difficulty_settings[i].doorsmode = undefeatabledoors + doorindependent;
    difficulty_settings[i].doorsdestructible = 40;
    difficulty_settings[i].doorspickable = 40;
    difficulty_settings[i].keysrando = 4;
    difficulty_settings[i].keys_containers = 0;
    difficulty_settings[i].infodevices_containers = 0;
    difficulty_settings[i].deviceshackable = 75;
    difficulty_settings[i].passwordsrandomized = 100;
    difficulty_settings[i].infodevices = 100;
    difficulty_settings[i].enemiesrandomized = 30;
    difficulty_settings[i].enemystats = 60;
    difficulty_settings[i].hiddenenemiesrandomized = 30;
    difficulty_settings[i].enemiesshuffled = 100;
    difficulty_settings[i].enemies_nonhumans = 60;
    difficulty_settings[i].bot_weapons = 20;
    difficulty_settings[i].bot_stats = 100;
    difficulty_settings[i].enemyrespawn = 0;
    difficulty_settings[i].skills_disable_downgrades = 0;
    difficulty_settings[i].skills_reroll_missions = 5;
    difficulty_settings[i].skills_independent_levels = 0;
    difficulty_settings[i].banned_skills = 9;
    difficulty_settings[i].banned_skill_levels = 5;
    difficulty_settings[i].minskill = 50;
    difficulty_settings[i].maxskill = 225;
    difficulty_settings[i].ammo = 70;
    difficulty_settings[i].medkits = 70;
    difficulty_settings[i].biocells = 70;
    difficulty_settings[i].lockpicks = 70;
    difficulty_settings[i].multitools = 70;
    difficulty_settings[i].speedlevel = 1;
    difficulty_settings[i].startinglocations = 100;
    difficulty_settings[i].goals = 100;
    difficulty_settings[i].equipment = 2;
    difficulty_settings[i].medbots = 27;
    more_difficulty_settings[i].empty_medbots = 20;
    difficulty_settings[i].repairbots = 27;
    difficulty_settings[i].medbotuses = 5;
    difficulty_settings[i].repairbotuses = 5;
    difficulty_settings[i].medbotcooldowns = 1;
    difficulty_settings[i].repairbotcooldowns = 1;
    difficulty_settings[i].medbotamount = 1;
    difficulty_settings[i].repairbotamount = 1;
    difficulty_settings[i].turrets_move = 50;
    difficulty_settings[i].turrets_add = 70;
    difficulty_settings[i].merchants = 25;
    difficulty_settings[i].dancingpercent = 25;
    difficulty_settings[i].swapitems = 100;
    difficulty_settings[i].swapcontainers = 100;
    difficulty_settings[i].augcans = 100;
    difficulty_settings[i].aug_value_rando = 100;
    difficulty_settings[i].skill_value_rando = 100;
    difficulty_settings[i].min_weapon_dmg = 50;
    difficulty_settings[i].max_weapon_dmg = 150;
    difficulty_settings[i].min_weapon_shottime = 50;
    difficulty_settings[i].max_weapon_shottime = 150;
    difficulty_settings[i].bingo_win = 0;
    difficulty_settings[i].bingo_freespaces = 1;
    difficulty_settings[i].spoilers = 1;
    difficulty_settings[i].health = 100;
    difficulty_settings[i].energy = 100;
    difficulty_settings[i].starting_map = 0;
    more_difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;

#ifdef hx
    difficulty_names[i] = "Hard";
#else
    difficulty_names[i] = "Extreme";
    difficulty_settings[i].CombatDifficulty = 3;
#endif
    difficulty_settings[i].doorsmode = undefeatabledoors + doorindependent;
    difficulty_settings[i].doorsdestructible = 25;
    difficulty_settings[i].doorspickable = 25;
    difficulty_settings[i].keysrando = 4;
    difficulty_settings[i].keys_containers = 0;
    difficulty_settings[i].infodevices_containers = 0;
    difficulty_settings[i].deviceshackable = 50;
    difficulty_settings[i].passwordsrandomized = 100;
    difficulty_settings[i].infodevices = 100;
    difficulty_settings[i].enemiesrandomized = 40;
    difficulty_settings[i].enemystats = 80;
    difficulty_settings[i].hiddenenemiesrandomized = 40;
    difficulty_settings[i].enemiesshuffled = 100;
    difficulty_settings[i].enemies_nonhumans = 70;
    difficulty_settings[i].bot_weapons = 40;
    difficulty_settings[i].bot_stats = 100;
    difficulty_settings[i].enemyrespawn = 0;
    difficulty_settings[i].skills_disable_downgrades = 0;
    difficulty_settings[i].skills_reroll_missions = 5;
    difficulty_settings[i].skills_independent_levels = 100;
    difficulty_settings[i].banned_skills = 9;
    difficulty_settings[i].banned_skill_levels = 7;
    difficulty_settings[i].minskill = 50;
    difficulty_settings[i].maxskill = 250;
    difficulty_settings[i].ammo = 65;
    difficulty_settings[i].medkits = 60;
    difficulty_settings[i].biocells = 50;
    difficulty_settings[i].lockpicks = 60;
    difficulty_settings[i].multitools = 60;
    difficulty_settings[i].speedlevel = 1;
    difficulty_settings[i].startinglocations = 100;
    difficulty_settings[i].goals = 100;
    difficulty_settings[i].equipment = 1;
    difficulty_settings[i].medbots = 25;
    more_difficulty_settings[i].empty_medbots = 20;
    difficulty_settings[i].repairbots = 25;
    difficulty_settings[i].medbotuses = 2;
    difficulty_settings[i].repairbotuses = 2;
    difficulty_settings[i].medbotcooldowns = 1;
    difficulty_settings[i].repairbotcooldowns = 1;
    difficulty_settings[i].medbotamount = 1;
    difficulty_settings[i].repairbotamount = 1;
    difficulty_settings[i].turrets_move = 50;
    difficulty_settings[i].turrets_add = 150;
    difficulty_settings[i].merchants = 25;
    difficulty_settings[i].dancingpercent = 25;
    difficulty_settings[i].swapitems = 100;
    difficulty_settings[i].swapcontainers = 100;
    difficulty_settings[i].augcans = 100;
    difficulty_settings[i].aug_value_rando = 100;
    difficulty_settings[i].skill_value_rando = 100;
    difficulty_settings[i].min_weapon_dmg = 50;
    difficulty_settings[i].max_weapon_dmg = 150;
    difficulty_settings[i].min_weapon_shottime = 50;
    difficulty_settings[i].max_weapon_shottime = 150;
    difficulty_settings[i].bingo_win = 0;
    difficulty_settings[i].bingo_freespaces = 1;
    difficulty_settings[i].spoilers = 1;
    difficulty_settings[i].health = 100;
    difficulty_settings[i].energy = 100;
    difficulty_settings[i].starting_map = 0;
    more_difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;

#ifdef hx
    difficulty_names[i] = "DeusEx";
#else
    difficulty_names[i] = "Impossible";
    difficulty_settings[i].CombatDifficulty = 4;
#endif
    difficulty_settings[i].doorsmode = undefeatabledoors + doorindependent;
    difficulty_settings[i].doorsdestructible = 25;
    difficulty_settings[i].doorspickable = 25;
    difficulty_settings[i].keysrando = 4;
    difficulty_settings[i].keys_containers = 0;
    difficulty_settings[i].infodevices_containers = 0;
    difficulty_settings[i].deviceshackable = 50;
    difficulty_settings[i].passwordsrandomized = 100;
    difficulty_settings[i].infodevices = 100;
    difficulty_settings[i].enemiesrandomized = 50;
    difficulty_settings[i].enemystats = 90;
    difficulty_settings[i].hiddenenemiesrandomized = 50;
    difficulty_settings[i].enemiesshuffled = 100;
    difficulty_settings[i].enemies_nonhumans = 80;
    difficulty_settings[i].bot_weapons = 50;
    difficulty_settings[i].bot_stats = 100;
    difficulty_settings[i].enemyrespawn = 0;
    difficulty_settings[i].skills_disable_downgrades = 0;
    difficulty_settings[i].skills_reroll_missions = 5;
    difficulty_settings[i].skills_independent_levels = 100;
    difficulty_settings[i].banned_skills = 9;
    difficulty_settings[i].banned_skill_levels = 9;
    difficulty_settings[i].minskill = 50;
    difficulty_settings[i].maxskill = 300;
    difficulty_settings[i].ammo = 50;
    difficulty_settings[i].medkits = 50;
    difficulty_settings[i].biocells = 40;
    difficulty_settings[i].lockpicks = 50;
    difficulty_settings[i].multitools = 50;
    difficulty_settings[i].speedlevel = 1;
    difficulty_settings[i].startinglocations = 100;
    difficulty_settings[i].goals = 100;
    difficulty_settings[i].equipment = 1;
    difficulty_settings[i].medbots = 20;
    more_difficulty_settings[i].empty_medbots = 20;
    difficulty_settings[i].repairbots = 20;
    difficulty_settings[i].medbotuses = 1;
    difficulty_settings[i].repairbotuses = 1;
    difficulty_settings[i].medbotcooldowns = 1;
    difficulty_settings[i].repairbotcooldowns = 1;
    difficulty_settings[i].medbotamount = 1;
    difficulty_settings[i].repairbotamount = 1;
    difficulty_settings[i].turrets_move = 50;
    difficulty_settings[i].turrets_add = 300;
    difficulty_settings[i].merchants = 25;
    difficulty_settings[i].dancingpercent = 25;
    difficulty_settings[i].swapitems = 100;
    difficulty_settings[i].swapcontainers = 100;
    difficulty_settings[i].augcans = 100;
    difficulty_settings[i].aug_value_rando = 100;
    difficulty_settings[i].skill_value_rando = 100;
    difficulty_settings[i].min_weapon_dmg = 50;
    difficulty_settings[i].max_weapon_dmg = 150;
    difficulty_settings[i].min_weapon_shottime = 50;
    difficulty_settings[i].max_weapon_shottime = 150;
    difficulty_settings[i].bingo_win = 0;
    difficulty_settings[i].bingo_freespaces = 1;
    difficulty_settings[i].spoilers = 1;
    difficulty_settings[i].health = 90;
    difficulty_settings[i].energy = 80;
    difficulty_settings[i].starting_map = 0;
    more_difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;

    for(i=0; i<ArrayCount(difficulty_settings); i++) {
        difficulty_settings[i].menus_pause = 1;
        if(#defined(hx)) {
            difficulty_settings[i].startinglocations = 0;
            difficulty_settings[i].merchants = 0;
        }
    }

    Super.CheckConfig();
}

function FlagsSettings GetDifficulty(int diff)
{
    return difficulty_settings[diff];
}
function MoreFlagsSettings GetMoreDifficulty(int diff)
{
    return more_difficulty_settings[diff];
}

function FlagsSettings SetDifficulty(int new_difficulty)
{
    difficulty = new_difficulty;
    settings = difficulty_settings[difficulty];
    moresettings = more_difficulty_settings[difficulty];

    if(!class'MenuChoice_ToggleMemes'.static.IsEnabled(self)) settings.dancingpercent = 0;

    if(gamemode == RandoMedium) {
        settings.startinglocations = 0;
        settings.goals = 0;
        settings.dancingpercent = 0;
    }
    else if(IsReducedRando()) {
        settings.doorsmode = 0;
        settings.doorsdestructible = 0;
        settings.doorspickable = 0;
        settings.keysrando = 0;
        settings.keys_containers = 0;
        settings.infodevices_containers = 0;
        settings.deviceshackable = 0;
        settings.infodevices = 0;
        settings.enemiesrandomized = 0;
        settings.hiddenenemiesrandomized = 0;
        settings.enemiesshuffled = 0;
        settings.enemies_nonhumans = 0;
        settings.bot_weapons = 0;
        settings.enemyrespawn = 0;
        settings.skills_disable_downgrades = 0;
        settings.skills_reroll_missions = 0;
        settings.skills_independent_levels = 0;
        settings.banned_skills = 0;
        settings.banned_skill_levels = 0;
        settings.speedlevel = 0;
        settings.startinglocations = 0;
        settings.goals = 0;
        settings.equipment = 0;
        settings.medbots = -1;
        settings.repairbots = -1;
        moresettings.empty_medbots = 0;
        settings.turrets_move = 0;
        settings.turrets_add = 0;
        settings.dancingpercent = 0;
        settings.swapitems = 0;
        settings.swapcontainers = 0;
        settings.health = 100;
        settings.energy = 100;
        if(IsZeroRando()) {
            settings.passwordsrandomized = 0;
            settings.enemystats = 0;
            settings.bot_stats = 0;
            settings.minskill = 100;
            settings.maxskill = settings.minskill;
            settings.ammo = 100;
            settings.medkits = 100;
            settings.biocells = 100;
            settings.lockpicks = 100;
            settings.multitools = 100;
            settings.augcans = 0;
            settings.aug_value_rando = 0;
            settings.skill_value_rando = 0;
            settings.min_weapon_dmg = 100;
            settings.max_weapon_dmg = 100;
            settings.min_weapon_shottime = 100;
            settings.max_weapon_shottime = 100;
            settings.merchants = 0;
            settings.medbotcooldowns = 0;
            settings.repairbotcooldowns = 0;
            settings.medbotamount = 0;
            settings.repairbotamount = 0;
            settings.medbotuses = 0;
            settings.repairbotuses = 0;
            moresettings.grenadeswap = 0;
        } else {
            settings.enemystats /= 2;
            settings.minskill = (settings.minskill + 100) / 2;
            settings.maxskill = (settings.maxskill + 200) / 3;
            settings.ammo = (settings.ammo + 100) / 2;
            settings.medkits = (settings.medkits + 100) / 2;
            settings.biocells = (settings.biocells + 100) / 2;
            settings.lockpicks = (settings.lockpicks + 100) / 2;
            settings.multitools = (settings.multitools + 100) / 2;
            settings.augcans = 100;
            settings.aug_value_rando = 50;
            settings.skill_value_rando = 50;
            settings.min_weapon_dmg = 75;
            settings.max_weapon_dmg = 125;
            settings.min_weapon_shottime = 75;
            settings.max_weapon_shottime = 125;
        }
    }
    else if(gamemode == SeriousSam) {
#ifndef hx
        settings.CombatDifficulty *= 0.2;
#endif
        settings.enemiesrandomized = 1000;
        settings.hiddenenemiesrandomized = 1000;
        settings.maxskill = Min(settings.minskill * 1.5, settings.maxskill * 0.75);
        settings.maxskill = Max(settings.minskill * 1.2, settings.maxskill);// ensure greater than minskill
        settings.ammo = (settings.ammo + 100) / 2;
        settings.equipment *= 2;
        settings.medkits = (settings.medkits + 100) / 2;
        settings.medbots *= 2;
        settings.health = 200;
    }
    else if(IsSpeedrunMode()) {
        // same doors rules as Normal difficulty
        settings.doorsmode = undefeatabledoors + doormutuallyinclusive;
        settings.doorsdestructible = 100;
        settings.doorspickable = 100;

        settings.deviceshackable = 100;

        // no banned skills
        settings.banned_skills = 0;
        settings.banned_skill_levels = 0;

        // skill costs like Rando Lite mode
        settings.minskill = (settings.minskill + 100) / 2;
        settings.maxskill = (settings.maxskill + 200) / 3;
        // but ensure maxskill cost at least 20% greater than minskill cost
        settings.maxskill = Max(settings.minskill * 1.2, settings.maxskill);
        // skill strength rando 80% wet/dry
        settings.skill_value_rando = 80;
        // TODO: maybe +1 speed? or starting with 2?
        settings.speedlevel = Clamp(settings.speedlevel, 1, 4);
        // slightly more starting equipment
        settings.equipment += 1;
        // speedrunners, please install augs
        moresettings.empty_medbots *= 1.5;
        // realtime menus
        settings.menus_pause = 0;
        // splits overlay
        moresettings.splits_overlay = 1;
    }
    else if(IsWaltonWare()) {
        settings.bingo_win = 1;
        settings.bingo_freespaces = 5;
        settings.skills_reroll_missions = 0;// no rerolls since after the menu screen you would immediately get a reroll depending what mission you start in
        settings.banned_skills = 0;// need computer skill for hacking
        settings.prison_pocket = 100; //Keep your items in mission 5
        moresettings.empty_medbots *= 1.5; // WW gets lower medbots chances pretty quickly
        bingo_duration = 1;
        bingo_scale = 0;
        moresettings.newgameplus_curve_scalar = 50;

        if(gamemode == WaltonWareHardcore) {
#ifndef hx
            settings.CombatDifficulty *= 0.2;
#endif
            settings.medkits = 0;
            settings.medbots = 0;
            settings.health = 200;
            autosave = 5; // Ironman, autosaves and manual saves disabled
        }
        else if(gamemode == WaltonWarex3) {
            settings.bingo_win = 3;
            settings.bingo_freespaces = 1;
            bingo_duration = 3;
            bingo_scale = 33;
            moresettings.newgameplus_curve_scalar = 75;
        }

        l("applying WaltonWare, DXRando: " $ dxr @ dxr.seed);
        settings.starting_map = class'DXRStartMap'.static.ChooseRandomStartMap(self, 10);
    }
    else if(IsHordeMode()) {
#ifndef hx
        settings.CombatDifficulty *= 0.75;
#endif
        autosave = 5; // Ironman, autosaves and manual saves disabled
    }
    return settings;
}

function string DifficultyName(int diff)
{
    if (diff>=ArrayCount(difficulty_names)){
        return "INVALID DIFFICULTY "$diff;
    }
    return difficulty_names[diff];
}

static function int GameModeIdForSlot(int slot)
{// allow us to reorder in the menu, similar to DXRLoadouts::GetIdForSlot
    if(slot--==0) return 0;
    if(slot--==0) return EntranceRando;
    if(slot--==0) return WaltonWare;
    if(slot--==0) return WaltonWareEntranceRando;
    if(!VersionIsStable()) {
        if(slot--==0) return WaltonWareHardcore;
        if(slot--==0) return WaltonWarex3;
    }
    if(slot--==0) return SpeedrunMode;
    if(slot--==0) return ZeroRando;
    if(slot--==0) return RandoLite;
    if(slot--==0) return RandoMedium;
    if(slot--==0) return SeriousSam;
    if(slot--==0) return HordeMode;
    return 999999;
}

static function string GameModeName(int gamemode)
{
    switch(gamemode) {
    case 0:
        return "Normal Randomizer";
#ifdef injections
    case EntranceRando:
        return "Entrance Randomization";
    case HordeMode:
        return "Horde Mode";
#endif
    case RandoLite:
        return "Randomizer Lite";
    case ZeroRando:
        return "Zero Rando";
    case RandoMedium:
        return "Randomizer Medium";
    case SeriousSam:
        return "Serious Sam Mode";
    case SpeedrunMode:
        return "Speedrun Mode";
    case WaltonWare:
        return "WaltonWare";
#ifdef injections
    case WaltonWareEntranceRando:
        return "WaltonWare Entrance Rando";
#endif
    case WaltonWareHardcore:
        return "WaltonWare Hardcore";
    case WaltonWarex3:
        return "WaltonWare x3";
    }
    //EnumOption("Kill Bob Page (Alpha)", 3, f.gamemode);
    //EnumOption("How About Some Soy Food?", 6, f.gamemode);
    //EnumOption("Max Rando", 7, f.gamemode);
    return "";
}

function bool IsEntranceRando()
{
    return gamemode == EntranceRando || gamemode == WaltonWareEntranceRando;
}

function bool IsHordeMode()
{
    return gamemode == HordeMode;
}

function bool IsZeroRando()
{
    return gamemode == ZeroRando;
}

function bool IsReducedRando()
{
    return gamemode == RandoLite || gamemode == ZeroRando || gamemode == RandoMedium;
}

function bool IsSpeedrunMode()
{
    return gamemode == SpeedrunMode;
}

function bool IsWaltonWare()
{
    return gamemode == WaltonWare || gamemode == WaltonWareEntranceRando || gamemode == WaltonWareHardcore || gamemode == WaltonWarex3;
}

function bool IsWaltonWareHardcore()
{
    return gamemode == WaltonWareHardcore;
}

simulated function AddDXRCredits(CreditsWindow cw)
{
    cw.PrintHeader("DXRFlags");

    cw.PrintText(VersionString() $ ", flagshash: " $ ToHex(FlagsHash()));
    cw.PrintText(StringifyFlags(Credits));
    cw.PrintLn();
}

simulated function TutorialDisableRandomization(bool enableSomeRando)
{
    // a little bit of safe rando just to get a taste?
    if(enableSomeRando) {
        // training final
        settings.medbots = 100;
        settings.repairbots = 100;
        settings.augcans = 100;
        settings.merchants = 100;
    }
    else {
        settings.swapitems = 0;
        settings.swapcontainers = 0;
        settings.deviceshackable = 0;
        settings.doorsmode = 0;
        settings.doorsdestructible = 0;
        settings.doorspickable = 0;
        settings.medbots = -1;// -1 means vanilla, 0 means none at all
        settings.repairbots = -1;
        settings.augcans = 0;
    }

    settings.keysrando = 0;
    settings.speedlevel = 0;
    settings.startinglocations = 0;
    settings.goals = 0;
    settings.infodevices = 0;

    settings.dancingpercent = 50;

    /*settings.medbotuses = 20;
    settings.repairbotuses = 20;
    settings.medbotcooldowns = 1;
    settings.repairbotcooldowns = 1;
    settings.medbotamount = 1;
    settings.repairbotamount = 1;*/

    settings.enemiesrandomized = 0;
    settings.hiddenenemiesrandomized = settings.enemiesrandomized;
    settings.enemystats = 0;
    settings.enemiesshuffled = 0;
    settings.enemies_nonhumans = 0;
    settings.bot_weapons = 0;
    settings.bot_stats = 0;
    settings.enemyrespawn = 0;

    settings.turrets_move = 0;
    settings.turrets_add = 0;

    settings.skills_reroll_missions = 0;
    settings.skills_independent_levels = 0;
    /*settings.minskill = 80;
    settings.maxskill = 120;
    settings.skill_value_rando = 30;*/
    settings.banned_skills = 0;
    settings.banned_skill_levels = 0;

    settings.ammo = 100;
    settings.multitools = 1000;
    settings.lockpicks = 1000;
    settings.biocells = 1000;
    settings.medkits = 1000;
    settings.equipment = 0;

    /*settings.min_weapon_dmg = 100;
    settings.max_weapon_dmg = 100;
    settings.min_weapon_shottime = 100;
    settings.max_weapon_shottime = 100;

    settings.aug_value_rando = 0;*/

    moresettings.grenadeswap = 0;
}

//Nothing fancy happening here, but gives a consistent place to change how we want to clamp across
//all clamped score values (Or applying any other tweaks we might want?)
function int ClampFlagValue(int flagval, int min, int max)
{
    return FClamp(flagval,min,max*2);
}

function int ScoreFlags()
{
    local int score, bingos;
    local PlayerDataItem data;

    if(IsEntranceRando())
        score += 100;

    data = class'PlayerDataItem'.static.GiveItem(dxr.player);
    bingos = data.NumberOfBingos();

    // values for starting_map in DXRMenuSetupRando or DXRStartMap, basically mission number * 10, multiply more for score reduction
    if(settings.bingo_win > 0 && bingos >= settings.bingo_win) // if a bingo win, still reduce score because bingo goals are scaled down
        score -= settings.starting_map * 50;// basically starting mission * 500
    else // else we won by hitting the end of the game
        score -= settings.starting_map * 120;// basically starting mission * 1200

    score -= settings.doorsdestructible * 5;
    score -= settings.doorspickable * 5;
    if(settings.keysrando > 0)
        score += 500;
    //score += settings.keys_containers;
    //score += settings.infodevices_containers;
    score -= ClampFlagValue(settings.deviceshackable,0,100) * 2;
    score += ClampFlagValue(settings.passwordsrandomized,0,100) * 2;
    score += ClampFlagValue(settings.infodevices,0,100) * 2;
    score += ClampFlagValue(settings.enemiesrandomized,0,1000);
    score += ClampFlagValue(settings.enemystats,0,100);
    //score += settings.hiddenenemiesrandomized;
    score += ClampFlagValue(settings.enemiesshuffled,0,100);
    score += ClampFlagValue(settings.enemies_nonhumans,0,100);
    score += settings.bot_weapons;
    score += ClampFlagValue(settings.bot_stats,0,100);
    if(settings.enemyrespawn > 0 && settings.enemyrespawn < 1000)
        score += 1500 - settings.enemyrespawn;
    //settings.skills_disable_downgrades = 5;
    //settings.skills_reroll_missions = 5;
    //settings.skills_independent_levels = 100;
    score += ClampFlagValue(settings.banned_skills,0,100) * 30;
    score += ClampFlagValue(settings.banned_skill_levels,0,100) * 30;
    score += sqrt(settings.minskill) * 60; //Square root so the bonus tapers off as you get more extreme
    score += sqrt(settings.maxskill) * 40; //Square root so the bonus tapers off as you get more extreme
    score += ClampFlagValue(settings.skill_value_rando, 0, 100) * 2;
    score -= ClampFlagValue(settings.ammo,0,100);
    score -= ClampFlagValue(settings.medkits,0,100);
    score -= ClampFlagValue(settings.biocells,0,100);
    score -= ClampFlagValue(settings.lockpicks,0,100);
    score -= ClampFlagValue(settings.multitools,0,100);
    score -= settings.speedlevel;
    score += settings.startinglocations;
    score += settings.goals;
    score -= settings.equipment * 10;
    score -= ClampFlagValue(settings.medbots,0,100);
    score -= ClampFlagValue(moresettings.empty_medbots,0,100) / 2;
    score -= ClampFlagValue(settings.repairbots,0,100);
    if(settings.medbotuses <= 0)
        score -= 100;
    score -= settings.medbotuses;
    if(settings.repairbotuses <= 0)
        score -= 100;
    score -= settings.repairbotuses;
    //settings.medbotcooldowns = 1;
    //settings.repairbotcooldowns = 1;
    //settings.medbotamount = 1;
    //settings.repairbotamount = 1;
    //settings.turrets_move = 50;
    score += ClampFlagValue(settings.turrets_add,0,10000) / 10;
    //settings.merchants = 30;
    //settings.dancingpercent = 25;
    score += ClampFlagValue(settings.swapitems,0,100);
    score += ClampFlagValue(settings.swapcontainers,0,100);
    //settings.augcans = 100;
    //settings.aug_value_rando = 100;
    //settings.min_weapon_dmg = 50;
    //settings.max_weapon_dmg = 150;
    //settings.min_weapon_shottime = 50;
    //settings.max_weapon_shottime = 150;
    //settings.bingo_win = 0;
    //settings.bingo_freespaces = 1;
    //settings.spoilers = 1;
    score -= settings.health;
    score -= settings.energy;
    score -= moresettings.remove_paris_mj12;
    return score * 5;// lazy multiply by 5 at the end
}

function RunTests()
{
    Super.RunTests();
}

function ExtendedTests()
{
    Super.ExtendedTests();

    gamemode = 0;
    testint(moresettings.remove_paris_mj12, 0, "check remove_paris_mj12");
    moresettings.remove_paris_mj12 = 50;
    SetDifficulty(0);
    testint(settings.bingo_freespaces, 1, "SetDifficulty check bingo_freespaces");
    testint(Settings.spoilers, 1, "SetDifficulty check spoilers");
    testint(Settings.menus_pause, 1, "SetDifficulty check menus_pause");
    testint(settings.health, 200, "SetDifficulty check health");
    testint(settings.energy, 200, "SetDifficulty check energy");
    testint(moresettings.remove_paris_mj12, 0, "SetDifficulty check remove_paris_mj12");
    SetDifficulty(1);
    testint(settings.health, 100, "SetDifficulty check health");
    testint(settings.energy, 100, "SetDifficulty check energy");
}

defaultproperties
{
    difficulty=2
    autosave=2
    loadout=0
    crowdcontrol=0
    mirroredmaps=-1
}
