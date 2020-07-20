class DXRando extends Info;

var transient DeusExPlayer Player;
//var transient FlagBase flags;
var DXRFlags flags;
var transient DeusExLevelInfo dxInfo;
var transient string localURL;

var int newseed;

//rando flags
var int seed;

var transient bool bNeedSave;

var transient private int CrcTable[256]; // for string hashing to do more stable seeding

var DXRBase modules[16];
var int num_modules;

function SetdxInfo(DeusExLevelInfo i)
{
    dxInfo = i;
    localURL = Caps(dxInfo.mapName);
    log("DXRando SetdxInfo got localURL: " $ localURL);
    PostPostBeginPlay();
}

function PostPostBeginPlay()
{
    local name flagName;
    local bool firstTime;

    Super.PostPostBeginPlay();

    if( localURL == "DX" || localURL == "" ) {
        log("DXRando PostPostBeginPlay returning because localURL == " $ localURL);
        return;
    }

    log("DXRando PostPostBeginPlay has localURL == " $ localURL);
    Player = DeusExPlayer(GetPlayerPawn());
    if( Player == None ) {
        log("DXRando PostPostBeginPlay() didn't find player?");
        SetTimer(0.1, False);
        return;
    }
    log("DXRando found Player "$Player);
    ClearModules();
    LoadFlagsModule();
    CrcInit();
    flags.LoadFlags();

    LoadModules();

    flagName = Player.rootWindow.StringToName("M"$localURL$"_Randomized");
    if (!flags.flags.GetBool(flagName))
    {
        firstTime = True;
        flags.flags.SetBool(flagName, True,, 999);
    }
    RandoEnter(firstTime);

    SetTimer(1.0, True);
}

function DXRFlags LoadFlagsModule()
{
    flags = DXRFlags(LoadModule(class'DXRFlags'));
    return flags;
}

function DXRBase LoadModule(class<DXRBase> moduleclass)
{
    local DXRBase m;
    log("DXRando loading module "$moduleclass);

    m = FindModule(moduleclass);
    if( m != None ) {
        log("DXRando found already loaded module "$moduleclass);
        if(m.dxr != Self) m.Init(Self);
        return m;
    }

    //m = new(None) moduleclass;
    m = Spawn(moduleclass, None);
    if ( m == None ) {
        log("DXRando failed to load module "$moduleclass);
        return None;
    }
    m.Init(Self);
    modules[num_modules] = m;
    num_modules++;
    log("DXRando finished loading module "$moduleclass);
    return m;
}

function LoadModules()
{
    LoadModule(class'DXRKeys');
    LoadModule(class'DXREnemies');
    LoadModule(class'DXRSwapItems');
    LoadModule(class'DXRSkills');
    LoadModule(class'DXRPasswords');
    LoadModule(class'DXRAugmentations');
    LoadModule(class'DXRReduceItems');

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
            m.Init(Self);
            modules[num_modules] = m;
            num_modules++;
            return m;
        }
    }

    log("DXRando failed to find module "$moduleclass);
    return None;
}

function ClearModules()
{
    local DXRBase m;
    num_modules=0;
    flags=None;
}

event Destroyed()
{
    local int i;
    log("DXRando.Destroyed()");

    num_modules = 0;
    flags = None;
    Player = None;
    Super.Destroyed();
}

function PreTravel()
{
    local int i;
    log("DXRando PreTravel()");
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

    if( bNeedSave )
        doAutosave();
}

function RandoEnter(bool firstTime)
{
    local int i;

    log("DXRando RandoEnter() firstTime: "$firstTime);
    
    if ( firstTime == true )
    {
        SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL) );

        log("DXRando randomizing "$localURL$" using seed " $ seed);

        if( Level.AmbientBrightness<150 ) Level.AmbientBrightness += flags.brightness;

        for(i=0; i<num_modules; i++) {
            modules[i].FirstEntry();
        }

        log("DXRando done randomizing "$localURL);
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

    if( (flags.autosave==2 && flags.flags.GetBool('PlayerTraveling') && localURL != "INTRO" )
        ||
        ( firstTime && flags.autosave==1 && localURL != "INTRO" )
    ) {
        bNeedSave=true;
    }
}

function doAutosave()
{
    local string saveName;

    //copied from DeusExPlayer QuickSave()
    if (
        ((dxInfo != None) && (dxInfo.MissionNumber < 0)) || 
        ((Player.IsInState('Dying')) || (Player.IsInState('Paralyzed')) || (Player.IsInState('Interpolating'))) || 
        (Player.dataLinkPlay != None) || (Level.Netmode != NM_Standalone)
    ){
        log("DXRando doAutosave() not saving");
        return;
    }

    saveName = "DXR " $ seed $ ": " $ dxInfo.MissionLocation;
    Player.SaveGame(-1, saveName);
    bNeedSave = false;
}

function int SetSeed(int s)
{
    newseed = s;
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

function RunTests()
{
    local int i, results;
    for(i=0; i<num_modules; i++) {
        results = modules[i].RunTests();
        if( results > 0 )
            log( modules[i] $ " failed "$results$" tests!" );
        else
            log( modules[i] $ " passed tests!" );
    }
}

defaultproperties
{
    bAlwaysRelevant=True
}
