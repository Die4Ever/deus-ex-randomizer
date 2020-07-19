class DXRFlags extends DXRBase;

var FlagBase flags;

//rando flags
var int seed;
var int flagsversion;//if you load an old game with a newer version of the randomizer, we'll need to set defaults for new flags
var int brightness, minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
var int keysrando;//0=off, 1=dumb, 2=on (old smart), 3=copies, 4=smart (v1.3)
var int doorspickable, doorsdestructible, deviceshackable, passwordsrandomized, gibsdropkeys;//could be bools, but int is more flexible, especially so I don't have to change the flag type
var int autosave;//0=off, 1=first time entering level, 2=every loading screen
var int removeinvisiblewalls, enemiesrandomized;

function Init(DXRando tdxr)
{
    Super.Init(tdxr);

    flags = dxr.Player.FlagBase;
    SetTimer(1.0, True);
}

function Timer()
{
    Super.Timer();
    if( flags.GetInt('Rando_version') == 0 ) {
        l("flags got deleted, saving again");//the intro deletes all flags
        SaveFlags();
    }
}

function InitDefaults()
{
    InitVersion();
    dxr.CrcInit();
    seed = dxr.Crc( Rand(MaxInt) @ (FRand()*1000000) @ (Level.TimeSeconds*1000) );
    seed = abs(seed) % 1000000;
    dxr.seed = seed;
    brightness = 5;
    minskill = 25;
    maxskill = 300;
    ammo = 80;
    multitools = 70;
    lockpicks = 70;
    biocells = 80;
    speedlevel = 1;
    keysrando = 4;
    doorspickable = 100;
    doorsdestructible = 100;
    deviceshackable = 100;
    passwordsrandomized = 100;
    gibsdropkeys = 1;
    medkits = 80;
    autosave = 1;
    removeinvisiblewalls = 0;
    enemiesrandomized = 50;
}

function LoadFlags()
{
    local int stored_version;
    l("LoadFlags()");
    InitDefaults();

    stored_version = flags.GetInt('Rando_version');

    if( stored_version >= 1 ) {
        seed = flags.GetInt('Rando_seed');
        dxr.seed = seed;
        brightness = flags.GetInt('Rando_brightness');
        minskill = flags.GetInt('Rando_minskill');
        maxskill = flags.GetInt('Rando_maxskill');
        ammo = flags.GetInt('Rando_ammo');
        multitools = flags.GetInt('Rando_multitools');
        lockpicks = flags.GetInt('Rando_lockpicks');
        biocells = flags.GetInt('Rando_biocells');
        speedlevel = flags.GetInt('Rando_speedlevel');
        keysrando = flags.GetInt('Rando_keys');
        doorspickable = flags.GetInt('Rando_doorspickable');
        doorsdestructible = flags.GetInt('Rando_doorsdestructible');
        deviceshackable = flags.GetInt('Rando_deviceshackable');
        passwordsrandomized = flags.GetInt('Rando_passwordsrandomized');
        gibsdropkeys = flags.GetInt('Rando_gibsdropkeys');
    }
    if( stored_version >= 2 ) {
        medkits = flags.GetInt('Rando_medkits');
    }
    if( stored_version >= 3 ) {
        autosave = flags.GetInt('Rando_autosave');
        removeinvisiblewalls = flags.GetInt('Rando_removeinvisiblewalls');
        enemiesrandomized = flags.GetInt('Rando_enemiesrandomized');
    }

    if(stored_version < flagsversion ) {
        l("upgraded flags from v"$stored_version);
        SaveFlags();
    }

    LogFlags("LoadFlags");
    dxr.Player.ClientMessage("Deus Ex Randomizer "$VersionString()$" seed "$seed);
}

function SaveFlags()
{
    l("SaveFlags()");
    InitVersion();
    flags.SetInt('Rando_seed', seed,, 999);
    dxr.seed = seed;

    flags.SetInt('Rando_version', flagsversion,, 999);
    flags.SetInt('Rando_brightness', brightness,, 999);
    flags.SetInt('Rando_minskill', minskill,, 999);
    flags.SetInt('Rando_maxskill', maxskill,, 999);
    flags.SetInt('Rando_ammo', ammo,, 999);
    flags.SetInt('Rando_multitools', multitools,, 999);
    flags.SetInt('Rando_lockpicks', lockpicks,, 999);
    flags.SetInt('Rando_biocells', biocells,, 999);
    flags.SetInt('Rando_medkits', medkits,, 999);
    flags.SetInt('Rando_speedlevel', speedlevel,, 999);
    flags.SetInt('Rando_keys', keysrando,, 999);
    flags.SetInt('Rando_doorspickable', doorspickable,, 999);
    flags.SetInt('Rando_doorsdestructible', doorsdestructible,, 999);
    flags.SetInt('Rando_deviceshackable', deviceshackable,, 999);
    flags.SetInt('Rando_passwordsrandomized', passwordsrandomized,, 999);
    flags.SetInt('Rando_gibsdropkeys', gibsdropkeys,, 999);
    flags.SetInt('Rando_autosave', autosave,, 999);
    flags.SetInt('Rando_removeinvisiblewalls', removeinvisiblewalls,, 999);
    flags.SetInt('Rando_enemiesrandomized', enemiesrandomized,, 999);

    LogFlags("SaveFlags");
}

function LogFlags(string prefix)
{
    l(prefix$" - "
        $ "seed: "$seed$", flagsversion: "$flagsversion$", brightness: "$brightness$", minskill: "$minskill$", maxskill: "$maxskill$", ammo: "$ammo
        $ ", multitools: "$multitools$", lockpicks: "$lockpicks$", biocells: "$biocells$", medkits: "$medkits
        $ ", speedlevel: "$speedlevel$", keysrando: "$keysrando$", doorspickable: "$doorspickable$", doorsdestructible: "$doorsdestructible
        $ ", deviceshackable: "$deviceshackable$", passwordsrandomized: "$passwordsrandomized$", gibsdropkeys: "$gibsdropkeys
        $ ", autosave: "$autosave$", removeinvisiblewalls: "$removeinvisiblewalls$", enemiesrandomized: "$enemiesrandomized
    );
}

function InitVersion()
{
    flagsversion = 3;
}

static function string VersionString()
{
    return "v1.3 Beta";
}

function MaxRando()
{
}
