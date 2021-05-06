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
var #var flagvarprefix  int brightness, minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
var #var flagvarprefix  int keysrando;//0=off, 1=dumb, 2=on (old smart), 3=copies, 4=smart (v1.3), 5=path finding?
var #var flagvarprefix  int doorsmode, doorspickable, doorsdestructible, deviceshackable, passwordsrandomized, gibsdropkeys;//could be bools, but int is more flexible, especially so I don't have to change the flag type
var #var flagvarprefix  int autosave;//0=off, 1=first time entering level, 2=every loading screen, 3=autosave-only
var #var flagvarprefix  int removeinvisiblewalls, enemiesrandomized, enemyrespawn, infodevices;
var #var flagvarprefix  int dancingpercent;
var #var flagvarprefix  int skills_disable_downgrades, skills_reroll_missions, skills_independent_levels;
var #var flagvarprefix  int startinglocations, goals, equipment;//equipment is a multiplier on how many items you get?
var #var flagvarprefix  int medbots, repairbots;//there are 90 levels in the game, so 10% means approximately 9 medbots and 9 repairbots for the whole game, I think the vanilla game has 12 medbots, but they're also placed in smart locations so we might want to give more than that for Normal difficulty
var #var flagvarprefix  int turrets_move, turrets_add;
var #var flagvarprefix  int crowdcontrol;
var #var flagvarprefix  int newgameplus_loops;
var #var flagvarprefix  int merchants;
var #var flagvarprefix  int banned_skills, banned_skill_levels, enemies_nonhumans;

var #var flagvarprefix  int undefeatabledoors, alldoors, keyonlydoors, highlightabledoors, doormutuallyinclusive, doorindependent, doormutuallyexclusive;
var #var flagvarprefix  int codes_mode;

var bool flags_loaded;

replication
{
    reliable if( Role==ROLE_Authority )
        f, seed, playthrough_id, flagsversion, gamemode, loadout, brightness, minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel,
        keysrando, doorsmode, doorspickable, doorsdestructible, deviceshackable, passwordsrandomized, gibsdropkeys, autosave,
        removeinvisiblewalls, enemiesrandomized, enemyrespawn, infodevices, dancingpercent, skills_disable_downgrades, skills_reroll_missions, skills_independent_levels,
        startinglocations, goals, equipment, medbots, repairbots, turrets_move, turrets_add, crowdcontrol, newgameplus_loops, merchants,
        banned_skills, banned_skill_levels, enemies_nonhumans,
        undefeatabledoors, alldoors, keyonlydoors, highlightabledoors, doormutuallyinclusive, doorindependent, doormutuallyexclusive,
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
    //CheckConfig();
    //dxr.CrcInit();

    undefeatabledoors = 1*256;
    alldoors = 2*256;
    keyonlydoors = 3*256;
    highlightabledoors = 4*256;
    doormutuallyinclusive = 1;
    doorindependent = 2;
    doormutuallyexclusive = 3;

    seed = 0;
    playthrough_id = class'DataStorage'.static._SystemTime(Level);
    if( dxr != None ) RollSeed();
    gamemode = 0;
    loadout = 0;
    brightness = 20;
    minskill = 25;
    maxskill = 300;
    ammo = 90;
    medkits = 90;
    multitools = 80;
    lockpicks = 80;
    biocells = 80;
    speedlevel = 1;
    keysrando = 4;
    doorsmode = keyonlydoors + doormutuallyexclusive;
    doorspickable = 50;
    doorsdestructible = 50;
    deviceshackable = 100;
    passwordsrandomized = 100;
    gibsdropkeys = 1;
    autosave = 2;
    removeinvisiblewalls = 0;
    enemiesrandomized = 25;
    enemyrespawn = 0;
    infodevices = 100;
    dancingpercent = 25;
    skills_disable_downgrades = 0;
    skills_reroll_missions = 0;
    skills_independent_levels = 0;
    startinglocations = 100;
    goals = 100;
    equipment = 1;
    medbots = 15;
    repairbots = 15;
    turrets_move = 50;
    turrets_add = 20;
    crowdcontrol = 0;
    newgameplus_loops = 0;
    merchants = 30;
    banned_skills = 5;
    banned_skill_levels = 5;
    enemies_nonhumans = 60;
    codes_mode = 2;
}

function CheckConfig()
{
    if( config_version < VersionToInt(1,5,6) ) {
#ifdef noflags
        InitDefaults();
#endif
    }
    Super.CheckConfig();
}

simulated function LoadFlags()
{
    //do flags binding
    local DataStorage ds;
    local int stored_version;
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

    if( stored_version >= 1 ) {
        seed = f.GetInt('Rando_seed');
        dxr.seed = seed;
        brightness = f.GetInt('Rando_brightness');
        minskill = f.GetInt('Rando_minskill');
        maxskill = f.GetInt('Rando_maxskill');
        ammo = f.GetInt('Rando_ammo');
        multitools = f.GetInt('Rando_multitools');
        lockpicks = f.GetInt('Rando_lockpicks');
        biocells = f.GetInt('Rando_biocells');
        speedlevel = f.GetInt('Rando_speedlevel');
        keysrando = f.GetInt('Rando_keys');
        doorspickable = f.GetInt('Rando_doorspickable');
        doorsdestructible = f.GetInt('Rando_doorsdestructible');
        deviceshackable = f.GetInt('Rando_deviceshackable');
        passwordsrandomized = f.GetInt('Rando_passwordsrandomized');
        gibsdropkeys = f.GetInt('Rando_gibsdropkeys');
    }
    if( stored_version >= 2 ) {
        medkits = f.GetInt('Rando_medkits');
    }
    if( stored_version >= 3 ) {
        autosave = f.GetInt('Rando_autosave');
        removeinvisiblewalls = f.GetInt('Rando_removeinvisiblewalls');
        enemiesrandomized = f.GetInt('Rando_enemiesrandomized');
        infodevices = f.GetInt('Rando_infodevices');
        dancingpercent = f.GetInt('Rando_dancingpercent');
    }
    if( stored_version >= 4 ) {
        doorsmode = f.GetInt('Rando_doorsmode');
        gamemode = f.GetInt('Rando_gamemode');
        enemyrespawn = f.GetInt('Rando_enemyrespawn');
    }
    if( stored_version >= VersionToInt(1,4,4) ) {
        skills_disable_downgrades = f.GetInt('Rando_skills_disable_downgrades');
        skills_reroll_missions = f.GetInt('Rando_skills_reroll_missions');
        skills_independent_levels = f.GetInt('Rando_skills_independent_levels');

        if( gamemode == 4 ) loadout = 1;
        if( gamemode == 5 ) loadout = 2;
    }
    if( stored_version >= VersionToInt(1,4,7) ) {
        loadout = f.GetInt('Rando_banneditems');
    }
    if( stored_version >= VersionToInt(1,4,9) ) {
        startinglocations = f.GetInt('Rando_startinglocations');
        goals = f.GetInt('Rando_goals');
        equipment = f.GetInt('Rando_equipment');
        medbots = f.GetInt('Rando_medbots');
        repairbots = f.GetInt('Rando_repairbots');
    }
    if( stored_version >= VersionToInt(1,5,0) ) {
        turrets_move = f.GetInt('Rando_turrets_move');
        turrets_add = f.GetInt('Rando_turrets_add');
        crowdcontrol = f.GetInt('Rando_crowdcontrol');
    }
    if( stored_version >= VersionToInt(1,5,1) ) {
        loadout = f.GetInt('Rando_loadout');
        newgameplus_loops = f.GetInt('Rando_newgameplus_loops');
    }
    if( stored_version >= VersionToInt(1,5,5) ) {
        playthrough_id = f.GetInt('Rando_playthrough_id');
    }
    if( stored_version >= VersionToInt(1,5,6) ) {
        merchants = f.GetInt('Rando_merchants');
        FlagInt('Rando_banned_skills', banned_skills);
        FlagInt('Rando_banned_skill_level', banned_skill_levels);
        FlagInt('Rando_enemies_nonhumans', enemies_nonhumans);
    }
    if( stored_version >= VersionToInt(1,5,7) ) {
        FlagInt('Rando_codes_mode', codes_mode);
    }

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

simulated function FlagInt(name flagname, out int val)
{
    if( f.CheckFlag(flagname, FLAG_Int) )
    {
        val = f.GetInt(flagname);
    }
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
    f.SetInt('Rando_seed', seed,, 999);
    dxr.seed = seed;

    f.SetInt('Rando_playthrough_id', playthrough_id,, 999);

    f.SetInt('Rando_version', flagsversion,, 999);
    f.SetInt('Rando_gamemode', gamemode,, 999);
    f.SetInt('Rando_loadout', loadout,, 999);
    f.SetInt('Rando_brightness', brightness,, 999);
    f.SetInt('Rando_minskill', minskill,, 999);
    f.SetInt('Rando_maxskill', maxskill,, 999);
    f.SetInt('Rando_ammo', ammo,, 999);
    f.SetInt('Rando_multitools', multitools,, 999);
    f.SetInt('Rando_lockpicks', lockpicks,, 999);
    f.SetInt('Rando_biocells', biocells,, 999);
    f.SetInt('Rando_medkits', medkits,, 999);
    f.SetInt('Rando_speedlevel', speedlevel,, 999);
    f.SetInt('Rando_keys', keysrando,, 999);
    f.SetInt('Rando_doorsmode', doorsmode,, 999);
    f.SetInt('Rando_doorspickable', doorspickable,, 999);
    f.SetInt('Rando_doorsdestructible', doorsdestructible,, 999);
    f.SetInt('Rando_deviceshackable', deviceshackable,, 999);
    f.SetInt('Rando_passwordsrandomized', passwordsrandomized,, 999);
    f.SetInt('Rando_gibsdropkeys', gibsdropkeys,, 999);
    f.SetInt('Rando_autosave', autosave,, 999);
    f.SetInt('Rando_removeinvisiblewalls', removeinvisiblewalls,, 999);
    f.SetInt('Rando_enemiesrandomized', enemiesrandomized,, 999);
    f.SetInt('Rando_enemyrespawn', enemyrespawn,, 999);
    f.SetInt('Rando_infodevices', infodevices,, 999);
    f.SetInt('Rando_dancingpercent', dancingpercent,, 999);

    f.SetInt('Rando_skills_disable_downgrades', skills_disable_downgrades,, 999);
    f.SetInt('Rando_skills_reroll_missions', skills_reroll_missions,, 999);
    f.SetInt('Rando_skills_independent_levels', skills_independent_levels,, 999);

    f.SetInt('Rando_startinglocations', startinglocations,, 999);
    f.SetInt('Rando_goals', goals,, 999);
    f.SetInt('Rando_equipment', equipment,, 999);

    f.SetInt('Rando_medbots', medbots,, 999);
    f.SetInt('Rando_repairbots', repairbots,, 999);
    f.SetInt('Rando_turrets_move', turrets_move,, 999);
    f.SetInt('Rando_turrets_add', turrets_add,, 999);
    f.SetInt('Rando_crowdcontrol', crowdcontrol,, 999);
    f.SetInt('Rando_newgameplus_loops', newgameplus_loops,, 999);
    f.SetInt('Rando_merchants', merchants,, 999);
    f.SetInt('Rando_codes_mode', codes_mode,, 999);

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
        autosave = 0;//autosaving while slowmo is set to high speed crashes the game, maybe autosave should adjust its waittime by the slowmo speed
        SaveNoFlags();
    }

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
    local float CombatDifficulty;
    local #var PlayerPawn  p;
    
#ifdef hx
    CombatDifficulty = HXGameInfo(Level.Game).CombatDifficulty;
#else
    p = player();
    if( p != None )
        CombatDifficulty = p.CombatDifficulty;
#endif
    info(prefix$" - " $ VersionString() $ ", " $ "seed: "$seed$", difficulty: " $ CombatDifficulty $ ", flagshash: " $ FlagsHash() $ ", playthrough_id: "$playthrough_id$", " $ StringifyFlags() );
}

simulated function AddDXRCredits(CreditsWindow cw) 
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
    cw.PrintHeader("DXRFlags");
    
    cw.PrintText(VersionString() $ ", " $ "seed: "$seed$", difficulty: " $ CombatDifficulty $ ", flagshash: " $ FlagsHash() $ ", playthrough_id: "$playthrough_id);
    cw.PrintText(StringifyFlags());
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
        $ ", brightness: "$brightness $ ", newgameplus_loops: "$newgameplus_loops $ ", ammo: " $ ammo $ ", merchants: "$ merchants
        $ ", minskill: "$minskill$", maxskill: "$maxskill$", skills_disable_downgrades: " $ skills_disable_downgrades $ ", skills_reroll_missions: " $ skills_reroll_missions $ ", skills_independent_levels: " $ skills_independent_levels
        $ ", multitools: "$multitools$", lockpicks: "$lockpicks$", biocells: "$biocells$", medkits: "$medkits
        $ ", speedlevel: "$speedlevel$", keysrando: "$keysrando$", doorsmode: "$doorsmode$", doorspickable: "$doorspickable$", doorsdestructible: "$doorsdestructible
        $ ", deviceshackable: "$deviceshackable$", passwordsrandomized: "$passwordsrandomized$", gibsdropkeys: "$gibsdropkeys
        $ ", autosave: "$autosave$", removeinvisiblewalls: "$removeinvisiblewalls$", enemiesrandomized: "$enemiesrandomized$", enemyrespawn: "$enemyrespawn$", infodevices: "$infodevices
        $ ", startinglocations: "$startinglocations$", goals: "$goals$", equipment: "$equipment$", dancingpercent: "$dancingpercent$", medbots: "$medbots$", repairbots: "$repairbots$", turrets_move: "$turrets_move$", turrets_add: "$turrets_add
        $ ", crowdcontrol: "$crowdcontrol$", banned_skills: "$banned_skills$", banned_skill_levels: "$banned_skill_levels$", enemies_nonhumans: "$enemies_nonhumans$", codes_mode: "$codes_mode;
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

simulated static function int VersionToInt(int major, int minor, int patch)
{
    local int ret;
    ret = major*10000+minor*100+patch;
    if( ret <= 10400 ) return minor;//v1.4 and earlier
    return ret;
}

simulated static function string VersionToString(int major, int minor, int patch)
{
    if( patch == 0 )
        return "v" $ major $"."$ minor;
    else
        return "v" $ major $"."$ minor $"."$ patch;
}

simulated static function int VersionNumber()
{
    return VersionToInt(1, 5, 7);
}

simulated static function bool VersionOlderThan(int config_version, int major, int minor, int patch)
{
    return config_version < VersionToInt(major, minor, patch);
}

simulated static function string VersionString()
{
    return VersionToString(1, 5, 8) $ " Alpha";
}

simulated function MaxRando()
{
    //should have a chance to make some skills completely unattainable, like 999999 cost? would this also have to be an option in the GUI or can it be exclusive to MaxRando?
}

function NewGamePlus()
{
    local #var PlayerPawn  p;
    local DataStorage ds;
    if( flagsversion == 0 ) {
        warning("NewGamePlus() flagsversion == 0");
        LoadFlags();
    }
    p = player();

    info("NewGamePlus()");
    seed++;
    playthrough_id = class'DataStorage'.static._SystemTime(Level);
    ds = class'DataStorage'.static.GetObj(p);
    if( ds != None ) ds.playthrough_id = playthrough_id;
    newgameplus_loops++;
    p.CombatDifficulty *= 1.3;
    minskill = minskill*1.2;// int *= float doesn't give as good accuracy as int = int*float
    maxskill = maxskill*1.2;
    enemiesrandomized = enemiesrandomized*1.2;
    ammo = ammo*0.9;
    medkits = medkits*0.8;
    multitools = multitools*0.8;
    lockpicks = lockpicks*0.8;
    biocells = biocells*0.8;
    medbots = medbots*0.8;
    repairbots = repairbots*0.8;
    turrets_add = turrets_add*1.3;
    merchants *= 0.9;

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

function TestRngExp(int minrange, int maxrange, int mid, float curve)
{
    local int min, max, avg, lows, highs, mids, times;
    local int i, t;

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
    avg /= times;
    test( min >= minrange-1, "exponential ^"$curve$" - min: "$min);
    test( min < minrange+10, "exponential ^"$curve$" - min: "$min);
    test( max <= maxrange+1, "exponential ^"$curve$" - max: "$max);
    test( max > maxrange-10, "exponential ^"$curve$" - max: "$max);
    test( avg < maxrange, "exponential ^"$curve$" - avg "$avg$" < maxrange "$maxrange);
    test( avg > minrange, "exponential ^"$curve$" - avg "$avg$" > minrange "$minrange);
    test( lows > times/10, "exponential ^"$curve$" - lows "$lows$" > times/8 "$(times/10));
    test( highs > times/10, "exponential ^"$curve$" - highs "$highs$" > times/8 "$(times/10));
}
