class DXRFlags extends DXRBase config(DXRando) transient;

var transient FlagBase f;

//rando flags
var int seed;
var int flagsversion;//if you load an old game with a newer version of the randomizer, we'll need to set defaults for new flags
var int brightness, minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
var int keysrando;//0=off, 1=dumb, 2=on (old smart), 3=copies, 4=smart (v1.3), 5=path finding?
var int doorspickable, doorsdestructible, deviceshackable, passwordsrandomized, gibsdropkeys;//could be bools, but int is more flexible, especially so I don't have to change the flag type
var int autosave;//0=off, 1=first time entering level, 2=every loading screen
var int removeinvisiblewalls, enemiesrandomized, infodevices;
var int dancingpercent;

var config int config_version;

function PreTravel()
{
    Super.PreTravel();
    f = None;
    Self.Destroy();// for some reason, "f = tdxr.Player.FlagBase;" inside the Init function crashes if I don't do this, not sure why
}

function Init(DXRando tdxr)
{
    Super.Init(tdxr);
    f = tdxr.Player.FlagBase;
}

function Timer()
{
    Super.Timer();

    if( f.GetInt('Rando_version') == 0 ) {
        l("flags got deleted, saving again");//the intro deletes all flags
        SaveFlags();
    }
}

function InitDefaults()
{
    InitVersion();
    CheckConfig();
    dxr.CrcInit();
    seed = dxr.Crc( Rand(MaxInt) @ (FRand()*1000000) @ (Level.TimeSeconds*1000) );
    seed = abs(seed) % 1000000;
    dxr.seed = seed;
    brightness = 5;
    minskill = 25;
    maxskill = 300;
    ammo = 90;
    multitools = 80;
    lockpicks = 80;
    biocells = 80;
    speedlevel = 1;
    keysrando = 4;
    doorspickable = 100;
    doorsdestructible = 100;
    deviceshackable = 100;
    passwordsrandomized = 100;
    gibsdropkeys = 1;
    medkits = 90;
    autosave = 1;
    removeinvisiblewalls = 0;
    enemiesrandomized = 25;
    infodevices = 0;
    dancingpercent = 25;
}

function CheckConfig()
{
    if( config_version == 0 ) {
    }
    if( config_version < flagsversion ) {
        config_version = flagsversion;
        SaveConfig();
    }
}

function LoadFlags()
{
    local int stored_version;
    l("LoadFlags()");

    InitDefaults();

    stored_version = f.GetInt('Rando_version');

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

    if(stored_version < flagsversion ) {
        l("upgraded flags from v"$stored_version);
        SaveFlags();
    }

    LogFlags("LoadFlags");
    dxr.Player.ClientMessage("Deus Ex Randomizer " $ VersionString() $ " seed: " $ seed $ ", difficulty: " $ dxr.Player.CombatDifficulty $ ", flags: " $ FlagsHash() );
    SetTimer(1.0, True);
}

function SaveFlags()
{
    l("SaveFlags()");

    InitVersion();
    f.SetInt('Rando_seed', seed,, 999);
    dxr.seed = seed;

    f.SetInt('Rando_version', flagsversion,, 999);
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
    f.SetInt('Rando_doorspickable', doorspickable,, 999);
    f.SetInt('Rando_doorsdestructible', doorsdestructible,, 999);
    f.SetInt('Rando_deviceshackable', deviceshackable,, 999);
    f.SetInt('Rando_passwordsrandomized', passwordsrandomized,, 999);
    f.SetInt('Rando_gibsdropkeys', gibsdropkeys,, 999);
    f.SetInt('Rando_autosave', autosave,, 999);
    f.SetInt('Rando_removeinvisiblewalls', removeinvisiblewalls,, 999);
    f.SetInt('Rando_enemiesrandomized', enemiesrandomized,, 999);
    f.SetInt('Rando_infodevices', infodevices,, 999);
    f.SetInt('Rando_dancingpercent', dancingpercent,, 999);

    LogFlags("SaveFlags");
}

function LogFlags(string prefix)
{
    l(prefix$" - " $ "seed: "$seed$", difficulty: " $ dxr.Player.CombatDifficulty $ ", " $ StringifyFlags() );
}

function string StringifyFlags()
{
    return "flagsversion: "$flagsversion$", brightness: "$brightness$", minskill: "$minskill$", maxskill: "$maxskill$", ammo: "$ammo
        $ ", multitools: "$multitools$", lockpicks: "$lockpicks$", biocells: "$biocells$", medkits: "$medkits
        $ ", speedlevel: "$speedlevel$", keysrando: "$keysrando$", doorspickable: "$doorspickable$", doorsdestructible: "$doorsdestructible
        $ ", deviceshackable: "$deviceshackable$", passwordsrandomized: "$passwordsrandomized$", gibsdropkeys: "$gibsdropkeys
        $ ", autosave: "$autosave$", removeinvisiblewalls: "$removeinvisiblewalls$", enemiesrandomized: "$enemiesrandomized$", infodevices: "$infodevices
        $ ", dancingpercent: "$dancingpercent;
}

function int FlagsHash()
{
    local int hash;
    hash = dxr.Crc(StringifyFlags());
    hash = int(abs(hash));
    return hash;
}

function InitVersion()
{
    flagsversion = 3;
}

static function string VersionString()
{
    return "v1.3.3.7";
}

function MaxRando()
{
    //should have a chance to make some skills completely unattainable, like 999999 cost? would this also have to be an option in the GUI or can it be exclusive to MaxRando?
}

function int RunTests()
{
    local int results, i;
    results = Super.RunTests();

    //this Crc function returns negative numbers
    results += testint( dxr.Crc("a bomb!"), -1813716842, "Crc32 test");
    results += testint( dxr.Crc("1723"), -441943723, "Crc32 test");
    results += testint( dxr.Crc("do you have a single fact to back that up"), -1473827402, "Crc32 test");

    SetSeed("smashthestate");
    for(i=0;i<10;i++)
        test( rng(100)>=0, "rng(100) >= 0");

    return results;
}
