class DXRFlags extends DXRBase transient;

var transient FlagBase f;

const Reading = 1;
const Writing = 2;
const Stringifying = 3;
const Printing = 4;
const Credits = 5;

//rando flags
#ifdef hx
var #var flagvarprefix  int next_seed;
#endif

var #var flagvarprefix  int seed, playthrough_id;
var #var flagvarprefix  int flagsversion;//if you load an old game with a newer version of the randomizer, we'll need to set defaults for new flags

var #var flagvarprefix  int gamemode;//0=original, 1=rearranged, 2=horde, 3=kill bob page, 4=stick to the prod, 5=stick to the prod +, 6=how about some soy food, 7=max rando
var #var flagvarprefix  int loadout;//0=none, 1=stick with the prod, 2=stick with the prod plus
var #var flagvarprefix  int brightness;
var #var flagvarprefix  int autosave;//0=off, 1=first time entering level, 2=every loading screen, 3=autosave-only
var #var flagvarprefix  int maxrando;
var #var flagvarprefix  int newgameplus_loops;
var #var flagvarprefix  int crowdcontrol;
var #var flagvarprefix  int codes_mode;

var #var flagvarprefix  int difficulty;// save which difficulty setting the game was started with, for nicer upgrading

struct FlagsSettings {
#ifndef hx
    var float CombatDifficulty;
#endif
    var int minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
    var int keysrando;//0=off, 1=dumb, 2=on (old smart), 3=copies, 4=smart (v1.3), 5=path finding?
    var int keys_containers, infodevices_containers;
    var int doorsmode, doorspickable, doorsdestructible, deviceshackable, passwordsrandomized;//could be bools, but int is more flexible, especially so I don't have to change the flag type
    var int enemiesrandomized, hiddenenemiesrandomized, enemiesshuffled, enemyrespawn, infodevices;
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
};

#ifdef hx
var config string difficulty_names[4];// Easy, Medium, Hard, DeusEx
var config FlagsSettings difficulty_settings[4];
#else
var config string difficulty_names[5];// Super Easy QA, Easy, Normal, Hard, Extreme
var config FlagsSettings difficulty_settings[5];
#endif

var #var flagvarprefix  FlagsSettings settings;

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
        f, seed, playthrough_id, flagsversion, gamemode, loadout, brightness, maxrando, newgameplus_loops,
        settings,
        codes_mode,
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

simulated function bool CheckLogin(#var PlayerPawn  p)
{
    return flags_loaded && Super.CheckLogin(p);
}

function PreFirstEntry()
{
    Super.PreFirstEntry();
    Timer();
    LogFlags("PreFirstEntry "$dxr.localURL);
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
    brightness = 15;
    autosave = 2;
    crowdcontrol = 0;
    newgameplus_loops = 0;
    codes_mode = 2;

#ifdef hx
    difficulty = 1;
#else
    difficulty = 2;
#endif
#ifndef vanilla
    codes_mode = 0;
    autosave = 0;
#endif
    settings = difficulty_settings[difficulty];
}

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(1,8,2,2) ) {
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
        difficulty_settings[i].enemies_nonhumans = 60;
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
        difficulty_settings[i].medbotuses = 0;
        difficulty_settings[i].repairbotuses = 0;
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
        i++;
#endif

        difficulty_names[i] = "Easy";
#ifndef hx
        difficulty_names[i] = "Normal";
        difficulty_settings[i].CombatDifficulty = 1;
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
        difficulty_settings[i].enemies_nonhumans = 60;
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
        difficulty_settings[i].medbotuses = 0;
        difficulty_settings[i].repairbotuses = 0;
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
        i++;

        difficulty_names[i] = "Medium";
#ifndef hx
        difficulty_names[i] = "Hard";
        difficulty_settings[i].CombatDifficulty = 1.5;
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
        difficulty_settings[i].medbotuses = 0;
        difficulty_settings[i].repairbotuses = 0;
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
        i++;

        difficulty_names[i] = "Hard";
#ifndef hx
        difficulty_names[i] = "Extreme";
        difficulty_settings[i].CombatDifficulty = 2;
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
        difficulty_settings[i].enemies_nonhumans = 60;
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
        difficulty_settings[i].lockpicks = 50;
        difficulty_settings[i].multitools = 50;
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
        difficulty_settings[i].turrets_add = 120;
        difficulty_settings[i].merchants = 30;
        difficulty_settings[i].dancingpercent = 25;
        difficulty_settings[i].swapitems = 100;
        difficulty_settings[i].swapcontainers = 100;
        difficulty_settings[i].augcans = 100;
        difficulty_settings[i].aug_value_rando = 100;
        difficulty_settings[i].skill_value_rando = 100;
        difficulty_settings[i].min_weapon_dmg = 75;
        difficulty_settings[i].max_weapon_dmg = 175;
        difficulty_settings[i].min_weapon_shottime = 50;
        difficulty_settings[i].max_weapon_shottime = 150;
        i++;

        difficulty_names[i] = "DeusEx";
#ifndef hx
        difficulty_names[i] = "Impossible";
        difficulty_settings[i].CombatDifficulty = 2.5;
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
        difficulty_settings[i].enemies_nonhumans = 60;
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
        difficulty_settings[i].lockpicks = 30;
        difficulty_settings[i].multitools = 30;
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
        difficulty_settings[i].turrets_add = 200;
        difficulty_settings[i].merchants = 30;
        difficulty_settings[i].dancingpercent = 25;
        difficulty_settings[i].swapitems = 100;
        difficulty_settings[i].swapcontainers = 100;
        difficulty_settings[i].augcans = 100;
        difficulty_settings[i].aug_value_rando = 100;
        difficulty_settings[i].skill_value_rando = 100;
        difficulty_settings[i].min_weapon_dmg = 100;
        difficulty_settings[i].max_weapon_dmg = 200;
        difficulty_settings[i].min_weapon_shottime = 50;
        difficulty_settings[i].max_weapon_shottime = 150;
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

simulated function LoadFlags()
{
    //do flags binding
    local DataStorage ds;
    local #var PlayerPawn  p;

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
        p.ClientMessage("Deus Ex Randomizer " $ VersionString() $ " seed: " $ seed $ ", difficulty: " $ p.CombatDifficulty
#ifdef injections
            $ ", New Game+ Loops: "$newgameplus_loops
#endif
            $ ", flags: " $ FlagsHash() );
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
    FlagInt('Rando_brightness', brightness, mode, str);
    FlagInt('Rando_crowdcontrol', crowdcontrol, mode, str);
    FlagInt('Rando_loadout', loadout, mode, str);
    FlagInt('Rando_codes_mode', codes_mode, mode, str);
    FlagInt('Rando_newgameplus_loops', newgameplus_loops, mode, str);
    FlagInt('Rando_playthrough_id', playthrough_id, mode, str);
    FlagInt('Rando_gamemode', gamemode, mode, str);

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

    FlagInt('Rando_swapitems', settings.swapitems, mode, str);
    FlagInt('Rando_swapcontainers', settings.swapcontainers, mode, str);
    FlagInt('Rando_augcans', settings.augcans, mode, str);
    FlagInt('Rando_aug_value_rando', settings.aug_value_rando, mode, str);
    FlagInt('Rando_skill_value_rando', settings.skill_value_rando, mode, str);
    FlagInt('Rando_min_weapon_dmg', settings.min_weapon_dmg, mode, str);
    FlagInt('Rando_max_weapon_dmg', settings.max_weapon_dmg, mode, str);
    FlagInt('Rando_min_weapon_shottime', settings.min_weapon_shottime, mode, str);
    FlagInt('Rando_max_weapon_shottime', settings.max_weapon_shottime, mode, str);

    return str;
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
    local #var PlayerPawn  p;
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
        p.ClientMessage("Deus Ex Randomizer " $ VersionString() $ " seed: " $ seed $ ", difficulty: " $ CombatDifficulty
#ifdef injections
            $ ", New Game+ Loops: "$newgameplus_loops
#endif
            $ ", flags: " $ FlagsHash() );
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
        local #var PlayerPawn  p;
#ifdef hx
    CombatDifficulty = HXGameInfo(Level.Game).CombatDifficulty;
#else
    p = player();
    if( p != None )
        CombatDifficulty = p.CombatDifficulty;
#endif
    if(mode == 0)
        mode = Stringifying;
    return BindFlags(mode, "flagsversion: "$flagsversion$", difficulty: " $ CombatDifficulty);
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
    // change the flags normally configurable on the Advanced Settings page, but try to keep the difficulty balanced
    // also make sure to randomize the doors mode and stuff
    info("ExecMaxRando()");
    SetGlobalSeed("ExecMaxRando");
    maxrando = 1;

    MaxRandoVal(settings.merchants);
    MaxRandoVal(settings.medbots);
    MaxRandoVal(settings.repairbots);

    settings.medbotuses = rng(7) + 1;
    settings.repairbotuses = rng(7) + 1;

    settings.medbotcooldowns = int(rngb()) + 1;// 1 or 2
    settings.repairbotcooldowns = int(rngb()) + 1;
    settings.medbotamount = int(rngb()) + 1;
    settings.repairbotamount = int(rngb()) + 1;

    settings.doorsmode = undefeatabledoors + doorindependent;
    settings.doorsdestructible = rng(100);
    settings.doorspickable = rng(100);

    settings.deviceshackable = rng(100);
    MaxRandoVal(settings.enemiesrandomized);
    settings.hiddenenemiesrandomized = settings.enemiesrandomized;
    settings.enemiesshuffled = 100;
    MaxRandoVal(settings.enemies_nonhumans);
    if(rngb())
        settings.enemyrespawn = rng(120) + 120;

    MaxRandoVal(settings.turrets_move);
    MaxRandoVal(settings.turrets_add);
    MaxRandoVal(settings.skills_reroll_missions);
    settings.skills_independent_levels = int(rngb());
    MaxRandoValPair(settings.minskill, settings.maxskill);
    MaxRandoVal(settings.banned_skills);
    MaxRandoVal(settings.banned_skill_levels);
    MaxRandoVal(settings.skill_value_rando);

    MaxRandoVal(settings.ammo);
    MaxRandoVal(settings.multitools);
    MaxRandoVal(settings.lockpicks);
    MaxRandoVal(settings.biocells);
    MaxRandoVal(settings.medkits);
    settings.equipment += int(rngb());
    MaxRandoValPair(settings.min_weapon_dmg, settings.max_weapon_dmg);
    MaxRandoValPair(settings.min_weapon_shottime, settings.max_weapon_shottime);
    MaxRandoVal(settings.aug_value_rando);
}

function NewGamePlus()
{
    local #var PlayerPawn  p;
    local DataStorage ds;
    local DXRSkills skills;
    local DXRWeapons weapons;
    local DXRAugmentations augs;
    local int i, exp;

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

    if(maxrando > 0) {
        // rollback settings to the default for the current difficulty
        settings = difficulty_settings[difficulty];
        // apply max rando
        ExecMaxRando();
        // increase difficulty on each flag like exp = newgameplus_loops; x *= 1.2 ^ exp;
        exp = newgameplus_loops;
    }

    SetGlobalSeed("NewGamePlus");

    p.CombatDifficulty *= pow(1.3, exp);
    settings.minskill = settings.minskill * pow(1.2, exp);// int *= float doesn't give as good accuracy as int = int*float
    settings.maxskill = settings.maxskill * pow(1.2, exp);
    settings.enemiesrandomized = settings.enemiesrandomized * pow(1.2, exp);
    settings.hiddenenemiesrandomized = settings.hiddenenemiesrandomized * pow(1.2, exp);
    settings.ammo = settings.ammo * pow(0.9, exp);
    settings.medkits = settings.medkits * pow(0.8, exp);
    settings.multitools = settings.multitools * pow(0.8, exp);
    settings.lockpicks = settings.lockpicks * pow(0.8, exp);
    settings.biocells = settings.biocells * pow(0.8, exp);
    settings.medbots = settings.medbots * pow(0.8, exp);
    settings.repairbots = settings.repairbots * pow(0.8, exp);
    settings.turrets_add = settings.turrets_add * pow(1.3, exp);
    settings.merchants = settings.merchants * pow(0.9, exp);

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
    testbool( chance_single(50), false, "chance_single(50) 3");
    testbool( chance_single(50), false, "chance_single(50) 4");

    teststring( FloatToString(0.5555, 1), "0.6", "FloatToString 1");
    teststring( FloatToString(0.5454999, 4), "0.5455", "FloatToString 2");
    teststring( FloatToString(0.5455, 2), "0.55", "FloatToString 3");

    testbool( #defined debug, false, "debug is disabled");
}

function ExtendedTests()
{
    local int i, total;
    local float f;
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
    testint(total, 4988, "rngb()");

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
        teststring( ds.GetConfigKey(i), "", "GetConfigKey("$i$") cleared after EndPlaythrough()");
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
