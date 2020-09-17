class DXRBase extends Info config(DXRando);

var transient DXRando dxr;
var transient int overallchances;
var config int config_version;

function Init(DXRando tdxr)
{
    l(".Init()");
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
    l(".FirstEntry()");
}

function AnyEntry()
{
    l(".AnyEntry()");
}

function ReEntry()
{
    l(".ReEntry()");
}

function PreTravel()
{
    l(".PreTravel()");
    dxr = None;
    SetTimer(0, False);
}

function Timer()
{
}

event Destroyed()
{
    l(".Destroyed()");
    dxr = None;
    Super.Destroyed();
}

function SetSeed(coerce string name)
{
    dxr.SetSeed( dxr.Crc(dxr.seed $ "MS_" $ dxr.dxInfo.MissionNumber $ dxr.localURL $ name) );
}

function int rng(int max)
{
    return dxr.rng(max);
}

function float rngf()
{// 0 to 1.0
    return float(dxr.rng(1000001))/1000000.0;
}

function float rngfn()
{// -1.0 to 1.0
    return rngf() * 2.0 - 1.0;
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
        err("failed to load class "$classstring);
    }
    else if( ClassIsChildOf(a, c) == false ) {
        err(classstring $ " is not a subclass of " $ c.name);
        return None;
    }
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
    l(".RunTests()");
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
