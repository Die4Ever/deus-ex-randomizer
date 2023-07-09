class DXRFlagsBase extends DXRBase transient abstract;

var transient FlagBase f;

const Reading = 1;
const Writing = 2;
const Stringifying = 3;
const Printing = 4;
const Credits = 5;
const Hashing = 6;

//rando flags
#ifdef hx
var #var(flagvarprefix) int next_seed;
#endif

var #var(flagvarprefix) int seed, playthrough_id;
var #var(flagvarprefix) int flagsversion;//if you load an old game with a newer version of the randomizer, we'll need to set defaults for new flags

var #var(flagvarprefix) int gamemode;//0=original, 1=rearranged, 2=horde, 3=rando lite //old... 3=kill bob page, 4=stick to the prod, 5=stick to the prod +, 6=how about some soy food, 7=max rando
var #var(flagvarprefix) int loadout;//0=none, 1=stick with the prod, 2=stick with the prod plus
var #var(flagvarprefix) int autosave;//0=off, 1=first time entering level, 2=every loading screen, 3=autosave-only
var #var(flagvarprefix) int maxrando;
var #var(flagvarprefix) int newgameplus_loops;
var #var(flagvarprefix) int crowdcontrol;
var #var(flagvarprefix) int mirroredmaps;
var #var(flagvarprefix) int bingo_duration;
var #var(flagvarprefix) int bingo_scale;

var #var(flagvarprefix) int difficulty;// save which difficulty setting the game was started with, for nicer upgrading
var #var(flagvarprefix) int bSetSeed;// int because all our flags are ints?


// When adding a new flag, make sure to update BindFlags, flagNameToHumanName, flagValToHumanVal,
// CheckConfig in subclass, maybe ExecMaxRando if it should be included in that, ScoreFlags, and SetDifficulty for different game modes
struct FlagsSettings {
#ifndef hx
    var float CombatDifficulty;
#endif
    var int minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
    var int keysrando;//0=off, 1=dumb, 2=on (old smart), 3=copies, 4=smart (v1.3), 5=path finding?
    var int keys_containers, infodevices_containers;
    var int doorsmode, doorspickable, doorsdestructible, deviceshackable, passwordsrandomized;//could be bools, but int is more flexible, especially so I don't have to change the flag type
    var int enemiesrandomized, hiddenenemiesrandomized, enemystats, enemiesshuffled, enemyrespawn, infodevices, bot_weapons, bot_stats;
    var int dancingpercent;
    var int skills_disable_downgrades, skills_reroll_missions, skills_independent_levels;
    var int startinglocations, goals, equipment;//equipment is a multiplier on how many items you get?
    var int medbots, repairbots;//there are 90 levels in the game, so 10% means approximately 9 medbots and 9 repairbots for the whole game, I think the vanilla game has 12 medbots, but they're also placed in smart locations so we might want to give more than that for Normal difficulty
    var int medbotuses, repairbotuses; //Limit the maximum number of uses for medbots and repairbots
    var int medbotcooldowns,repairbotcooldowns;
    var int medbotamount,repairbotamount;
    var int turrets_move, turrets_add;
    var int merchants;
    var int banned_skills, banned_skill_levels, enemies_nonhumans;
    var int swapitems, swapcontainers, augcans, aug_value_rando, skill_value_rando;
    var int min_weapon_dmg, max_weapon_dmg, min_weapon_shottime, max_weapon_shottime;
    var int prison_pocket;// just for Heinki, keep your items when getting captured
    var int bingo_win; //Number of bingo lines to beat the game
    var int bingo_freespaces; //Number of bingo free spaces
    var int spoilers; //0=Disallowed, 1=Available
    var int menus_pause; // 0=no pause, 1=vanilla
    var int starting_map;

    // leave these at the end for the automated tests
    var int health, energy;// normally just 100
};

var config bool speedrun_mode;

var #var(flagvarprefix) FlagsSettings settings;

const undefeatabledoors = 256;//1*256;
const alldoors = 512;//2*256;
const keyonlydoors = 768;//3*256;
const highlightabledoors = 1024;//4*256;
const doormutuallyinclusive = 1;
const doorindependent = 2;
const doormutuallyexclusive = 3;

var bool flags_loaded;
var int stored_version;

replication
{
    reliable if( Role==ROLE_Authority )
        f, seed, playthrough_id, flagsversion, gamemode, loadout, maxrando, newgameplus_loops,
        settings, bingo_duration, bingo_scale,
        flags_loaded;
}

// override these in subclass
function InitDefaults();
function FlagsSettings SetDifficulty(int new_difficulty);
simulated function ExecMaxRando();
function string DifficultyName(int diff);
static function string GameModeName(int gamemode);

simulated function PreTravel()
{
    Super.PreTravel();
    l("PreTravel "$dxr.localURL);
#ifndef noflags
    if( dxr != None && f != None && f.GetInt('Rando_version') == 0 ) {
        info("PreTravel "$dxr.localURL$" SaveFlags");
        SaveFlags();
    }
#endif
    // the game silently crashes if you don't wipe out all references to FlagBase during PreTravel?
    // and we want to do it here instead of in DXRando.uc to ensure it happens after SaveFlags()
    f = None;
    dxr.flagbase = None;
    dxr.Disable('Tick');
    dxr.bTickEnabled = false;
    dxr.SetTimer(0, false);
}

function Init(DXRando tdxr)
{
    Super.Init(tdxr);
    tdxr.seed = seed;
#ifdef flags
    InitVersion();
#endif
}

simulated function Timer()
{
    Super.Timer();
#ifdef flags
    if( f != None && f.GetInt('Rando_version') == 0 ) {
        info("flags got deleted, saving again");//the intro deletes all flags
        SaveFlags();
    }
#endif
}

simulated function bool CheckLogin(#var(PlayerPawn) p)
{
    return flags_loaded && Super.CheckLogin(p);
}

function PreFirstEntry()
{
    Super.PreFirstEntry();
    Timer();
    LogFlags("PreFirstEntry "$dxr.localURL);
#ifdef revision
    if( player().bIsFemalePlayer && !f.GetBool('LDDPJCIsFemale') ) {
        f.SetBool('LDDPJCIsFemale', true,, 999);
    }
#endif
}

function AnyEntry()
{
    Super.AnyEntry();
    Timer();
    LogFlags("AnyEntry "$dxr.localURL);
    /*l("AnyEntry() game: "$Level.Game);
    if( Level.Game.Class == class'DeusExGameInfo' ) {
        ConsoleCommand("start "$dxr.localURL$"?game=DeusEx.RandoGameInfo");
    }
    l("AnyEntry() after game: "$Level.Game);*/
}

function RollSeed()
{
    seed = dxr.Crc( Rand(MaxInt) @ (FRand()*1000000) @ (Level.TimeSeconds*1000) );
    seed = abs(seed) % 1000000;
    dxr.seed = seed;
    bSetSeed = 0;
}

#ifdef hx
function HXRollSeed()
{
    difficulty = Level.Game.Difficulty;
    SetDifficulty(difficulty);
    NewPlaythroughId();
    if( next_seed != 0 ) {
        seed = next_seed;
        dxr.seed = seed;
        next_seed = 0;
        bSetSeed = 1;
    }
    else {
        RollSeed();
    }
    ExecMaxRando();
    SaveConfig();
}
#endif

function NewPlaythroughId() {
    playthrough_id = class'DataStorage'.static._SystemTime(Level);
    playthrough_id += (Rand(MaxInt) & 0xffff0000) + dxr.Crc(Level.TimeSeconds) * 65536;
}

function CheckConfig()
{
#ifdef noflags
    InitDefaults();
#endif

    Super.CheckConfig();
}

simulated function DisplayRandoInfoMessage(#var(PlayerPawn) p, float CombatDifficulty)
{
    local string str,str2;

    str = "Deus Ex Randomizer " $ VersionString() $ ", Seed: " $ seed;
    if(bSetSeed > 0)
        str = str $ " (Set Seed)";

    str2= "Difficulty: " $ TrimTrailingZeros(CombatDifficulty)
#ifdef injections
            $ ", New Game+ Loops: "$newgameplus_loops
#endif
            $ ", Flags: " $ ToHex(FlagsHash());

    info(str);
    info(str2);
    if(p != None){
        p.ClientMessage(str);
        p.ClientMessage(str2);
    }
}

simulated function LoadFlags()
{
    //do flags binding
    local DataStorage ds;
    local #var(PlayerPawn) p;

    if( Role != ROLE_Authority ) {
        err("LoadFlags() we're not the authority here!");
        return;
    }
#ifdef noflags
    LoadNoFlags();
    return;
#endif

    info("LoadFlags()");
    p = player();

    f = dxr.flagbase;
    InitDefaults();

    if( f == None) {
        err("LoadFlags() f == None");
        return;
    }

    flags_loaded = true;
    stored_version = f.GetInt('Rando_version');

    if( stored_version == 0 && dxr.localURL != "DX" && dxr.localURL != "DXONLY" && dxr.localURL != "00_TRAINING" ) {
        err(dxr.localURL$" failed to load flags! using default randomizer settings");
        autosave = 0;//autosaving while slowmo is set to high speed crashes the game, maybe autosave should adjust its waittime by the slowmo speed
    }

    BindFlags(Reading);

    if(stored_version < flagsversion ) {
        info("upgraded flags from "$stored_version$" to "$flagsversion);
        SaveFlags();
    } else if (stored_version > flagsversion ) {
        warning("downgraded flags from "$stored_version$" to "$flagsversion);
        SaveFlags();
    }

    LogFlags("LoadFlags");
    if( p != None )
        DisplayRandoInfoMessage(p, p.CombatDifficulty);
    SetTimer(1.0, True);

    ds = class'DataStorage'.static.GetObj(dxr);
    if( ds != None ) ds.playthrough_id = playthrough_id;
}

simulated function string BindFlags(int mode, optional string str)
{
    if(mode != Hashing) {
        // keep the flagshash more stable for leaderboards
        if( FlagInt('Rando_seed', seed, mode, str) )
            dxr.seed = seed;
        FlagInt('Rando_playthrough_id', playthrough_id, mode, str);
    }

    FlagInt('Rando_maxrando', maxrando, mode, str);

    FlagInt('Rando_autosave', autosave, mode, str);
    FlagInt('Rando_crowdcontrol', crowdcontrol, mode, str);
    FlagInt('Rando_loadout', loadout, mode, str);
    FlagInt('Rando_newgameplus_loops', newgameplus_loops, mode, str);
    FlagInt('Rando_gamemode', gamemode, mode, str);
    FlagInt('Rando_setseed', bSetSeed, mode, str);
    FlagInt('Rando_mirroredmaps', mirroredmaps, mode, str);
    FlagInt('Rando_bingo_duration', bingo_duration, mode, str);
    FlagInt('Rando_bingo_scale', bingo_scale, mode, str);

    if( FlagInt('Rando_difficulty', difficulty, mode, str) ) {
        SetDifficulty(difficulty);
    }

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
    if(!FlagInt('Rando_enemystats', settings.enemystats, mode, str) && mode==Reading) {
        settings.enemystats = settings.enemiesrandomized * 2;
    }
    FlagInt('Rando_hiddenenemiesrandomized', settings.hiddenenemiesrandomized, mode, str);
    FlagInt('Rando_enemiesshuffled', settings.enemiesshuffled, mode, str);
    FlagInt('Rando_infodevices', settings.infodevices, mode, str);
    FlagInt('Rando_infodevices_containers', settings.infodevices_containers, mode, str);
    FlagInt('Rando_dancingpercent', settings.dancingpercent, mode, str);
    FlagInt('Rando_doorsmode', settings.doorsmode, mode, str);
    FlagInt('Rando_enemyrespawn', settings.enemyrespawn, mode, str);

    FlagInt('Rando_skills_disable_downgrades', settings.skills_disable_downgrades, mode, str);
    FlagInt('Rando_skills_reroll_missions', settings.skills_reroll_missions, mode, str);
    FlagInt('Rando_skills_independent_levels', settings.skills_independent_levels, mode, str);
    FlagInt('Rando_startinglocations', settings.startinglocations, mode, str);
    FlagInt('Rando_goals', settings.goals, mode, str);
    FlagInt('Rando_equipment', settings.equipment, mode, str);

    FlagInt('Rando_medbots', settings.medbots, mode, str);
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

    FlagInt('Rando_spoilers', settings.spoilers, mode, str);
    FlagInt('Rando_menus_pause', settings.menus_pause, mode, str);
    FlagInt('Rando_health', settings.health, mode, str);
    FlagInt('Rando_energy', settings.energy, mode, str);

    FlagInt('Rando_starting_map', settings.starting_map, mode, str);

    return str;
}

simulated function string flagNameToHumanName(name flagname){
    switch(flagname){
        case 'Rando_seed':
            return "Seed";
        case 'Rando_maxrando':
            return "Max Rando";
        case 'Rando_setseed':
            return "Set Seed";
        case 'Rando_autosave':
            return "Autosave";
        case 'Rando_crowdcontrol':
            return "Crowd Control";
        case 'Rando_loadout':
            return "Loadout";
        case 'Rando_newgameplus_loops':
            return "New Game+ Loop";
        case 'Rando_playthrough_id':
            return "Playthrough ID";
        case 'Rando_gamemode':
            return "Game Mode";
        case 'Rando_mirroredmaps':
            return "Mirrored Maps";
        case 'Rando_difficulty':
            return "Difficulty";
        case 'Rando_minskill':
            return "Minimum Skill Cost";
        case 'Rando_maxskill':
            return "Maximum Skill Cost";
        case 'Rando_ammo':
            return "Ammo Drops";
        case 'Rando_multitools':
            return "Multitool Drops";
        case 'Rando_lockpicks':
            return "Lockpick Drops";
        case 'Rando_biocells':
            return "Bioelectric Cell Drops";
        case 'Rando_speedlevel':
            return "Starting Speed Enhancement Level";
        case 'Rando_keys':
            return "NanoKey Locations";
        case 'Rando_keys_containers':
            return "NanoKeys can be swapped with containers";
        case 'Rando_doorspickable':
            return "Pickable Doors"; ///////////////Might need adjustment?//////////////////
        case 'Rando_doorsdestructible':
            return "Destructible Doors"; ///////////////Might need adjustment?//////////////////
        case 'Rando_deviceshackable':
            return "Electronic Devices";
        case 'Rando_passwordsrandomized':
            return "Passwords";
        case 'Rando_medkits':
            return "Medkit Drops";
        case 'Rando_enemiesrandomized':
            return "Enemy Randomization";
        case 'Rando_enemystats':
            return "Enemy Stats Boost";
        case 'Rando_hiddenenemiesrandomized':
            return "Hidden Enemy Randomization";
        case 'Rando_enemiesshuffled':
            return "Enemy Shuffling";
        case 'Rando_infodevices':
            return "Datacube Locations";
        case 'Rando_infodevices_containers':
            return "Datacubes can be swapped with containers";
        case 'Rando_dancingpercent':
            return "Dancing";
        case 'Rando_doorsmode':
            return "Doors Mode"; ///////////////Might need adjustment?//////////////////
        case 'Rando_enemyrespawn':
            return "Enemy Respawn Time";
        case 'Rando_skills_disable_downgrades':
            return "Disallow downgrades on New Game screen";
        case 'Rando_skills_reroll_missions':
            return "How often to reroll skill costs";
        case 'Rando_skills_independent_levels':
            return "Predictability of skill level cost scaling";
        case 'Rando_startinglocations':
            return "Starting Locations";
        case 'Rando_goals':
            return "Goal Locations";
        case 'Rando_equipment':
            return "Starting Equipment Amount";
        case 'Rando_medbots':
            return "Medbots";
        case 'Rando_repairbots':
            return "Repairbots";
        case 'Rando_medbotuses':
            return "Uses per Medbot";
        case 'Rando_repairbotuses':
            return "Uses per Repairbot";
        case 'Rando_medbotcooldowns':
            return "Medbot Cooldowns";
        case 'Rando_repairbotcooldowns':
            return "Repairbot Cooldowns";
        case 'Rando_medbotamount':
            return "Medbot Heal Amount";
        case 'Rando_repairbotamount':
            return "Repairbot Charge Amount";
        case 'Rando_turrets_move':
            return "Move Turrets";
        case 'Rando_turrets_add':
            return "Add Turrets";
        case 'Rando_merchants':
            return "The Merchant Chance";
        case 'Rando_banned_skills':
            return "Banned Skills";
        case 'Rando_banned_skill_level':
            return "Banned Skill Levels";
        case 'Rando_enemies_nonhumans':
            return "Enemy Non-Human Chance";
        case 'Rando_bot_weapons':
            return "Robot Weapons";
        case 'Rando_bot_stats':
            return "Non-human Stats";
        case 'Rando_swapitems':
            return "Swap Items";
        case 'Rando_swapcontainers':
            return "Swap Containers";
        case 'Rando_augcans':
            return "Aug Can Content Randomization";
        case 'Rando_aug_value_rando':
            return "Aug Strength Randomization";
        case 'Rando_skill_value_rando':
            return "Skill Strength Randomization";
        case 'Rando_min_weapon_dmg':
            return "Min Weapon Damage";
        case 'Rando_max_weapon_dmg':
            return "Max Weapon Damage";
        case 'Rando_min_weapon_shottime':
            return "Minimum Weapon Firing Speed";
        case 'Rando_max_weapon_shottime':
            return "Maximum Weapon Firing Speed";
        case 'Rando_prison_pocket':
            return "JC's Prison Pocket";
        case 'Rando_bingo_win':
            return "Bingo Lines to Win";
        case 'Rando_bingo_freespaces':
            return "Bingo Free Spaces";
        case 'Rando_bingo_duration':
            return "Bingo Duration";
        case 'Rando_bingo_scale':
            return "Bingo Scale";
        case 'Rando_spoilers':
            return "Spoiler Buttons";
        case 'Rando_menus_pause':
            return "Menus Pause The Game";
        case 'Rando_health':
            return "Player Max Health";
        case 'Rando_energy':
            return "Player Max Energy";
        case 'Rando_starting_map':
            return "Starting Map";
        default:
            return flagname $ "(ADD HUMAN READABLE NAME!)"; //Showing the raw flag name will stand out more
    }
}

simulated function string flagValToHumanVal(name flagname, int val){
    local DXRLoadouts loadout;
    local string ret;

    switch(flagname){
        //Basic true/false
        case 'Rando_setseed':
            if(val==0) return "False";
            else return "True";

        //Return the straight number
        case 'Rando_seed':
        case 'Rando_speedlevel':
        case 'Rando_medbotuses':
        case 'Rando_repairbotuses':
        case 'Rando_bingo_win':
        case 'Rando_equipment':
        case 'Rando_newgameplus_loops':
        case 'Rando_health':
        case 'Rando_energy':
            return string(val);

        //Return the number as hex
        case 'Rando_playthrough_id':
            return ToHex(val);

        //Return the number as a percent
        case 'Rando_mirroredmaps':
        case 'Rando_minskill':
        case 'Rando_maxskill':
        case 'Rando_ammo':
        case 'Rando_multitools':
        case 'Rando_lockpicks':
        case 'Rando_biocells':
        case 'Rando_deviceshackable':
        case 'Rando_medbots':
        case 'Rando_repairbots':
        case 'Rando_medkits':
        case 'Rando_dancingpercent':
        case 'Rando_turrets_move':
        case 'Rando_turrets_add':
        case 'Rando_merchants':
        case 'Rando_augcans':
        case 'Rando_aug_value_rando':
        case 'Rando_skill_value_rando':
        case 'Rando_min_weapon_dmg':
        case 'Rando_max_weapon_dmg':
        case 'Rando_min_weapon_shottime':
        case 'Rando_max_weapon_shottime':
        case 'Rando_banned_skills':
        case 'Rando_banned_skill_level':
        case 'Rando_enemies_nonhumans':
        case 'Rando_swapitems':
        case 'Rando_swapcontainers':
        case 'Rando_enemiesrandomized':
        case 'Rando_enemystats':
        case 'Rando_hiddenenemiesrandomized':
        case 'Rando_enemiesshuffled':
        case 'Rando_bot_stats':
        case 'Rando_bingo_scale':
            return val$"%";

        case 'Rando_enemyrespawn':
            return val$" seconds";

        //Medbot/Repairbot cooldown and amount options
        case 'Rando_medbotcooldowns':
        case 'Rando_repairbotcooldowns':
        case 'Rando_medbotamount':
        case 'Rando_repairbotamount':
            if (val==0){
                return "Unchanged";
            }else if (val==1){
                return "Individual";
            } else if (val==2){
                return "Global";
            }
            break;

        case 'Rando_crowdcontrol':
            if (val==0){
                return "Disabled";
            } else if (val==1){
                return "Enabled (With Names)";
            } else if (val==2){
                return "Enabled (Anonymous)";
            } else if (val==3) {
                return "Offline Simulated";
            }
            break;

        case 'Rando_prison_pocket':
            if (val==0){
                return "Disabled";
            } else if (val==1) {
                return "Unaugmented";
            } else if (val>1) {
                return "Augmented";
            }
            break;

        case 'Rando_keys':
        case 'Rando_bot_weapons':
            if (val==4){
                return "Randomized";
            } else if (val==0){
                return "Unchanged";
            }
            break;

        case 'Rando_keys_containers':
        case 'Rando_infodevices_containers':
            if (val==100){
                return "Enabled";
            } else {
                return "Disabled";
            }
            break;


        case 'Rando_maxrando':
            if (val == 1) {
                return "Enabled";
            } else {
                return "Disabled";
            }

        case 'Rando_autosave':
            if (val==0) {
                return "Off";
            } else if (val==1) {
                return "First Entry";
            } else if (val==2) {
                return "Every Entry";
            } else if (val==3) {
                return "Autosaves Only (Hardcore)";
            }
            break;

        case 'Rando_passwordsrandomized':
        case 'Rando_startinglocations':
        case 'Rando_goals':
        case 'Rando_infodevices':
            if (val==0){
                return "Unchanged";
            } else if (val==100){
                return "Randomized";
            }
            break;

        case 'Rando_skills_disable_downgrades':
            if (val==0){
                return "Allowed";
            } else if (val==5) {
                return "Disallowed";
            }
            break;

        case 'Rando_skills_reroll_missions':
            if (val==0){
                return "Don't Reroll";
            } else if (val==1){
                return "Reroll Every Mission";
            } else if (val==2){
                return "Reroll Every 2 Missions";
            } else if (val==3){
                return "Reroll Every 3 Missions";
            } else if (val==5){
                return "Reroll Every 5 Missions";
            }
            break;

        case 'Rando_difficulty':
            if (val<4){
                return DifficultyName(val);
            }
            break;

        case 'Rando_gamemode':
            return GameModeName(val);

        case 'Rando_skills_independent_levels':
            if (val==0){
                return "Relative Skill Level Costs";
            } else if (val==1) {
                return "Unpredictable Skill Level Costs";
            }
            break;

        case 'Rando_loadout':
            foreach AllActors(class'DXRLoadouts', loadout) { break; }
            if( loadout == None )
                return "All Items Allowed";
            else {
                return loadout.GetName(val);
            }

        case 'Rando_bingo_freespaces':
            if(val == 0) {
                return "Disabled";
            } else if(val == 1) {
                return "Enabled";
            } else {
                return val $ " Free Spaces";
            }
            break;

        case 'Rando_bingo_duration':
            if(val == 0) {
                return "End of Game";
            } else if(val == 1) {
                return "1 Mission";
            } else {
                return val $ " Missions";
            }
            break;

        //Weird, handle later
        case 'Rando_doorsmode':
            switch(val/256*256) {
            case undefeatabledoors:
                ret = "undefeatable";
                break;
            case alldoors:
                ret = "all";
                break;
            case keyonlydoors:
                ret = "key-only";
                break;
            case highlightabledoors:
                ret = "highlightable";
                break;
            default:
                ret = (val/256*256) $ " (Unhandled!)";
                break;
            }
            ret = ret $ " / ";
            switch(val%256) {
                case doormutuallyinclusive: return ret $ "mutually inclusive";
                case doorindependent: return ret $ "independent";
                case doormutuallyexclusive: return ret $ "mutually exclusive";
                default: return ret $ (val%256) $ " (Unhandled!)";
            }
            return val $ " (Unhandled!)";

        case 'Rando_doorspickable':
        case 'Rando_doorsdestructible':
            return val $ "%";

        case 'Rando_spoilers':
            if(val==0){
                return "Disallowed";
            } else if (val==1){
                return "Available";
            }
            break;

        case 'Rando_menus_pause':
            if(val==0) {
                return "No";
            } else {
                return "Yes";
            }
            break;

        case 'Rando_starting_map':
            return class'DXRStartMap'.static.GetStartingMapName(val);
            break;
        default:
            return val $ " (Unhandled!)";
    }
    return val $ " (Mishandled!)";
}

// returns true is read was successful
simulated function bool FlagInt(name flagname, out int val, int mode, out string str)
{
    if( mode == 0 ) {
        err("FlagInt("$flagname$", "$val$", 0, ...) unknown mode");
    }
    else if( mode == Reading ) {
        if( f.CheckFlag(flagname, FLAG_Int) )
        {
            val = f.GetInt(flagname);
            return true;
        }
    }
    else if( mode == Writing ) {
        f.SetInt(flagname, val,, 999);
    }
    else if ( mode == Credits ) {
        str = str $ "|n" $ flagNameToHumanName(flagname)$": "$flagValToHumanVal(flagname,val);
    }
    else {
        if(mode == Printing && Len(str) > 300) {
            info(str);
            str = "";
        }
        else if(mode == Credits && Len(str)-FindLast(str, "|n") > 50)
            str = str $ ",|n";
        else if(Len(str) > 0)
            str = str $ ", ";

        str = str $ ReplaceText(flagname, "Rando_", "") $ ": " $ val;
    }
    return false;
}

simulated function SaveFlags()
{
    if( Role != ROLE_Authority ) {
        err("SaveFlags() we're not the authority here!");
        return;
    }

#ifdef noflags
    SaveNoFlags();
    return;
#endif

    l("SaveFlags()");
    f = dxr.flagbase;
    if( f == None ) {
        err("SaveFlags() f == None");
        return;
    }

    InitVersion();
    f.SetInt('Rando_version', flagsversion,, 999);
    BindFlags(Writing);
    LogFlags("SaveFlags");
}

simulated function LoadNoFlags()
{
    local #var(PlayerPawn) p;
    local DataStorage ds;
    local float CombatDifficulty;

    flags_loaded = true;

#ifdef hx
    CombatDifficulty = HXGameInfo(Level.Game).CombatDifficulty;
#else
    p = player();
    if( p != None )
        CombatDifficulty = p.CombatDifficulty;
#endif

    info("LoadNoFlags()");

    if( flagsversion == 0 && dxr.localURL != "DX" && dxr.localURL != "DXONLY" && dxr.localURL != "00_TRAINING" ) {
        err(dxr.localURL$" failed to load flags! using default randomizer settings");
        InitDefaults();
        autosave = 0;
        SaveNoFlags();
    }

    stored_version = flagsversion;

#ifdef hx
    // bool flags work though
    if( dxr.localURL != "DX" && dxr.localURL != "DXONLY" && dxr.localURL != "00_TRAINING" ) {
        if( ! dxr.flagbase.GetBool('Rando_rolled') ) {
            HXRollSeed();
            dxr.flagbase.SetBool('Rando_rolled', true,, 999);
        }
    }
#endif

    dxr.seed = seed;

    ds = class'DataStorage'.static.GetObj(dxr);
    if( ds != None ) ds.playthrough_id = playthrough_id;

    LogFlags("LoadNoFlags");
    if( p != None )
        DisplayRandoInfoMessage(p, CombatDifficulty);
}

simulated function SaveNoFlags()
{
    l("SaveNoFlags()");

    InitVersion();
    SaveConfig();

    LogFlags("SaveNoFlags");
}

simulated function LogFlags(string prefix)
{
    local string str;
    str = prefix$" "$Self.Class$" - version: " $ VersionString(true) $ ", flagshash: " $ FlagsHash();// this goes to telemetry as an int
    str = BindFlags(Printing, str);
    if(Len(str) > 0)
        info(prefix @ str);
}

simulated function string StringifyFlags(int mode)
{
        local float CombatDifficulty;
        local #var(PlayerPawn) p;
#ifdef hx
    CombatDifficulty = HXGameInfo(Level.Game).CombatDifficulty;
#else
    p = player();
    if( p != None )
        CombatDifficulty = p.CombatDifficulty;
#endif
    return BindFlags(mode, "difficulty: " $ TrimTrailingZeros(CombatDifficulty));
}

simulated function int FlagsHash()
{
    local int hash;
    hash = dxr.Crc(StringifyFlags(Hashing));
    hash = int(abs(hash));
    return hash;
}

function InitVersion()
{
    flagsversion = VersionNumber();
}

simulated function MaxRandoVal(out int val)
{
    val = rngrecip(val, 2);
}

simulated function MaxRandoValPair(out int min, out int max)
{
    local int i;

    MaxRandoVal(min);
    MaxRandoVal(max);

    if(min > max) {
        i = min;
        min = max;
        max = i;
    } else if(min == max) {
        min--;
        max++;
    }
}

function NewGamePlusVal(out int val, float curve, float exp)
{
    if(val > 0) {
        val = val * (curve ** exp);// int *= float doesn't give as good accuracy as int = int*float
        if(val <= 0) val = 1;
    }
}

function RunTests()
{
    local int i, t;
    Super.RunTests();

    test( dxr != None, "found dxr "$dxr );
    //this Crc function returns negative numbers
    testint( dxr.Crc("a bomb!"), -1813716842, "Crc32 test");
    testint( dxr.Crc("1723"), -441943723, "Crc32 test");
    testint( dxr.Crc("do you have a single fact to back that up"), -1473827402, "Crc32 test");

    SetSeed("smashthestate");
    testint( rng(1), 0, "rng(1) is 0");
    for(i=0;i<10;i++) {
        t=rng(100);
        test( t >=0 && t < 100, "rng(100) got " $t$" >= 0 and < 100");
    }
    dxr.SetSeed(-111);
    i = rng(100);
    test( rng(100) != i, "rng(100) != rng(100)");

    dxr.SetSeed(111);
    testbool( chance_single(0), false, "chance_single(0)");
    testbool( chance_single(1), false, "chance_single(1)");
    testbool( chance_single(100), true, "chance_single(100)");
    testbool( chance_single(50), true, "chance_single(50) 1");
    testbool( chance_single(50), false, "chance_single(50) 2");
    testbool( chance_single(50), true, "chance_single(50) 3");
    testbool( chance_single(50), false, "chance_single(50) 4");

    teststring( FloatToString(0.5555, 1), "0.6", "FloatToString 1");
    teststring( FloatToString(0.5454999, 4), "0.5455", "FloatToString 2");
    teststring( FloatToString(0.5455, 2), "0.55", "FloatToString 3");

    teststring( TrimTrailingZeros(FloatToString(0.5, 3)), "0.5", "TrimTrailingZeros 1");
    teststring( TrimTrailingZeros(FloatToString(0.5, 1)), "0.5", "TrimTrailingZeros 2");
    teststring( TrimTrailingZeros(FloatToString(1, 5)), "1", "TrimTrailingZeros 3");
    teststring( TrimTrailingZeros(FloatToString(10, 5)), "10", "TrimTrailingZeros 4");
    teststring( TrimTrailingZeros(FloatToString(0.01, 5)), "0.01", "TrimTrailingZeros 5");

    testbool( #defined(debug), false, "debug is disabled");
}

function ExtendedTests()
{
    local int i, total;
    local float f;
    local string credits_text;
    Super.ExtendedTests();

    testint(FindLast("this is a test", "nope"), -1, "FindLast");
    testint(FindLast("this is a test", " "), 9, "FindLast");

    dxr.SetSeed(0451);
    testfloatrange( (9**4), 9*9*9*9, 0.001, "pow");
    testfloatrange( (5.7**3), 5.7*5.7*5.7, 0.001, "pow");

    TestRngExp(0, 1, 0.5, 1.5);

    for(i=1;i<=4;i++)
        TestRngExp(25, 300, 100, i);
    for(i=1;i<=4;i++)
        TestRngExp(50, 300, 100, i);
    for(i=1;i<=4;i++)
        TestRngExp(50, 400, 100, i);
    for(i=1;i<=4;i++)
        TestRngExp(25, 150, 100, i);

    dxr.SetSeed(0451);
    for(i=0;i<10000;i++)
        if(rngb()) total++;
    // close enough?
    testint(total, 4992, "rngb()");

    for(i=0;i<1000;i++) {
        f = rngrecip(1, 2);
        if(f < 0.5)
            test(false, "rngrecip "$ f $ " < 0.5");
        if(f > 2)
            test(false, "rngrecip "$ f $ " > 2");

        f = rngrecip(100, 4);
        if(f < 25)
            test(false, "rngrecip "$ f $ " < 25");
        if(f > 400)
            test(false, "rngrecip "$ f $ " > 400");
    }

    TestTime();
    TestStorage();

    credits_text = StringifyFlags(Credits);
    test( InStr(credits_text, "(ADD HUMAN READABLE NAME!)") == -1, "Credits does not contain (ADD HUMAN READABLE NAME!)");
    test( InStr(credits_text, "(Unhandled!)") == -1, "Credits does not contain (Unhandled!)");
    test( InStr(credits_text, "(Mishandled!)") == -1, "Credits does not contain (Mishandled!)");

    teststring(ToHex(0), "0", "ToHex(0)");
    teststring(ToHex(0xF), "F", "ToHex(0xF)");
    teststring(ToHex(0x1F), "1F", "ToHex(0x1F)");
    teststring(ToHex(0x100F), "100F", "ToHex(0x100F)");
    teststring(ToHex(0x9001F), "9001F", "ToHex(0x9001F)");

    gamemode = 0;
    SetDifficulty(0);
    testint(settings.bingo_freespaces, 1, "SetDifficulty check bingo_freespaces");
    testint(Settings.spoilers, 1, "SetDifficulty check spoilers");
    testint(Settings.menus_pause, 1, "SetDifficulty check menus_pause");
    testint(settings.health, 200, "SetDifficulty check health");
    testint(settings.energy, 200, "SetDifficulty check energy");
    SetDifficulty(1);
    testint(settings.health, 100, "SetDifficulty check health");
    testint(settings.energy, 100, "SetDifficulty check energy");
}

function TestTime()
{
    local DataStorage ds;
    local int y,m,d,h,min,s;//old backup values;
    local int time1, time2, i;
    local bool didOverflow;

    y=Level.Year;
    m=Level.Month;
    d=Level.Day;
    h=Level.Hour;
    min=Level.Minute;
    s=Level.Second;
    ds = Spawn(class'DataStorage');

    Level.Year=1723;
    Level.Month=2;
    Level.Day=6;
    Level.Hour=12;
    Level.Minute=0;
    Level.Second=0;
    time1 = ds.SystemTime();
    Level.Day = 7;
    time2 = ds.SystemTime();

    testint(time2-time1, 86400, "1723-02-06 vs 1723-02-07");
    Level.Month = 3;
    time2 = ds.SystemTime();
    testint(time2-time1, 86400*29, "1723-02-06 vs 1723-03-07");
    Level.Hour = 0;
    time2 = ds.SystemTime();
    testint(time2-time1, 86400*28 + 3600*12, "1723-02-06 noon vs 1723-03-07 midnight");

    Level.Year=2020;
    Level.Month=2;
    Level.Day=6;
    time1 = ds.SystemTime();
    Level.Month=3;
    time2 = ds.SystemTime();
    testint(time2-time1, 86400*29, "leap year 2020-02-06 vs 2020-03-06");

    for(i=2030; i<=2040; i++) {
        //test int overflows, I fully expect people to still be playing this in the year 2040, so we gotta make sure it works
        Level.Year=i;
        Level.Month=6;
        Level.Day=23;
        time1 = ds.SystemTime();
        Level.Day=24;
        time2 = ds.SystemTime();
        testint(time2-time1, 86400, "int overflow, "$i$"-06-23 vs "$i$"-06-24");

        Level.Day=27;
        time2 = ds.SystemTime();
        testint(time2-time1, 4*86400, "int overflow, "$i$"-06-23 vs "$i$"-06-27");

        Level.Month=7;
        Level.Day=1;
        time2 = ds.SystemTime();
        testint(time2-time1, 8*86400, "int overflow, "$i$"-06-23 vs "$i$"-07-01");

        Level.Year=i+1;
        Level.Month=6;
        Level.Day=23;
        time2 = ds.SystemTime();
        if( time2-time1 == 366*86400 )
            testint(time2-time1, 366*86400, "int overflow, leap year "$i$"-06-23 vs "$(i+1)$"-06-23");
        else
            testint(time2-time1, 365*86400, "int overflow, non-leap year "$i$"-06-23 vs "$(i+1)$"-06-23");

        if( time2 < time1 ) {
            l("did overflow on year "$i$" to "$(i+1));
            didOverflow=true;
        }
    }

    test(didOverflow, "tested timestamp overflow");

    Level.Year=y;
    Level.Month=m;
    Level.Day=d;
    Level.Hour=h;
    Level.Minute=min;
    Level.Second=s;
    ds.Destroy();
}

function TestStorage()
{
    local DataStorage ds;
    local int i;
    ds = Spawn(class'DataStorage');
    for(i=0;i <3 ;i++) {
        ds.SetConfig(i, i, 100);
        testint( int(ds.GetConfigKey(i)), i, "GetConfigKey("$i$")");
    }
    ds.EndPlaythrough();
    for(i=0;i <3 ;i++) {
        teststring( ds.GetConfigKey(i), i, "GetConfigKey("$i$") not cleared after EndPlaythrough()");
    }
    ds.config_dirty = false;// don't bother writing to disk
    ds.Destroy();
}

function TestRngExp(float minrange, float maxrange, float mid, float curve)
{
    local float min, max, avg, t;
    local int lows, highs, mids, times;
    local int i;

    times = 10000;
    min=maxrange;
    max=minrange;
    highs=0;
    lows=0;
    mids=0;
    for(i=0; i<times; i++) {
        t=rngexp(minrange, maxrange, curve);
        avg += t;
        if(t<min) min=t;
        if(t>max) max=t;
        if(t<mid) lows++;
        if(t>mid) highs++;
        if(t==mid) mids++;
    }
    avg /= float(times);
    test( min >= minrange, "exponential ^"$curve$" - min: "$min);
    test( min < minrange+10, "exponential ^"$curve$" - min: "$min);
    test( max <= maxrange, "exponential ^"$curve$" - max: "$max);
    test( max > maxrange-10, "exponential ^"$curve$" - max: "$max);
    test( avg < maxrange, "exponential ^"$curve$" - avg "$avg$" < maxrange "$maxrange);
    test( avg > minrange, "exponential ^"$curve$" - avg "$avg$" > minrange "$minrange);
    test( lows > times/10, "exponential ^"$curve$" - lows "$lows$" > times/8 "$(times/10));
    test( highs > times/10, "exponential ^"$curve$" - highs "$highs$" > times/8 "$(times/10));
}
