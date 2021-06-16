#ifdef hx
class DXRBase extends Info config(HXRando);
#else
class DXRBase extends Info config(DXRando);
#endif

var transient DXRando dxr;
var transient float overallchances;
var config int config_version;

var transient int passes;
var transient int fails;
var transient bool inited;

replication
{
    reliable if( Role==ROLE_Authority )
        dxr, inited;
}

function Init(DXRando tdxr)
{
    //l(Self$".Init()");
    dxr = tdxr;
    CheckConfig();
    inited = true;
}

function bool ConfigOlderThan(int major, int minor, int patch, int build)
{
    return class'DXRFlags'.static.VersionOlderThan(config_version, major, minor, patch, build);
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        info("upgraded config from "$config_version$" to "$class'DXRFlags'.static.VersionNumber());
        config_version = class'DXRFlags'.static.VersionNumber();
        SaveConfig();
    }
}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    l("PostNetBeginPlay()");
}

simulated function PreFirstEntry();
simulated function FirstEntry();
simulated function PostFirstEntry();

simulated function AnyEntry();
simulated function PostAnyEntry();

simulated function ReEntry(bool IsTravel);

simulated function bool CheckLogin(#var PlayerPawn  player)
{
    info("CheckLogin("$player$"), inited: "$inited$", dxr.flagbase: "$dxr.flagbase$", dxr.flags.flags_loaded: "$dxr.flags.flags_loaded$", player.SkillSystem: "$player.SkillSystem$", player.SkillSystem.FirstSkill: "$player.SkillSystem.FirstSkill);
    if( inited == false ) return false;
    if( player == None ) return false;
    if( player.SkillSystem == None ) return false;
    if( player.SkillSystem.FirstSkill == None ) return false;
    return true;
}

simulated function PlayerLogin(#var PlayerPawn  player)
{
    l("PlayerLogin("$player$")");
}

simulated function PlayerRespawn(#var PlayerPawn  player)
{
    l("PlayerRespawn("$player$")");
}

simulated function PlayerAnyEntry(#var PlayerPawn  player)
{
    l("PlayerAnyEntry("$player$")");
}

simulated event PreTravel()
{
    SetTimer(0, False);
}

simulated event Timer()
{
}

simulated event Tick(float deltaTime);

simulated event Destroyed()
{
    dxr = None;
    Super.Destroyed();
}

simulated function int SetSeed(coerce string name)
{
    return dxr.SetSeed( dxr.Crc(dxr.seed $ dxr.localURL $ name) );
}

simulated function int rng(int max)
{
    return dxr.rng(max);
}

simulated function float rngf()
{// 0 to 1.0
    local float f;
    f = float(dxr.rng(100001))/100000.0;
    //l("rngf() "$f);
    return f;
}

simulated function float rngfn()
{// -1.0 to 1.0
    return rngf() * 2.0 - 1.0;
}

simulated function float rngrange(float val, float min, float max)
{
    local float mult, r, ret;
    mult = max - min;
    r = rngf();
    ret = val * (r * mult + min);
    //l("rngrange r: "$r$", mult: "$mult$", min: "$min$", max: "$max$", val: "$val$", return: "$ret);
    return ret;
}

simulated function float rngrangeseeded(float val, float min, float max, coerce string classname)
{
    local float mult, r, ret;
    local int oldseed;
    oldseed = dxr.SetSeed( dxr.seed + dxr.Crc(classname) );//manually set the seed to avoid using the level name in the seed
    mult = max - min;
    r = rngf();
    ret = val * (r * mult + min);
    //l("rngrange r: "$r$", mult: "$mult$", min: "$min$", max: "$max$", val: "$val$", return: "$ret);
    dxr.SetSeed(oldseed);
    return ret;
}

simulated static function float pow(float m, float e)
{
    return exp(e * loge(m) );
}

simulated function float rngexp(float min, float max, float curve)
{
    local float frange, f;
    min = pow(min, 1/curve);
    max = pow(max+1.0, 1/curve);
    frange = max-min;
    f = rngf()*frange + min;
    return pow(f, curve);
}

simulated function bool RandoLevelValues(Actor a, float min, float max, out string Desc)
{
    local #var prefix Augmentation aug;
    local #var prefix Skill sk;
    local string s, word;
    local int i, len, oldseed;
    local float prev_d, d, v, min_val;

    oldseed = dxr.SetSeed( dxr.Crc(dxr.seed $ " RandoLevelValues " $ a.class.name ) );

    aug = #var prefix Augmentation(a);
    sk = #var prefix Skill(a);

    if( aug != None ) len = ArrayCount(aug.LevelValues);
    else if( sk != None ) len = ArrayCount(sk.LevelValues);

    for(i=0; i < len; i++) {
        if( aug != None ) d = aug.Default.LevelValues[i];
        else if( sk != None ) d = sk.Default.LevelValues[i];

        v = rngrange(d, min, max);
        if( i>0 && prev_d < d && v < min_val ) v = min_val;
        else if( i>0 && prev_d > d && v > min_val ) v = min_val;
        min_val = v;

        if( aug != None ) aug.LevelValues[i] = v;
        else if( sk != None ) sk.LevelValues[i] = v;

        if( i>0 ) s = s $ ", ";
        s = s $ DescriptionLevel(a, i, word);
        prev_d = d;
    }

    s = "(" $ word $ ": " $ s $ ")";

    dxr.SetSeed( oldseed );

    if( InStr(Desc, s) == -1 ) {
        Desc = Desc $ "|n|n" $ s;
        return true;
    }
    return false;
}

simulated function string DescriptionLevel(Actor a, int i, out string word)
{
    err("DXRBase DescriptionLevel failed for "$a);
    return "err";
}

simulated function static int staticrng(DXRando dxr, int max)
{
    return dxr.rng(max);
}

simulated function float initchance()
{
    if(overallchances > 0.01 && overallchances < 99.99) warning("initchance() overallchances == "$overallchances);
    overallchances=0;
    return rngf()*100.0;
}

simulated function bool chance(float percent, float r)
{
    overallchances+=percent;
    if(overallchances>100.01) warning("chance("$percent$", "$r$") overallchances == "$overallchances);
    return r>= (overallchances-percent) && r< overallchances;
}

simulated function bool chance_remaining(int r)
{
    local int percent;
    percent = 100 - overallchances;
    return chance(percent, r);
}

simulated function bool chance_single(float percent)
{
    return rngf()*100.0 < percent;
}

simulated function class<Actor> GetClassFromString(string classstring, class<Actor> c)
{
    local class<Actor> a;
    if( InStr(classstring, ".") == -1 ) {
#ifdef hx
        classstring = "HX.HX" $ classstring;
#else
        classstring = "DeusEx." $ classstring;
#endif
    }
    a = class<Actor>(DynamicLoadObject(classstring, class'class'));
    if( a == None ) {
        err("GetClassFromString: failed to load class "$classstring);
    }
    else if( ClassIsChildOf(a, c) == false ) {
        err("GetClassFromString: " $ classstring $ " is not a subclass of " $ c.name);
        return None;
    }
    //l("GetClassFromString: found " $ classstring);
    return a;
}

final function Class<Inventory> ModifyInventoryClass( out Class<Inventory> InventoryClass )
{
#ifdef hx
    HXGameInfo(Level.Game).ModifyInventoryClass( InventoryClass );
#endif
    return InventoryClass;
}

final function Class<Actor> ModifyActorClass( out Class<Actor> ActorClass )
{
#ifdef hx
    HXGameInfo(Level.Game).ModifyActorClass( ActorClass );
#endif
    return ActorClass;
}

simulated final function #var PlayerPawn  player(optional bool quiet)
{
    local #var PlayerPawn  p;
    //p = #var PlayerPawn (GetPlayerPawn());
    p = dxr.Player;
    if( p == None ) {
        p = #var PlayerPawn (GetPlayerPawn());
        dxr.Player = p;
    }
    if( p == None && !quiet ) warning("player() found None");
    return p;
}

simulated static function string UnpackString(out string s)
{
    local int i, l;
    local string ret;
    l = Len(s);
    for(i=0; i<l; i++) {
        if( Mid(s, i, 1) == "," ) {
            ret = Left(s, i);
            s = Mid(s, i+1);
            return ret;
        }
    }
    ret = s;
    s="";
    return ret;
}

simulated static function string FloatToString(float f, int decimal_places)
{
    local int i;
    local string s;
    f += 0.5 * pow(10, -decimal_places);// round it instead of floor
    s = string(f);
    i = InStr(s, ".");
    if( i != -1 ) {
        s = Left(s, i+1+decimal_places);
    }
    return s;
}

//Based on function MessageBox from DeusExRootWindow
//msgBoxMode = 0 or 1, 0 = Yes/No box, 1 = OK box
//module will presumably be the module you are creating the message box for
//id lets you provide an ID so you can identify where the response should go
simulated function CreateMessageBox( String msgTitle, String msgText, int msgBoxMode, 
                           DXRBase module, int id, optional bool noPause) {
                           
    local DXRMessageBoxWindow msgBox;

    info(module$" CreateMessageBox "$msgTitle$" - "$msgText);

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(player().rootWindow).PushWindow(Class'DXRMessageBoxWindow', False, noPause ));
    msgBox.SetTitle(msgTitle);
    msgBox.SetMessageText(msgText);
    msgBox.SetMode(msgBoxMode);
    msgBox.SetCallback(module,id);
    msgBox.SetDeferredKeyPress(True);
}

//As above, except you can provide a list of button labels to use instead of Yes, no, or OK
//You can only fit 3 buttons along a box, and the labels can't be too long.
//7 Characters is about the label limit before the button box starts expanding.
//You can likely fit about 34ish characters between all three labels before it looks bad
simulated function CreateCustomMessageBox (String msgTitle, String msgText, int numBtns, String buttonLabels[3],
                                 DXRBase module, int id, optional bool noPause) {
    local DXRMessageBoxWindow msgBox;

    info(module$" CreateCustomMessageBox "$msgTitle$" - "$msgText);

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(player().rootWindow).PushWindow(Class'DXRMessageBoxWindow', False, noPause ));
    msgBox.SetTitle(msgTitle);
    msgBox.SetMessageText(msgText);
    msgBox.SetCustomMode(numBtns,buttonLabels);
    msgBox.SetCallback(module,id);
    msgBox.SetDeferredKeyPress(True);

}

//Implement this in your DXRBase subclass to handle message boxes for your particular needs
simulated function MessageBoxClicked(int button, int callbackId) {
    local DXRMessageBoxWindow msgBox;
    local string title, message;

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(player().rootWindow).GetTopWindow());
    if( msgBox != None ) {
        title = msgBox.winTitle.titleText;
        message = msgBox.winText.GetText();
    }
    
    if (msgBox.mbMode == 0 || msgBox.mbMode == 1) {
        switch(button) {
            case 0:
                info("MessageBoxClicked Yes: "$title$" - "$message);
                break;
            case 1:
                info("MessageBoxClicked No: "$title$" - "$message);
                break;
            case 2:
                info("MessageBoxClicked OK: "$title$" - "$message);
                break;
        }
    } else if (msgBox.mbMode == 2) {
        //Custom mode
        info("MessageBoxClicked "$msgBox.customBtn[button].buttonText$": "$title$" - "$message);
    }
    
    DXRMessageBoxWindow(DeusExRootWindow(player().rootWindow).PopWindow());

    //Implementations in subclasses just need to call Super to pop the window, then can handle the message however they want
    //Buttons:
    //Yes = 0
    //No = 1
    //OK = 2
}

simulated function AddDXRCredits(CreditsWindow cw) 
{
}


//consider this like debug or trace
simulated function l(coerce string message)
{
    log(message, class.name);

    /*if( (InStr(class'DXRFlags'.static.VersionString(), "Alpha")>=0 || InStr(class'DXRFlags'.static.VersionString(), "Beta")>=0) ) {
        class'Telemetry'.static.SendLog(Self, "DEBUG", message);
    }*/
}

simulated function info(coerce string message)
{
    log("INFO: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "INFO", message);
}

simulated function warning(coerce string message)
{
    log("WARNING: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "WARNING", message);
}

simulated function err(coerce string message, optional bool skip_player_message)
{
    log("ERROR: " $ message, class.name);
#ifdef singleplayer
    if(dxr != None && !skip_player_message && player() != None) {
        player().ClientMessage( Class @ message, 'ERROR' );
    }
#else
    BroadcastMessage(class.name$": ERROR: "$message, true, 'ERROR');
#endif

    class'DXRTelemetry'.static.SendLog(dxr, Self, "ERROR", message);
}

simulated function name StringToName(string s)
{
    return dxr.flagbase.StringToName(s);
}

final function StartRunTests()
{
    l(".RunTests() " $ dxr.localURL);
    passes = 0;
    fails = 0;
    RunTests();
}

function RunTests()
{
}

final function StartExtendedTests()
{// these are tests that depend on being in a real level
    l(".ExtendedTests() " $ dxr.localURL);
    passes = 0;
    fails = 0;
    ExtendedTests();
}

function ExtendedTests()
{
}

function bool test(bool result, string testname)
{
    if(result == true) {
        l("pass: "$testname);
        passes++;
        return true;
    }
    else {
        err("fail: "$testname);
        fails++;
        return false;
    }
}

function bool testbool(bool result, bool expected, string testname)
{
    if(result == expected) {
        l("pass: "$testname$": got "$result);
        passes++;
        return true;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected);
        fails++;
        return false;
    }
}

function bool testint(int result, int expected, string testname)
{
    if(result == expected) {
        l("pass: "$testname$": got "$result);
        passes++;
        return true;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected);
        fails++;
        return false;
    }
}

function bool testfloat(float result, float expected, string testname)
{
    if(result ~= expected) {
        //print both because they might not be exactly equal
        l("pass: "$testname$": got "$result$", expected "$expected);
        passes++;
        return true;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected);
        fails++;
        return false;
    }
}

function bool testfloatrange(float result, float expected, float range, string testname)
{
    local float diff;
    diff = abs(result-expected);
    if( diff <= range ) {
        //print both because they might not be exactly equal
        l("pass: "$testname$": got "$result$", expected "$expected$", with range "$range);
        passes++;
        return true;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected$", with range "$range);
        fails++;
        return false;
    }
}

function bool teststring(string result, string expected, string testname)
{
    if(result == expected) {
        l("pass: "$testname$": got "$result);
        passes++;
        return true;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected);
        fails++;
        return false;
    }
}

defaultproperties
{
    NetPriority=0.2
    bAlwaysRelevant=True
    bGameRelevant=True
    RemoteRole=ROLE_SimulatedProxy
}
