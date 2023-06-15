class DXRando extends DXRInfo transient;

var transient #var(PlayerPawn) Player;
var transient FlagBase flagbase;
var transient DXRFlags flags;
var transient DataStorage ds;
var transient DXRTelemetry telemetry;
var transient DeusExLevelInfo dxInfo;
var transient string localURL;

var int seed, tseed;

var transient private int CrcTable[256]; // for string hashing to do more stable seeding

var transient DXRBase modules[48];
var transient int num_modules;

var config string modules_to_load[47];// 1 less than the modules array, because we always load the DXRFlags module
var config int config_version;

var transient bool runPostFirstEntry;
var transient bool bTickEnabled;// bTickEnabled is just for DXRandoTests to inspect
var transient bool bLoginReady;

replication
{
    reliable if( Role==ROLE_Authority )
        modules, num_modules, runPostFirstEntry, bTickEnabled, localURL, dxInfo, telemetry, flags, flagbase, CrcTable, seed;
}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    Player = #var(PlayerPawn)(GetPlayerPawn());
    l(Self$".PostNetBeginPlay() "$Player);
    SetTimer(0.2, true);
}

simulated event Timer()
{
    local int i;
    if( bTickEnabled == true ) return;

    if( bLoginReady ) {
        PlayerLogin(Player);
        SetTimer(0, false);
    }

    if( ! CheckLogin(Player) )
        return;

    bLoginReady = true;
}

function SetdxInfo(DeusExLevelInfo i)
{
    local LevelInfo li;
    dxInfo = i;
    if(i == None) {
        foreach AllActors(class'LevelInfo', li) { break; }
        warning("SetdxInfo got None, LevelInfo: "$li @ li.Title);
        return;
    }
    localURL = Caps(dxInfo.mapName);
    l("SetdxInfo got localURL: " $ localURL $ ", mapname: " $ i.MissionLocation);

    // undo the damage that DXRBacktracking has done to prevent saves from being deleted
    // must do this before the mission script is loaded, so we can't wait for finding the player and loading modules
    class'DXRBacktracking'.static.LevelInit(Self);

    CrcInit();
    ClearModules();
    LoadFlagsModule();
    CheckConfig();

    Enable('Tick');
    bTickEnabled = true;
}

function DXRInit()
{
    l("DXRInit has localURL == " $ localURL $ ", flagbase == "$flagbase);
    if( flagbase != None ) return;

    Player = #var(PlayerPawn)(GetPlayerPawn());
    if( Player == None )
        foreach AllActors(class'#var(PlayerPawn)', Player)
            break;
    if(Player == None)
        return;

    flagbase = Player.FlagBase;
#ifdef hx
    flagbase = HXGameInfo(Level.Game).Steve.FlagBase;
#endif
    if( flagbase == None ) {
        warn("DXRInit() didn't find flagbase?");
        return;
    }
    l("found flagbase: "$flagbase$", Player: "$Player);

    flags.InitCoordsMult();// for some reason flags is loaded too early and doesn't have the new map url
    flags.LoadFlags();
    LoadModules();
    RandoEnter();
}

function CheckConfig()
{
    local int i;

    if( VersionOlderThan(config_version, 2,4,2,2) ) {
        for(i=0; i < ArrayCount(modules_to_load); i++) {
            modules_to_load[i] = "";
        }

        if(#defined(vanilla))
            vanilla_modules();
        else if(#defined(hx))
            hx_modules();
        else if(#defined(gmdx))
            gmdx_modules();
        else if(#defined(revision))
            revision_modules();
        else if(#defined(vmd))
            vmd_modules();
        else {
            warning("unknown mod, using default set of modules!");
            hx_modules();
        }
    }
    Super.CheckConfig();
}

function vanilla_modules()
{
    local int i;
    modules_to_load[i++] = "DXRTelemetry";
    modules_to_load[i++] = "DXRMissions";
    modules_to_load[i++] = "DXRSwapItems";
    //modules_to_load[i++] = "DXRAddItems";
    modules_to_load[i++] = "DXRFixup";
    modules_to_load[i++] = "DXRBrightness";
    modules_to_load[i++] = "DXRBacktracking";
    modules_to_load[i++] = "DXRKeys";
    modules_to_load[i++] = "DXRDoors";
    modules_to_load[i++] = "DXRSkills";
    modules_to_load[i++] = "DXRPasswords";
    modules_to_load[i++] = "DXRAugmentations";
    modules_to_load[i++] = "DXRReduceItems";
    modules_to_load[i++] = "DXRNames";
    modules_to_load[i++] = "DXRMemes";
    modules_to_load[i++] = "DXREnemies";
    modules_to_load[i++] = "DXREntranceRando";
    modules_to_load[i++] = "DXRAutosave";
    modules_to_load[i++] = "DXRHordeMode";
    //modules_to_load[i++] = "DXRKillBobPage";
    modules_to_load[i++] = "DXREnemyRespawn";
    modules_to_load[i++] = "DXRLoadouts";
    modules_to_load[i++] = "DXRWeapons";
    modules_to_load[i++] = "DXRCrowdControl";
    modules_to_load[i++] = "DXRMachines";
    modules_to_load[i++] = "DXRStats";
    modules_to_load[i++] = "DXRNPCs";
    modules_to_load[i++] = "DXRFashion";
    modules_to_load[i++] = "DXRHints";
    modules_to_load[i++] = "DXREvents";
    //modules_to_load[i++] = "DXRMapInfo";
    modules_to_load[i++] = "DXRMusic";
    modules_to_load[i++] = "DXRMusicPlayer";
    modules_to_load[i++] = "DXRPlayerStats";
    modules_to_load[i++] = "DXRMapVariants";
}

function hx_modules()
{
    local int i;
    modules_to_load[i++] = "DXRTelemetry";
    modules_to_load[i++] = "DXRMissions";
    modules_to_load[i++] = "DXRSwapItems";
    modules_to_load[i++] = "DXRFixup";
    modules_to_load[i++] = "DXRBrightness";
    modules_to_load[i++] = "DXRKeys";
    modules_to_load[i++] = "DXRDoors";
    modules_to_load[i++] = "DXRSkills";
    modules_to_load[i++] = "DXRPasswords";
    modules_to_load[i++] = "DXRAugmentations";
    modules_to_load[i++] = "DXRReduceItems";
    modules_to_load[i++] = "DXRNames";
    modules_to_load[i++] = "DXRMemes";
    modules_to_load[i++] = "DXREnemies";
    modules_to_load[i++] = "DXRHordeMode";
    modules_to_load[i++] = "DXREnemyRespawn";
    modules_to_load[i++] = "DXRLoadouts";
    modules_to_load[i++] = "DXRWeapons";
    modules_to_load[i++] = "DXRCrowdControl";
    modules_to_load[i++] = "DXRMachines";
    modules_to_load[i++] = "DXRStats";
    modules_to_load[i++] = "DXRHints";
    modules_to_load[i++] = "DXRReplaceActors";
    modules_to_load[i++] = "DXREvents";
    modules_to_load[i++] = "DXRPlayerStats";
    modules_to_load[i++] = "DXRMapVariants";
}

function gmdx_modules()
{
    local int i;
    modules_to_load[i++] = "DXRTelemetry";
    modules_to_load[i++] = "DXRMissions";
    modules_to_load[i++] = "DXRSwapItems";
    modules_to_load[i++] = "DXRFixup";
    modules_to_load[i++] = "DXRBrightness";
    modules_to_load[i++] = "DXRKeys";
    modules_to_load[i++] = "DXRDoors";
    modules_to_load[i++] = "DXRSkills";
    modules_to_load[i++] = "DXRPasswords";
    modules_to_load[i++] = "DXRAugmentations";
    modules_to_load[i++] = "DXRReduceItems";
    modules_to_load[i++] = "DXRNames";
    modules_to_load[i++] = "DXRMemes";
    modules_to_load[i++] = "DXREnemies";
    modules_to_load[i++] = "DXRHordeMode";
    modules_to_load[i++] = "DXREnemyRespawn";
    modules_to_load[i++] = "DXRLoadouts";
    modules_to_load[i++] = "DXRWeapons";
    modules_to_load[i++] = "DXRCrowdControl";
    modules_to_load[i++] = "DXRMachines";
    modules_to_load[i++] = "DXRStats";
    modules_to_load[i++] = "DXRHints";
    modules_to_load[i++] = "DXRReplaceActors";
    modules_to_load[i++] = "DXRNPCs";
    modules_to_load[i++] = "DXRFashion";
    modules_to_load[i++] = "DXREvents";
    modules_to_load[i++] = "DXRMusic";
    modules_to_load[i++] = "DXRMusicPlayer";
    modules_to_load[i++] = "DXRPlayerStats";
    modules_to_load[i++] = "DXRMapVariants";
}

function revision_modules()
{
    gmdx_modules();
}

function vmd_modules()
{
    local int i;
    modules_to_load[i++] = "DXRTelemetry";
    modules_to_load[i++] = "DXRMissions";
    modules_to_load[i++] = "DXRSwapItems";
    modules_to_load[i++] = "DXRFixup";
    modules_to_load[i++] = "DXRBrightness";
    modules_to_load[i++] = "DXRKeys";
    modules_to_load[i++] = "DXRDoors";
    modules_to_load[i++] = "DXRSkills";
    modules_to_load[i++] = "DXRPasswords";
    modules_to_load[i++] = "DXRAugmentations";
    modules_to_load[i++] = "DXRReduceItems";
    modules_to_load[i++] = "DXRNames";
    modules_to_load[i++] = "DXRMemes";
    modules_to_load[i++] = "DXREnemies";
    modules_to_load[i++] = "DXRHordeMode";
    modules_to_load[i++] = "DXREnemyRespawn";
    modules_to_load[i++] = "DXRLoadouts";
    modules_to_load[i++] = "DXRWeapons";
    modules_to_load[i++] = "DXRCrowdControl";
    modules_to_load[i++] = "DXRMachines";
    modules_to_load[i++] = "DXRStats";
    modules_to_load[i++] = "DXRHints";
    modules_to_load[i++] = "DXRReplaceActors";
    modules_to_load[i++] = "DXRNPCs";
    modules_to_load[i++] = "DXREvents";
    modules_to_load[i++] = "DXRMusic";
    modules_to_load[i++] = "DXRMusicPlayer";
    modules_to_load[i++] = "DXRPlayerStats";
    modules_to_load[i++] = "DXRMapVariants";
}

function DXRFlags LoadFlagsModule()
{
    flags = DXRFlags(LoadModule(class'DXRFlags'));
    return flags;
}

function DXRBase LoadModule(class<DXRBase> moduleclass)
{
    local DXRBase m;
    moduleclass = moduleclass.static.GetModuleToLoad(self, moduleclass);
    l("loading module "$moduleclass);

    m = FindModule(moduleclass, true);
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

function DXRBase LoadModuleByString(string classstring)
{
    local class<Actor> c;
    if( InStr(classstring, ".") == -1 ) {
        classstring = "#var(package)." $ classstring;
    }
    c = flags.GetClassFromString(classstring, class'DXRBase');
    return LoadModule( class<DXRBase>(c) );
}

function LoadModules()
{
    local int i;

    for( i=0; i < ArrayCount( modules_to_load ); i++ ) {
        if( modules_to_load[i] == "" ) continue;
        LoadModuleByString(modules_to_load[i]);
    }

    telemetry = DXRTelemetry(FindModule(class'DXRTelemetry'));
}

simulated final function DXRBase FindModule(class<DXRBase> moduleclass, optional bool bSilent)
{
    local DXRBase m;
    local int i;
    for(i=0; i<num_modules; i++)
        if( modules[i] != None )
            if( ClassIsChildOf(modules[i].Class, moduleclass) )
                return modules[i];

    foreach AllActors(class'DXRBase', m)
    {
        if( ClassIsChildOf(m.Class, moduleclass) ) {
            if(!bSilent)
                l("FindModule("$moduleclass$") found "$m);
            m.Init(Self);
            modules[num_modules] = m;
            num_modules++;
            return m;
        }
    }

    if(!bSilent)
        l("didn't find module "$moduleclass);
    return None;
}

function ClearModules()
{
    num_modules=0;
    flags=None;
}

simulated event Tick(float deltaTime)
{
    if( Role < ROLE_Authority ) {
        Disable('Tick');
        return;
    }
    DXRTick(deltaTime);
}

function DXRTick(float deltaTime)
{
    local #var(PlayerPawn) pawn;
    local int i;
    SetTimer(0, false);
    if( dxInfo == None )
    {
        //waiting...
        //l("DXRTick dxInfo == None");
        return;
    }
    else if( flagbase == None )
    {
        DXRInit();
    }
    else if(runPostFirstEntry)
    {
        for(i=0; i<num_modules; i++) {
            modules[i].PostFirstEntry();
        }
        info("done randomizing "$localURL$" PostFirstEntry using seed " $ seed $ ", deltaTime: " $ deltaTime);
        runPostFirstEntry = false;
    }
    else
    {
        RunTests();

        for(i=0; i<num_modules; i++) {
            modules[i].PostAnyEntry();
        }

        Disable('Tick');
        bTickEnabled = false;
    }
}

function RandoEnter()
{
    local #var(PlayerPawn) pawn;
    local int i;
    local bool firstTime;
    local name flagName;
    local bool IsTravel;
    local string map;

    if( flagbase == None ) {
        err("RandoEnter() flagbase == None");
        return;
    }

    IsTravel = flagbase.GetBool('PlayerTraveling');

    map = localURL;
    map = class'DXRMapVariants'.static.GetDirtyMapName(map, flags.coords_mult);
    flagName = flagbase.StringToName("M"$StripMapName(map)$"_Randomized");
    if (!flagbase.GetBool(flagName))
    {
        firstTime = True;
        flagbase.SetBool(flagName, True,, dxInfo.missionNumber+1);
    }

    info("RandoEnter() firstTime: "$firstTime$", IsTravel: "$IsTravel$", seed: "$seed @ localURL @ map @ GetURLMap());

    if ( firstTime == true )
    {
        //if( !IsTravel ) warning(localURL$": loaded save but FirstEntry? firstTime: "$firstTime$", IsTravel: "$IsTravel);
        SetSeed( Crc(seed $ localURL) );

        info("randomizing "$localURL$" using seed " $ seed);

        for(i=0; i<num_modules; i++) {
            modules[i].PreFirstEntry();
        }

        for(i=0; i<num_modules; i++) {
            modules[i].FirstEntry();
        }

        runPostFirstEntry = true;
        info("done randomizing "$localURL$" using seed " $ seed);
    }
    else
    {
        for(i=0; i<num_modules; i++) {
            modules[i].ReEntry(IsTravel);
        }
    }

    for(i=0; i<num_modules; i++) {
        modules[i].AnyEntry();
    }

    foreach AllActors(class'#var(PlayerPawn)', pawn) {
        PlayerLogin(pawn);
    }
}

simulated function bool CheckLogin(#var(PlayerPawn) p)
{
    local int i;

    err("CheckLogin("$p$"), bTickEnabled: "$bTickEnabled$", flagbase: "$flagbase$", num_modules: "$num_modules$", flags: "$flags);
    if( bTickEnabled == true ) return false;

    for(i=0; i<num_modules; i++) {
        if( modules[i] == None )
            return false;
        if( modules[i].dxr != Self )
            return false;
        if( ! modules[i].CheckLogin(p) )
            return false;
    }
    return true;
}

simulated function PlayerLogin(#var(PlayerPawn) p)
{
    local int i;
    local PlayerDataItem data;

    if( flags == None || !flags.flags_loaded ) {
        info("PlayerLogin("$p$") flags: "$flags$", flags.flags_loaded: "$flags.flags_loaded);
        return;
    }

    data = class'PlayerDataItem'.static.GiveItem(p);
    info("PlayerLogin("$p$") do it, p.PlayerDataItem: " $ data $", data.local_inited: "$data.local_inited$", mission: "$dxInfo.missionNumber);

#ifdef singleplayer
    if ( flags.stored_version != 0 && flags.stored_version < VersionNumber() ) {
        info("upgrading "$data$" from "$data.version$" to "$VersionNumber());
        data.version = VersionNumber();
    }
#endif

    if( !data.local_inited && dxInfo.missionNumber > 0 && dxInfo.missionNumber < 98 )
    {
        for(i=0; i<num_modules; i++) {
            modules[i].PlayerLogin(p);
        }
        data.local_inited = true;
    }
    for(i=0; i<num_modules; i++) {
        modules[i].PlayerAnyEntry(p);
    }

    data.version = VersionNumber();
}

simulated function PlayerRespawn(#var(PlayerPawn) p)
{
    local int i;
    for(i=0; i<num_modules; i++) {
        modules[i].PlayerRespawn(p);
    }
}

simulated final function int SetSeed(int s)
{
    local int oldseed;
    oldseed = tseed;
    //log("SetSeed old seed == "$newseed$", new seed == "$s);
    tseed = s;
    return oldseed;
}

simulated final function int rng(int max)
{
    const gen1 = 1073741821;// half of gen2, rounded down
    const gen2 = 2147483643;
    tseed = gen1 * tseed * 5 + gen2 + (tseed/5) * 3;
    // in unrealscript >>> is right shift and filling the left with 0s, >> shifts but keeps the sign
    // this means we don't need abs, which is a float function anyways
    return imod((tseed >>> 8), max);
}


// ============================================================================
// CrcInit https://web.archive.org/web/20181105143221/http://unrealtexture.com/Unreal/Downloads/3DEditing/UnrealEd/Tutorials/unrealwiki-offline/crc32.html
//
// Initializes CrcTable and prepares it for use with Crc.
// ============================================================================

simulated final function CrcInit() {

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

simulated final function int Crc(coerce string Text) {

    local int CrcValue;
    local int IndexChar;

    //if(CrcTable[1] == 0)
        //err("CrcTable uninitialized?");

    CrcValue = 0xffffffff;

    for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
        CrcValue = (CrcValue >>> 8) ^ CrcTable[Asc(Mid(Text, IndexChar, 1)) ^ (CrcValue & 0xff)];

    return CrcValue;
}

simulated function DXRando GetDXR()
{
    return Self;
}

function RunTests()
{
    local int i, failures;
    l("starting RunTests()");
    for(i=0; i<num_modules; i++) {
        modules[i].StartRunTests();
        if( modules[i].fails > 0 ) {
            failures++;
            Player.ShowHud(true);
            err( "ERROR: " $ modules[i] @ modules[i].fails $ " tests failed!" );
        }
        else
            l( modules[i] $ " passed tests!" );
    }

    if( failures == 0 ) {
        l( "all tests passed!" );
    } else {
        Player.ShowHud(true);
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
            Player.ShowHud(true);
            err( "ERROR: " $ modules[i] @ modules[i].fails $ " tests failed!" );
        }
        else
            l( modules[i] $ " passed tests!" );
    }

    if( failures == 0 ) {
        l( "all extended tests passed!" );
    } else {
        Player.ShowHud(true);
        err( "ERROR: " $ failures $ " modules failed tests!" );
    }
}

defaultproperties
{
    NetPriority=0.1
}
