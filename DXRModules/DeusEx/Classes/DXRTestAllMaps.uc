class DXRTestAllMaps expands DXRBase;

var config string maps[128];

function CheckConfig()
{
    local int i;
    if( config_version < 4 ) {
        GetAllMaps(maps);
    }
    Super.CheckConfig();
}

function AnyEntry()
{
    Super.AnyEntry();
    SetTimer(0.5, True);
}

function Timer()
{
    local int i;
    local bool found;
    Super.Timer();
    if( dxr == None ) return;
    if( dxr.bTickEnabled ) return;// wait for everything to finish

    for(i=0; i < ArrayCount(maps); i++) {
        if( Caps(maps[i]) == Caps(dxr.localURL) ) {
            found = true;
            continue;
        }
        if( found == true && maps[i] != "" ) {
            Level.Game.SendPlayer(dxr.player, maps[i]);
            break;
        }
    }
    SetTimer(0, False);
}

static function GetAllMaps(out string maps[128])
{
    local int i;
    for(i=0; i < ArrayCount(maps); i++) {
        maps[i] = "";
    }
    i=0;
    maps[i++] = "01_NYC_UNATCOIsland";
    maps[i++] = "01_NYC_UNATCOHQ";
    maps[i++] = "02_NYC_Bar";
    maps[i++] = "02_NYC_BatteryPark";
    maps[i++] = "02_NYC_FreeClinic";
    maps[i++] = "02_NYC_Hotel";
    maps[i++] = "02_NYC_Smug";
    maps[i++] = "02_NYC_Street";
    maps[i++] = "02_NYC_Underground";
    maps[i++] = "02_NYC_Warehouse";
    maps[i++] = "03_NYC_747";
    maps[i++] = "03_NYC_Airfield";
    maps[i++] = "03_NYC_AirfieldHeliBase";
    maps[i++] = "03_NYC_BatteryPark";
    maps[i++] = "03_NYC_BrooklynBridgeStation";
    maps[i++] = "03_NYC_Hangar";
    maps[i++] = "03_NYC_MolePeople";
    maps[i++] = "03_NYC_UNATCOHQ";
    maps[i++] = "03_NYC_UNATCOIsland";
    maps[i++] = "04_NYC_Bar";
    maps[i++] = "04_NYC_BatteryPark";
    maps[i++] = "04_NYC_Hotel";
    maps[i++] = "04_NYC_NSFHQ";
    maps[i++] = "04_NYC_Smug";
    maps[i++] = "04_NYC_Street";
    maps[i++] = "04_NYC_UNATCOHQ";
    maps[i++] = "04_NYC_UNATCOIsland";
    maps[i++] = "04_NYC_Underground";
    maps[i++] = "05_NYC_UNATCOHQ";
    maps[i++] = "05_NYC_UNATCOIsland";
    maps[i++] = "05_NYC_UNATCOMJ12lab";
    maps[i++] = "06_HongKong_Helibase";
    maps[i++] = "06_HongKong_MJ12lab";
    maps[i++] = "06_HongKong_Storage";
    maps[i++] = "06_HongKong_TongBase";
    maps[i++] = "06_HongKong_VersaLife";
    maps[i++] = "06_HongKong_WanChai_Canal";
    maps[i++] = "06_HongKong_WanChai_Garage";
    maps[i++] = "06_HongKong_WanChai_Market";
    maps[i++] = "06_HongKong_WanChai_Street";
    maps[i++] = "06_HongKong_WanChai_Underworld";
    maps[i++] = "08_NYC_Bar";
    maps[i++] = "08_NYC_FreeClinic";
    maps[i++] = "08_NYC_Hotel";
    maps[i++] = "08_NYC_Smug";
    maps[i++] = "08_NYC_Street";
    maps[i++] = "08_NYC_Underground";
    maps[i++] = "09_NYC_Dockyard";
    maps[i++] = "09_NYC_Graveyard";
    maps[i++] = "09_NYC_Ship";
    maps[i++] = "09_NYC_ShipBelow";
    maps[i++] = "09_NYC_ShipFan";
    maps[i++] = "10_Paris_Catacombs";
    maps[i++] = "10_Paris_Catacombs_Tunnels";
    maps[i++] = "10_Paris_Chateau";
    maps[i++] = "10_Paris_Club";
    maps[i++] = "10_Paris_Metro";
    maps[i++] = "11_Paris_Cathedral";
    maps[i++] = "11_Paris_Everett";
    maps[i++] = "11_Paris_Underground";
    maps[i++] = "12_Vandenberg_Cmd";
    maps[i++] = "12_Vandenberg_Computer";
    maps[i++] = "12_Vandenberg_Gas";
    maps[i++] = "12_Vandenberg_Tunnels";
    maps[i++] = "14_OceanLab_Lab";
    maps[i++] = "14_Oceanlab_Silo";
    maps[i++] = "14_OceanLab_UC";
    maps[i++] = "14_Vandenberg_Sub";
    maps[i++] = "15_Area51_Bunker";
    maps[i++] = "15_Area51_Entrance";
    maps[i++] = "15_Area51_Final";
    maps[i++] = "15_Area51_Page";
    /*maps[i++] = "00_Training";
    maps[i++] = "00_TrainingCombat";
    maps[i++] = "00_TrainingFinal";
    maps[i++] = "99_Endgame1";
    maps[i++] = "99_Endgame2";
    maps[i++] = "99_Endgame3";
    maps[i++] = "99_Endgame4";*/
    //maps[i++] = "00_Intro";
}

static function int GetMissionNumber(string map)
{
    local int mission;

    mission = (Asc(map)-Asc("0")) * 10;
    mission += (Asc(Mid(map,1,1))-Asc("0"));
    return mission;
}

static function string PickRandomMap(DXRando dxr)
{
    local string maps[128];
    local int i, numMaps, slot;

    GetAllMaps(maps);
    for(i=0; i < ArrayCount(maps); i++) {
        if( maps[i] != "" ) numMaps++;
    }

    slot = dxr.rng(numMaps);
    numMaps=0;

    for(i=0; i < ArrayCount(maps); i++) {
        if( numMaps==slot && maps[i] != "" ) {
            return maps[i];
        }
        if( maps[i] != "" ) numMaps++;
    }
    return "";
}

function RunTests()
{
    Super.RunTests();

    testint( GetMissionNumber("06_HongKong_WanChai_Underworld") , 6, "GetMissionNumber(\"06_HongKong_WanChai_Underworld\")" );
    testint( GetMissionNumber("15_Area51_Final") , 15, "GetMissionNumber(\"15_Area51_Final\")" );
    test( PickRandomMap(dxr) != "", "PickRandomMap" );
}
