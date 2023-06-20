class DXRMapVariants extends DXRBase transient;

static function bool MirrorMapsAvailable()
{
    local GameDirectory mapDir;
    local bool ret;
    local int mapIndex;
    local String mapFileName;
    local vector v;

    // Create our Map Directory class
    mapDir = new(None) Class'GameDirectory';
    mapDir.SetDirType(mapDir.EGameDirectoryTypes.GD_Maps);
    mapDir.GetGameDirectory();

    for( mapIndex=0; mapIndex<mapDir.GetDirCount(); mapIndex++)
    {
        mapFileName = mapDir.GetDirFilename(mapIndex);
        v = GetCoordsMult(mapFileName);
        if(v.X<0 || v.Y<0) {
            ret = true;
            break;
        }
    }

    CriticalDelete( mapDir );
    mapDir = None;
    return ret;
}

static function string GetVariantName(string map)
{
    local vector coordsMult;

    coordsMult = GetCoordsMult(map);

    if (coordsMult.X==1 && coordsMult.Y==1 && coordsMult.Z==1){
        return ""; //Normal
    } else if (coordsMult.X==-1 && coordsMult.Y==1 && coordsMult.Z==1){
        return "Mirrored";
    }

    return coordsMult.X$","$coordsMult.Y$","$coordsMult.Z;
}

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

static function string GetMapPostfix(vector v)
{
    local string s;
    if(v.X!=1 || v.Y!=1 || v.Z!=1) {
        s = "_" $ TrimTrailingZeros(v.X);
        s = s $ "_" $ TrimTrailingZeros(v.Y);
        s = s $ "_" $ TrimTrailingZeros(v.Z);
    }
    return s;
}

static function string CleanupMapName(string mapName)
{// do this when entering a level, called by DXRBacktracking LevelInit
    local vector v;
    local string s, ret;
    v = GetCoordsMult(mapName);
    s = GetMapPostfix(v);
    ret = ReplaceText(mapName, s, "");
    log("CleanupMapName ReplaceText("$mapName$", "$s$", \"\") == "$ret, 'DXRMapVariants');
    return ret;
}

static function string GetDirtyMapName(string map, vector v)
{
    local string post;
    post = GetMapPostfix(v);
    if(InStr(map, post) == -1)
        return map $ post;
    return map;
}

function int GetMirrorMapsSetting()
{
    return dxr.flags.mirroredmaps;
}

simulated function FirstEntry()
{
    local Teleporter t;
    local MapExit me;
    local string s;

    s = CleanupMapName(dxr.dxInfo.mapName);
    dxr.dxInfo.mapName = GetDirtyMapName(s, coords_mult);

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
    if(i==0) return url;
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
    l("VaryURL url=="$url$", map=="$map$", after=="$after);
    map = VaryMap(map);
    l("VaryURL newmap=="$map);
    return map $ after;
}

function string VaryMap(string map)
{
    local int chance;
    map = CleanupMapName(map);
    chance = GetMirrorMapsSetting();
    if(chance_single(chance))
        return map $"_-1_1_1";
    return map;
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
    local int oldseed;
    v = GetCoordsMult(GetURLMap());
    l(GetURLMap() @ v);

    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_-1_1_1.dx", -1, 1, 1);
    TestCoords("DX.dx", "DX.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark_Test.dx", "02_NYC_BatteryPark_Test.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_1_2_1.dx", 1,2,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_0.1_1.2_-1.3.dx", 0.1, 1.2, -1.3);

    /*oldseed = dxr.seed;
    dxr.seed = 111;// fragile dependency on rng
    teststring(VaryURL("test#"), "test_-1_1_1#", "VaryURL");
    teststring(VaryURL("test"), "test_-1_1_1", "VaryURL");
    teststring(VaryURL("test.dx"), "test_-1_1_1.dx", "VaryURL");
    dxr.seed = oldseed;*/
}
