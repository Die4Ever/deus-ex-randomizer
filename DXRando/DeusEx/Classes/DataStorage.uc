class DataStorage extends Inventory config(DXRDataStorage);

struct KVP {
    var string key;
    var string value;
    var int expiration;
};

var config KVP config_data[128];
var travel KVP var_data[128];

function int SystemTime()
{
    local int time;
    time = Level.Second + (Level.Minute*60) + (Level.Hour*3600) + (Level.Day*86400);
    //TODO: the length of a month or year varies...
    time += Level.Month * 86400 * 30;
    time += (Level.Year-2000) * 86400 * 365;
    return time;
}

function static DataStorage GetObj(DeusExPlayer p)
{
    local DataStorage d;
    d = DataStorage(p.FindInventoryType(class'DataStorage'));
    if( d == None )
        d = DataStorage(class'DXRActorsBase'.static.GiveItem(p, class'DataStorage'));
    return d;
}

function string GetConfigKey(string key)
{
    local int i;
    for( i=0; i < ArrayCount(config_data); i++) {
        if( config_data[i].key == key ) {
            if( IsData(config_data[i]) ) return config_data[i].value;
            else return "";
        }
    }
    return "";
}

function string GetConfigIndex(int i, optional out string key)
{
    if( IsData(config_data[i]) ) {
        key = config_data[i].key;
        return config_data[i].value;
    }
    else return "";
}

function bool SetConfig(string key, string value, optional int expire_seconds)
{
    local int i;
    for( i=0; i < ArrayCount(config_data); i++) {
        if( config_data[i].key == key ) {
            if( SetKVP(config_data[i], key, value, expire_seconds) ) {
                SaveConfig();
                return true;
            }
            else return false;
        }
    }
    for( i=0; i < ArrayCount(config_data); i++) {
        if( ! IsData(config_data[i]) ) {
            if( SetKVP(config_data[i], key, value, expire_seconds) ) {
                SaveConfig();
                return true;
            }
            else return false;
        }
    }
    return false;
}

function string GetVariableKey(string key)
{
    local int i;
    for( i=0; i < ArrayCount(var_data); i++) {
        if( var_data[i].key == key ) {
            if( IsData(var_data[i]) ) return var_data[i].value;
            else return "";
        }
    }
    return "";
}

function string GetVariableIndex(int i, optional out string key)
{
    if( IsData(var_data[i]) ) {
        key = var_data[i].key;
        return var_data[i].value;
    }
    return "";
}

function bool SetVariable(string key, string value, optional int expire_seconds)
{
    local int i;
    for( i=0; i < ArrayCount(var_data); i++) {
        if( var_data[i].key == key ) return SetKVP(var_data[i], key, value, expire_seconds);
    }
    for( i=0; i < ArrayCount(var_data); i++) {
        if( ! IsData(var_data[i]) ) return SetKVP(var_data[i], key, value, expire_seconds);
    }
    return false;
}

function bool IsData(KVP data)
{
    // subtraction is more resistant to integer overflow than just doing a < operator
    if( data.expiration != 0 && data.expiration - SystemTime() < 0 ) return false;
    if( data.key == "" ) return false;
    if( data.value == "" ) return false;
    return true;
}

function bool SetKVP(out KVP data, string key, string value, optional int expire_seconds)
{
    data.key = key;
    data.value = value;
    if( expire_seconds == 0 ) data.expiration = 0;
    else data.expiration = expire_seconds + SystemTime(); 
    return true;
}

defaultproperties
{
    bDisplayableInv=False
    ItemName="DataStorage"
    bHidden=True
}
