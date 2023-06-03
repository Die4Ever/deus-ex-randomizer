class DXRMapVariants extends DXRBase transient;

static function vector GetCoordsMult(string map)
{// DXRBase calls this in Init
    local vector v;
    local float f[3];
    local int a, b;
    local string s;

    b = Len(map);
    for(a=0; a <3 && b != -1; a++) {
        b = FindLast(Left(map, b), "_");
        if(b==-1) break;
        s = Mid(map, b+1);
        f[a] = float(s);
        if(f[a] ~= 0) break;
    }
    if(a==3) {
        v.X = f[2];
        v.Y = f[1];
        v.Z = f[0];
        return v;
    }

    return vect(1,1,1);
}

static function string CleanupMapName(string mapName)
{// do this when entering a level, called by DXRBacktracking LevelInit
    local vector v;
    local string s, ret;
    v = GetCoordsMult(mapName);
    s = "_" $ TrimTrailingZeros(v.X);
    s = s $ "_" $ TrimTrailingZeros(v.Y);
    s = s $ "_" $ TrimTrailingZeros(v.Z);
    ret = ReplaceText(mapName, s, "");
    log("CleanupMapName ReplaceText("$mapName$", "$s$", \"\") == "$ret, 'DXRMapVariants');
    return ret;
}

function PreTravel()
{// make the localURL match the filename, so saved data works correctly
    Super.PreTravel();
    dxr.dxInfo.mapName = GetURLMap();
}

simulated function FirstEntry()
{
    local Teleporter t;
    local MapExit me;

    player().strStartMap = VaryMap(player().strStartMap);

    foreach AllActors(class'Teleporter', t) {
        t.URL = VaryURL(t.URL);
    }
    foreach AllActors(class'MapExit', me) {
        me.DestMap = VaryURL(me.DestMap);
    }
}

simulated function AnyEntry()
{
    l(GetURLMap() @ coords_mult);
}

function string VaryURL(string url)
{
    local string map, after;
    local int i, t;

    i = Len(url);
    t = InStr(url, "?");
    if(t != -1 && t < i)
        i = t;
    t = InStr(url, "#");
    if(t != -1 && t < i)
        i = t;
    t = InStr(url, ".");
    if(t != -1 && t < i)
        i = t;

    map = Left(url, i);
    after = Mid(url, i);
    l("url=="$url$", map=="$map$", after=="$after);
    map = VaryMap(map);
    return map $ after;
}

function string VaryMap(string map)
{
    return map $"_-1_1_1";
}

function TestCoords(string mapName, string map, float x, float y, float z)
{
    local vector v;
    v = GetCoordsMult(map);
    testfloat(v.X, x, map $ " X");
    testfloat(v.Y, y, map $ " Y");
    testfloat(v.Z, z, map $ " Z");

    teststring(CleanupMapName(map), mapName, "CleanupMapName "$mapName);
}

function ExtendedTests()
{
    local vector v;
    v = GetCoordsMult(GetURLMap());
    l(GetURLMap() @ v);

    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_-1_1_1.dx", -1, 1, 1);
    TestCoords("DX.dx", "DX.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark_Test.dx", "02_NYC_BatteryPark_Test.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_1_1_1.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_0.1_1.2_-1.3.dx", 0.1, 1.2, -1.3);

    teststring(VaryURL("test#"), "test_-1_1_1#", "VaryURL");
    teststring(VaryURL("test"), "test_-1_1_1", "VaryURL");
    teststring(VaryURL("test.dx"), "test_-1_1_1.dx", "VaryURL");
}
