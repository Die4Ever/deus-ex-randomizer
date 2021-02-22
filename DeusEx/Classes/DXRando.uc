class DXRando extends Info config(DXRando) transient;

var transient DeusExPlayer Player;
var transient DXRFlags flags;
var transient DeusExLevelInfo dxInfo;
var transient string localURL;

var int newseed;
var int seed;

var transient private int CrcTable[256]; // for string hashing to do more stable seeding

var transient DXRBase modules[32];
var transient int num_modules;

var config string modules_to_load[31];// 1 less than the modules array, because we always load the DXRFlags module
var config int config_version;

function SetdxInfo(DeusExLevelInfo i)
{
    dxInfo = i;
    localURL = Caps(dxInfo.mapName);
    l("SetdxInfo got localURL: " $ localURL);
    PostPostBeginPlay();
}

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    CrcInit();

    if( localURL == "" ) {
        l("PostPostBeginPlay returning because localURL == " $ localURL);
        return;
    }

    l("PostPostBeginPlay has localURL == " $ localURL);
    foreach AllActors(class'DeusExPlayer', Player) { break; }
    if( Player == None ) {
        l("PostPostBeginPlay() didn't find player?");
        SetTimer(0.1, False);
        return;
    }
    info("found Player "$Player);
    ClearModules();
    LoadFlagsModule();
    flags.LoadFlags();
    CheckConfig();
    LoadModules();

    RandoEnter();
}

function CheckConfig()
{
    local int i;

    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,1) ) {
        for(i=0; i < ArrayCount(modules_to_load); i++) {
            modules_to_load[i] = "";
        }

        i=0;
        modules_to_load[i++] = "DXRMissions";
        modules_to_load[i++] = "DXRSwapItems";
        //modules_to_load[i++] = "DXRAddItems";
        modules_to_load[i++] = "DXRFixup";
        modules_to_load[i++] = "DXRBacktracking";
        modules_to_load[i++] = "DXRKeys";
        modules_to_load[i++] = "DXRSkills";
        modules_to_load[i++] = "DXRPasswords";
        modules_to_load[i++] = "DXRAugmentations";
        modules_to_load[i++] = "DXRReduceItems";
        modules_to_load[i++] = "DXRNames";
        modules_to_load[i++] = "DXRAutosave";
        modules_to_load[i++] = "DXRMemes";
        modules_to_load[i++] = "DXREnemies";
        modules_to_load[i++] = "DXREntranceRando";
        modules_to_load[i++] = "DXRHordeMode";
        modules_to_load[i++] = "DXRKillBobPage";
        modules_to_load[i++] = "DXREnemyRespawn";
        modules_to_load[i++] = "DXRLoadouts";
        modules_to_load[i++] = "DXRWeapons";
        modules_to_load[i++] = "DXRCrowdControl";
        modules_to_load[i++] = "DXRMachines";
        modules_to_load[i++] = "DXRTelemetry";
    }
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        info("upgraded config from "$config_version$" to "$class'DXRFlags'.static.VersionNumber());
        config_version = class'DXRFlags'.static.VersionNumber();
        SaveConfig();
    }
}

function DXRFlags LoadFlagsModule()
{
    flags = DXRFlags(LoadModule(class'DXRFlags'));
    return flags;
}

function DXRBase LoadModule(class<DXRBase> moduleclass)
{
    local DXRBase m;
    l("loading module "$moduleclass);

    m = FindModule(moduleclass);
    if( m != None ) {
        info("found already loaded module "$m);
        if(m.dxr != Self) m.Init(Self);
        return m;
    }

    m = Spawn(moduleclass, None);
    if ( m == None ) {
        err("failed to load module "$moduleclass);
        return None;
    }
    modules[num_modules] = m;
    num_modules++;
    m.Init(Self);
    l("finished loading module "$m);
    return m;
}

function LoadModules()
{
    local int i;
    local class<Actor> c;
    for( i=0; i < ArrayCount( modules_to_load ); i++ ) {
        if( modules_to_load[i] == "" ) continue;
        c = flags.GetClassFromString(modules_to_load[i], class'DXRBase');
        LoadModule( class<DXRBase>(c) );
    }
    RunTests();
}

function DXRBase FindModule(class<DXRBase> moduleclass)
{
    local DXRBase m;
    local int i;
    for(i=0; i<num_modules; i++)
        if( modules[i] != None )
            if( modules[i].Class == moduleclass )
                return modules[i];

    foreach AllActors(class'DXRBase', m)
    {
        if( m.Class == moduleclass ) {
            l("FindModule("$moduleclass$") found "$m);
            m.Init(Self);
            modules[num_modules] = m;
            num_modules++;
            return m;
        }
    }

    l("didn't find module "$moduleclass);
    return None;
}

function ClearModules()
{
    num_modules=0;
    flags=None;
}

event Destroyed()
{
    local int i;
    info("Destroyed()");

    ClearModules();
    Player = None;
    Super.Destroyed();
}

function PreTravel()
{
    local int i;
    info("PreTravel()");
    // turn off the timer
    SetTimer(0, False);

    ClearModules();
    Player=None;
}

function Timer()
{
    local int i;
    if( Player == None ) {
        PostPostBeginPlay();
        return;
    }
}

function RandoEnter()
{
    local int i;
    local bool firstTime;
    local name flagName;

    flagName = Player.rootWindow.StringToName("M"$localURL$"_Randomized");
    if (!flags.f.GetBool(flagName))
    {
        firstTime = True;
        flags.f.SetBool(flagName, True,, 999);
    }

    info("RandoEnter() firstTime: "$firstTime);

    if ( firstTime == true )
    {
        SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL) );

        info("randomizing "$localURL$" using seed " $ seed);

        for(i=0; i<num_modules; i++) {
            modules[i].FirstEntry();
        }

        info("done randomizing "$localURL$" using seed " $ seed);
    }
    else
    {
        for(i=0; i<num_modules; i++) {
            modules[i].ReEntry();
        }
    }

    for(i=0; i<num_modules; i++) {
        modules[i].AnyEntry();
    }

}

function int SetSeed(int s)
{
    local int oldseed;
    oldseed = newseed;
    //log("SetSeed old seed == "$newseed$", new seed == "$s);
    newseed = s;
    return oldseed;
}

function int rng(int max)
{
    local int gen1, gen2;
    gen2 = 2147483643;
    gen1 = gen2/2;
    newseed = gen1 * newseed * 5 + gen2 + (newseed/5) * 3;
    newseed = abs(newseed);
    return (newseed >>> 8) % max;
}


// ============================================================================
// CrcInit https://web.archive.org/web/20181105143221/http://unrealtexture.com/Unreal/Downloads/3DEditing/UnrealEd/Tutorials/unrealwiki-offline/crc32.html
//
// Initializes CrcTable and prepares it for use with Crc.
// ============================================================================

final function CrcInit() {

    const CrcPolynomial = 0xedb88320;

    local int CrcValue;
    local int IndexBit;
    local int IndexEntry;

  for (IndexEntry = 0; IndexEntry < 256; IndexEntry++) {
        CrcValue = IndexEntry;

        for (IndexBit = 8; IndexBit > 0; IndexBit--)
        {
            if ((CrcValue & 1) != 0)
                CrcValue = (CrcValue >>> 1) ^ CrcPolynomial;
            else
                CrcValue = CrcValue >>> 1;
        }
        
        CrcTable[IndexEntry] = CrcValue;
    }
}


// ============================================================================
// Crc
//
// Calculates and returns a checksum of the given string. Call CrcInit before.
// ============================================================================

final function int Crc(coerce string Text) {

    local int CrcValue;
    local int IndexChar;

    CrcValue = 0xffffffff;

    for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
        CrcValue = (CrcValue >>> 8) ^ CrcTable[Asc(Mid(Text, IndexChar, 1)) ^ (CrcValue & 0xff)];

    return CrcValue;
}

function l(string message)
{
    log(message, class.name);
}

function info(string message)
{
    log("INFO: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(Self, Self, "INFO", message);
}

function warning(string message)
{
    log("WARNING: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(Self, Self, "WARNING", message);
}

function err(string message)
{
    log("ERROR: " $ message, class.name);
    Player.ClientMessage( Class @ message );

    class'DXRTelemetry'.static.SendLog(Self, Self, "ERROR", message);
}

function RunTests()
{
    local int i, failures;
    l("starting RunTests()");
    for(i=0; i<num_modules; i++) {
        modules[i].StartRunTests();
        if( modules[i].fails > 0 ) {
            failures++;
            player.ShowHud(true);
            err( "ERROR: " $ modules[i] @ modules[i].fails $ " tests failed!" );
        }
        else
            l( modules[i] $ " passed tests!" );
    }

    if( failures == 0 ) {
        l( "all tests passed!" );
    } else {
        player.ShowHud(true);
        err( "ERROR: " $ failures $ " modules failed tests!" );
    }
}

function ExtendedTests()
{
    local int i, failures;
    l("starting ExtendedTests()");
    for(i=0; i<num_modules; i++) {
        modules[i].StartExtendedTests();
        if( modules[i].fails > 0 ) {
            failures++;
            player.ShowHud(true);
            err( "ERROR: " $ modules[i] @ modules[i].fails $ " tests failed!" );
        }
        else
            l( modules[i] $ " passed tests!" );
    }

    if( failures == 0 ) {
        l( "all extended tests passed!" );
    } else {
        player.ShowHud(true);
        err( "ERROR: " $ failures $ " modules failed tests!" );
    }
}

defaultproperties
{
     bAlwaysRelevant=True
}
