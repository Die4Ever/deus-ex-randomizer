class Json extends Object transient;
// singleton class

//JSON parsing states
const KeyState = 1;
const ValState = 2;
const ArrayState = 3;
const ArrayDoneState = 4;

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
var JsonMsg _data;

function _parse(string msg) {
    _data = ParseJson(msg);
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
    return _data.count;
}

function int max_count() {
    return ArrayCount(_data.e);
}

function int max_values() {
    return ArrayCount(_data.e[0].value);
}

function string get_string(IntPair i) {
    return Mid(_buf, i.idx, i.len);
}

function string key_at(int k) {
    return get_string(_data.e[k].key);
}

function string at(int k, optional int i) {
    return get_string(_data.e[k].value[i]);
}

function int find(string key) {
    local int i;
    local int j;

    for (i=0;i<_data.count;i++) {
        if (get_string(_data.e[i].key) == key) {
            return i;
        }
    }

    // error!
    return -1;
}

function int get_vals(string key, optional out string vals[10]) {
    local int i;
    local int j;

    i = find(key);
    if(i == -1)
        return 0;

    for(j=0; j < ArrayCount(vals); j++)
        vals[j] = get_string(_data.e[i].value[j]);
    return _data.e[i].valCount;
}

function int get_vals_count(string key) {
    local int i;
    i = find(key);
    if(i == -1)
        return 0;
    return _data.e[i].valCount;
}

function string get(string key, optional int v) {
    local int i;
    i = find(key);
    if(i == -1)
        return "";
    return get_string(_data.e[i].value[v]);
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
        case Chr(34): //Quotes
        case Chr(92): //Backslash
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

function JsonMsg ParseJson(string msg) {
    local int i, length;
    local IntPair p;
    local string c;
    //local string buf;

    local int parsestate;
    local bool inquotes;
    local bool escape;
    local int inBraces;

    local JsonMsg j;

    local bool elemDone;

    elemDone = False;

    parsestate = KeyState;
    inquotes = False;
    escape = False;

    //Strip any spaces outside of strings to standardize the input a bit
    msg = JsonStripSpaces(msg);
    if( ! _IsJson(msg) ) {
        l(".ParseJson IsJson failed!", msg);
        return j;
    }

    _buf = "";

    // we set the length to -1 to end the loop
    length = Len(msg);
    for (i = 0; i < length; i++) {
        c = Mid(msg,i,1); //Grab a single character

        if (!inQuotes) {
            switch (c) {
                case ":":
                case ",":
                    //Wrap up the current string that was being handled
                    if (parsestate == KeyState) {
                        StripQuotes(_buf, p);
                        j.e[j.count].key = p;
                        parsestate = ValState;
                    } else if (parsestate == ValState) {
                        j.e[j.count].value[j.e[j.count].valCount] = p;
                        j.e[j.count].valCount++;
                        parsestate = KeyState;
                        elemDone = True;
                    } else if (parsestate == ArrayState) {
                        // TODO: arrays of objects
                        if (c != ":") {
                            j.e[j.count].value[j.e[j.count].valCount] = p;
                            j.e[j.count].valCount++;
                        }
                    } else if (parsestate == ArrayDoneState){
                        parseState = KeyState;
                    }
                    p.idx = Len(_buf);
                    p.len = 0;
                    break; // break for colon and comma

                case "{":
                    inBraces++;
                    p.idx = Len(_buf);
                    p.len = 0;
                    break;

                case "}":
                    inBraces--;
                    if (inBraces == 0 && parsestate == ValState) {
                        j.e[j.count].value[j.e[j.count].valCount] = p;
                        j.e[j.count].valCount++;
                        parsestate = KeyState;
                        elemDone = True;
                    }
                    if (parsestate == ArrayState) {
                        // TODO: arrays of objects
                    }
                    else if(inBraces > 0) {
                        // TODO: sub objects
                    }
                    else {
                        // last loop iteration
                        length = -1;
                    }
                    break;

                case "]":
                    if (parsestate == ArrayState) {
                        j.e[j.count].value[j.e[j.count].valCount] = p;
                        j.e[j.count].valCount++;
                        elemDone = True;
                        parsestate = ArrayDoneState;
                    } else {
                        _buf = _buf $ c;
                        p.len++;
                    }
                    break;
                case "[":
                    if (parsestate == ValState){
                        parsestate = ArrayState;
                    } else {
                        _buf = _buf $ c;
                        p.len++;
                    }
                    break;
                case Chr(34): //Quotes
                    inQuotes = !inQuotes;
                    break;
                default:
                    //Build up the buffer
                    _buf = _buf $ c;
                    p.len++;
                    break;

            }
        } else {
            switch(c) {
                case Chr(34): //Quotes
                    if (escape) {
                        escape = False;
                        c = JsonGetEscapedChar(c);
                        _buf = _buf $ c;
                        p.len += Len(c);
                    } else {
                        inQuotes = !inQuotes;
                    }
                    break;
                case Chr(92): //Backslash, escape character time
                    if (escape) {
                        //If there has already been one, then we need to turn it into the right char
                        escape = False;
                        c = JsonGetEscapedChar(c);
                        _buf = _buf $ c;
                        p.len += Len(c);
                    } else {
                        escape = True;
                    }
                    break;
                default:
                    //Build up the buffer
                    if (escape) {
                        escape = False;
                        c = JsonGetEscapedChar(c);
                        _buf = _buf $ c;
                        p.len += Len(c);
                    } else {
                        _buf = _buf $ c;
                        p.len++;
                    }
                    break;
            }
        }

        if (elemDone) {
          j.count++;
          elemDone = False;
        }
    }

    return j;
}
