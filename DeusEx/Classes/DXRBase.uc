class DXRBase extends Info config(DXRando);

var transient DXRando dxr;
var transient int overallchances;
var config int config_version;

function Init(DXRando tdxr)
{
    l(Self$".Init()");
    dxr = tdxr;
    CheckConfig();
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        l("upgrading config from "$config_version$" to "$class'DXRFlags'.static.VersionNumber());
        config_version = class'DXRFlags'.static.VersionNumber();
        SaveConfig();
    }
}

function FirstEntry()
{
    l(Self$".FirstEntry()");
}

function AnyEntry()
{
    l(Self$".AnyEntry()");
}

function ReEntry()
{
    l(Self$".ReEntry()");
}

function PreTravel()
{
    l(Self$".PreTravel()");
    dxr = None;
    SetTimer(0, False);
}

function Timer()
{
}

event Destroyed()
{
    l(Self$".Destroyed()");
    dxr = None;
    Super.Destroyed();
}

function int SetSeed(coerce string name)
{
    return dxr.SetSeed( dxr.Crc(dxr.seed $ "MS_" $ dxr.dxInfo.MissionNumber $ dxr.localURL $ name) );
}

function int rng(int max)
{
    return dxr.rng(max);
}

function float rngf()
{// 0 to 1.0
    local float f;
    f = float(dxr.rng(100001))/100000.0;
    //l("rngf() "$f);
    return f;
}

function float rngfn()
{// -1.0 to 1.0
    return rngf() * 2.0 - 1.0;
}

function float rngrange(float val, float min, float max)
{
    local float mult;
    mult = max - min;
    return val * (rngf() * mult + min);
}

function string RandoLevelValues(out float LevelValues[4], float DefaultLevelValues[4], float min, float max)
{
    local int i;
    local float min_val;
    local string s;

    s = "(Values: ";
    for(i=0; i<ArrayCount(LevelValues); i++) {
        LevelValues[i] = rngrange(DefaultLevelValues[i], min, max);
        if( i>0 && DefaultLevelValues[i-1] < DefaultLevelValues[i] && LevelValues[i] < min_val ) LevelValues[i] = min_val;
        else if( i>0 && DefaultLevelValues[i-1] > DefaultLevelValues[i] && LevelValues[i] > min_val ) LevelValues[i] = min_val;
        min_val = LevelValues[i];
        if( i>0 ) s = s $ ", ";
        s = s $ int(LevelValues[i]/DefaultLevelValues[i]*100.0) $ "%";
    }
    s = s $ ")";
    return s;
}

function static int staticrng(DXRando dxr, int max)
{
    return dxr.rng(max);
}

function int initchance()
{
    if(overallchances > 0 && overallchances < 100) l("WARNING: initchance() overallchances == "$overallchances);
    overallchances=0;
    return rng(100);
}

function bool chance(int percent, int r)
{
    overallchances+=percent;
    if(overallchances>100) l("WARNING: chance("$percent$", "$r$") overallchances == "$overallchances);
    return r>= (overallchances-percent) && r< overallchances;
}

function bool chance_remaining(int r)
{
    local int percent;
    percent = 100 - overallchances;
    return chance(percent, r);
}

function bool chance_single(int percent)
{
    return rng(100) < percent;
}

function class<Actor> GetClassFromString(string classstring, class<Actor> c)
{
    local class<Actor> a;
    if( InStr(classstring, ".") == -1 )
        classstring = "DeusEx." $ classstring;
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

function l(string message)
{
    log(message, class.name);
}

function err(string message)
{
    log("ERROR: " $ message, class.name);
    if(dxr != None && dxr.Player != None) {
        dxr.Player.ClientMessage( Class @ message );
    }
}

function int RunTests()
{
    l(".RunTests() " $ dxr.localURL);
    return 0;
}

function int test(bool result, string testname)
{
    if(result == true) {
        l("pass: "$testname);
        return 0;
    }
    else {
        err("fail: "$testname);
        return 1;
    }
}

function int testbool(bool result, bool expected, string testname)
{
    if(result == expected) {
        l("pass: "$testname$": got "$result);
        return 0;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected);
        return 1;
    }
}

function int testint(int result, int expected, string testname)
{
    if(result == expected) {
        l("pass: "$testname$": got "$result);
        return 0;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected);
        return 1;
    }
}

function int teststring(string result, string expected, string testname)
{
    if(result == expected) {
        l("pass: "$testname$": got "$result);
        return 0;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected);
        return 1;
    }
}
