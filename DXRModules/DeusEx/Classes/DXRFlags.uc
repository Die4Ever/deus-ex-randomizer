class DXRFlags extends DXRBase transient;

var transient FlagBase f;

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
    var int doorsmode, doorspickable, doorsdestructible, deviceshackable, passwordsrandomized;//could be bools, but int is more flexible, especially so I don't have to change the flag type
    var int enemiesrandomized, enemyrespawn, infodevices;
    var int dancingpercent;
    var int skills_disable_downgrades, skills_reroll_missions, skills_independent_levels;
    var int startinglocations, goals, equipment;//equipment is a multiplier on how many items you get?
    var int medbots, repairbots;//there are 90 levels in the game, so 10% means approximately 9 medbots and 9 repairbots for the whole game, I think the vanilla game has 12 medbots, but they're also placed in smart locations so we might want to give more than that for Normal difficulty
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
        f, seed, playthrough_id, flagsversion, gamemode, loadout, brightness, newgameplus_loops,
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
    f = None;
    dxr.flagbase = None;
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
    dxr.CrcInit();
    seed = dxr.Crc( Rand(MaxInt) @ (FRand()*1000000) @ (Level.TimeSeconds*1000) );
    seed = abs(seed) % 1000000;
    dxr.seed = seed;
}

#ifdef hx
function HXRollSeed()
{
    difficulty = Level.Game.Difficulty;
    settings = difficulty_settings[difficulty];
    playthrough_id = class'DataStorage'.static._SystemTime(Level);
    if( next_seed != 0 ) {
        seed = next_seed;
        dxr.seed = seed;
        next_seed = 0;
    }
    else {
        RollSeed();
    }
    SaveConfig();
}
#endif

function InitDefaults()
{
    InitVersion();

    seed = 0;
    playthrough_id = class'DataStorage'.static._SystemTime(Level);
    if( dxr != None ) RollSeed();
    gamemode = 0;
    loadout = 0;
    brightness = 20;
    autosave = 2;
    crowdcontrol = 0;
    newgameplus_loops = 0;
    codes_mode = 2;

#ifdef hx
    difficulty = 1;
#else
    difficulty = 2;
#endif
    settings = difficulty_settings[difficulty];
}

simulated static function CurrentVersion(optional out int major, optional out int minor, optional out int patch, optional out int build)
{
    major=1;
    minor=6;
    patch=4;
    build=2;//build can't be higher than 99
}

simulated static function string VersionString(optional bool full)
{
    local int major,minor,patch,build;
    CurrentVersion(major,minor,patch,build);
    return VersionToString(major, minor, patch, build, full) $ " Alpha";
}

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(1,6,3,2) ) {
        // setup default difficulties
        i=0;
#ifndef hx
        difficulty_names[i] = "Super Easy QA";
        difficulty_settings[i].CombatDifficulty = 0;
        difficulty_settings[i].doorsmode = alldoors + doormutuallyinclusive;
        difficulty_settings[i].doorsdestructible = 100;
        difficulty_settings[i].doorspickable = 100;
        difficulty_settings[i].keysrando = 4;
        difficulty_settings[i].deviceshackable = 100;
        difficulty_settings[i].passwordsrandomized = 100;
        difficulty_settings[i].infodevices = 100;
        difficulty_settings[i].enemiesrandomized = 20;
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
        difficulty_settings[i].turrets_move = 100;
        difficulty_settings[i].turrets_add = 50;
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
#endif

        difficulty_names[i] = "Easy";
#ifndef hx
        difficulty_settings[i].CombatDifficulty = 1;
#endif
        difficulty_settings[i].doorsmode = undefeatabledoors + doormutuallyinclusive;
        difficulty_settings[i].doorsdestructible = 100;
        difficulty_settings[i].doorspickable = 100;
        difficulty_settings[i].keysrando = 4;
        difficulty_settings[i].deviceshackable = 100;
        difficulty_settings[i].passwordsrandomized = 100;
        difficulty_settings[i].infodevices = 100;
        difficulty_settings[i].enemiesrandomized = 20;
        difficulty_settings[i].enemies_nonhumans = 60;
        difficulty_settings[i].enemyrespawn = 0;
        difficulty_settings[i].skills_disable_downgrades = 0;
        difficulty_settings[i].skills_reroll_missions = 5;
        difficulty_settings[i].skills_independent_levels = 0;
        difficulty_settings[i].banned_skills = 3;
        difficulty_settings[i].banned_skill_levels = 3;
        difficulty_settings[i].minskill = 25;
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
        difficulty_names[i] = "Normal";
        difficulty_settings[i].CombatDifficulty = 1.5;
#endif
        difficulty_settings[i].doorsmode = undefeatabledoors + doormutuallyexclusive;
        difficulty_settings[i].doorsdestructible = 50;
        difficulty_settings[i].doorspickable = 50;
        difficulty_settings[i].keysrando = 4;
        difficulty_settings[i].deviceshackable = 100;
        difficulty_settings[i].passwordsrandomized = 100;
        difficulty_settings[i].infodevices = 100;
        difficulty_settings[i].enemiesrandomized = 30;
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
        difficulty_settings[i].CombatDifficulty = 2;
#endif
        difficulty_settings[i].doorsmode = undefeatabledoors + doormutuallyexclusive;
        difficulty_settings[i].doorsdestructible = 25;
        difficulty_settings[i].doorspickable = 25;
        difficulty_settings[i].keysrando = 4;
        difficulty_settings[i].deviceshackable = 50;
        difficulty_settings[i].passwordsrandomized = 100;
        difficulty_settings[i].infodevices = 100;
        difficulty_settings[i].enemiesrandomized = 40;
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
        difficulty_settings[i].turrets_move = 50;
        difficulty_settings[i].turrets_add = 120;
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

        difficulty_names[i] = "DeusEx";
#ifndef hx
        difficulty_names[i] = "Extreme";
        difficulty_settings[i].CombatDifficulty = 3;
#endif
        difficulty_settings[i].doorsmode = undefeatabledoors + doormutuallyexclusive;
        difficulty_settings[i].doorsdestructible = 25;
        difficulty_settings[i].doorspickable = 25;
        difficulty_settings[i].keysrando = 4;
        difficulty_settings[i].deviceshackable = 50;
        difficulty_settings[i].passwordsrandomized = 100;
        difficulty_settings[i].infodevices = 100;
        difficulty_settings[i].enemiesrandomized = 50;
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
        difficulty_settings[i].turrets_move = 50;
        difficulty_settings[i].turrets_add = 200;
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

    BindFlags(false);

    if(stored_version < flagsversion ) {
        info("upgraded flags from "$stored_version$" to "$flagsversion);
        SaveFlags();
    } else if (stored_version > flagsversion ) {
        warning("downgraded flags from "$stored_version$" to "$flagsversion);
        SaveFlags();
    }

    LogFlags("LoadFlags");
    if( p != None )
        p.ClientMessage("Deus Ex Randomizer " $ VersionString() $ " seed: " $ seed $ ", difficulty: " $ p.CombatDifficulty $ ", New Game+ Loops: "$newgameplus_loops$", flags: " $ FlagsHash() );
    SetTimer(1.0, True);

    ds = class'DataStorage'.static.GetObj(p);
    if( ds != None ) ds.playthrough_id = playthrough_id;
}

simulated function BindFlags(bool writing)
{
    if( FlagInt('Rando_seed', seed, writing) )
        dxr.seed = seed;

    FlagInt('Rando_autosave', autosave, writing);
    FlagInt('Rando_brightness', brightness, writing);
    FlagInt('Rando_crowdcontrol', crowdcontrol, writing);
    FlagInt('Rando_loadout', loadout, writing);
    FlagInt('Rando_codes_mode', codes_mode, writing);
    FlagInt('Rando_newgameplus_loops', newgameplus_loops, writing);
    FlagInt('Rando_playthrough_id', playthrough_id, writing);
    FlagInt('Rando_gamemode', gamemode, writing);

    if( FlagInt('Rando_difficulty', difficulty, writing) ) {
        settings = difficulty_settings[difficulty];
    }

    FlagInt('Rando_minskill', settings.minskill, writing);
    FlagInt('Rando_maxskill', settings.maxskill, writing);
    FlagInt('Rando_ammo', settings.ammo, writing);
    FlagInt('Rando_multitools', settings.multitools, writing);
    FlagInt('Rando_lockpicks', settings.lockpicks, writing);
    FlagInt('Rando_biocells', settings.biocells, writing);
    FlagInt('Rando_speedlevel', settings.speedlevel, writing);
    FlagInt('Rando_keys', settings.keysrando, writing);
    FlagInt('Rando_doorspickable', settings.doorspickable, writing);
    FlagInt('Rando_doorsdestructible', settings.doorsdestructible, writing);
    FlagInt('Rando_deviceshackable', settings.deviceshackable, writing);
    FlagInt('Rando_passwordsrandomized', settings.passwordsrandomized, writing);

    FlagInt('Rando_medkits', settings.medkits, writing);
    FlagInt('Rando_enemiesrandomized', settings.enemiesrandomized, writing);
    FlagInt('Rando_infodevices', settings.infodevices, writing);
    FlagInt('Rando_dancingpercent', settings.dancingpercent, writing);
    FlagInt('Rando_doorsmode', settings.doorsmode, writing);
    FlagInt('Rando_enemyrespawn', settings.enemyrespawn, writing);

    FlagInt('Rando_skills_disable_downgrades', settings.skills_disable_downgrades, writing);
    FlagInt('Rando_skills_reroll_missions', settings.skills_reroll_missions, writing);
    FlagInt('Rando_skills_independent_levels', settings.skills_independent_levels, writing);
    FlagInt('Rando_startinglocations', settings.startinglocations, writing);
    FlagInt('Rando_goals', settings.goals, writing);
    FlagInt('Rando_equipment', settings.equipment, writing);
    FlagInt('Rando_medbots', settings.medbots, writing);
    FlagInt('Rando_repairbots', settings.repairbots, writing);
    FlagInt('Rando_turrets_move', settings.turrets_move, writing);
    FlagInt('Rando_turrets_add', settings.turrets_add, writing);

    FlagInt('Rando_merchants', settings.merchants, writing);
    FlagInt('Rando_banned_skills', settings.banned_skills, writing);
    FlagInt('Rando_banned_skill_level', settings.banned_skill_levels, writing);
    FlagInt('Rando_enemies_nonhumans', settings.enemies_nonhumans, writing);

    FlagInt('Rando_swapitems', settings.swapitems, writing);
    FlagInt('Rando_swapcontainers', settings.swapcontainers, writing);
    FlagInt('Rando_augcans', settings.augcans, writing);
    FlagInt('Rando_aug_value_rando', settings.aug_value_rando, writing);
    FlagInt('Rando_skill_value_rando', settings.skill_value_rando, writing);
    FlagInt('Rando_min_weapon_dmg', settings.min_weapon_dmg, writing);
    FlagInt('Rando_max_weapon_dmg', settings.max_weapon_dmg, writing);
    FlagInt('Rando_min_weapon_shottime', settings.min_weapon_shottime, writing);
    FlagInt('Rando_max_weapon_shottime', settings.max_weapon_shottime, writing);
}

// returns true is read was successful
simulated function bool FlagInt(name flagname, out int val, bool writing)
{
    if( writing ) {
        f.SetInt(flagname, val,, 999);
        return false;
    }

    if( f.CheckFlag(flagname, FLAG_Int) )
    {
        val = f.GetInt(flagname);
        return true;
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
    BindFlags(true);
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

#ifdef hx
    ds = class'DataStorage'.static.GetObj(self);
#else
    ds = class'DataStorage'.static.GetObj(p);
#endif
    if( ds != None ) ds.playthrough_id = playthrough_id;

    LogFlags("LoadNoFlags");
    if( p != None )
        p.ClientMessage("Deus Ex Randomizer " $ VersionString() $ " seed: " $ seed $ ", difficulty: " $ CombatDifficulty $ ", New Game+ Loops: "$newgameplus_loops$", flags: " $ FlagsHash() );
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
    info(prefix$" "$Self.Class$" - " $ VersionString() $ ", " $ "seed: "$seed$ ", flagshash: " $ FlagsHash() $ ", playthrough_id: "$playthrough_id$", " $ StringifyFlags() );
    info(prefix$" - " $ StringifyDifficultySettings(settings) );
}

simulated function AddDXRCredits(CreditsWindow cw) 
{
    cw.PrintHeader("DXRFlags");
    
    cw.PrintText(VersionString() $ ", " $ "seed: "$seed$", flagshash: " $ FlagsHash() $ ", playthrough_id: "$playthrough_id);
    cw.PrintText(StringifyFlags());
    cw.PrintText(StringifyDifficultySettings(settings));
    cw.PrintLn();
}

simulated function string StringifyFlags()
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
    return "flagsversion: "$flagsversion$", gamemode: "$gamemode $ ", difficulty: " $ CombatDifficulty $ ", loadout: "$loadout
        $ ", brightness: "$brightness $ ", newgameplus_loops: "$newgameplus_loops
        $ ", autosave: "$autosave$", crowdcontrol: "$crowdcontrol$", codes_mode: "$codes_mode;
}

simulated function string StringifyDifficultySettings( FlagsSettings s )
{
    return "ammo: " $ s.ammo $ ", merchants: "$ s.merchants
        $ ", minskill: "$s.minskill$", maxskill: "$s.maxskill$", skills_disable_downgrades: " $ s.skills_disable_downgrades
        $ ", skills_reroll_missions: " $ s.skills_reroll_missions $ ", skills_independent_levels: " $ s.skills_independent_levels
        $ ", multitools: "$s.multitools$", lockpicks: "$s.lockpicks$", biocells: "$s.biocells$", medkits: "$s.medkits
        $ ", speedlevel: "$s.speedlevel$", keysrando: "$s.keysrando$", doorsmode: "$s.doorsmode$", doorspickable: "$s.doorspickable
        $ ", doorsdestructible: "$s.doorsdestructible$", deviceshackable: "$s.deviceshackable$", passwordsrandomized: "$s.passwordsrandomized
        $ ", enemiesrandomized: "$s.enemiesrandomized$", enemyrespawn: "$s.enemyrespawn$", infodevices: "$s.infodevices
        $ ", startinglocations: "$s.startinglocations$", goals: "$s.goals$", equipment: "$s.equipment$", dancingpercent: "$s.dancingpercent
        $ ", medbots: "$s.medbots$", repairbots: "$s.repairbots$", turrets_move: "$s.turrets_move$", turrets_add: "$s.turrets_add
        $ ", banned_skills: "$s.banned_skills$", banned_skill_levels: "$s.banned_skill_levels$ ", enemies_nonhumans: "$s.enemies_nonhumans
        $ ", swapitems: "$s.swapitems$", swapcontainers: "$s.swapcontainers$", augcans: "$s.augcans
        $ ", aug_value_rando: "$s.aug_value_rando$", skill_value_rando: "$s.skill_value_rando
        $ ", min_weapon_dmg: "$s.min_weapon_dmg$", max_weapon_dmg: "$s.max_weapon_dmg
        $ ", min_weapon_shottime: "$s.min_weapon_shottime$", max_weapon_shottime: "$s.max_weapon_shottime;
}

simulated function int FlagsHash()
{
    local int hash;
    hash = dxr.Crc(StringifyFlags());
    hash += dxr.Crc(StringifyDifficultySettings(settings));
    hash = int(abs(hash));
    return hash;
}

function InitVersion()
{
    flagsversion = VersionNumber();
}

simulated static function int VersionToInt(int major, int minor, int patch, int build)
{
    local int ret;
    ret = major*10000+minor*100+patch;
    if( ret <= 10400 ) return minor;//v1.4 and earlier
    if( ret > 10508 ) {
        ret = major*1000000+minor*10000+patch*100+build;
    }
    return ret;
}

simulated static function string VersionToString(int major, int minor, int patch, optional int build, optional bool full)
{
    if( full )
        return "v" $ major $"."$ minor $"."$ patch $"."$ build;
    else if( patch == 0 )
        return "v" $ major $"."$ minor;
    else
        return "v" $ major $"."$ minor $"."$ patch;
}

simulated static function int VersionNumber()
{
    local int major,minor,patch,build;
    CurrentVersion(major,minor,patch,build);
    return VersionToInt(major, minor, patch, build);
}

simulated static function bool VersionOlderThan(int config_version, int major, int minor, int patch, int build)
{
    return config_version < VersionToInt(major, minor, patch, build);
}

simulated function MaxRando()
{
    //should have a chance to make some skills completely unattainable, like 999999 cost? would this also have to be an option in the GUI or can it be exclusive to MaxRando?
}

function NewGamePlus()
{
    local #var PlayerPawn  p;
    local DataStorage ds;
    local DXRSkills skills;
    local DXRWeapons weapons;
    local DXRAugmentations augs;
    local int i;

    if( flagsversion == 0 ) {
        warning("NewGamePlus() flagsversion == 0");
        LoadFlags();
    }
    p = player();

    info("NewGamePlus()");
    seed++;
    dxr.seed = seed;
    playthrough_id = class'DataStorage'.static._SystemTime(Level);
    ds = class'DataStorage'.static.GetObj(p);
    if( ds != None ) ds.playthrough_id = playthrough_id;
    newgameplus_loops++;
    p.CombatDifficulty *= 1.3;
    settings.minskill = settings.minskill*1.2;// int *= float doesn't give as good accuracy as int = int*float
    settings.maxskill = settings.maxskill*1.2;
    settings.enemiesrandomized = settings.enemiesrandomized*1.2;
    settings.ammo = settings.ammo*0.9;
    settings.medkits = settings.medkits*0.8;
    settings.multitools = settings.multitools*0.8;
    settings.lockpicks = settings.lockpicks*0.8;
    settings.biocells = settings.biocells*0.8;
    settings.medbots = settings.medbots*0.8;
    settings.repairbots = settings.repairbots*0.8;
    settings.turrets_add = settings.turrets_add*1.3;
    settings.merchants = settings.merchants*0.9;

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
}

function ExtendedTests()
{
    local int i;
    Super.ExtendedTests();

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
