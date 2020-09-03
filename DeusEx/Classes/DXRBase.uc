class DXRBase extends Info;

var transient DXRando dxr;
var transient int overallchances;

function Init(DXRando tdxr)
{
    l(".Init()");
    dxr = tdxr;
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

function SetSeed(string name)
{
    dxr.SetSeed( dxr.Crc(dxr.seed $ "MS_" $ dxr.dxInfo.MissionNumber $ dxr.localURL $ name) );
}

function int rng(int max)
{
    return dxr.rng(max);
}

function int initchance()
{
    if(overallchances > 0 && overallchances < 100) l("initchance() overallchances == "$overallchances);
    overallchances=0;
    return rng(100);
}

function bool chance(int percent, int r)
{
    overallchances+=percent;
    if(overallchances>100) l("chance("$percent$", "$r$") overallchances == "$overallchances);
    return r>= (overallchances-percent) && r< overallchances;
}

function bool chance_single(int percent)
{
    return rng(100) < percent;
}

function l(string message)
{
    log(message, class.name);
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
        l("fail: "$testname);
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
        l("fail: "$testname$": got "$result$", expected "$expected);
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
        l("fail: "$testname$": got "$result$", expected "$expected);
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
        l("fail: "$testname$": got "$result$", expected "$expected);
        return 1;
    }
}
