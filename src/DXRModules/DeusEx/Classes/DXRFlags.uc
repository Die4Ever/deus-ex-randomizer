class DXRFlags extends DXRFlagsNGPMaxRando transient;

const FullRando = 0;
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
const ZeroRandoPlus = 12;
const OneItemMode = 13;
const BingoCampaign = 14;
const NormalRandomizer = 15;
const StrongAugsMode = 16;
const SpeedrunTraining = 17;
const SeriousRando = 18; // same as Full Rando, but memes disabled by default
const GroundhogDay = 19;

const HordeZombies = 1020;
const WaltonWareHalloweenEntranceRando = 1029;
const HalloweenEntranceRando = 1030;
const HalloweenMode = 1031;
const WaltonWareHalloween = 1032;// why didn't they put leap day at the end of October?
const HalloweenMBM = 1033;

#ifdef hx
var string difficulty_names[4];// Easy, Medium, Hard, DeusEx
var FlagsSettings difficulty_settings[4];
var MoreFlagsSettings more_difficulty_settings[4];
#else
var string vanilla_difficulty_names[5];// Super Easy QA, Easy, Medium, Hard, Realistic
var string difficulty_names[5];// Super Easy QA, Normal, Hard, Extreme, Impossible
var FlagsSettings difficulty_settings[5];
var MoreFlagsSettings more_difficulty_settings[5];
#endif

// only access these in defaults, mostly for balance change checks
var bool bZeroRandoPure, bZeroRando, bReducedRando, bCrowdControl;

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
#ifdef injections
    local DXRAutosave autosave;
#endif

    Super.PlayerAnyEntry(p);

    if(!VersionIsStable() || #bool(debug))
        p.bCheatsEnabled = true;

    if(difficulty_names[difficulty] == "Super Easy QA" && dxr.dxInfo.missionNumber > 0 && dxr.dxInfo.missionNumber < 99) {
        p.bCheatsEnabled = true;
        p.ReducedDamageType = 'All';// god mode
        p.AllAmmo();
    }

    //Disable achievements for Revision Rando, as requested
    if(#defined(revision)){
        f.SetBool('AchievementsDisabled', true,, 999);
    }

    l("starting map is set to "$settings.starting_map);
}

simulated function SetGlobals()
{
    default.bZeroRandoPure = IsZeroRandoPure();
    default.bZeroRando = IsZeroRando(); // currently only used for weapon description text
    default.bReducedRando = IsReducedRando();
    default.bCrowdControl = (crowdcontrol!=0);
}

function InitAdvancedDefaults()
{
    bingo_duration=0;
    bingo_scale=100;
    newgameplus_loops = 0;
    bingoBoardRoll = 0;

    newgameplus_max_item_carryover = 5;
    newgameplus_num_skill_downgrades = 2;
    newgameplus_num_removed_augs = 1;
    newgameplus_num_removed_weapons = 1;

    clothes_looting=0;
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
    InitAdvancedDefaults();

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
}

//#region difficulty defaults
function CheckConfig()
{
    local int i;
    // setup default difficulties
    i=0;
#ifndef hx
    difficulty_names[i] = "Super Easy QA";
    vanilla_difficulty_names[i] = "Super Easy QA";
    difficulty_settings[i].CombatDifficulty = 0;
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
    more_difficulty_settings[i].reanimation = 0;
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
    difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = -1;// disable NG+ for faster testing, gamemode can override
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].enemies_weapons = 100;
    more_difficulty_settings[i].aug_loc_rando = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;
#endif

#ifdef hx
    difficulty_names[i] = "Easy";
#else
    difficulty_names[i] = "Normal";
    vanilla_difficulty_names[i] = "Easy";
    difficulty_settings[i].CombatDifficulty = 1.3;
#endif
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
    more_difficulty_settings[i].reanimation = 0;
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
    difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].enemies_weapons = 100;
    more_difficulty_settings[i].aug_loc_rando = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;

#ifdef hx
    difficulty_names[i] = "Medium";
#else
    difficulty_names[i] = "Hard";
    vanilla_difficulty_names[i] = "Medium";
    difficulty_settings[i].CombatDifficulty = 2;
#endif
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
    more_difficulty_settings[i].reanimation = 0;
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
    difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].enemies_weapons = 100;
    more_difficulty_settings[i].aug_loc_rando = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;

#ifdef hx
    difficulty_names[i] = "Hard";
#else
    difficulty_names[i] = "Extreme";
    vanilla_difficulty_names[i] = "Hard";
    difficulty_settings[i].CombatDifficulty = 3;
#endif
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
    more_difficulty_settings[i].reanimation = 0;
    difficulty_settings[i].skills_disable_downgrades = 0;
    difficulty_settings[i].skills_reroll_missions = 5;
    difficulty_settings[i].skills_independent_levels = 1;
    difficulty_settings[i].banned_skills = 9;
    difficulty_settings[i].banned_skill_levels = 7;
    difficulty_settings[i].minskill = 50;
    difficulty_settings[i].maxskill = 250;
    difficulty_settings[i].ammo = 65;
    difficulty_settings[i].medkits = 60;
    difficulty_settings[i].biocells = 60;
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
    difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].enemies_weapons = 100;
    more_difficulty_settings[i].aug_loc_rando = 0;
    more_difficulty_settings[i].splits_overlay = 0;
    i++;

#ifdef hx
    difficulty_names[i] = "DeusEx";
#else
    difficulty_names[i] = "Impossible";
    vanilla_difficulty_names[i] = "Realistic";
    difficulty_settings[i].CombatDifficulty = 4;
#endif
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
    more_difficulty_settings[i].reanimation = 0;
    difficulty_settings[i].skills_disable_downgrades = 0;
    difficulty_settings[i].skills_reroll_missions = 5;
    difficulty_settings[i].skills_independent_levels = 1;
    difficulty_settings[i].banned_skills = 9;
    difficulty_settings[i].banned_skill_levels = 9;
    difficulty_settings[i].minskill = 50;
    difficulty_settings[i].maxskill = 300;
    difficulty_settings[i].ammo = 50;
    difficulty_settings[i].medkits = 50;
    difficulty_settings[i].biocells = 50;
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
    difficulty_settings[i].grenadeswap = 100;
    more_difficulty_settings[i].newgameplus_curve_scalar = 100;
    more_difficulty_settings[i].camera_mode = 0;
    more_difficulty_settings[i].enemies_weapons = 100;
    more_difficulty_settings[i].aug_loc_rando = 0;
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
//#endregion

function FlagsSettings GetDifficulty(int diff)
{
    return difficulty_settings[diff];
}
function MoreFlagsSettings GetMoreDifficulty(int diff)
{
    return more_difficulty_settings[diff];
}

//#region SetDifficulty
function SetDifficulty(int new_difficulty)
{
    difficulty = new_difficulty;
    settings = difficulty_settings[difficulty];
    moresettings = more_difficulty_settings[difficulty];

    if(!class'MenuChoice_ToggleMemes'.static.IsEnabled(self)) settings.dancingpercent = 0;

    if(gamemode == SeriousRando) { // same as Full Rando, but memes disabled by default, and only serious goal locations
        settings.dancingpercent = 0;
        settings.merchants = 0;
        settings.goals = 200;
    }
    else if(gamemode == RandoMedium || gamemode == NormalRandomizer) { // Normal is the same as Medium, except it doesn't count as Reduced Rando when dealing with balance changes or memes
        settings.startinglocations = 0;
        settings.goals = 0;
        settings.enemiesrandomized *= 0.8;
        settings.ammo = (settings.ammo+100) / 2;
        moresettings.enemies_weapons *= 0.5;
        settings.bot_weapons = 0;
        settings.skills_disable_downgrades = 0;
        settings.skills_independent_levels = 0;
        settings.banned_skills = 0;
        //settings.banned_skill_levels = 0;
        settings.turrets_move = 0;
        settings.turrets_add = 0;
        settings.health = 100;
        if(gamemode == RandoMedium) {
            settings.dancingpercent = 0;
        }
    }
    else if(IsReducedRando()) {
        settings.doorsdestructible = 0;
        settings.doorspickable = 0;
        settings.keysrando = 0;
        settings.keys_containers = 0;
        settings.infodevices_containers = 0;
        settings.deviceshackable = 0;
        settings.infodevices = 0;
        settings.enemiesrandomized = 0;
        moresettings.enemies_weapons = 0;
        settings.hiddenenemiesrandomized = 0;
        settings.enemiesshuffled = 0;
        settings.enemies_nonhumans = 0;
        settings.bot_weapons = 0;
        settings.enemyrespawn = 0;
        moresettings.reanimation = 0;
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
            #ifndef hx
            switch(difficulty) {
            case 1:
                settings.CombatDifficulty = 1;
                break;
            case 2:
                settings.CombatDifficulty = 1.5;
                break;
            case 3:
                settings.CombatDifficulty = 2;
                break;
            case 4:
                settings.CombatDifficulty = 4;
                break;
            }
            #endif
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
            settings.grenadeswap = 0;
            // disable NG+ by default
            moresettings.newgameplus_curve_scalar = -1;
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
        if(gamemode==SpeedrunTraining) {
            settings.goals = 101;
        }
        // same doors rules as Normal difficulty
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
        // disable NG+ by default
        if(class'MenuChoice_NewGamePlus'.default.value != 2)
            moresettings.newgameplus_curve_scalar = -1;
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
        moresettings.newgameplus_curve_scalar = 40;

        if(gamemode == WaltonWareHardcore) {
#ifndef hx
            settings.CombatDifficulty *= 0.2;
#endif
            settings.medkits = 0;
            settings.medbots = 0;
            settings.health = 200;
            //autosave = 5; // Ironman, autosaves and manual saves disabled, set by the menu so it is no longer forced
        }
        else if(gamemode == WaltonWarex3) {
            settings.bingo_win = 3;
            settings.bingo_freespaces = 1;
            bingo_duration = 3;
            bingo_scale = 33;
            moresettings.newgameplus_curve_scalar = 65;
        }

        if(newgameplus_loops == 0) { // this gets overwritten by LoadFlags anyways, but the logging is noisy
            l("applying WaltonWare, DXRando: " $ dxr @ dxr.seed);
            settings.starting_map = class'DXRStartMap'.static.ChooseRandomStartMap(self, -1); // avoid Liberty Island first
        }
    }
    else if (IsBingoCampaignMode()) {
        settings.bingo_win = 1;
        settings.bingo_freespaces = 1;
        settings.banned_skills = 0;
        bingo_duration = 1;
        bingo_scale = 0;
    }
    else if(IsHordeMode()) {
#ifndef hx
        settings.CombatDifficulty *= 0.75;
#endif
        autosave = 5; // Ironman, autosaves and manual saves disabled
        settings.merchants = 100;
        // horde mode handles the greenbots itself
        settings.medbots = 0;
        settings.repairbots = 0;
        moresettings.empty_medbots = 0;
        settings.banned_skills = 0; //Don't ban skills entirely
        moresettings.aug_loc_rando = 100;
        settings.skills_reroll_missions = 0; //Don't reroll skills (so the new game skill costs match in-game)
    }
    else if(gamemode == HalloweenMode) {
        //moresettings.camera_mode = 1;// 3rd person? or maybe just stick to 1st person lol
        //autosave = 7;// fixed saves, HACK: we set this in DXRMenuSelectDifficulty so you can override it
    }

    if (IsHalloweenMode()){
        clothes_looting = 1;
        moresettings.reanimation = 20;
        moresettings.stalkers = 0x0004FFFF; // high bits for quantity (4 is 4x Bobbys or 1x any other type), low bits for flags
        switch(difficulty) {
            case 0: moresettings.reanimation = 25; break;
            case 1: moresettings.reanimation = 25; break;
            case 2: moresettings.reanimation = 20; break;// Hard
            case 3: moresettings.reanimation = 17; break;
            case 4: moresettings.reanimation = 15; break;
        }
    } else {
        clothes_looting = 0;
    }

    if(gamemode == EntranceRando || gamemode == WaltonWareEntranceRando || gamemode == HalloweenEntranceRando || gamemode == WaltonWareHalloweenEntranceRando) {
        moresettings.entrance_rando = 100;
    }

    if(class'MenuChoice_NewGamePlus'.default.value == 0 && !IsWaltonWare())
        moresettings.newgameplus_curve_scalar = -1;

    if(gamemode == GroundhogDay) {
        moresettings.newgameplus_curve_scalar = 0;
    }

    class'DXRLoadouts'.static.AdjustFlags(self, loadout); // new game menu doesn't initialize its own DXRLoadouts
}
//#endregion

function string DifficultyName(int diff)
{
    if (diff>=ArrayCount(difficulty_names)){
        return "INVALID DIFFICULTY "$diff;
    }
#ifndef hx
    if(IsZeroRando()) {
        return vanilla_difficulty_names[diff];
    }
#endif
    return difficulty_names[diff];
}

function string DifficultyDesc(int diff)
{
    if (diff>=ArrayCount(difficulty_names)){
        return "INVALID DIFFICULTY "$diff;
    }
    SetDifficulty(diff); // new game menu uses a temporary DXRFlags actor, and in-game flags menu can't access this help

#ifndef hx
    if(IsZeroRando()) {
        return "The player takes " $ int(settings.CombatDifficulty*100.0) $ "% damage.";
    }
#endif

    return "Settings for " $ DifficultyName(diff) $ " difficulty " $ GameModeName(gamemode) $ ":|n|n" $ DescribeDifficulty();
}

simulated function string DescribeDifficulty()
{
    local string str;
    local int mode;
    mode = Credits;

    #ifndef hx
        str = str $ "The player takes " $ int(settings.CombatDifficulty*100.0) $ "% damage.";
    #endif
    FlagInt('Rando_minskill', settings.minskill, mode, str);
    FlagInt('Rando_maxskill', settings.maxskill, mode, str);
    FlagInt('Rando_ammo', settings.ammo, mode, str);
    FlagInt('Rando_multitools', settings.multitools, mode, str);
    FlagInt('Rando_lockpicks', settings.lockpicks, mode, str);
    FlagInt('Rando_biocells', settings.biocells, mode, str);
    FlagInt('Rando_speedlevel', settings.speedlevel, mode, str);
    FlagInt('Rando_keys', settings.keysrando, mode, str);
    FlagInt('Rando_keys_containers', settings.keys_containers, mode, str);
    FlagInt('Rando_doorspickable', settings.doorspickable, mode, str);
    FlagInt('Rando_doorsdestructible', settings.doorsdestructible, mode, str);
    FlagInt('Rando_deviceshackable', settings.deviceshackable, mode, str);
    FlagInt('Rando_passwordsrandomized', settings.passwordsrandomized, mode, str);

    FlagInt('Rando_medkits', settings.medkits, mode, str);
    FlagInt('Rando_enemiesrandomized', settings.enemiesrandomized, mode, str);
    FlagInt('Rando_enemystats', settings.enemystats, mode, str);
    FlagInt('Rando_enemies_weapons', moresettings.enemies_weapons, mode, str);
    FlagInt('Rando_hiddenenemiesrandomized', settings.hiddenenemiesrandomized, mode, str);
    FlagInt('Rando_enemiesshuffled', settings.enemiesshuffled, mode, str);
    FlagInt('Rando_infodevices', settings.infodevices, mode, str);
    FlagInt('Rando_infodevices_containers', settings.infodevices_containers, mode, str);
    FlagInt('Rando_dancingpercent', settings.dancingpercent, mode, str);
    FlagInt('Rando_enemyrespawn', settings.enemyrespawn, mode, str);
    FlagInt('Rando_reanimation', moresettings.reanimation, mode, str);
    FlagInt('Rando_removeparismj12', remove_paris_mj12, mode, str);

    FlagInt('Rando_skills_disable_downgrades', settings.skills_disable_downgrades, mode, str);
    FlagInt('Rando_skills_reroll_missions', settings.skills_reroll_missions, mode, str);
    FlagInt('Rando_skills_independent_levels', settings.skills_independent_levels, mode, str);
    FlagInt('Rando_startinglocations', settings.startinglocations, mode, str);
    FlagInt('Rando_goals', settings.goals, mode, str);
    FlagInt('Rando_equipment', settings.equipment, mode, str);

    FlagInt('Rando_medbots', settings.medbots, mode, str);
    FlagInt('Rando_empty_medbots', moresettings.empty_medbots, mode, str);
    FlagInt('Rando_repairbots', settings.repairbots, mode, str);
    FlagInt('Rando_medbotuses', settings.medbotuses, mode, str);
    FlagInt('Rando_repairbotuses', settings.repairbotuses, mode, str);
    FlagInt('Rando_medbotcooldowns', settings.medbotcooldowns, mode, str);
    FlagInt('Rando_repairbotcooldowns', settings.repairbotcooldowns, mode, str);
    FlagInt('Rando_medbotamount', settings.medbotamount, mode, str);
    FlagInt('Rando_repairbotamount', settings.repairbotamount, mode, str);

    FlagInt('Rando_turrets_move', settings.turrets_move, mode, str);
    FlagInt('Rando_turrets_add', settings.turrets_add, mode, str);

    FlagInt('Rando_merchants', settings.merchants, mode, str);
    FlagInt('Rando_banned_skills', settings.banned_skills, mode, str);
    FlagInt('Rando_banned_skill_level', settings.banned_skill_levels, mode, str);
    FlagInt('Rando_enemies_nonhumans', settings.enemies_nonhumans, mode, str);
    FlagInt('Rando_bot_weapons', settings.bot_weapons, mode, str);
    FlagInt('Rando_bot_stats', settings.bot_stats, mode, str);

    FlagInt('Rando_swapitems', settings.swapitems, mode, str);
    FlagInt('Rando_swapcontainers', settings.swapcontainers, mode, str);
    FlagInt('Rando_augcans', settings.augcans, mode, str);
    FlagInt('Rando_aug_value_rando', settings.aug_value_rando, mode, str);
    FlagInt('Rando_skill_value_rando', settings.skill_value_rando, mode, str);
    FlagInt('Rando_min_weapon_dmg', settings.min_weapon_dmg, mode, str);
    FlagInt('Rando_max_weapon_dmg', settings.max_weapon_dmg, mode, str);
    FlagInt('Rando_min_weapon_shottime', settings.min_weapon_shottime, mode, str);
    FlagInt('Rando_max_weapon_shottime', settings.max_weapon_shottime, mode, str);

    FlagInt('Rando_prison_pocket', settings.prison_pocket, mode, str);

    FlagInt('Rando_bingo_win', settings.bingo_win, mode, str);
    FlagInt('Rando_bingo_freespaces', settings.bingo_freespaces, mode, str);

    FlagInt('Rando_menus_pause', settings.menus_pause, mode, str);
    FlagInt('Rando_health', settings.health, mode, str);
    FlagInt('Rando_energy', settings.energy, mode, str);

    FlagInt('Rando_grenadeswap', settings.grenadeswap, mode, str);

    FlagInt('Rando_newgameplus_max_item_carryover', newgameplus_max_item_carryover, mode, str);
    FlagInt('Rando_num_skill_downgrades', newgameplus_num_skill_downgrades, mode, str);
    FlagInt('Rando_num_removed_augs', newgameplus_num_removed_augs, mode, str);
    FlagInt('Rando_num_removed_weapons', newgameplus_num_removed_weapons, mode, str);

    return str;
}

function int GameModeIdForSlot(int slot)
{// allow us to reorder in the menu, similar to DXRLoadouts::GetIdForSlot
    if(slot--==0) return NormalRandomizer;
    if(slot--==0) return FullRando;
    if(slot--==0) return HalloweenMode;
    if(slot--==0) return EntranceRando;
    if(slot--==0) return SeriousRando;

    if(slot--==0) return WaltonWare;
    if(slot--==0) return WaltonWareHalloween;
    if(slot--==0) return WaltonWareHardcore;
    if(!VersionIsStable()) {
        if(slot--==0) return WaltonWarex3;
    }
    if(slot--==0) return BingoCampaign;
    if(slot--==0) return HalloweenMBM;

    if(slot--==0) return ZeroRando;
    if(slot--==0) return ZeroRandoPlus;
    if(slot--==0) return RandoLite;
    if(slot--==0) return RandoMedium;

    if(slot--==0) return SpeedrunMode;
    if(slot--==0) return SpeedrunTraining;
    if(slot--==0) return SeriousSam;
    if(slot--==0) return HordeMode;
    if(slot--==0) return HordeZombies;
    if(slot--==0) return OneItemMode;
    if(slot--==0) return StrongAugsMode;
    if(slot--==0) return GroundhogDay;
    return 999999;
}

function string GameModeName(int gamemode)
{
    switch(gamemode) {
    case FullRando:
        return "Full Randomizer";
    case NormalRandomizer:
        return "Normal Randomizer";
#ifdef injections
    case EntranceRando:
        return "Entrance Randomization";
    case HalloweenEntranceRando:
        return "Halloween Entrance Randomization";
    case HordeMode:
        return "Horde Mode";
    case HordeZombies:
        return "Zombies Horde Mode";// maybe a full-time replacement for original horde mode?
#endif
    case RandoLite:
        return "Randomizer Lite";
    case ZeroRando:
        return "Zero Rando";
    case ZeroRandoPlus:
        return "Zero Rando Plus";
    case RandoMedium:
        return "Randomizer Medium";
    case SeriousRando:
        return "Serious Rando";
    case SeriousSam:
        return "Serious Sam Mode";
    case SpeedrunMode:
        return "Speedrun Mode";
    case SpeedrunTraining:
        return "Speedrun Training Mode";
    case WaltonWareHalloween:
        return "WaltonWare Halloween";
    case WaltonWare:
        return "WaltonWare";
#ifdef injections
    case WaltonWareEntranceRando:
        return "WaltonWare Entrance Rando";
    case WaltonWareHalloweenEntranceRando:
        return "WaltonWare Halloween Entrance Rando";
#endif
    case WaltonWareHardcore:
        return "WaltonWare Hardcore";
    case WaltonWarex3:
        return "WaltonWare x3";
    case HalloweenMode:
        return "Halloween Mode";// maybe needs a better name
    case OneItemMode:
        return "One Item Mode";
    case BingoCampaign:
        if (#defined(vanilla)) {
            return "Mr. Page's Mean Bingo Machine";
        }
        return "";
    case HalloweenMBM:
        if (#defined(vanilla)) {
            return "Mr. Page's Horrifying Bingo Machine";
        }
        return "";
    case StrongAugsMode:
        return "Strong Augs Mode";
    case GroundhogDay:
        return "Groundhog Day";
    }
    //EnumOption("Kill Bob Page (Alpha)", 3, f.gamemode);
    //EnumOption("How About Some Soy Food?", 6, f.gamemode);
    //EnumOption("Max Rando", 7, f.gamemode);
    return "";
}

//#region GameModeHelpText
function string GameModeHelpText(int gamemode)
{
    local string s;
    switch(gamemode) {
    case FullRando:
        s =   "The FULL Randomizer experience.  Randomizes:|n";
        s = s$"|n";
        s = s$"  ~ Goal Locations|n";
        s = s$"  ~ Computer Passwords and Keypad Codes|n";
        s = s$"  ~ Skill Strength and Cost|n";
        s = s$"  ~ Augmentation Strength|n";
        s = s$"  ~ Augmentations in Canisters|n";
        s = s$"  ~ Item Locations and Quantities|n";
        s = s$"  ~ Datacube Locations|n";
        s = s$"  ~ Nanokey Locations|n";
        s = s$"  ~ Crate Locations|n";
        s = s$"  ~ Enemy Locations, Quantities, and Types|n";
        s = s$"  ~ Medical Bot and Repair Bot Locations|n";
        s = s$"  ~ Starting Location (on some maps)|n";
        s = s$"  ~ Auto Turret Locations|n";
        s = s$"  ~ Weapon Mod Types|n";
        s = s$"  ~ Planted Grenade Types|n";
        s = s$"  ~ And more!|n";
        s = s$"|n";
        s = s$"Item quantities are also reduced to encourage more variety of playstyles.";
        return s;
    case SeriousRando:
        s =   "The SERIOUS Randomizer experience.  Memes are disabled by default.  Randomizes:|n";
        s = s$"|n";
        s = s$"  ~ Goal Locations|n";
        s = s$"  ~ Computer Passwords and Keypad Codes|n";
        s = s$"  ~ Skill Strength and Cost|n";
        s = s$"  ~ Augmentation Strength|n";
        s = s$"  ~ Augmentations in Canisters|n";
        s = s$"  ~ Item Locations and Quantities|n";
        s = s$"  ~ Datacube Locations|n";
        s = s$"  ~ Nanokey Locations|n";
        s = s$"  ~ Crate Locations|n";
        s = s$"  ~ Enemy Locations, Quantities, and Types|n";
        s = s$"  ~ Medical Bot and Repair Bot Locations|n";
        s = s$"  ~ Starting Location (on some maps)|n";
        s = s$"  ~ Auto Turret Locations|n";
        s = s$"  ~ Weapon Mod Types|n";
        s = s$"  ~ Planted Grenade Types|n";
        s = s$"  ~ And more!|n";
        s = s$"|n";
        s = s$"Item quantities are also reduced to encourage more variety of playstyles.";
        return s;
    case NormalRandomizer:
        s =   "The totally normal Randomizer experience.  Randomizes:|n";
        s = s$"|n";
        s = s$"  ~ Computer Passwords and Keypad Codes|n";
        s = s$"  ~ Skill strength and cost|n";
        s = s$"  ~ Augmentation strength|n";
        s = s$"  ~ Augmentations in Canisters|n";
        s = s$"  ~ Item Locations and Quantities|n";
        s = s$"  ~ Datacube Locations|n";
        s = s$"  ~ Nanokey Locations|n";
        s = s$"  ~ Crate Locations|n";
        s = s$"  ~ Enemy Locations, Quantities, and Types|n";
        s = s$"  ~ Medical Bot and Repair Bot Locations|n";
        s = s$"  ~ And more!";
        return s;
    case EntranceRando:
        return "The FULL Randomizer experience, but level transitions are also randomized so they will take you to a different level than usual (within the same mission).";
    case HalloweenEntranceRando:
        return "The FULL Randomizer experience, plus the Halloween Mode features, and level transitions are also randomized so they will take you to a different level than usual (within the same mission).";
    case HordeMode:
        return "Try to survive against waves of enemies in the Cathedral, with items spawning between waves.";
    case HordeZombies:
        return "Try to survive against waves of enemies in the Cathedral, with items spawning between waves, plus the Halloween Mode features.";
    case ZeroRando:
        return "As close to vanilla as possible, with Randomizer quality of life improvements and extra functionality (like Bingo or Crowd Control).";
    case ZeroRandoPlus:
        return "No randomization and very close to vanilla, but with more of the balance changes introduced in the Randomizer, such as computer hacking costing energy.";
    case RandoLite:
        s = "The minimal randomizer. Mostly retains immersion and objects are where you would expect them to be. Randomizes:|n";
        s = s$"|n";
        s = s$"  ~ Computer Passwords and Keypad Codes|n";
        s = s$"  ~ Skill Strength and Cost|n";
        s = s$"  ~ Augmentation Strength|n";
        s = s$"  ~ Augmentations in Canisters|n";
        s = s$"  ~ Enemy Stats|n";
        s = s$"  ~ Medical Bot and Repair Bot Stats|n";
        s = s$"  ~ Weapon Stats|n";
        s = s$"  ~ Item Quantities|n";
        s = s$"  ~ Weapon Mod Types|n";
        s = s$"  ~ Planted Grenade Types|n";
        s = s$"  ~ Randomly Added Merchants";
        return s;
    case RandoMedium:
        s = "Similar to Randomizer Lite but with many more randomization features enabled by default. Remember you can tweak the settings in the Advanced menu to play with any randomization level you want.  Randomizes:|n";
        s = s$"|n";
        s = s$"  ~ Computer Passwords and Keypad Codes|n";
        s = s$"  ~ Skill Strength and Cost|n";
        s = s$"  ~ Augmentation Strength|n";
        s = s$"  ~ Augmentations in Canisters|n";
        s = s$"  ~ Item Locations and Quantities|n";
        s = s$"  ~ Datacube Locations|n";
        s = s$"  ~ Nanokey Locations|n";
        s = s$"  ~ Crate Locations|n";
        s = s$"  ~ Enemy Locations, Quantities, and Types|n";
        s = s$"  ~ Medical Bot and Repair Bot Locations and Stats|n";
        s = s$"  ~ Weapon Stats|n";
        s = s$"  ~ And more!";
        return s;
    case SeriousSam:
        return "The Randomizer experience, except enemy quantities have been cranked up, damage multipliers are decreased, and maximum health has been increased.";
    case SpeedrunMode:
        return "Full Randomizer, but with optimizations to ensure a more consistent speedrunning experience!  This also enables the built-in speedrun timer.";
    case SpeedrunTraining:
        return "Same as speedrun mode, but enables the Goal Location Hints option, highlighting the possible goal locations.";
    case WaltonWareHalloween:
        return "WaltonWare with the additional Halloween Mode features.";
    case WaltonWare:
        s =   "A bingo-focused fast game mode where you start on a random map and must complete a line on your bingo board to win!|n";
        s = s$"|n";
        s = s$"  ~ All bingo goals will be able to be completed within one mission|n";
        s = s$"  ~ Bingo Goal quantities are reduced to be more easily completed|n";
        s = s$"  ~ Five free spaces on the board, so all lines only require 4 goals to complete|n";
        s = s$"|n";
        s = s$"Once a line on your board has been completed, you will taken to another randomly selected map and the difficulty will increase!|n";
        s = s$"|n";
        s = s$"How long can you last?";
        return s;
    case WaltonWareEntranceRando:
        return "The same WaltonWare experience, but level transitions are also randomized so they will take you to a different level than usual (within the same mission).";
    case WaltonWareHalloweenEntranceRando:
        return "WaltonWare with the additional Halloween Mode features and level transitions are also randomized so they will take you to a different level than usual (within the same mission).";
    case WaltonWareHardcore:
        return "The WaltonWare experience, except ALL saving is disabled!  You do not get healed after each loop.  No medkits or medbots.  How long can you last?";
    case WaltonWarex3:
        return "The WaltonWare experience, except goals are now spread across three missions instead of one!|n|nHow long can you last?";
    case HalloweenMode:
        s =   "The FULL Randomizer experience, but with additional Halloween-themed features:|n";
        s = s$"|n";
        s = s$"  ~ Zombies will revive from corpses after about 20 seconds|n";
        s = s$"  ~ Mr. H will stalk you around the world|n";
        s = s$"  ~ Loot new clothes from bodies to grow your selection of costumes|n";
        s = s$"  ~ Light augmentation is dim and costs energy (like in vanilla)|n";
        s = s$"  ~ Jack O'Lanterns and Spiderwebs added for aesthetics";
        return s;
    case OneItemMode:
        return "The FULL Randomizer experience, except... For some reason, all items in each level are replaced by a single type of item?";
    case BingoCampaign:
        s =   "Play through the entire randomized game, but you must complete a line of bingo in each mission before being able to progress.|n";
        s = s$"|n";
        s = s$"  ~ All bingo goals will be able to be completed within one mission|n";
        s = s$"  ~ Bingo Goal quantities are reduced to be more easily completed|n";
        s = s$"  ~ Five free spaces on the board, so all lines only require 4 goals to complete|n";
        s = s$"|n";
        s = s$"Can YOU outsmart the Mean Bingo Machine?";
        return s;
    case HalloweenMBM:
        return "Mr. Page's Mean Bingo Machine combined with Halloween Mode.  You are required to complete a bingo line to progress past each mission.  Look out for zombies, Mr. H, and the limited saves!";
    case StrongAugsMode:
        return "The FULL Randomizer experience but augmentations are generally randomized to be stronger than normal.";
    case GroundhogDay:
        return "The FULL Randomizer experience, but New Game+ will not change your seed or your flags, giving you a chance to play the same game over and over again to keep improving.";
    }
    //EnumOption("Kill Bob Page (Alpha)", 3, f.gamemode);
    //EnumOption("How About Some Soy Food?", 6, f.gamemode);
    //EnumOption("Max Rando", 7, f.gamemode);
    return "";
}
//#endregion

//#region IsGameModes
function bool IsHordeMode()
{
    return gamemode == HordeMode || gamemode == HordeZombies;
}

function bool IsZeroRando()
{
    return gamemode == ZeroRando || gamemode == ZeroRandoPlus;
}

function bool IsZeroRandoPure()
{
    return gamemode == ZeroRando;
}

function bool IsReducedRando()
{
    return gamemode == RandoLite || gamemode == ZeroRando || gamemode == ZeroRandoPlus || gamemode == RandoMedium;
}

function bool IsSeriousRando()
{
    return gamemode == SeriousRando;
}

function bool IsSpeedrunMode()
{
    return gamemode == SpeedrunMode || gamemode == SpeedrunTraining;
}

function bool IsWaltonWare()
{
    return gamemode == WaltonWare || gamemode == WaltonWareEntranceRando || gamemode == WaltonWareHardcore || gamemode == WaltonWarex3 || gamemode == WaltonWareHalloween || gamemode == WaltonWareHalloweenEntranceRando;
}

function bool IsWaltonWareHardcore()
{
    return gamemode == WaltonWareHardcore;
}

function bool IsBingoCampaignMode()
{
    return gamemode == BingoCampaign || gamemode == HalloweenMBM;
}

function bool IsBingoMode()
{
    return IsWaltonWare() || IsBingoCampaignMode();
}

function bool IsHalloweenMode()
{
    return gamemode == HalloweenMode || gamemode == HordeZombies || gamemode == WaltonWareHalloween || gamemode == HalloweenEntranceRando || gamemode == WaltonWareHalloweenEntranceRando || gamemode == HalloweenMBM;
}

function bool IsOneItemMode()
{
    return gamemode == OneItemMode;
}

function bool IsStrongAugsMode()
{
    return gamemode == StrongAugsMode;
}
//#endregion

function int GetStartingMap()
{
    return settings.starting_map & 0xFF;
}

simulated function AddDXRCredits(CreditsWindow cw)
{
    if(dxr.rando_beaten > 0 && OnEndgameMap()) {
        if(IsReducedRando()) {
            cw.PrintText("Now that you've beaten "$ GameModeName(gamemode) $",");
            cw.PrintText("maybe you're ready for the Normal Randomizer game mode,");
            cw.PrintText("or one of our other crazy game modes!");
            cw.PrintLn();
        }
        else if(gamemode == NormalRandomizer) {
            cw.PrintText("Now that you've beaten "$ GameModeName(gamemode) $",");
            cw.PrintText("maybe you're ready for the Full Randomizer game mode,");
            cw.PrintText("or one of our other crazy game modes!");
            cw.PrintLn();
        }
    }

    cw.PrintHeader("DXRFlags");

    cw.PrintText(VersionString() $ ", flagshash: " $ ToHex(FlagsHash()));
    cw.PrintText(StringifyFlags(Credits));
    cw.PrintLn();
}

simulated function TutorialDisableRandomization(bool enableSomeRando)
{
    if(!IsReducedRando()) {
        gamemode = 0;// no weird game modes in the training
    }

    // a little bit of safe rando just to get a taste?
    if(enableSomeRando && !IsReducedRando()) {
        // training final
        settings.medbots = 100;
        settings.repairbots = 100;
        settings.augcans = 100;
    }
    else {
        settings.swapitems = 0;
        settings.swapcontainers = 0;
        settings.deviceshackable = 0;
        settings.doorsdestructible = 0;
        settings.doorspickable = 0;
        settings.medbots = -1;// -1 means vanilla, 0 means none at all
        settings.repairbots = -1;
        settings.augcans = 0;
    }

    settings.merchants = 0;  //We'll manually add merchants so they don't interfere
    settings.keysrando = 0;
    settings.speedlevel = 0;
    settings.startinglocations = 0;
    settings.goals = 0;
    settings.infodevices = 0;

    if(!IsReducedRando()) {
        settings.dancingpercent = 50;
    }

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
    moresettings.reanimation = 0;

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

    settings.grenadeswap = 0;
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

    if(moresettings.entrance_rando > 0)
        score += 100;

    data = class'PlayerDataItem'.static.GiveItem(dxr.player);
    bingos = data.NumberOfBingos();

    // values for starting_map in DXRMenuSetupRando or DXRStartMap, basically mission number * 10, multiply more for score reduction
    if(settings.bingo_win > 0 && bingos >= settings.bingo_win) // if a bingo win, still reduce score because bingo goals are scaled down
        score -= GetStartingMap() * 50;// basically starting mission * 500
    else // else we won by hitting the end of the game
        score -= GetStartingMap() * 120;// basically starting mission * 1200

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
    if(moresettings.reanimation > 0 && moresettings.reanimation < 100)
        score += 5 * (150 - moresettings.reanimation);
    //settings.skills_disable_downgrades = 5;
    //settings.skills_reroll_missions = 5;
    //settings.skills_independent_levels = 1;
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
    score -= remove_paris_mj12;
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
    testint(moresettings.splits_overlay, 0, "check splits_overlay");
    moresettings.splits_overlay = 50;// testing for struct size
    SetDifficulty(0);
    testint(settings.bingo_freespaces, 1, "SetDifficulty check bingo_freespaces");
    testint(Settings.spoilers, 1, "SetDifficulty check spoilers");
    testint(Settings.menus_pause, 1, "SetDifficulty check menus_pause");
    testint(settings.health, 200, "SetDifficulty check health");
    testint(settings.energy, 200, "SetDifficulty check energy");
    testint(moresettings.splits_overlay, 0, "SetDifficulty check splits_overlay");
    SetDifficulty(1);
    testint(settings.health, 100, "SetDifficulty check health");
    testint(settings.energy, 100, "SetDifficulty check energy");
}

defaultproperties
{
    gamemode=15// Normal Randomizer
    difficulty=1
    autosave=2
    loadout=0
    crowdcontrol=0
    mirroredmaps=-1
}
