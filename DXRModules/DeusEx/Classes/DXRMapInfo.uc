class DXRMapInfo expands DXRBase transient;

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

    if( DeusExRootWindow(player().rootWindow).actorDisplay.viewClass != None ) {
        SetTimer(0, False);
        return;
    }

    for(i=0; i < ArrayCount(maps); i++) {
        if( Caps(maps[i]) == Caps(dxr.localURL) ) {
            found = true;
            continue;
        }
        if( found == true && maps[i] != "" ) {
            Level.Game.SendPlayer(player(), maps[i]);
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
    local int mission, i;

    i = (Asc(map)-Asc("0"));
    if( i < 0 || i > 9 ) return 0;
    mission = i * 10;
    i = (Asc(Mid(map,1,1))-Asc("0"));
    if( i < 0 || i > 9 ) return 0;
    mission += i;
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

static function string GetEntranceName(string mapname, string teleportername)
{
switch(mapname)
    {
        case "00_TRAINING":
            return "Training";
        case "00_TRAININGCOMBAT":
            return "Combat Training";
        case "00_TRAININGFINAL":
            return "Final Training";
        case "01_NYC_UNATCOHQ":
        case "03_NYC_UNATCOHQ":
        case "04_NYC_UNATCOHQ":
        case "05_NYC_UNATCOHQ":
            switch(teleportername)
            {
                case "Inside_UN_HQ":
                case "unatcohq":
                    return "UNATCO HQ Interior Front Door";
                case "UN_med":
                    return "UNATCO HQ Medical Door";
            }
            break;
        case "01_NYC_UNATCOISLAND":
        case "03_NYC_UNATCOISLAND":
        case "04_NYC_UNATCOISLAND":
        case "05_NYC_UNATCOISLAND":
            switch(teleportername)
            {
                case "tunnel_drop_nyc":
                case "unatcoisland":
                    return "Liberty Island UNATCO Entrance";
                case "":
                    return "UNATCO Helipad";
            }
            break;
        case "02_NYC_BAR":
        case "04_NYC_BAR":
        case "08_NYC_BAR":
            switch(teleportername)
            {
                case "ToBarBackEntrance":
                    return "Bar Back Door Interior";
                case "ToBarFrontEntrance":
                    return "Bar Front Door Interior";
            }
            break;
        case "02_NYC_BATTERYPARK":
        case "03_NYC_BATTERYPARK":
        case "04_NYC_BATTERYPARK":
            switch(teleportername)
            {
                case "ToBatteryPark":
                    return "Battery Park Subway";
                case "BBSExit":
                    return "Battery Park underneath Phone Booth";
                case "":
                    return "Battery Park";
            }
            break;
        case "02_NYC_FREECLINIC":
        case "08_NYC_FREECLINIC":
            switch(teleportername)
            {
                case "FromStreet":
                    return "Free Clinic Interior";
            }
            break;
        case "02_NYC_HOTEL":
        case "04_NYC_HOTEL":
        case "08_NYC_HOTEL":
            switch(teleportername)
            {
                case "ToHotelBedroom":
                    return "Hotel Bedroom Interior";
                case "ToHotelFrontDoor":
                    return "Hotel Front Door Interior";
            }
            break;
        case "02_NYC_SMUG":
        case "04_NYC_SMUG":
        case "08_NYC_SMUG":
            switch(teleportername)
            {
                case "ToSmugFrontDoor":
                case "PathNode83":
                    return "Smuggler Front Door Interior";
                case "ToSmugBackDoor":
                    return "Smuggler Back Door Interior";
            }
            break;
        case "02_NYC_STREET":
        case "04_NYC_STREET":
        case "08_NYC_STREET":
            switch(teleportername)
            {
                case "FromSmugBackDoor":
                    return "Smuggler Back Door Exterior";
                case "FromSmugFrontDoor":
                    return "Smuggler Front Door Exterior";
                case "FromBarBackEntrance":
                    return "Bar Back Door Exterior";
                case "FromBarFrontEntrance":
                    return "Bar Front Door Exterior";
                case "FromHotelFrontDoor":
                    return "Hotel Front Door Exterior";
                case "FromClinic":
                    return "Free Clinic Exterior";
                case "BedroomWindow":
                    return "Hotel Bedroom Window Exterior";
                case "FromWarehouseAlley":
                    return "Osgoode & Sons Back Exit";
                case "FromRoofTop":
                    return "Underground Elevator";
                case "FromNYCUndergroundSewer2":
                    return "Sewer Entrance near Subway";
                case "FromNYCSump":
                    return "Sewer Entrance near Hotel";
                case "FromNSFHQ":
                    return "Road to NSF HQ";
                case "PathNode194":
                case "ToStreet":
                    return "Hells Kitchen Subway";
                case "":
                    return "Hells Kitchen Streets";
            }
            break;
        case "02_NYC_UNDERGROUND":
        case "04_NYC_UNDERGROUND":
        case "08_NYC_UNDERGROUND":
            switch(teleportername)
            {
                case "ToNYCUndergroundSewer2":
                    return "Sewer Interior outside Facility";
                case "ToNYCSump":
                    return "Sewer Interior inside Facility";
            }
            break;
        case "02_NYC_WAREHOUSE":
            switch(teleportername)
            {
                case "ToRoofTop":
                    return "Warehouse Rooftops";
                case "ToWarehouseAlley":
                    return "Warehouse Alleys";
            }
            break;
        case "03_NYC_747":
            switch(teleportername)
            {
                case "747PassEnt":
                    return "747 Interior";
            }
            break;
        case "03_NYC_AIRFIELD":
            switch(teleportername)
            {
                case "BHElevatorExit":
                    return "Top of Elevator to Airfield";
                case "ToOcean":
                    return "Sewer Exit to Airfield";
                case "HangarExit":
                    return "Hangar Entrance Exterior";
            }
            break;
        case "03_NYC_AIRFIELDHELIBASE":
            switch(teleportername)
            {
                case "BHElevatorEnt":
                    return "Bottom of Elevator in Helibase";
                case "SewerEnt":
                    return "Helibase Entrance from Mole People";
                case "FromOcean":
                    return "Sewer Entrance in Helibase";
            }
            break;
        case "03_NYC_BROOKLYNBRIDGESTATION":
            switch(teleportername)
            {
                case "MoleExit":
                    return "Brooklyn Bridge Station Bathroom Entrance";
                case "FromNYCStreets":
                    return "Brooklyn Bridge Station Sewer Entrance";
            }
            break;
        case "03_NYC_HANGAR":
            switch(teleportername)
            {
                case "HangarEnt":
                    return "Main Hangar Entrance Interior";
                case "747PassExit":
                    return "Hangar Door to 747";
            }
            break;
        case "03_NYC_MOLEPEOPLE":
            switch(teleportername)
            {
                case "MoleEnt":
                    return "Mole People Entrance";
                case "SewerExit":
                    return "Mole People Bathroom";
            }
            break;
        case "04_NYC_NSFHQ":
            switch(teleportername)
            {
                case "ToNSFHQ":
                    return "NSF HQ";
            }
            break;
        case "05_NYC_UNATCOMJ12LAB":
            switch(teleportername)
            {
                case "mj12":
                    return "UNATCO MJ12 Base Entrance";
                case "":
                    return "UNATCO MJ12 Jail Cell";
            }
            break;
        case "06_HONGKONG_HELIBASE":
            switch(teleportername)
            {
                case "Helibase":
                    return "MJ12 Helibase Elevator";
                case "":
                    return "MJ12 Helibase";
            }
            break;
        case "06_HONGKONG_MJ12LAB":
            switch(teleportername)
            {
                case "cathedral":
                    return "MJ12 Lab Main Elevator";
                case "tubeend":
                    return "MJ12 Lab Level 2 Elevator";
            }
            break;
        case "06_HONGKONG_STORAGE":
            switch(teleportername)
            {
                case "waterpipe":
                    return "UC Canal Exit";
                case "basement":
                    return "UC Elevator Entrance";
                case "BackDoor":
                    return "UC Canal Road Entrance";
            }
            break;
        case "06_HONGKONG_TONGBASE":
            switch(teleportername)
            {
                case "lab":
                    return "Tong's Base Interior";
            }
            break;
        case "06_HONGKONG_VERSALIFE":
            switch(teleportername)
            {
                case "Secret":
                    return "Versalife Upper Elevator";
                case "Lobby":
                    return "Versalife Interior Main Entrance";
            }
            break;
        case "06_HONGKONG_WANCHAI_CANAL":
            switch(teleportername)
            {
                case "canal":
                    return "Canal Pipe Exit from UC";
                case "Street":
                    return "Canal Tunnel from Tonnochi Road";
                case "market01":
                    return "Canal Entrance from Market";
                case "alleyin":
                    return "Canal Side Alley";
                case "double":
                    return "Canal Entrance Near Old China Hand";
            }
            break;
        case "06_HONGKONG_WANCHAI_GARAGE":
            switch(teleportername)
            {
                case "market04":
                    return "Canal Road Entrance from Market";
            }
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            switch(teleportername)
            {
                case "market":
                    return "Market Elevator from Versalife";
                case "cargoup":
                    return "Market Elevator from Helibase";
                case "canal01":
                    return "Market Entrance from Canal";
                case "canal03":
                    return "Market Entrance from Lucky Money";
                case "garage01":
                    return "Market Entrance from Canal Road";
                case "chinahand":
                    return "Market Entrance from Old China Hand";
                case "compound":
                    return "Market Entrance from Tong's Lab";
            }
            break;
        case "06_HONGKONG_WANCHAI_STREET":
            switch(teleportername)
            {
                case "canal":
                    return "Tonnochi Road Main Entrance";
                case "alleyout":
                    return "Tonnochi Road Side Alley";
            }
            break;
        case "06_HONGKONG_WANCHAI_UNDERWORLD":
            switch(teleportername)
            {
                case "market03":
                    return "Lucky Money Entrance";
            }
            break;
        case "09_NYC_DOCKYARD":
            switch(teleportername)
            {
                case "ToDockyardSewer":
                    return "Dockyard Sewer Entrance";
                case "FromAircondDuct":
                    return "Dockyard Exterior Air Conditioning Entrance";
                case "ExitShip":
                    return "Dockyard Exterior Front Door";
                case "":
                    return "Brooklyn Naval Shipyards";
            }
            break;
        case "09_NYC_GRAVEYARD":
            switch(teleportername)
            {
                case "Entrance":
                case "":
                    return "Graveyard";
            }
            break;
        case "09_NYC_SHIP":
            switch(teleportername)
            {
                case "EnterShip":
                    return "Superfreighter Exterior Front Door";
                case "FromFanRoom":
                    return "Superfreighter Exterior Fan Entrance";
                case "FromDuctRoom":
                    return "Superfreighter Exterior Ducting Entrance";
                case "FromDockyardSewer":
                    return "Superfreighter Exterior Sewer Entrance";
                case "FromBelow":
                    return "Superfreighter Exterior Lower Deck Stairs";
            }
            break;
        case "09_NYC_SHIPBELOW":
            switch(teleportername)
            {
                case "FromAbove":
                    return "Superfreighter Interior Lower Deck Stairs";
            }
            break;
        case "09_NYC_SHIPFAN":
            switch(teleportername)
            {
                case "ToFanRoom":
                    return "Dockyard Ventilation Fan Hall Entrance";
                case "ToDuctRoom":
                    return "Dockyard Ventilation Ducting Entrance";
                case "ToAircondDuct":
                    return "Dockyard Ventilation Air Conditioner Entrance";
            }
            break;
        case "10_PARIS_CATACOMBS":
            switch(teleportername)
            {
                case "spiralstair":
                    return "Paris Exterior Spiral Staircase";
                case "":
                    return "Paris Denfert-Rochereau";
            }
            break;
        case "10_PARIS_CATACOMBS_TUNNELS":
            switch(teleportername)
            {
                case "spiralstair":
                    return "Catacombs Interior Spiral Staircase";
                case "ambientsound10":
                    return "Catacombs Interior Sewer Entrance";
            }
            break;
        case "10_PARIS_CHATEAU":
            switch(teleportername)
            {
                case "CHATEAU_START":
                    return "DuClare Estate Front Doors";
                case "Light135":
                    return "DuClare Estate Sewer Entrance";
                case "":
                    return "DuClare Estate";
            }
            break;
        case "10_PARIS_CLUB":
            switch(teleportername)
            {
                case "Paris_Club1":
                    return "Porte De L'Enfer Interior Front Entrance";
                case "Paris_Club2":
                    return "Porte De L'Enfer Interior Back Entrance";
            }
            break;
        case "10_PARIS_METRO":
            switch(teleportername)
            {
                case "sewer":
                    return "Paris Streets Sewer Entrance";
                case "paris_metro1":
                    return "Paris Streets Club Front Entrance";
                case "paris_metro2":
                    return "Paris Streets Club Back Entrance";
                case "PathNode447":
                    return "Paris Streets Helicopter behind Club";
            }
            break;
        case "11_PARIS_CATHEDRAL":
            switch(teleportername)
            {
                case "cathedralstart":
                    return "Cathedral Sewer Entrance";
                case "Paris_Underground":
                    return "Cathedral Metro Entrance";
            }
            break;
        case "11_PARIS_EVERETT":
            switch(teleportername)
            {
                case "Entrance":
                    return "Everett Main Entrance";
            }
            break;
        case "11_PARIS_UNDERGROUND":
            switch(teleportername)
            {
                case "Paris_Underground":
                    return "Paris Metro Interior Entrance";
            }
            break;
        case "12_VANDENBERG_CMD":
            switch(teleportername)
            {
                case "commstat":
                    return "Vandenberg Comms Building Tunnel Entrance";
                case "storage":
                    return "Vandenberg Main Building Tunnel Exit";
                case "hall":
                    return "Vandenberg Control Center Exterior Entrance";
                case "PathNode8":
                    return "Vandenberg Helipad";
                case "":
                    return "Vandenberg";
            }
            break;
        case "12_VANDENBERG_COMPUTER":
            switch(teleportername)
            {
                case "computer":
                    return "Vandenberg Control Center Interior Entrance";
            }
            break;
        case "12_VANDENBERG_GAS":
            switch(teleportername)
            {
                case "gas_start":
                case "":
                    return "Gas Station Main Entrance";
                case "PathNode98":
                    return "Gas Station Junkyard Entrance";
            }
            break;
        case "12_VANDENBERG_TUNNELS":
            switch(teleportername)
            {
                case "Start":
                    return "Vandenberg Tunnel Start";
                case "End":
                    return "Vandenberg Tunnel End";
            }
            break;
        case "14_OCEANLAB_LAB":
            switch(teleportername)
            {
                case "Sunkentunnel":
                    return "Ocean Lab UC Exterior Entrance";
                case "Sunkenlab":
                    return "Ocean Lab Sub Bay";
            }
            break;
        case "14_OCEANLAB_SILO":
            switch(teleportername)
            {
                case "frontgate":
                case "":
                    return "Silo Front Gates";
            }
            break;
        case "14_OCEANLAB_UC":
            switch(teleportername)
            {
                case "UC":
                    return "Ocean Lab UC Interior Entrance";
            }
            break;
        case "14_VANDENBERG_SUB":
            switch(teleportername)
            {
                case "subbay":
                    return "Ocean Lab Shoreside Sub Bay";
                case "PlayerStart":
                case "":
                    return "Ocean Lab Shoreside Helicopter";
                case "InterpolationPoint39":
                    return "Ocean Lab Shoreside Rooftop Helicopter";
            }
            break;
        case "15_AREA51_BUNKER":
            switch(teleportername)
            {
                case "commstat":
                case "Light188":
                    return "Area 51 Bunker Exterior Door";
                case "":
                case "bunker_start":
                    return "Area 51 Bunker";
            }
            break;
        case "15_AREA51_ENTRANCE":
            switch(teleportername)
            {
                case "Start":
                    return "Area 51 Sector 2 Entrance";
                case "Light73":
                    return "Area 51 Sector 2 Door from Sector 3";
            }
            break;
        case "15_AREA51_FINAL":
            switch(teleportername)
            {
                case "final_end":
                    return "Area 51 Sector 3 Door from Sector 4";
                case "Start":
                    return "Area 51 Sector 3 Door from Sector 2";
            }
            break;
        case "15_AREA51_PAGE":
            switch(teleportername)
            {
                case "page_start":
                    return "Area 51 Sector 4 Door from Sector 3";
            }
            break;
    }

    return mapname$" ("$teleportername$") - Report me!";
}

static function string GetTeleporterName(string mapname, string teleportername)
{
    local string finalName, variantName;

    if (InStr(teleportername,"?TONAME=")!=-1){
        teleportername = Right(teleportername,Len(teleporterName)-8);
    }

    //Strip a .dx from the map name if it's there
    mapName = class'DXRInfo'.static.ReplaceText(mapName,".dx","");

    //Strip any spaces that might be in the name...
    mapName = class'DXRInfo'.static.ReplaceText(mapName," ","");

    mapname = Caps(mapname); //Just to be sure

    variantName = class'DXRMapVariants'.static.GetVariantName(mapName);
    mapname = class'DXRMapVariants'.static.CleanupMapName(mapname);

    finalName = GetEntranceName(mapname,teleportername);

    if (variantName!=""){
        finalName = finalName @ "(" $ variantName $ ")";
    }

    return finalName;
}

function RunTests()
{
    Super.RunTests();

    testint( GetMissionNumber("Intro") , 0, "GetMissionNumber(\"Intro\")" );
    testint( GetMissionNumber("2Fort") , 0, "GetMissionNumber(\"2Fort\")" );
    testint( GetMissionNumber("06_HongKong_WanChai_Underworld") , 6, "GetMissionNumber(\"06_HongKong_WanChai_Underworld\")" );
    testint( GetMissionNumber("15_Area51_Final") , 15, "GetMissionNumber(\"15_Area51_Final\")" );
    test( PickRandomMap(dxr) != "", "PickRandomMap" );
}
