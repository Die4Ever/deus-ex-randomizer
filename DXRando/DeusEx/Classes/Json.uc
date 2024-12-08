//////////////////////////////////////////////////////////////////////
//                  JSON Handling for UnrealScript                  //
//                                                                  //
//               Written by Die4Ever and TheAstropath               //
//                                                                  //
//  Report issues with this class at https://mods4ever.com/discord  //
//        or https://github.com/Die4Ever/deus-ex-randomizer         //
//////////////////////////////////////////////////////////////////////

class Json extends Info transient;
// singleton class

// #region Private Members
struct IntPair
{
    var int idx, len;
};

struct JsonElement
{
    var IntPair key;
    var IntPair value[10];// make sure to keep this in sync with get_vals
    var int valCount;
};

struct JsonMsg
{
    var JsonElement e[100];
    var int count;
};

var JsonMsg j;
var bool singleton;

// parsing state variables
var int i;
var IntPair p;
var int parsestate;
var int inBraces;
var string msg;
var string _buf;

// #endregion
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                    JSON PUBLIC INTERFACE                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #region Json Public Interface
static function Json parse(LevelInfo parent, string msg) {
    local Json o;
    foreach parent.AllActors(class'Json', o) {
        if(o.singleton) break;
    }
    if(o == None) {
        o = parent.Spawn(class'Json');
        o.singleton = true;
    }
    o._parse(msg);
    return o;
}

function int count() {
    return j.count;
}

function int max_count() {
    return ArrayCount(j.e);
}

function int max_values() {
    return ArrayCount(j.e[0].value);
}

function string get_string(IntPair i) {
    return Mid(_buf, i.idx, i.len);
}

function string key_at(int k) {
    return get_string(j.e[k].key);
}

function string at(int k, optional int i) {
    return get_string(j.e[k].value[i]);
}

function int find(string key) {
    local int k;

    for (k=0;k<j.count;k++) {
        if (get_string(j.e[k].key) == key) {
            return k;
        }
    }

    // error!
    return -1;
}

function int get_vals(string key, optional out string vals[10]) {
    local int l;
    local int k;

    k = find(key);
    if(k == -1)
        return 0;

    for(l=0; l < ArrayCount(vals); l++)
        vals[l] = get_string(j.e[k].value[l]);
    return j.e[k].valCount;
}

function int get_vals_count(string key) {
    local int k;
    k = find(key);
    if(k == -1)
        return 0;
    return j.e[k].valCount;
}

function string get(string key, optional int i) {
    local int k;
    k = find(key);
    if(k == -1)
        return "";
    return get_string(j.e[k].value[i]);
}

// #endregion
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                            JSON OUTPUT                                                   ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #region Json Output
static function string Start(string type)
{
    return "{\"type\":\"" $ type $ "\"";
}

static function Add(out string j, coerce string key, coerce string value)
{
    j = j $ ",\"" $ key $ "\":\"" $ JsonEscapeCharsInString(value) $ "\"";
}

static function End(out string j)
{
    j = j $ "}";
}

// #endregion
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                    INTERNAL JSON STUFF                                                   ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #region Internal Json Stuff

//JSON parsing states
const KeyState = 1;
const ValState = 2;
const ArrayState = 3;
const ArrayDoneState = 4;
const EndJsonState = 5;
const ObjectState = 6;

static function l(coerce string message, string j)
{
    local int length;

    length = Len(j);
    log(message $ " length: "$length, default.class.name);
    if(length > 500) {
        log("Left 200: "$Left(j, 200), default.class.name);
        log("Right 200: "$Right(j, 200), default.class.name);
    } else {
        log(j, default.class.name);
    }
}

static function StripQuotes(string msg, out IntPair p) {
    if (Mid(msg,p.idx,1)==Chr(34)) {
        if (Mid(msg,p.idx+p.len-1,1)==Chr(34)) {
            p.idx++;
            p.len-=2;
            return;
        }
    }
}

static function string JsonStripSpaces(string msg) {
    local int i, a, length, lastCurly;
    local string c;
    local string buf;
    local bool inQuotes;

    inQuotes = False;
    msg = Mid(msg, InStr(msg, "{"));

    length = Len(msg);
    for (i = 0; i < length; i++) {
        c = Mid(msg,i,1); //Grab a single character
        a = Asc(c);

        if (!inQuotes && (a<33 || a>126)) {
            continue;  //Don't add whitespace or invisible characters to the buffer if we're outside quotes
        } else if (a==34) {// 34 is "
            inQuotes = !inQuotes;
        } else if (a==125) {// 125 is }
            lastCurly = Len(buf)+1;
        }

        buf = buf $ c;
    }

    buf = Mid(buf, 0, lastCurly);

    return buf;
}

//Returns the appropriate character for whatever is after
//the backslash, eg \c
static function string JsonGetEscapedChar(string c) {
    switch(c){
        case "b":
            return Chr(8); //Backspace
        case "f":
            return Chr(12); //Form feed
        case "n":
            return Chr(10); //New line
        case "r":
            return Chr(13); //Carriage return
        case "t":
            return Chr(9); //Tab
        case "\"": //Quotes
        case "\\": //Backslash
            return c;
        default:
            return "";
    }
}


static function string JsonEscapeCharsInString(string inmsg) {
    local int i, a, length;
    local string buf, c;

    buf = "";
    length = Len(inmsg);
    for (i = 0; i < length; i++) {
        c = Mid(inmsg,i,1); //Grab a single character
        a = Asc(c);

        switch(a){
            case 34: //34 is "
                buf = buf $ Chr(92) $ Chr(34); // replaces with \ " (no space between slash and quotes - without the space UCC gets stuck)
                break;
            case 92: //92 is \
                buf = buf $ Chr(92) $ Chr(92); //Replaces with \\
                break;
            default:
                buf = buf $ c;
                break;
        }
    }
    return buf;
}


function int ParseKey(string msg, out int i, out IntPair p, out int inBraces) {
    local string c;

    for(i=i; i < Len(msg); i++) {
        c = Mid(msg,i,1); //Grab a single character
        switch (c) {
        case ":":
        case ",":
            //Wrap up the current string that was being handled
            StripQuotes(_buf, p);
            j.e[j.count].key = p;
            p.idx = Len(_buf);
            p.len = 0;
            return ValState;

        case "{":
            inBraces++;
            p.idx = Len(_buf);
            p.len = 0;
            break;

        case "}":
            inBraces--;
            if(inBraces <= 0)
                return EndJsonState;

        case "]":
            _buf = _buf $ c;
            p.len++;
            break;

        case "[":
            _buf = _buf $ c;
            p.len++;
            break;

        case "\"": //Quotes
            ParseQuotes(msg, i, p);
            break;

        default:
            //Build up the buffer
            _buf = _buf $ c;
            p.len++;
            break;
        }
    }
}

function int ParseVal(string msg, out int i, out IntPair p, out int inBraces) {
    local string c;

    for(i=i; i < Len(msg); i++) {
        c = Mid(msg,i,1); //Grab a single character
        switch (c) {
        case ":":
        case ",":
            j.e[j.count].value[j.e[j.count].valCount] = p;
            j.e[j.count].valCount++;
            j.count++;
            p.idx = Len(_buf);
            p.len = 0;
            return KeyState;

        case "{":
            inBraces++;
            p.idx = Len(_buf);
            p.len = 0;
            return ObjectState;

        case "}":
            inBraces--;
            if (inBraces <= 0) {
                j.e[j.count].value[j.e[j.count].valCount] = p;
                j.e[j.count].valCount++;
                j.count++;
                return EndJsonState;
            }
            break;

        case "]":
            _buf = _buf $ c;
            p.len++;
            break;

        case "[":
            return ArrayState;

        case "\"": // Quotes
            ParseQuotes(msg, i, p);
            break;

        default:
            //Build up the buffer
            _buf = _buf $ c;
            p.len++;
            break;
        }
    }
}

function int ParseArray(string msg, out int i, out IntPair p, out int inBraces) {
    local string c;

    for(i=i; i < Len(msg); i++) {
        c = Mid(msg,i,1); //Grab a single character
        switch (c) {
        case ":":
            // TODO: arrays of objects
            p.idx = Len(_buf);
            p.len = 0;
            break;

        case ",":
            j.e[j.count].value[j.e[j.count].valCount] = p;
            j.e[j.count].valCount++;
            p.idx = Len(_buf);
            p.len = 0;
            break;

        case "{":
            inBraces++;
            p.idx = Len(_buf);
            p.len = 0;
            return ObjectState;

        case "}":
            // TODO: arrays of objects
            inBraces--;
            break;

        case "]":
            j.e[j.count].value[j.e[j.count].valCount] = p;
            j.e[j.count].valCount++;
            j.count++;
            return ArrayDoneState;

        case "[":
            // TODO: arrays in arrays
            _buf = _buf $ c;
            p.len++;
            break;

        case "\"": //Quotes
            ParseQuotes(msg, i, p);
            break;

        default:
            //Build up the buffer
            _buf = _buf $ c;
            p.len++;
            break;
        }
    }
}

function int ParseObject(string msg, out int i, out IntPair p, out int inBraces) {
    local string c;
    // TODO: objects, probably store the keys as keys["parentkey.key"] = val

    for(i=i; i < Len(msg); i++) {
        c = Mid(msg,i,1); //Grab a single character
        switch (c) {
        case "{":
            inBraces++;
            p.idx = Len(_buf);
            p.len = 0;
            return ObjectState;

        case "}":
            inBraces--;
            return ArrayDoneState;

        default:
            //Build up the buffer
            _buf = _buf $ c;
            p.len++;
            break;
        }
    }
}

function int ParseArrayDone(string msg, out int i, out IntPair p, out int inBraces) {
    local string c;

    for(i=i; i < Len(msg); i++) {
        c = Mid(msg,i,1); //Grab a single character
        switch (c) {
        case ",":
            p.idx = Len(_buf);
            p.len = 0;
            return KeyState;

        case "}":
            inBraces--;
            if(inBraces <= 0)
                return EndJsonState;

        default:
            //Build up the buffer
            _buf = _buf $ c;
            p.len++;
            break;
        }
    }
}

function ParseQuotes(string msg, out int i, out IntPair p) {
    local string c;

    for(i=i+1; i < Len(msg); i++) {
        c = Mid(msg,i,1); //Grab a single character
        switch (c) {
        case "\"": //Quotes
            return;

        case "\\": //Backslash, escape character time
            i++;
            c = Mid(msg,i,1); //Grab a single character
            c = JsonGetEscapedChar(c);
            _buf = _buf $ c;
            p.len += Len(c);
            break;

        default:
            //Build up the buffer
            _buf = _buf $ c;
            p.len++;
            break;
        }
    }
}


function _parse(string tmsg) {
    StartParse(tmsg);
    if(! ParseIter(999999)) {
        log("ERROR: _parse ran too long, i: "$i);
    }
    msg = "";
}

function bool StartParse(string tmsg)
{
    local JsonMsg data;
    parsestate = KeyState;
    j = data;// clear the global

    //Strip any spaces outside of strings to standardize the input a bit
    msg = JsonStripSpaces(tmsg);
    if( Len(msg) < 2 ) {
        parsestate = EndJsonState;
        l(".StartParse IsJson failed!", msg);
        return false;
    }

    _buf = "";
    i = 0;
    return true;
}

function bool ParseIter(int num)
{
    // returns false when done, so you can easily while loop on it
    for(num=num+i; i<num; i++) {
        //log("ParseIter state: "$parsestate);
        switch(parsestate) {
        case KeyState:
            parsestate = ParseKey(msg, i, p, inBraces);
            break;
        case ValState:
            parsestate = ParseVal(msg, i, p, inBraces);
            break;
        case ArrayState:
            parsestate = ParseArray(msg, i, p, inBraces);
            break;
        case ArrayDoneState:
            parsestate = ParseArrayDone(msg, i, p, inBraces);
            break;
        case ObjectState:
            parsestate = ParseObject(msg, i, p, inBraces);
            break;
        case EndJsonState:
            return true;
        }
    }
    return false;
}
// #endregion
