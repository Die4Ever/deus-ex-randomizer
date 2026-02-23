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
    local string s,cr;

    cr = class'DXRInfo'.static.CR();

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
            s = "UNATCO HQ";
            switch(teleportername)
            {
                case "Inside_UN_HQ":
                case "unatcohq":
                    return s$cr$"(Front Door)";
                    break;
                case "UN_med":
                    return s$cr$"(Medical Door)";
                    break;
            }
            break;
        case "01_NYC_UNATCOISLAND":
        case "03_NYC_UNATCOISLAND":
        case "04_NYC_UNATCOISLAND":
        case "05_NYC_UNATCOISLAND":
            s = "Liberty Island";
            switch(teleportername)
            {
                case "tunnel_drop_nyc":
                case "unatcoisland":
                    return s$cr$"(UNATCO Entrance)";
                case "":
                    return s$cr$"(UNATCO Helipad)";
            }
            break;
        case "02_NYC_BAR":
        case "04_NYC_BAR":
        case "08_NYC_BAR":
            s = "Bar";
            switch(teleportername)
            {
                case "ToBarBackEntrance":
                    return s$cr$"(Back Door)";
                case "ToBarFrontEntrance":
                    return s$cr$"(Front Door)";
            }
            break;
        case "02_NYC_BATTERYPARK":
        case "03_NYC_BATTERYPARK":
        case "04_NYC_BATTERYPARK":
            s = "Battery Park";
            switch(teleportername)
            {
                case "ToBatteryPark":
                    return s$cr$"(Subway)";
                case "BBSExit":
                    return s$cr$"(Below Phone Booth)";
                case "":
                    return s;
            }
            break;
        case "02_NYC_FREECLINIC":
        case "08_NYC_FREECLINIC":
            s = "Free Clinic";
            switch(teleportername)
            {
                case "FromStreet":
                    return s$cr$"(Main Entrance)";
            }
            break;
        case "02_NYC_HOTEL":
        case "04_NYC_HOTEL":
        case "08_NYC_HOTEL":
            s = "Hotel";
            switch(teleportername)
            {
                case "ToHotelBedroom":
                    return s$cr$"(Bedroom Window)";
                case "ToHotelFrontDoor":
                    return s$cr$"(Front Door)";
            }
            break;
        case "02_NYC_SMUG":
        case "04_NYC_SMUG":
        case "08_NYC_SMUG":
            s = "Smuggler";
            switch(teleportername)
            {
                case "ToSmugFrontDoor":
                case "PathNode83":
                    return s$cr$"(Front Door)";
                case "ToSmugBackDoor":
                    return s$cr$"(Back Door)";
            }
            break;
        case "02_NYC_STREET":
        case "04_NYC_STREET":
        case "08_NYC_STREET":
            s = "Hells Kitchen Streets";
            switch(teleportername)
            {
                case "FromSmugBackDoor":
                    return s$cr$"(Smuggler Back Door)";
                case "FromSmugFrontDoor":
                    return s$cr$"(Smuggler Front Door)";
                case "FromBarBackEntrance":
                    return s$cr$"(Bar Back Door)";
                case "FromBarFrontEntrance":
                    return s$cr$"(Bar Front Door)";
                case "FromHotelFrontDoor":
                    return s$cr$"(Hotel Front Door)";
                case "FromClinic":
                    return s$cr$"(Free Clinic Door)";
                case "BedroomWindow":
                    return s$cr$"(Hotel Window)";
                case "FromWarehouseAlley":
                    return s$cr$"(Osgoode & Sons Back Exit)";
                case "FromRoofTop":
                    return s$cr$"(Underground Elevator)";
                case "FromNYCUndergroundSewer2":
                    return s$cr$"(Sewer Entrance near Subway)";
                case "FromNYCSump":
                    return s$cr$"(Sewer Entrance near Hotel)";
                case "FromNSFHQ":
                    return s$cr$"(Road to NSF HQ)";
                case "PathNode194":
                case "ToStreet":
                case "NYCSubway":  //Rev: Backtracking from M04 Battery Park back to Hell's Kitchen
                    return s$cr$"(Subway)";
                case "":
                    return s;
            }
            break;
        case "02_NYC_UNDERGROUND":
        case "04_NYC_UNDERGROUND":
        case "08_NYC_UNDERGROUND":
            s = "Sewers";
            switch(teleportername)
            {
                case "ToNYCUndergroundSewer2":
                    return s$cr$"(Outside Facility)";
                case "ToNYCSump":
                    return s$cr$"(Inside Facility)";
            }
            break;
        case "02_NYC_WAREHOUSE":
            s = "Warehouse District";
            switch(teleportername)
            {
                case "ToRoofTop":
                    return s$cr$"(Rooftop Elevator)";
                case "ToWarehouseAlley":
                    return s$cr$"(Alleys)";
            }
            break;
        case "03_NYC_747":
            s = "747";
            switch(teleportername)
            {
                case "747PassEnt":
                    return s$cr$"(Front Door)";
            }
            break;
        case "03_NYC_AIRFIELD":
            s = "Airfield";
            switch(teleportername)
            {
                case "BHElevatorExit":
                    return s$cr$"(Elevator)";
                case "ToOcean":
                    return s$cr$"(Sewer)";
                case "HangarExit":
                    return s$cr$"(Hangar Entrance)";
                case "HangarExit2":
                    return s$cr$"(Hangar Back Entrance)";
            }
            break;
        case "03_NYC_AIRFIELDHELIBASE":
            s = "Helibase";
            switch(teleportername)
            {
                case "BHElevatorEnt":
                    return s$cr$"(Elevator)";
                case "SewerEnt":
                    return s$cr$"(Mole People Sewer)";
                case "FromOcean":
                    return s$cr$"(Sewers to Ocean)";
            }
            break;
        case "03_NYC_BROOKLYNBRIDGESTATION":
            s = "Brooklyn Bridge Station";
            switch(teleportername)
            {
                case "MoleExit":
                    return s$cr$"(Bathroom)";
                case "FromNYCStreets":
                    return s$cr$"(Sewer)";
            }
            break;
        case "03_NYC_HANGAR":
            s = "Hangar";
            switch(teleportername)
            {
                case "HangarEnt":
                    return s$cr$"(Main Entrance)";
                case "747PassExit":
                    return s$cr$"(747)";
                case "HangarEnt2":
                    return s$cr$"(Back Hangar Entrance)";
            }
            break;
        case "03_NYC_MOLEPEOPLE":
            s = "Mole People";
            switch(teleportername)
            {
                case "MoleEnt":
                    return s$cr$"(Main Entrance)";
                case "SewerExit":
                    return s$cr$"(Bathroom)";
            }
            break;
        case "04_NYC_NSFHQ":
            s = "NSF HQ";
            switch(teleportername)
            {
                case "ToNSFHQ":
                    return s;
            }
            break;
        case "05_NYC_UNATCOMJ12LAB":
            s = "UNATCO MJ12 Lab";
            switch(teleportername)
            {
                case "mj12":
                    return s$cr$"(Base Entrance)";
                case "":
                    return s$cr$"(Jail Cell)";
            }
            break;
        case "06_HONGKONG_ENTERINGSCENE": //Rev: Flows straight into Helibase anyway, just fall through
        case "06_HONGKONG_HELIBASE":
            s = "MJ12 Helibase";
            switch(teleportername)
            {
                case "Helibase":
                    return s$cr$"(Elevator)";
                case "":
                    return s;
            }
            break;
        case "06_HONGKONG_MJ12LAB":
            s = "Versalife Lab (Level 1)";
            switch(teleportername)
            {
                case "cathedral":
                    return s$cr$"(Office Elevator)";
                case "tubeend":
                    return s$cr$"(Level 2 Elevator)";
            }
            break;
        case "06_HONGKONG_STORAGE":
            s = "Versalife Lab (Level 2)";
            switch(teleportername)
            {
                case "waterpipe":
                    return s$cr$"(Canal Pipe)";
                case "basement":
                    return s$cr$"(Level 1 Elevator)";
                case "BackDoor":
                    return s$cr$"(Canal Road Entrance)";
            }
            break;
        case "06_HONGKONG_TONGBASE":
            s = "Tong's Base";
            switch(teleportername)
            {
                case "lab":
                    return s;
            }
            break;
        case "06_HONGKONG_VERSALIFE":
            s = "Versalife Offices";
            switch(teleportername)
            {
                case "Secret":
                    return s$cr$"(Upper Elevator)";
                case "Lobby":
                    return s$cr$"(Main Elevator)";
            }
            break;
        case "06_HONGKONG_WANCHAI_CANAL":
            s = "Hong Kong Canals";
            switch(teleportername)
            {
                case "canal":
                    return s$cr$"(Level 2 Labs Pipe)";
                case "Street":
                    return s$cr$"(Tonnochi Road Tunnel)";
                case "market01":
                    return s$cr$"(Main Entrance from Market)";
                case "alleyin":
                    return s$cr$"(Tonnochi Road Side Alley)";
                case "double":
                    return s$cr$"(Entrance Near Old China Hand)";
            }
            break;
        case "06_HONGKONG_WANCHAI_GARAGE":
            s = "Canal Road";
            switch(teleportername)
            {
                case "market04":
                    return s$cr$"(Stairs)";
            }
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            s = "Wan Chai Market";
            switch(teleportername)
            {
                case "market":
                    return s$cr$"(Versalife Elevator)";
                case "cargoup":
                    return s$cr$"(Helibase Elevator)";
                case "canal01":
                    return s$cr$"(Main Entrance from Canal)";
                case "canal03":
                    return s$cr$"(Lucky Money)";
                case "garage01":
                    return s$cr$"(Canal Road Stairs)";
                case "chinahand":
                    return s$cr$"(Canal Entrance to Old China Hand)";
                case "compound":
                    return s$cr$"(Tong's Lab)";
                case "MarketFromCompound1": //Rev: Transitions between Market and Compound map
                case "MarketFromCompound2":
                    return s$cr$"(Luminous Path Compound)";
            }
            break;
        case "06_HONGKONG_WANCHAI_COMPOUND": //Rev: Map where the Luminous Path Compound is
            s = "Luminous Path Compound";
            switch(teleportername)
            {
                case "CompoundFromMarket1":
                case "CompoundFromMarket2":
                    return s$cr$"(Wan Chai Market)";
                case "compound":
                    return s$cr$"(Tong's Lab)";
            }
            break;
        case "06_HONGKONG_WANCHAI_STREET":
            s = "Tonnochi Road";
            switch(teleportername)
            {
                case "canal":
                    return s$cr$"(Main Entrance)";
                case "alleyout":
                    return s$cr$"(Side Alley)";
            }
            break;
        case "06_HONGKONG_WANCHAI_UNDERWORLD":
            s = "Lucky Money";
            switch(teleportername)
            {
                case "market03":
                    return s$cr$"(Entrance)";
            }
            break;
        case "09_NYC_DOCKYARD":
            s = "Brooklyn Naval Shipyards";
            switch(teleportername)
            {
                case "ToDockyardSewer":
                    return s$cr$"(Sewer Entrance)";
                case "FromAircondDuct":
                    return s$cr$"(Ventilation System)";
                case "ExitShip":
                    return s$cr$"(Front Door)";
                case "":
                    return s;
            }
            break;
        case "09_NYC_GRAVEYARD":
            s = "Graveyard";
            switch(teleportername)
            {
                case "Entrance":
                case "":
                    return s;
            }
            break;
        case "09_NYC_SHIP":
            s = "Superfreighter Docks";
            switch(teleportername)
            {
                case "EnterShip":
                    return s$cr$"(Front Door)";
                case "FromFanRoom":
                    return s$cr$"(Fan Entrance)";
                case "FromDuctRoom":
                    return s$cr$"(Ducting Entrance)";
                case "FromDockyardSewer":
                    return s$cr$"(Sewer Entrance)";
                case "FromBelow":
                    return s$cr$"(Lower Deck Stairs)";
            }
            break;
        case "09_NYC_SHIPBELOW":
            s = "Superfreighter Lower Decks";
            switch(teleportername)
            {
                case "FromAbove":
                    return s$cr$"(Stairs)";
            }
            break;
        case "09_NYC_SHIPFAN":
            s = "Dockyard Ventilation";
            switch(teleportername)
            {
                case "ToFanRoom":
                    return s$cr$"(Fan Hall Entrance)";
                case "ToDuctRoom":
                    return s$cr$"(Ducting Entrance)";
                case "ToAircondDuct":
                    return s$cr$"(Rooftop Entrance)";
            }
            break;
        case "10_PARIS_CATACOMBS":
            s = "Paris Denfert-Rochereau";
            switch(teleportername)
            {
                case "spiralstair":
                    return s$cr$"(Spiral Staircase)";
                case "FromEntrance": //Rev: connection from new ENTRANCE map to the "Catacombs" exterior area
                    return s$cr$"(Entrance Building)";
                case "FromMetro"://Rev: connection to 10_PARIS_CATACOMBS_METRO
                    return s$cr$"(Closed Metro Station)";
                case "":
                    return s;
            }
            break;
        case "10_PARIS_ENTRANCE": //Rev: 10_PARIS_CATACOMBS is split up, this is the building you start on top of, to just past the greasels
            s = "Paris Denfert-Rochereau Tower";
            switch(teleportername)
            {
                case "ToEntrance":
                    return s$cr$"(Exterior)";
                case "":
                    return s;
            }
            break;
        case "10_PARIS_CATACOMBS_METRO": //Rev: 10_PARIS_CATACOMBS is split up, this is the the little mall area with some MJ12 and a guy selling rockets
            s = "Paris Closed Metro Station";
            switch(teleportername)
            {
                case "metro":
                    return s$cr$"(Main Entrance)";
            }
            break;

        case "10_PARIS_CATACOMBS_TUNNELS":
            s = "Paris Catacombs";
            switch(teleportername)
            {
                case "spiralstair":
                    return s$cr$"(Spiral Staircase)";
                case "ambientsound10":
                    return s$cr$"(Sewer Entrance)";
            }
            break;
        case "10_PARIS_CHATEAU":
            s = "DuClare Chateau";
            switch(teleportername)
            {
                case "CHATEAU_START":
                    return s$cr$"(Front Doors)";
                case "Light135":
                    return s$cr$"(Sewer Entrance)";
                case "":
                    return s;
            }
            break;
        case "10_PARIS_CLUB":
            s = "Porte De L'Enfer";
            switch(teleportername)
            {
                case "Paris_Club1":
                    return s$cr$"(Front Door)";
                case "Paris_Club2":
                    return s$cr$"(Back Door)";
            }
            break;
        case "10_PARIS_METRO":
            s = "Paris Streets";
            switch(teleportername)
            {
                case "sewer":
                    return s$cr$"(Sewer Entrance)";
                case "paris_metro1":
                    return s$cr$"(Club Front Door)";
                case "paris_metro2":
                    return s$cr$"(Club Back Door)";
                case "PathNode447":
                    return s$cr$"(Helicopter behind Club)";
            }
            break;
        case "11_PARIS_CATHEDRAL":
            s = "Cathedral";
            switch(teleportername)
            {
                case "cathedralstart":
                    return s$cr$"(Sewer Entrance)";
                case "Paris_Underground":
                case "FromMetro": //Revision
                    return s$cr$"(Metro Station Entrance)";
            }
            break;
        case "11_PARIS_EVERETT":
            s = "Everett";
            switch(teleportername)
            {
                case "Entrance":
                    return s$cr$"(Main Entrance)";
            }
            break;
        case "11_PARIS_UNDERGROUND":
            s = "Paris Metro Station";
            switch(teleportername)
            {
                case "Paris_Underground":
                case "metro": //Revision
                    return s$cr$"(Main Entrance)";
                case "PathNode68":
                    return s$cr$"(Train Tracks)";
            }
            break;
        case "12_VANDENBERG_CMD":
            s = "Vandenberg Command";
            switch(teleportername)
            {
                case "commstat":
                    return s$cr$"(Comms Building Tunnel Entrance)";
                case "storage":
                    return s$cr$"(Main Building Tunnel Entrance)";
                case "hall":
                    return s$cr$"(Control Center Door)";
                case "PathNode8":
                    return s$cr$"(Helipad)";
                case "":
                    return s;
            }
            break;
        case "12_VANDENBERG_COMPUTER":
            s = "Vandenberg Control Center";
            switch(teleportername)
            {
                case "computer":
                    return s;
            }
            break;
        case "12_VANDENBERG_GAS":
            s = "Gas Station";
            switch(teleportername)
            {
                case "gas_start":
                case "":
                    return s$cr$"(Main Entrance)";
                case "PathNode98":
                    return s$cr$"(Junkyard)";
            }
            break;
        case "12_VANDENBERG_TUNNELS":
            s = "Vandenberg Tunnel";
            switch(teleportername)
            {
                case "Start":
                    return s$cr$"(Start)";
                case "End":
                    return s$cr$"(End)";
            }
            break;
        case "14_OCEANLAB_LAB":
            s = "Ocean Lab";
            switch(teleportername)
            {
                case "Sunkentunnel":
                    return s$cr$"(UC Entrance)";
                case "Sunkenlab":
                    return s$cr$"(Sub Bay)";
            }
            break;
        case "14_OCEANLAB_SILO":
            s = "Silo";
            switch(teleportername)
            {
                case "frontgate":
                case "":
                    return s$cr$"(Front Gates)";
            }
            break;
        case "14_OCEANLAB_UC":
            s = "Ocean Lab UC";
            switch(teleportername)
            {
                case "UC":
                    return s$cr$"(Main Entrance)";
            }
            break;
        case "14_VANDENBERG_SUB":
            s = "Ocean Lab Shoreside";
            switch(teleportername)
            {
                case "subbay":
                    return s$cr$"(Sub Bay)";
                case "PlayerStart":
                case "":
                    return s$cr$"(Shore Helicopter)";
                case "InterpolationPoint39":
                    return s$cr$"(Rooftop Helicopter)";
            }
            break;
        case "15_AREA51_BUNKER":
            s = "Area 51 Bunker";
            switch(teleportername)
            {
                case "commstat":
                case "Light188":
                    return s$cr$"(Sector 2 Door)";
                case "":
                case "bunker_start":
                    return s;
            }
            break;
        case "15_AREA51_ENTRANCE":
            s = "Area 51 Sector 2";
            switch(teleportername)
            {
                case "Start":
                    return s$cr$"(Main Entrance)";
                case "Light73":
                    return s$cr$"(Bottom of Elevator)";
            }
            break;
        case "15_AREA51_FINAL":
            s = "Area 51 Sector 3";
            switch(teleportername)
            {
                case "final_end":
                    return s$cr$"(Sector 4 Door)";
                case "Start":
                    return s$cr$"(Sector 2 Elevator)";
            }
            break;
        case "15_AREA51_PAGE":
            s = "Area 51 Sector 4";
            switch(teleportername)
            {
                case "page_start":
                    return s$cr$"(Sector 3 Door)";
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
        finalName = finalName $ class'DXRInfo'.Static.CR() $ variantName;
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
