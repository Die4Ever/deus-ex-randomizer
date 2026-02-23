class DXRMapVariants extends DXRBase transient;

var int missions[13];
var string starts[13];

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
    //log("CleanupMapName ReplaceText("$mapName$", "$s$", \"\") == "$ret, 'DXRMapVariants');
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


static function bool IsRevisionMaps(#var(PlayerPawn) player, optional Bool init)
{
#ifndef revision
    return False;
#else
    local RevMenuChoice_Maps mapMenu;
    local Bool rc;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (init){
        mapMenu = new(None) class'RevMenuChoice_Maps';
        mapMenu.player = player;
        mapMenu.LoadSetting();

        //Check to see if Revision is using Revision or Vanilla maps...
        if (mapMenu.GetValue()==0){
            //0 = Vanilla
            rc = False;
        } else {
            rc = True;
        }
        CriticalDelete(mapMenu);
        //player.ClientMessage("RevisionMapsInit: "$rc);
    } else {
        rc = dxr.RevisionMaps;
        //player.ClientMessage("RevisionMapsCache: "$rc);
    }
    return rc;
#endif
}

static function bool IsVanillaMaps(#var(PlayerPawn) player)
{
    if(#defined(vanillamaps)) return true;
    if(#defined(revision)) return !IsRevisionMaps(player);
    return false;
}

function int GetMirrorMapsSetting()
{
#ifndef injections
    return -1; //Ignore the mirroredmaps setting, since we don't support them without injections
#endif
    return dxr.flags.mirroredmaps;
}

function CheckConfig()
{
    local int i, slot, tempi, startidx;
    local string temp;

    Super.CheckConfig();

    SetGlobalSeed( "SpeedrunShuffle maps " $ dxr.seed);
    startidx = ArrayCount(starts)-2;// length - 2 because Area 51 is not shuffled
    if(dxr.flags.moresettings.entrance_rando > 0) { // entrance rando combines 10+11 and 12+14
        starts[9] = starts[10];
        starts[10] = starts[12];

        missions[9] = missions[10];
        missions[10] = missions[12];

        startidx -= 2;
    }
    for(i=startidx; i>=0; i--) {
        slot = rng(i+1);

        temp = starts[i];
        starts[i] = starts[slot];
        starts[slot] = temp;

        tempi = missions[i];
        missions[i] = missions[slot];
        missions[slot] = tempi;
    }
    for(i=0; i<startidx+2; i++) {
        l("speedshuffle " $ i @ starts[i]);
    }
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

static function int SplitMapName(string url)
{
    local int i, t;

    i = Len(url);
    if(i==0) return 0;

    t = InStr(url, "?");
    if(t != -1 && t < i)
        i = t;
    t = InStr(url, "#");
    if(t != -1 && t < i)
        i = t;
    t = InStr(url, ".");
    if(t != -1 && t < i)
        i = t;

    return i;
}

function string VaryURL(string url)
{
    local string map, after;
    local int i;

    i = SplitMapName(url);
    map = Left(url, i);
    after = Mid(url, i);
    l("VaryURL url=="$url$", map=="$map$", after=="$after);
    map = VaryMap(map);
    l("VaryURL newmap=="$map);
    return map $ after;
}

function string VaryMap(string map)
{
    local int chance, i;
    local bool isStartMap;
    local string nextMap;
    map = CleanupMapName(map);

    switch (map){
        case "DX":
        case "DXONLY":
            //Never go to the mirrored versions of the intro screen
            //It's unnecessary, and the camera rotation is messed up
            return map;
    }

    if(dxr.flags.gamemode == dxr.flags.SpeedShuffle) {
        for(i=0; i<ArrayCount(starts); i++) {
            if(missions[i] == dxr.dxInfo.MissionNumber) nextMap = starts[i+1];
            if(map ~= starts[i]) isStartMap = true; // only if this teleporter is going to a starting map
        }
        if(isStartMap) {
            if(dxr.dxInfo.MissionNumber == 98) nextMap = starts[0]; // coming from the intro
            if(nextMap != "") map = nextMap;
        }
    }

    chance = GetMirrorMapsSetting();
    SetGlobalSeed( "VaryURL " $ Caps(map) );
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
    local int oldmirroredmaps;
    v = GetCoordsMult(GetURLMap());
    l(GetURLMap() @ v);

    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_-1_1_1.dx", -1, 1, 1);
    TestCoords("02_NYC_BatteryPark#tele", "02_NYC_BatteryPark_-1_1_1#tele", -1, 1, 1);
    TestCoords("DX.dx", "DX.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark_Test.dx", "02_NYC_BatteryPark_Test.dx", 1,1,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_1_2_1.dx", 1,2,1);
    TestCoords("02_NYC_BatteryPark.dx", "02_NYC_BatteryPark_0.1_1.2_-1.3.dx", 0.1, 1.2, -1.3);

    #ifdef injections
    oldmirroredmaps = dxr.flags.mirroredmaps;
    dxr.flags.mirroredmaps = 100;
    teststring(VaryURL("test#"), "test_-1_1_1#", "VaryURL 1");
    teststring(VaryURL("test#tele"), "test_-1_1_1#tele", "VaryURL 2");
    teststring(VaryURL("test"), "test_-1_1_1", "VaryURL 3");
    teststring(VaryURL("test.dx"), "test_-1_1_1.dx", "VaryURL 4");
    teststring(VaryURL("test?query=param"), "test_-1_1_1?query=param", "VaryURL 5");

    //DX and DXONLY shouldn't ever return mirrored versions
    teststring(VaryURL("DX.dx"), "DX.dx", "VaryURL 6");
    teststring(VaryURL("DX"), "DX", "VaryURL 7");
    teststring(VaryURL("DXOnly.dx"), "DXOnly.dx", "VaryURL 8");
    teststring(VaryURL("DXOnly"), "DXOnly", "VaryURL 9");
    dxr.flags.mirroredmaps = oldmirroredmaps;
    #endif
}

defaultproperties
{
    starts(0)="01_NYC_UNATCOIsland"
    starts(1)="02_NYC_BatteryPark"
    starts(2)="03_NYC_UNATCOIsland"
    starts(3)="04_NYC_UNATCOIsland"
    starts(4)="05_NYC_UNATCOMJ12lab"
    starts(5)="06_HongKong_Helibase"
    starts(6)="08_NYC_Street"
    starts(7)="09_NYC_Dockyard"
    starts(8)="10_Paris_Catacombs"
    starts(9)="11_Paris_Cathedral"
    starts(10)="12_Vandenberg_Cmd"
    starts(11)="14_Vandenberg_Sub"
    starts(12)="15_Area51_Bunker"
    missions(0)=1
    missions(1)=2
    missions(2)=3
    missions(3)=4
    missions(4)=5
    missions(5)=6
    missions(6)=8
    missions(7)=9
    missions(8)=10
    missions(9)=11
    missions(10)=12
    missions(11)=14
    missions(12)=15
}
