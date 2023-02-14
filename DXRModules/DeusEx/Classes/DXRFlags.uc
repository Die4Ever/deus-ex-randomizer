class DXRFlags extends DXRBase transient;

var transient FlagBase f;

const Reading = 1;
const Writing = 2;
const Stringifying = 3;
const Printing = 4;
const Credits = 5;

//rando flags
#ifdef hx
var #var(flagvarprefix) int next_seed;
#endif

var #var(flagvarprefix) int seed, playthrough_id;
var #var(flagvarprefix) int flagsversion;//if you load an old game with a newer version of the randomizer, we'll need to set defaults for new flags

var #var(flagvarprefix) int gamemode;//0=original, 1=rearranged, 2=horde, 3=kill bob page, 4=stick to the prod, 5=stick to the prod +, 6=how about some soy food, 7=max rando
var #var(flagvarprefix) int loadout;//0=none, 1=stick with the prod, 2=stick with the prod plus
var #var(flagvarprefix) int autosave;//0=off, 1=first time entering level, 2=every loading screen, 3=autosave-only
var #var(flagvarprefix) int maxrando;
var #var(flagvarprefix) int newgameplus_loops;
var #var(flagvarprefix) int crowdcontrol;

var #var(flagvarprefix) int difficulty;// save which difficulty setting the game was started with, for nicer upgrading
var #var(flagvarprefix) int bSetSeed;// int because all our flags are ints?


// When adding a new flag, make sure to update BindFlags, flagNameToHumanName, flagValToHumanVal,
// CheckConfig, and maybe ExecMaxRando if it should be included in that
struct FlagsSettings {
#ifndef hx
    var float CombatDifficulty;
#endif
    var int minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
    var int keysrando;//0=off, 1=dumb, 2=on (old smart), 3=copies, 4=smart (v1.3), 5=path finding?
    var int keys_containers, infodevices_containers;
    var int doorsmode, doorspickable, doorsdestructible, deviceshackable, passwordsrandomized;//could be bools, but int is more flexible, especially so I don't have to change the flag type
    var int enemiesrandomized, hiddenenemiesrandomized, enemiesshuffled, enemyrespawn, infodevices, bot_weapons, bot_stats;
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
};

#ifdef hx
var config string difficulty_names[4];// Easy, Medium, Hard, DeusEx
var config FlagsSettings difficulty_settings[4];
#else
var config string difficulty_names[5];// Super Easy QA, Easy, Normal, Hard, Extreme
var config FlagsSettings difficulty_settings[5];
#endif

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
        settings,
        flags_loaded;
}

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

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);
    if(!VersionIsStable())
        p.bCheatsEnabled = true;
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
    settings = difficulty_settings[difficulty];
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

function InitDefaults()
{
    InitVersion();

    seed = 0;
    NewPlaythroughId();
    if( dxr != None ) RollSeed();
    gamemode = 0;
    loadout = 0;
    autosave = 2;
    crowdcontrol = 0;
    newgameplus_loops = 0;

#ifdef hx
    difficulty = 1;
    maxrando = 1;
#else
    difficulty = 2;
    maxrando = 0;
#endif

#ifndef vanilla
    autosave = 0;
#endif
    settings = difficulty_settings[difficulty];

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
    if( ConfigOlderThan(2,2,0,3) ) {
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
        difficulty_settings[i].hiddenenemiesrandomized = 20;
        difficulty_settings[i].enemiesshuffled = 100;
        difficulty_settings[i].enemies_nonhumans = 40;
        difficulty_settings[i].bot_weapons = 0;
        difficulty_settings[i].bot_stats = 0;
        difficulty_settings[i].enemyrespawn = 0;
        difficulty_settings[i].skills_disable_downgrades = 0;
        difficulty_settings[i].skills_reroll_missions = 1;
        difficulty_settings[i].skills_independent_levels = 0;
        difficulty_settings[i].banned_skills = 5;
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
        i++;
#endif

        difficulty_names[i] = "Easy";
#ifndef hx
        difficulty_names[i] = "Normal";
        difficulty_settings[i].CombatDifficulty = 1.2;
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
        difficulty_settings[i].hiddenenemiesrandomized = 20;
        difficulty_settings[i].enemiesshuffled = 100;
        difficulty_settings[i].enemies_nonhumans = 40;
        difficulty_settings[i].bot_weapons = 0;
        difficulty_settings[i].bot_stats = 0;
        difficulty_settings[i].enemyrespawn = 0;
        difficulty_settings[i].skills_disable_downgrades = 0;
        difficulty_settings[i].skills_reroll_missions = 5;
        difficulty_settings[i].skills_independent_levels = 0;
        difficulty_settings[i].banned_skills = 3;
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
        difficulty_settings[i].repairbots = 35;
        difficulty_settings[i].medbotuses = 10;
        difficulty_settings[i].repairbotuses = 10;
        difficulty_settings[i].medbotcooldowns = 1;
        difficulty_settings[i].repairbotcooldowns = 1;
        difficulty_settings[i].medbotamount = 1;
        difficulty_settings[i].repairbotamount = 1;
        difficulty_settings[i].turrets_move = 50;
        difficulty_settings[i].turrets_add = 30;
        difficulty_settings[i].merchants = 30;
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
        i++;

        difficulty_names[i] = "Medium";
#ifndef hx
        difficulty_names[i] = "Hard";
        difficulty_settings[i].CombatDifficulty = 1.7;
#endif
        difficulty_settings[i].doorsmode = undefeatabledoors + doormutuallyexclusive;
        difficulty_settings[i].doorsdestructible = 50;
        difficulty_settings[i].doorspickable = 50;
        difficulty_settings[i].keysrando = 4;
        difficulty_settings[i].keys_containers = 0;
        difficulty_settings[i].infodevices_containers = 0;
        difficulty_settings[i].deviceshackable = 100;
        difficulty_settings[i].passwordsrandomized = 100;
        difficulty_settings[i].infodevices = 100;
        difficulty_settings[i].enemiesrandomized = 30;
        difficulty_settings[i].hiddenenemiesrandomized = 30;
        difficulty_settings[i].enemiesshuffled = 100;
        difficulty_settings[i].enemies_nonhumans = 60;
        difficulty_settings[i].bot_weapons = 0;
        difficulty_settings[i].bot_stats = 0;
        difficulty_settings[i].enemyrespawn = 0;
        difficulty_settings[i].skills_disable_downgrades = 0;
        difficulty_settings[i].skills_reroll_missions = 5;
        difficulty_settings[i].skills_independent_levels = 0;
        difficulty_settings[i].banned_skills = 5;
        difficulty_settings[i].banned_skill_levels = 5;
        difficulty_settings[i].minskill = 50;
        difficulty_settings[i].maxskill = 300;
        difficulty_settings[i].ammo = 70;
        difficulty_settings[i].medkits = 70;
        difficulty_settings[i].biocells = 70;
        difficulty_settings[i].lockpicks = 70;
        difficulty_settings[i].multitools = 70;
        difficulty_settings[i].speedlevel = 1;
        difficulty_settings[i].startinglocations = 100;
        difficulty_settings[i].goals = 100;
        difficulty_settings[i].equipment = 2;
        difficulty_settings[i].medbots = 25;
        difficulty_settings[i].repairbots = 25;
        difficulty_settings[i].medbotuses = 5;
        difficulty_settings[i].repairbotuses = 5;
        difficulty_settings[i].medbotcooldowns = 1;
        difficulty_settings[i].repairbotcooldowns = 1;
        difficulty_settings[i].medbotamount = 1;
        difficulty_settings[i].repairbotamount = 1;
        difficulty_settings[i].turrets_move = 50;
        difficulty_settings[i].turrets_add = 70;
        difficulty_settings[i].merchants = 30;
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
        i++;

        difficulty_names[i] = "Hard";
#ifndef hx
        difficulty_names[i] = "Extreme";
        difficulty_settings[i].CombatDifficulty = 2.3;
#endif
        difficulty_settings[i].doorsmode = undefeatabledoors + doormutuallyexclusive;
        difficulty_settings[i].doorsdestructible = 25;
        difficulty_settings[i].doorspickable = 25;
        difficulty_settings[i].keysrando = 4;
        difficulty_settings[i].keys_containers = 0;
        difficulty_settings[i].infodevices_containers = 0;
        difficulty_settings[i].deviceshackable = 50;
        difficulty_settings[i].passwordsrandomized = 100;
        difficulty_settings[i].infodevices = 100;
        difficulty_settings[i].enemiesrandomized = 40;
        difficulty_settings[i].hiddenenemiesrandomized = 40;
        difficulty_settings[i].enemiesshuffled = 100;
        difficulty_settings[i].enemies_nonhumans = 70;
        difficulty_settings[i].bot_weapons = 0;
        difficulty_settings[i].bot_stats = 0;
        difficulty_settings[i].enemyrespawn = 0;
        difficulty_settings[i].skills_disable_downgrades = 5;
        difficulty_settings[i].skills_reroll_missions = 5;
        difficulty_settings[i].skills_independent_levels = 100;
        difficulty_settings[i].banned_skills = 5;
        difficulty_settings[i].banned_skill_levels = 7;
        difficulty_settings[i].minskill = 50;
        difficulty_settings[i].maxskill = 300;
        difficulty_settings[i].ammo = 60;
        difficulty_settings[i].medkits = 60;
        difficulty_settings[i].biocells = 50;
        difficulty_settings[i].lockpicks = 60;
        difficulty_settings[i].multitools = 60;
        difficulty_settings[i].speedlevel = 1;
        difficulty_settings[i].startinglocations = 100;
        difficulty_settings[i].goals = 100;
        difficulty_settings[i].equipment = 1;
        difficulty_settings[i].medbots = 20;
        difficulty_settings[i].repairbots = 20;
        difficulty_settings[i].medbotuses = 3;
        difficulty_settings[i].repairbotuses = 3;
        difficulty_settings[i].medbotcooldowns = 1;
        difficulty_settings[i].repairbotcooldowns = 1;
        difficulty_settings[i].medbotamount = 1;
        difficulty_settings[i].repairbotamount = 1;
        difficulty_settings[i].turrets_move = 50;
        difficulty_settings[i].turrets_add = 150;
        difficulty_settings[i].merchants = 30;
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
        i++;

        difficulty_names[i] = "DeusEx";
#ifndef hx
        difficulty_names[i] = "Impossible";
        difficulty_settings[i].CombatDifficulty = 3;
#endif
        difficulty_settings[i].doorsmode = undefeatabledoors + doormutuallyexclusive;
        difficulty_settings[i].doorsdestructible = 25;
        difficulty_settings[i].doorspickable = 25;
        difficulty_settings[i].keysrando = 4;
        difficulty_settings[i].keys_containers = 0;
        difficulty_settings[i].infodevices_containers = 0;
        difficulty_settings[i].deviceshackable = 50;
        difficulty_settings[i].passwordsrandomized = 100;
        difficulty_settings[i].infodevices = 100;
        difficulty_settings[i].enemiesrandomized = 50;
        difficulty_settings[i].hiddenenemiesrandomized = 50;
        difficulty_settings[i].enemiesshuffled = 100;
        difficulty_settings[i].enemies_nonhumans = 80;
        difficulty_settings[i].bot_weapons = 0;
        difficulty_settings[i].bot_stats = 0;
        difficulty_settings[i].enemyrespawn = 0;
        difficulty_settings[i].skills_disable_downgrades = 5;
        difficulty_settings[i].skills_reroll_missions = 5;
        difficulty_settings[i].skills_independent_levels = 100;
        difficulty_settings[i].banned_skills = 7;
        difficulty_settings[i].banned_skill_levels = 7;
        difficulty_settings[i].minskill = 50;
        difficulty_settings[i].maxskill = 400;
        difficulty_settings[i].ammo = 40;
        difficulty_settings[i].medkits = 50;
        difficulty_settings[i].biocells = 30;
        difficulty_settings[i].lockpicks = 50;
        difficulty_settings[i].multitools = 50;
        difficulty_settings[i].speedlevel = 1;
        difficulty_settings[i].startinglocations = 100;
        difficulty_settings[i].goals = 100;
        difficulty_settings[i].equipment = 1;
        difficulty_settings[i].medbots = 15;
        difficulty_settings[i].repairbots = 15;
        difficulty_settings[i].medbotuses = 1;
        difficulty_settings[i].repairbotuses = 1;
        difficulty_settings[i].medbotcooldowns = 1;
        difficulty_settings[i].repairbotcooldowns = 1;
        difficulty_settings[i].medbotamount = 1;
        difficulty_settings[i].repairbotamount = 1;
        difficulty_settings[i].turrets_move = 50;
        difficulty_settings[i].turrets_add = 300;
        difficulty_settings[i].merchants = 30;
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
        i++;

#ifdef hx
        for(i=0; i<ArrayCount(difficulty_settings); i++) {
            difficulty_settings[i].startinglocations = 0;
            difficulty_settings[i].merchants = 0;
        }
#endif

#ifdef noflags
        InitDefaults();
#endif
    }
    Super.CheckConfig();
}

function FlagsSettings SetDifficulty(int new_difficulty)
{
    difficulty = new_difficulty;
    settings = difficulty_settings[difficulty];
    return settings;
}

static function string GameModeName(int gamemode)
{
    switch(gamemode) {
    case 0:
        return "Normal Randomizer";
    case 1:
        return "Entrance Randomization";
    case 2:
        return "Horde Mode";
    }
    //EnumOption("Kill Bob Page (Alpha)", 3, f.gamemode);
    //EnumOption("How About Some Soy Food?", 6, f.gamemode);
    //EnumOption("Max Rando", 7, f.gamemode);
    return "";
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
            $ ", Flags: " $ FlagsHash();

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
    if( FlagInt('Rando_seed', seed, mode, str) )
        dxr.seed = seed;

    FlagInt('Rando_maxrando', maxrando, mode, str);

    FlagInt('Rando_autosave', autosave, mode, str);
    FlagInt('Rando_crowdcontrol', crowdcontrol, mode, str);
    FlagInt('Rando_loadout', loadout, mode, str);
    FlagInt('Rando_newgameplus_loops', newgameplus_loops, mode, str);
    FlagInt('Rando_playthrough_id', playthrough_id, mode, str);
    FlagInt('Rando_gamemode', gamemode, mode, str);
    FlagInt('Rando_setseed', bSetSeed, mode, str);

    if( FlagInt('Rando_difficulty', difficulty, mode, str) ) {
        settings = difficulty_settings[difficulty];
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
        case 'Rando_spoilers':
            return "Spoiler Buttons";
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
        case 'Rando_playthrough_id':
        case 'Rando_speedlevel':
        case 'Rando_medbotuses':
        case 'Rando_repairbotuses':
        case 'Rando_bingo_win':
        case 'Rando_equipment':
        case 'Rando_newgameplus_loops':
            return ""$val;

        //Return the number as a percent
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
        case 'Rando_hiddenenemiesrandomized':
        case 'Rando_enemiesshuffled':
        case 'Rando_bot_stats':
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
                return difficulty_names[val];
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
    str = prefix$" "$Self.Class$" - version: " $ VersionString(true) $ ", flagshash: " $ FlagsHash();
    str = BindFlags(Printing, str);
    if(Len(str) > 0)
        info(prefix @ str);
}

simulated function AddDXRCredits(CreditsWindow cw)
{
    cw.PrintHeader("DXRFlags");

    cw.PrintText(VersionString() $ ", flagshash: " $ FlagsHash());
    cw.PrintText(StringifyFlags(Credits));
    cw.PrintLn();
}

simulated function string StringifyFlags(optional int mode)
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
    if(mode == 0)
        mode = Stringifying;
    return BindFlags(mode, "flagsversion: "$flagsversion$", difficulty: " $ TrimTrailingZeros(CombatDifficulty));
}

simulated function int FlagsHash()
{
    local int hash;
    hash = dxr.Crc(StringifyFlags());
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

simulated function ExecMaxRando()
{
    // set local seed
    // set a flag to save that we are in Max Rando mode
    info("ExecMaxRando()");
    SetGlobalSeed("ExecMaxRando");
    maxrando = 1;

    RandomizeSettings(False);
}


//Initialize the values that get tweaked by max rando
simulated function InitMaxRandoSettings()
{
    settings.merchants = difficulty_settings[difficulty].merchants;
    settings.dancingpercent = difficulty_settings[difficulty].dancingpercent;
    settings.medbots = difficulty_settings[difficulty].medbots;
    settings.repairbots = difficulty_settings[difficulty].repairbots;
    settings.enemiesrandomized=difficulty_settings[difficulty].enemiesrandomized;
    settings.enemies_nonhumans=difficulty_settings[difficulty].enemies_nonhumans;
    settings.bot_weapons=difficulty_settings[difficulty].bot_weapons;
    settings.bot_stats=difficulty_settings[difficulty].bot_stats;
    settings.turrets_move=difficulty_settings[difficulty].turrets_move;
    settings.turrets_add=difficulty_settings[difficulty].turrets_add;
    settings.skills_reroll_missions=difficulty_settings[difficulty].skills_reroll_missions;
    settings.minskill=difficulty_settings[difficulty].minskill;
    settings.maxskill=difficulty_settings[difficulty].maxskill;
    settings.banned_skills=difficulty_settings[difficulty].banned_skills;
    settings.banned_skill_levels=difficulty_settings[difficulty].banned_skill_levels;
    settings.ammo=difficulty_settings[difficulty].ammo;
    settings.multitools=difficulty_settings[difficulty].multitools;
    settings.lockpicks=difficulty_settings[difficulty].lockpicks;
    settings.biocells=difficulty_settings[difficulty].biocells;
    settings.medkits=difficulty_settings[difficulty].medkits;
    settings.equipment = difficulty_settings[difficulty].equipment;
    settings.min_weapon_dmg=difficulty_settings[difficulty].min_weapon_dmg;
    settings.max_weapon_dmg=difficulty_settings[difficulty].max_weapon_dmg;
    settings.min_weapon_shottime=difficulty_settings[difficulty].min_weapon_shottime;
    settings.max_weapon_shottime=difficulty_settings[difficulty].max_weapon_shottime;
    settings.enemyrespawn = difficulty_settings[difficulty].enemyrespawn;

}

//Randomize the values.  If forceMenuOptions is set, we will only allow the values to be set to
//the options available in DXRMenuSetupRando
simulated function RandomizeSettings(bool forceMenuOptions)
{
    info("RandomizeSettings("$string(forceMenuOptions)$")");

    // change the flags normally configurable on the Advanced Settings page, but try to keep the difficulty balanced
    // also make sure to randomize the doors mode and stuff
    MaxRandoVal(settings.merchants);
    MaxRandoVal(settings.dancingpercent);
    MaxRandoVal(settings.medbots);
    MaxRandoVal(settings.repairbots);

    settings.medbotuses = rng(7) + 1;
    settings.repairbotuses = rng(7) + 1;

    settings.medbotcooldowns = int(rngb()) + 1;// 1 or 2
    settings.repairbotcooldowns = int(rngb()) + 1;
    settings.medbotamount = int(rngb()) + 1;
    settings.repairbotamount = int(rngb()) + 1;

    if (forceMenuOptions){
        //Eventually we can add logic to randomize between the door menu options
    } else {
        settings.doorsmode = undefeatabledoors + doorindependent;
        settings.doorsdestructible = rng(100);
        settings.doorspickable = rng(100);
    }

    /* To match the menu options, we just randomize between 0, 50, and 100 */
    if (forceMenuOptions){
        settings.deviceshackable = rng(3)*50;
    } else {
        settings.deviceshackable = rng(100);
    }

    MaxRandoVal(settings.enemiesrandomized);
    settings.hiddenenemiesrandomized = settings.enemiesrandomized;
    settings.enemiesshuffled = 100;
    MaxRandoVal(settings.enemies_nonhumans);

    if(rngb()) {
        settings.enemyrespawn = rng(120) + 120;
    } else {
        settings.enemyrespawn = 0;
    }

    if(rngb()) {
        settings.bot_weapons = 4;
    } else {
        settings.enemyrespawn = 0;
    }

    if(rngb()) {
        settings.bot_stats = 100;
    } else {
        settings.bot_stats = 0;
    }

    MaxRandoVal(settings.turrets_move);
    MaxRandoVal(settings.turrets_add);

    MaxRandoVal(settings.skills_reroll_missions);
    settings.skills_independent_levels = int(rngb());
    MaxRandoValPair(settings.minskill, settings.maxskill);
    MaxRandoVal(settings.banned_skills);
    MaxRandoVal(settings.banned_skill_levels);
    settings.skill_value_rando = 100;

    MaxRandoVal(settings.ammo);
    MaxRandoVal(settings.multitools);
    MaxRandoVal(settings.lockpicks);
    MaxRandoVal(settings.biocells);
    MaxRandoVal(settings.medkits);
    settings.equipment += int(rngb());

    MaxRandoValPair(settings.min_weapon_dmg, settings.max_weapon_dmg);
    MaxRandoValPair(settings.min_weapon_shottime, settings.max_weapon_shottime);

    settings.aug_value_rando = 100;
}

simulated function TutorialDisableRandomization(bool enableSomeRando)
{
    // a little bit of safe rando just to get a taste?
    if(!enableSomeRando) {
        settings.swapitems = 0;
        settings.swapcontainers = 0;
        settings.deviceshackable = 0;
        settings.doorsmode = 0;
        settings.doorsdestructible = 0;
        settings.doorspickable = 0;
    }

    settings.keysrando = 0;
    settings.speedlevel = 0;
    settings.startinglocations = 0;
    settings.goals = 0;
    settings.infodevices = 0;
    //settings.merchants = 0;
    settings.augcans = 0;

    settings.dancingpercent = 50;
    settings.medbots = -1;
    settings.repairbots = -1;

    /*settings.medbotuses = 20;
    settings.repairbotuses = 20;
    settings.medbotcooldowns = 1;
    settings.repairbotcooldowns = 1;
    settings.medbotamount = 1;
    settings.repairbotamount = 1;*/

    settings.enemiesrandomized = 0;
    settings.hiddenenemiesrandomized = settings.enemiesrandomized;
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
}

function NewGamePlusVal(out int val, float curve, float exp)
{
    if(val > 0) {
        val = val * pow(curve, exp);// int *= float doesn't give as good accuracy as int = int*float
        if(val <= 0) val = 1;
    }
}

function NewGamePlus()
{
    local #var(PlayerPawn) p;
    local DataStorage ds;
    local DXRSkills skills;
    local DXRWeapons weapons;
    local DXRAugmentations augs;
    local int i;
    local float exp;

    if( flagsversion == 0 ) {
        warning("NewGamePlus() flagsversion == 0");
        LoadFlags();
    }
    p = player();

    info("NewGamePlus()");
    seed++;
    dxr.seed = seed;
    NewPlaythroughId();
    ds = class'DataStorage'.static.GetObj(dxr);
    if( ds != None ) ds.playthrough_id = playthrough_id;
    newgameplus_loops++;
    exp = 1;

    // always enable maxrando when doing NG+?
    maxrando = 1;
    if(maxrando > 0) {
        // rollback settings to the default for the current difficulty
        // we only want to do this on maxrando because we want to retain the user's custom choices
        settings = difficulty_settings[difficulty];
        ExecMaxRando();
        // increase difficulty on each flag like exp = newgameplus_loops; x *= 1.2 ^ exp;
        exp = newgameplus_loops;
    }

    SetGlobalSeed("NewGamePlus");
    p.CombatDifficulty *= 1.3;
    NewGamePlusVal(settings.minskill, 1.2, exp);
    NewGamePlusVal(settings.minskill, 1.2, exp);
    NewGamePlusVal(settings.maxskill, 1.2, exp);
    NewGamePlusVal(settings.enemiesrandomized, 1.2, exp);
    NewGamePlusVal(settings.hiddenenemiesrandomized, 1.2, exp);
    NewGamePlusVal(settings.ammo, 0.9, exp);
    NewGamePlusVal(settings.medkits, 0.8, exp);
    NewGamePlusVal(settings.multitools, 0.8, exp);
    NewGamePlusVal(settings.lockpicks, 0.8, exp);
    NewGamePlusVal(settings.biocells, 0.8, exp);
    NewGamePlusVal(settings.medbots, 0.8, exp);
    NewGamePlusVal(settings.repairbots, 0.8, exp);
    NewGamePlusVal(settings.turrets_add, 1.3, exp);
    NewGamePlusVal(settings.merchants, 0.9, exp);

    if (p.KeyRing != None)
    {
        p.KeyRing.RemoveAllKeys();
        if ((Role == ROLE_Authority) && (Level.NetMode != NM_Standalone))
        {
            p.KeyRing.ClientRemoveAllKeys();
        }
    }
    p.DeleteAllNotes();
    p.DeleteAllGoals();
    p.ResetConversationHistory();
    p.SetInHandPending(None);
    p.SetInHand(None);
    p.bInHandTransition = False;
    p.RestoreAllHealth();

    skills = DXRSkills(dxr.FindModule(class'DXRSkills'));
    if( skills != None ) {
        for(i=0; i<5; i++)
            skills.DowngradeRandomSkill(p);
        p.SkillPointsAvail /= 2;
    }
    else p.SkillPointsAvail = 0;

    augs = DXRAugmentations(dxr.FindModule(class'DXRAugmentations'));
    if( augs != None )
        augs.RemoveRandomAug(p);

    weapons = DXRWeapons(dxr.FindModule(class'DXRWeapons'));
    if( weapons != None )
        weapons.RemoveRandomWeapon(p);

    info("NewGamePlus() deleting all flags");
    f.DeleteAllFlags();
    DeusExRootWindow(p.rootWindow).ResetFlags();
    info("NewGamePlus() deleted all flags");
    SaveFlags();
    p.bStartNewGameAfterIntro = true;
    class'PlayerDataItem'.static.ResetData(p);
    Level.Game.SendPlayer(p, "00_intro");
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
    testfloatrange( pow(9,4), 9*9*9*9, 0.001, "pow");
    testfloatrange( pow(5.7,3), 5.7*5.7*5.7, 0.001, "pow");

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
