class DXRBase extends Info config(DXRando);

var transient DXRando dxr;
var transient int overallchances;
var config int config_version;

var transient int passes;
var transient int fails;

function Init(DXRando tdxr)
{
    l(Self$".Init()");
    dxr = tdxr;
    CheckConfig();
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        info("upgraded config from "$config_version$" to "$class'DXRFlags'.static.VersionNumber());
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
    local float mult, r, ret;
    mult = max - min;
    r = rngf();
    ret = val * (r * mult + min);
    //l("rngrange r: "$r$", mult: "$mult$", min: "$min$", max: "$max$", val: "$val$", return: "$ret);
    return ret;
}

function string RandoLevelValues(out float LevelValues[4], float DefaultLevelValues[4], float min, float max)
{
    local int i;
    local float min_val, avg;
    local string s, n;

    for(i=0; i<ArrayCount(LevelValues); i++) {
        avg += DefaultLevelValues[i];
    }
    avg /= float(ArrayCount(LevelValues));

    s = "(Old v1.5 Values: ";
    n = "(Raw Values: ";
    for(i=0; i<ArrayCount(LevelValues); i++) {
        LevelValues[i] = rngrange(DefaultLevelValues[i], min, max);
        if( i>0 && DefaultLevelValues[i-1] < DefaultLevelValues[i] && LevelValues[i] < min_val ) LevelValues[i] = min_val;
        else if( i>0 && DefaultLevelValues[i-1] > DefaultLevelValues[i] && LevelValues[i] > min_val ) LevelValues[i] = min_val;
        min_val = LevelValues[i];
        if( i>0 ) s = s $ ", ";

        if( LevelValues[i] == DefaultLevelValues[i] ) s = s $ "100%";
        else s = s $ int(LevelValues[i]/DefaultLevelValues[i]*100.0) $ "%";

        n = n $ "|n";
        n = n $ LevelValues[i] $ " / " $ DefaultLevelValues[i];
    }
    s = s $ ")";
    n = n $ ")";
    return s $ "|n|n" $ n;
}

function static int staticrng(DXRando dxr, int max)
{
    return dxr.rng(max);
}

function int initchance()
{
    if(overallchances > 0 && overallchances < 100) warning("initchance() overallchances == "$overallchances);
    overallchances=0;
    return rng(100);
}

function bool chance(int percent, int r)
{
    overallchances+=percent;
    if(overallchances>100) warning("chance("$percent$", "$r$") overallchances == "$overallchances);
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

static function string UnpackString(out string s)
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


//Based on function MessageBox from DeusExRootWindow
//msgBoxMode = 0 or 1, 0 = Yes/No box, 1 = OK box
//module will presumably be the module you are creating the message box for
//id lets you provide an ID so you can identify where the response should go
function CreateMessageBox( String msgTitle, String msgText, int msgBoxMode, 
                           DXRBase module, int id, optional bool noPause) {
                           
    local DXRMessageBoxWindow msgBox;

    info(module$" CreateMessageBox "$msgTitle$" - "$msgText);

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(dxr.Player.rootWindow).PushWindow(Class'DXRMessageBoxWindow', False, noPause ));
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
function CreateCustomMessageBox (String msgTitle, String msgText, int numBtns, String buttonLabels[3],
                                 DXRBase module, int id, optional bool noPause) {
    local DXRMessageBoxWindow msgBox;

    info(module$" CreateCustomMessageBox "$msgTitle$" - "$msgText);

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(dxr.Player.rootWindow).PushWindow(Class'DXRMessageBoxWindow', False, noPause ));
    msgBox.SetTitle(msgTitle);
    msgBox.SetMessageText(msgText);
    msgBox.SetCustomMode(numBtns,buttonLabels);
    msgBox.SetCallback(module,id);
    msgBox.SetDeferredKeyPress(True);

}

//Implement this in your DXRBase subclass to handle message boxes for your particular needs
function MessageBoxClicked(int button, int callbackId) {
    local DXRMessageBoxWindow msgBox;
    local string title, message;

    msgBox = DXRMessageBoxWindow(DeusExRootWindow(dxr.Player.rootWindow).GetTopWindow());
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
    
    DXRMessageBoxWindow(DeusExRootWindow(dxr.Player.rootWindow).PopWindow());

    //Implementations in subclasses just need to call Super to pop the window, then can handle the message however they want
    //Buttons:
    //Yes = 0
    //No = 1
    //OK = 2
}

//consider this like debug or trace
function l(string message)
{
    log(message, class.name);

    /*if( (InStr(class'DXRFlags'.static.VersionString(), "Alpha")>=0 || InStr(class'DXRFlags'.static.VersionString(), "Beta")>=0) ) {
        class'Telemetry'.static.SendLog(Self, "DEBUG", message);
    }*/
}

function info(string message)
{
    log("INFO: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "INFO", message);
}

function warning(string message)
{
    log("WARNING: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "WARNING", message);
}

function err(string message)
{
    log("ERROR: " $ message, class.name);
    if(dxr != None && dxr.Player != None) {
        dxr.Player.ClientMessage( Class @ message );
    }

    class'DXRTelemetry'.static.SendLog(dxr, Self, "ERROR", message);
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
        //print both because they might not be exaclty equal
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
