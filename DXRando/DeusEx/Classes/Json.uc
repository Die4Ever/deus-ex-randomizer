class Json extends Object transient;
// singleton class

//JSON parsing states
const KeyState = 1;
const ValState = 2;
const ArrayState = 3;
const ArrayDoneState = 4;
const EndState = 5;

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

var string _buf;
var JsonMsg j;

function _parse(string msg) {
    ParseJson(msg);
}

static function Json parse(LevelInfo parent, string msg, optional Json o) {
    if(o == None)
        foreach parent.AllObjects(class'json', o)
            break;
    if(o == None)
        o = new(parent) class'json';
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
    local int i;
    local int k;

    k = find(key);
    if(k == -1)
        return 0;

    for(i=0; i < ArrayCount(vals); i++)
        vals[i] = get_string(j.e[k].value[i]);
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                    INTERNAL JSON STUFF                                                   ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

static function bool _IsJson(string msg) {
    // we've already run JsonStripSpaces
    if (Mid(msg, 0, 1) != "{") {
        l("_IsJson missing opening curly brace:", msg);
        return false;
    }
    if (Mid(msg, Len(msg)-1, 1) != "}") {
        l("_IsJson missing closing curly brace:", msg);
        return false;
    }

    return true;
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
                return EndState;

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
            break;

        case "}":
            inBraces--;
            if (inBraces <= 0) {
                j.e[j.count].value[j.e[j.count].valCount] = p;
                j.e[j.count].valCount++;
                j.count++;
                return EndState;
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
            break;

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
                return EndState;

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

function ParseJson(string msg) {
    local int i;
    local IntPair p;
    local int parsestate;
    local int inBraces;
    local JsonMsg data;

    parsestate = KeyState;

    //Strip any spaces outside of strings to standardize the input a bit
    msg = JsonStripSpaces(msg);
    if( ! _IsJson(msg) ) {
        l(".ParseJson IsJson failed!", msg);
        return;
    }

    _buf = "";
    j = data;// clear the global

    //l("ParseJson start", msg);
    for(i=0; i<999999; i++) {
        //log("ParseJson state: "$parsestate);
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
        case EndState:
            return;
        }
    }
    //log("ERROR: ParseJson ran too long, i: "$i);
}
