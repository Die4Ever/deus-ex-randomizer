#ifdef injections
class DXRInfo extends DXRVersion config(DXRando) abstract;
#else
class DXRInfo extends DXRVersion config(#var(package)) abstract;
#endif

var transient int passes;
var transient int fails;
var config int config_version;

simulated function class<Actor> GetClassFromString(string classstring, class<Actor> c, optional bool silent)
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
        if (!silent){
            err("GetClassFromString: failed to load class "$classstring);
        }
    }
    else if( ClassIsChildOf(a, c) == false ) {
        if (!silent){
            err("GetClassFromString: " $ classstring $ " is not a subclass of " $ c.name);
        }
        return None;
    }
    //l("GetClassFromString: found " $ classstring);
    return a;
}

function bool ConfigOlderThan(int major, int minor, int patch, int build)
{
    return VersionOlderThan(config_version, major, minor, patch, build);
}

function CheckConfig()
{
    if( config_version < VersionNumber() ) {
        info("upgraded config from "$config_version$" to "$VersionNumber());
        config_version = VersionNumber();
        SaveConfig();
    }
}

simulated function DXRando GetDXR()
{
    local DXRando dxr;
    foreach AllActors(class'DXRando', dxr) {
        return dxr;
    }
    return None;
}

simulated final function #var(PlayerPawn) player(optional bool quiet)
{
    local #var(PlayerPawn) p;
    local DXRando dxr;
    dxr = GetDXR();
    if(dxr != None) p = dxr.Player;
    if( p == None ) {
        p = #var(PlayerPawn)(GetPlayerPawn());
        if(p==None){ //If GetPlayerPawn() didn't work (probably in HX)
            foreach AllActors(class'#var(PlayerPawn)', p){break;}
        }
        if(dxr != None) dxr.Player = p;
    }
    if( p == None && !quiet ) warning("player() found None");
    return p;
}

/*
========= LOGGING FUNCTIONS
*/
simulated function debug(coerce string message)
{
#ifdef debug
    if(Len(message)>900)
        warning("Len(message)>900: "$Left(message, 500));
    else
        log(message, class.name);
#endif
}

//does not send to telemetry
simulated function l(coerce string message)
{
    if(Len(message)>900)
        warning("Len(message)>900: "$Left(message, 500));
    else
        log(message, class.name);

    /*if( (InStr(VersionString(), "Alpha")>=0 || InStr(VersionString(), "Beta")>=0) ) {
        class'Telemetry'.static.SendLog(Self, "DEBUG", message);
    }*/
}

simulated function info(coerce string message)
{
    if(Len(message)>900)
        warning("Len(message)>900: "$Left(message, 500));
    else
        log("INFO: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(GetDXR(), Self, "INFO", message);
}

simulated function warning(coerce string message)
{
    if(Len(message)>900)
        warning("Len(message)>900: "$Left(message, 500));
    else
        log("WARNING: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(GetDXR(), Self, "WARNING", message);
}

simulated function err(coerce string message, optional bool skip_player_message)
{
    if(Len(message)>900)
        err("Len(message)>900: "$Left(message, 500));
    else
        log("ERROR: " $ message, class.name);
#ifdef singleplayer
    if(!skip_player_message && player() != None) {
        player().ClientMessage( Class @ message, 'ERROR', true );
    }
#else
    BroadcastMessage(class.name$": ERROR: "$message, true, 'ERROR');
#endif

    class'DXRTelemetry'.static.SendLog(GetDXR(), Self, "ERROR", message);
}

static function OpenURL(PlayerPawn p, string url)
{
    class'DXRando'.default.dxr.bIsOpeningURL = true;
    p.ConsoleCommand("start " $ url);
    class'DXRando'.default.dxr.bIsOpeningURL = false;
}

static function int _SystemTime(LevelInfo Level)
{
    local int time, m;
    time = Level.Second + (Level.Minute*60) + (Level.Hour*3600) + (Level.Day*86400);

    switch(Level.Month) {
        // in case 12, we add the days of november not december, because we're still in december
        // all the cases roll over to add the other days of the year that have passed
        case 12:
            time += 30 * 86400;
        case 11:
            time += 31 * 86400;
        case 10:
            time += 30 * 86400;
        case 9:
            time += 31 * 86400;
        case 8:
            time += 31 * 86400;
        case 7:
            time += 30 * 86400;
        case 6:
            time += 31 * 86400;
        case 5:
            time += 30 * 86400;
        case 4:
            time += 31 * 86400;
        case 3:
            time += 28 * 86400;
        case 2:
            time += 31 * 86400;
    }

    time += (Level.Year-1970) * 86400 * 365;

    // leap years...
    time += (Level.Year-1)/4 * 86400;// leap year every 4th year
    time -= (Level.Year-1)/100 * 86400;// but not every 100th year
    time += (Level.Year-1)/400 * 86400;// unless it's also a 400th year
    // if the current year is a leap year, have we passed it?
    if ( (Level.Year % 4) == 0 && ( (Level.Year % 100) != 0 || (Level.Year % 400) == 0 ) && Level.Month > 2 )
        time += 86400;
    return time;
}

function bool IsAprilFools()
{
    // April Fools!
    return Level.Month == 4 && Level.Day == 1 && class'MenuChoice_ToggleMemes'.static.IsEnabled(GetDXR().flags);
}

function bool IsOctober()
{
    // Happy Halloween! This will be used for general halloween things like cosmetic changes and piano song weighting
    if(GetDXR().flags.IsHalloweenMode()) return true; // this takes priority over memes
    if(!class'MenuChoice_OctoberCosmetics'.static.IsEnabled(GetDXR().flags)) return false;
    return Level.Month == 10;
}

function bool IsHalloween()
{
    // Happy Halloween! This will be used for general halloween things like cosmetic changes and piano song weighting
    if(GetDXR().flags.IsHalloweenMode()) return true; // this takes priority over memes
    if(!class'MenuChoice_OctoberCosmetics'.static.IsEnabled(GetDXR().flags)) return false;
    return Level.Month == 10 && Level.Day == 31;
}

function bool IsFridayThe13th()
{// idk what we would use this for, giving the player "bad luck"? lol
    return Level.DayOfWeek == 5 && Level.Day == 13;
}

function bool DateAtLeast(int year, int month, int day)
{
    if(Level.Year > year) return true;
    if(Level.Year == year && Level.Month > month) return true;
    if(Level.Year == year && Level.Month == month && Level.Day >= day) return true;
    return false;
}

function bool IsChristmasSeason()
{
    if (Level.Month==11) return true;
    if (Level.Month==12 && Level.Day<=25) return true;
    return false;
}

static function bool OnTitleScreen()
{
    local DXRando dxr;
    dxr = class'DXRando'.default.dxr;
    if(dxr == None) return true;
    if (#defined(revision)){
        if (Left(dxr.LocalURL,9)~="BENCHMARK"){ //The animated main menus are the "BENCHMARK" maps
            return True;
        }
    }
    return dxr.LocalURL=="DX" || dxr.LocalURL=="DXONLY";
}

static function bool OnEndgameMap()
{
    local DXRando dxr;
    dxr = class'DXRando'.default.dxr;
    if(dxr == None) return true;
    return dxr.dxInfo.missionNumber == 99;
}

final function int SystemTime()
{
    return _SystemTime(Level);
}

/*
========= STRING FUNCTIONS
*/
simulated static function name StringToName(string s)
{
    return class'DXRando'.default.dxr.flagbase.StringToName(s);
}

simulated static final function string StripMapName(string s)
{
    local string stripped;
    local int i;
    for(i=0; i<Len(s); i++) {
        stripped = stripped $ ToAlphaNumeric(s, i);
    }
    return stripped;
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

static function int Ceil(float f)
{
    local int ret;
    ret = f;
    if( float(ret) < f )
        ret++;
    return ret;
}

static function int imod(int a, int b)
{// % converts to float in UnrealScript
    return a-(a/b*b);
}

static function int NumBitsSet(int mask)
{// get the number of set bits, or the number of missions in a mask
    local int num;

    while(mask != 0) {
        num += int((mask & 1) != 0);
        mask = mask >> 1;
    }
    return num;
}


static function string IntCommas(int i)
{
    local string s;
    local bool negative;
    local int j;
    if(i<0) {
        negative = true;
        i *= -1;
    }
    j = imod(i, 1000);
    if(i < 1000 || j >= 100)
        s = string(j);
    else if(j<10)
        s = "00" $ string(j);
    else
        s = "0" $ string(j);
    i/=1000;
    while(i>0) {
        j = imod(i, 1000);
        if(i < 1000 || j >= 100)
            s = string(j) $ "," $ s;
        else if(j<10)
            s = "00" $ string(j) $ "," $ s;
        else
            s = "0" $ string(j) $ "," $ s;
        i /= 1000;
    }
    if(negative)
        s = "-" $ s;
    return s;
}

simulated static function string FloatToString(float f, int decimal_places)
{
    local int i;
    local string s;
    f += 0.5 * (10 ** -decimal_places);// round it instead of floor
    s = string(f);
    i = InStr(s, ".");
    if( i != -1 ) {
        s = Left(s, i+1+decimal_places);
    }
    return s;
}

simulated static function String TruncateFloat(coerce string val, int numDec)
{
    local int truncPoint;

    truncPoint = InStr(val,".");

    if (truncPoint==-1){
        return val;
    }

    truncPoint++; //include the decimal point...
    truncPoint+=numDec;

    return Left(val,truncPoint);
}

simulated static function string TrimTrailingZeros(coerce string s)
{
    local int dec, end;

    dec = InStr(s, ".");
    if(dec == -1) return s;
    for(end=Len(s)-1; Mid(s, end, 1) == "0"; end--) {
    }
    if(Mid(s, end, 1) != ".")
        end++;
    return Left(s, end);
}

static static function string ToHex(int val)
{
    local int t;
    local string s;

    if(val==0) return "0";

    while(val!=0) {
        t = val & 0xf;
        val = val >>> 4;
        switch(t) {
        case 10: s="A"$s; break;
        case 11: s="B"$s; break;
        case 12: s="C"$s; break;
        case 13: s="D"$s; break;
        case 14: s="E"$s; break;
        case 15: s="F"$s; break;
        default: s = t $ s; break;
        }
    }
    return s;
}

static function string ActorToString( Actor a )
{
    local string out;
    out = a.Class.Name$"."$a.Name$"("$a.Location$")";
    if(a.tag != '')
        out = out @ a.tag;
    if( a.Base != None && a.Base.Class!=class'LevelInfo' )
        out = out $ " (Base:"$a.Base.Name$")";
    return out;
}

static function bool NamesAreSimilar(coerce string a, coerce string b)
{
    local int len_a, len_b;
    len_a = Len(a);
    len_b = Len(b);

    if( len_a - len_b < -1 ) return false;
    return Left( a, len_a-2 ) == Left( b, len_a-2 );
}

static function int FindLast(coerce string Text, coerce string search)
{
    local int last, a, b;
    last = -1;
    while(a != -1) {
        last = b - 1;
        a = InStr(Mid(Text, b), search);
        b += a + 1;
    }
    return last;
}

simulated static final function string ReplaceText(coerce string Text, coerce string Replace, coerce string With, optional bool word, optional int max)
{
    local int i, replace_len;
    local string Output, capsReplace;

    replace_len = Len(Replace);
    if(replace_len == 0) return Text;
    capsReplace = Caps(Replace);

    i = WordInStr( Caps(Text), capsReplace, replace_len, word );
    while (i != -1) {
        Output = Output $ Left(Text, i) $ With;
        Text = Mid(Text, i + replace_len);
        if(--max == 0) break;
        i = WordInStr( Caps(Text), capsReplace, replace_len, word);
    }
    Output = Output $ Text;
    return Output;
}

simulated static final function int WordInStr(coerce string Text, coerce string Replace, int replace_len, optional bool word)
{
    local int i, e;
    i = InStr(Text, Replace);
    if(word==false || i==-1) return i;

    if(i>0) {
        if( IsWordChar(Text, i-1) ) {
            e = WordInStr(Mid(Text, i+1), Replace, replace_len, word);
            if( e <= 0 ) return -1;
            return i+1+e;
        }
    }
    e = i + replace_len;
    if( e < Len(Text) ) {
        if( IsWordChar(Text, e) ) {
            e = WordInStr(Mid(Text, i+1), Replace, replace_len, word);
            if( e <= 0 ) return -1;
            return i+1+e;
        }
    }
    return i;
}

simulated static final function bool IsWordChar(coerce string Text, int index)
{
    local int c;
    c = Asc(Mid(Text, index, 1));
    if( c>=48 && c<=57) // 0-9
        return true;
    if( c>=65 && c<=90) // A-Z
        return true;
    if( c>=97 && c<=122) // a-z
        return true;
    if( c == 39 ) // apostrophe
        return true;
    return false;
}

simulated static final function string ToAlphaNumeric(coerce string Text, int index)
{
    local int c;
    c = Asc(Mid(Text, index, 1));
    if( c>=48 && c<=57) // 0-9
        return Mid(Text, index, 1);
    if( c>=65 && c<=90) // A-Z
        return Mid(Text, index, 1);
    if( c>=97 && c<=122) // a-z
        return Mid(Text, index, 1);
    return "_";
}

simulated static function String CR()
{
    return Chr(13) $ Chr(10);
}

/*
========= TEST FUNCTIONS
*/
final function StartRunTests()
{
    l(".RunTests() " $ GetDXR().localURL);
    passes = 0;
    fails = 0;
    RunTests();
}

function RunTests()
{
}

final function StartExtendedTests()
{// these are tests that depend on being in a real level
    l(".ExtendedTests() " $ GetDXR().localURL);
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
        debug("pass: "$testname);
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
        debug("pass: "$testname$": got "$result);
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
        debug("pass: "$testname$": got "$result);
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
        debug("pass: "$testname$": got "$result$", expected "$expected);
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
        debug("pass: "$testname$": got "$result$", expected "$expected$", with range "$range);
        passes++;
        return true;
    }
    else {
        err("fail: "$testname$": got "$result$", expected "$expected$", with range "$range);
        fails++;
        return false;
    }
}

function bool teststring(coerce string result, coerce string expected, coerce string testname)
{
    if(result == expected) {
        debug("pass: "$testname$": got "$result);
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
