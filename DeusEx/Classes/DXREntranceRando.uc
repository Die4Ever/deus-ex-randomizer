//=============================================================================
// DXREntranceRando.
//=============================================================================
class DXREntranceRando expands DXRBase;

//Defines an edge of a map where you can transfer between maps
//Via Teleporter or MapExit
//In the main game, all of them have an inbound point and an outbound one
//The outbound one is only identifiable by it's destination, while the inbound
//One has the tag set.
struct MapTransfer
{
    var() string mapname;
    var() string inTag;
    var() string outTag;
    var() bool used;
};

//Defines a connection between two MapTransfer points
struct Connection
{
    var() MapTransfer a;
    var() MapTransfer b;
};

//This structure is used for rando validation
struct MapConnection
{
    var() string mapname;
    var() int    numDests;
    var() string dest[15]; //List of maps that can be reached from this one
};
var Connection conns[50];
var int numConns;

var Connection fixed_conns[8];
var int numFixedConns;

var MapTransfer xfers[50];
var int numXfers;

struct BanConnection
{
    var string map_a;
    var string map_b;
};
var config BanConnection BannedConnections[32];

/*struct AddConnection
{
    var string mapname;
    var string dest;
    var vector pos;
    var rotator rot;
    var string type;//chopper, button, teleporter?
    var bool fixed;
};
var config AddConnection AddConnections[16];*/

var config string dead_ends[32];

var config int min_connections_selfconnect;

function CheckConfig()
{
    local int i;
    if( config_version < 4 ) {
        for(i=0; i < ArrayCount(BannedConnections); i++) {
            BannedConnections[i].map_a = "";
            BannedConnections[i].map_b = "";
        }
        BannedConnections[0].map_a = "02_NYC_BatteryPark";
        BannedConnections[0].map_b = "02_NYC_Underground";
        BannedConnections[1].map_a = "02_NYC_BatteryPark";
        BannedConnections[1].map_b = "02_NYC_Warehouse";
    }
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,5) ) {
        min_connections_selfconnect = 999;
        dead_ends[0] = "03_NYC_AirfieldHeliBase#FromOcean";
        dead_ends[1] = "06_HONGKONG_WANCHAI_GARAGE#Teleporter";
        //dead_ends[2] = "12_VANDENBERG_CMD#storage";//it's actually backwards from this...
    }
    for(i=0; i < ArrayCount(BannedConnections); i++) {
        BannedConnections[i].map_a = Caps(BannedConnections[i].map_a);
        BannedConnections[i].map_b = Caps(BannedConnections[i].map_b);
    }
    for(i=0; i < ArrayCount(dead_ends); i++) {
        dead_ends[i] = Caps(dead_ends[i]);
    }
    Super.CheckConfig();
}

function int GetNextTransferIdx()
{
    local int i;
    
    i = 0;
    for (i=0;i<numXfers;i++)
    {
        if (xfers[i].used==False)
        {
            return i;
        }
    }   
    return -1;
}

//This gets the <offset>th unused transfer and returns its index
function int GetUnusedTransferByOffset(int offset)
{
    local int idx;
    local int numUnused;
    
    idx = 0;
    numUnused = 0;
    
    for(idx=0;idx<numXfers;idx++)
    {
        if (xfers[idx].used == False)
        {
            if (numUnused==offset)
                return idx;
            else
                numUnused++;
        }
    }
    return -1;
}

function int GetNumXfersByMap(string mapname)
{
    local int i;
    local int count;
    
    count = 0;
    
    for (i=0;i<numXfers;i++)
    {
        if (xfers[i].mapname == mapname)
        {
            count++;
        }
    }
    
    return count;
}

function bool IsDeadEndMap(string mapname)
{
    return GetNumXfersByMap(mapname)==1;
}

function bool CanSelfConnect(string mapname)
{
    return GetNumXfersByMap(mapname) >= min_connections_selfconnect;
}

function bool IsConnectionValid(int missionNum, MapTransfer a, MapTransfer b)
{
    local int i;

    if( a.mapname == b.mapname && a.inTag == b.inTag && a.outTag == b.outTag ) {
        err("IsConnectionValid got duplicate MapTransfers? mapname: " $ a.mapname $", inTag: " $ a.inTag $", outTag: " $a.outTag);
        return False;
    }

    if ( IsDeadEndMap(a.mapname) && IsDeadEndMap(b.mapname) )
    {
        return False;
    }
    
    if ( a.mapname == b.mapname)
    {
        if ( !CanSelfConnect(a.mapname))
        {
            return False;
        }
    }

    for(i=0; i < ArrayCount(BannedConnections); i++) {
        if( 
            (a.mapname == BannedConnections[i].map_a && b.mapname == BannedConnections[i].map_b)
            ||
            (b.mapname == BannedConnections[i].map_a && a.mapname == BannedConnections[i].map_b)
        ) {
            return false;
        }
    }
    
    return True;
}


function bool ValidateConnections()
{
    local MapConnection mapdests[15];
    local int numMaps;
    local int numPasses;
    local int i,j,k;
    local bool foundMap;
    
    local string canvisit[15];
    local int visitable;
    
    local bool canVisitMap;
    
    numPasses = numConns;
    numMaps = GetAllMapNames(mapdests);
    
    if( DuplicateConnections() > 0 ) return false;

    //Determine what maps can be visited from each map
    for (i=0;i<numConns;i++)
    {
        MarkMapsConnected(mapdests, numMaps, conns[i].a, conns[i].b);
    }
    
    //Start finding out what maps we can visit
    visitable = 0;
    canvisit[visitable]=mapdests[0].mapname;
    visitable++;
    
    for( i=0;i<numPasses;i++)
    {
        for ( j=0;j<numMaps;j++)
        {
            //See if map can be visited
            canVisitMap = False;
            for (k=0;k<visitable;k++)
            {
                if (mapdests[j].mapname == canvisit[k])
                {
                    canVisitMap = True;
                }
            }
            
            //If map can be visited, go through all the places it can go
            if (canVisitMap)
            {
                MarkMapDestinationsVisitible(mapdests[j], canvisit, visitable);
            }
        }
    }
    
    //Theoretically I should probably actually check to see if the maps match,
    //but this is fairly safe...
    l("ValidateConnections visitable: " $ visitable $", numMaps: " $ numMaps);
    return visitable == numMaps;
}

function int GetAllMapNames(out MapConnection mapdests[15])
{
    local int i, j, numMaps;
    local bool found;
    for(i=0;i<numFixedConns;i++) {
        found=false;
        for(j=0; j<numMaps; j++) {
            if( fixed_conns[i].a.mapname == mapdests[j].mapname ) {
                found=true;
                break;
            }
        }
        if (found == false)
        {
            mapdests[numMaps].mapname = fixed_conns[i].a.mapname;
            mapdests[numMaps].numDests = 0;
            numMaps++;
        }

        found=false;
        for(j=0; j<numMaps; j++) {
            if( fixed_conns[i].b.mapname == mapdests[j].mapname ) {
                found=true;
                break;
            }
        }
        if (found == false)
        {
            mapdests[numMaps].mapname = fixed_conns[i].b.mapname;
            mapdests[numMaps].numDests = 0;
            numMaps++;
        }
    }
    for (i=0;i<numXfers;i++)
    {
        found=false;
        for(j=0; j<numMaps; j++) {
            if( xfers[i].mapname == mapdests[j].mapname ) {
                found=true;
                break;
            }
        }
        if (found == false)
        {
            mapdests[numMaps].mapname = xfers[i].mapname;
            mapdests[numMaps].numDests = 0;
            numMaps++;
        }
    }
    return numMaps;
}

function MarkMapsConnected(out MapConnection mapdests[15], int numMaps, MapTransfer a, MapTransfer b)
{
    local int mapidx;

    if( IsDeadEndConnection(b, a) == false ) {
        mapidx = FindMapDestinations(mapdests, numMaps, a.mapname);
        if(mapidx == -1) {
            err("failed MarkMapsConnected("$numMaps$", "$a.mapname$", "$b.mapname$") find A");
            return;
        }
        AddDestination( mapdests[mapidx], b.mapname);
    }

    if( IsDeadEndConnection(a, b) == false ) {
        mapidx = FindMapDestinations(mapdests, numMaps, b.mapname);
        if(mapidx == -1) {
            err("failed MarkMapsConnected("$numMaps$", "$a.mapname$", "$b.mapname$") find B");
            return;
        }
        AddDestination( mapdests[mapidx], a.mapname);
    }
}

function bool IsDeadEndConnection(MapTransfer m, MapTransfer from)
{
    local int i;
    local string s;

    if(from.outTag == "") return true;
    if(m.inTag == "") return true;
    s = Caps(m.mapname $"#"$ m.inTag);
    for(i=0; i < ArrayCount(dead_ends); i++) {
        if( s == dead_ends[i] ) {
            return true;
        }
    }
    return false;
}

function int FindMapDestinations(MapConnection mapdests[15], int numMaps, string mapname)
{
    local int i;
    for (i=0;i<numMaps;i++)
    {
        if (mapdests[i].mapname == mapname)
        {
            return i;
        }
    }
    err("failed to FindMapDestinations for "$mapname);
    return -1;
}

function AddDestination( out MapConnection map, string mapname )
{
    local int i;
    for(i=0; i < map.numDests; i++) {
        if( map.dest[i] == mapname ) {
            return;
        }
    }
    map.dest[map.numDests] = mapname;
    map.numDests++;
}

function int DuplicateConnections()
{
    local int dupes, i, j;

    for(i=0; i < numConns; i++) {
        for(j=i+1; j < numConns; j++) {
            if( CheckDuplicate(conns[i].a, conns[j].a)
                || CheckDuplicate(conns[i].a, conns[j].b)
                || CheckDuplicate(conns[i].b, conns[j].b)
                || CheckDuplicate(conns[i].b, conns[j].a)
            ) {
                dupes++;
            }
        }
    }
    return dupes;
}

function bool CheckDuplicate(MapTransfer a, MapTransfer b)
{
    if( a.mapname != b.mapname ) return false;
    if( a.inTag == b.inTag
        || a.outTag == b.outTag
    ) {
        return true;
    }
    return false;
}

function MarkMapDestinationsVisitible(MapConnection m, out string canvisit[15], out int visitable)
{
    local int k, p;
    local bool canVisitDest;

    for (k=0;k<m.numDests;k++)
    {
        //If any of those destinations are not in the places we can visit, add them
        canVisitDest = False;
        for (p=0;p<visitable;p++)
        {
            if ( canvisit[p]==m.dest[k] )
            {
                canVisitDest = True;
            }
        }
        if (canVisitDest == False)
        {
            canvisit[visitable] = m.dest[k];
            visitable++;
        }
    }
}

function GenerateConnections(int missionNum)
{
    local int attempts;
    local bool isValid;
    isValid = False;
    for(attempts=0; attempts<100; attempts++)
    {
        _GenerateConnections(missionNum);
        if(ValidateConnections())
            return;
    }
    err("GenerateConnections("$missionNum$") failed after "$attempts$" attempts!");
}

function _GenerateConnections(int missionNum)
{
    local int xfersUsed;
    local int connsMade;
    local int nextAvailIdx;
    local int destOffset;
    local int destIdx;
    local int maxAttempts;
    local int i;
    
    maxAttempts = 20;
    
    for(i=0;i<numXfers;i++)
    {
        xfers[i].used = False;
    }
    xfersUsed = 0;
    connsMade = 0;

    for(i=0; i < numFixedConns; i++) {
        conns[i] = fixed_conns[i];
        connsMade++;
    }

    while (xfersUsed < numXfers)
    {
        nextAvailIdx = GetNextTransferIdx();
        conns[connsMade].a = xfers[nextAvailIdx];
    
        xfers[nextAvailIdx].used = True;
        xfersUsed++;
    
        //Get a random unused transfer
        for (i=0;i<maxAttempts;i++)
        {
            destOffset = rng(numXfers-xfersUsed);
            destIdx = GetUnusedTransferByOffset(destOffset);
        
            if (IsConnectionValid(missionNum,xfers[nextAvailIdx],xfers[destIdx]))
            {
                break;
            }
        }
        if( i >= maxAttempts ) {
            l("failed to find valid connection");
        }
        xfers[destIdx].used = True;
        xfersUsed++;
    
        conns[connsMade].b = xfers[destIdx];
        connsMade++;
    }
    numConns = connsMade;
}

function AddXfer(string mapname, string inTag, string outTag)
{
    xfers[numXfers].mapname = Caps(mapname);
    xfers[numXfers].inTag = Caps(inTag);
    xfers[numXfers].outTag = Caps(outTag);
    xfers[numXfers].used = False;
    
    numXfers++;
}

function AddDoubleXfer(string mapname_a, string inTag, string mapname_b, string outTag)
{
    AddXfer(mapname_a, inTag, outTag);//we might need to also store mapname_b in the case of duplicate tags
    AddXfer(mapname_b, outTag, inTag);
}

function AddFixedConn(string map_a, string inTag_a, string map_b, string outTag_a)
{
    fixed_conns[numFixedConns].a.mapname = Caps(map_a);
    fixed_conns[numFixedConns].a.inTag = Caps(inTag_a);
    fixed_conns[numFixedConns].a.outTag = Caps(outTag_a);
    fixed_conns[numFixedConns].b.mapname = Caps(map_b);
    fixed_conns[numFixedConns].b.inTag = Caps(outTag_a);
    fixed_conns[numFixedConns].b.outTag = Caps(inTag_a);
    numFixedConns++;
}

function RandoMission2()
{
    AddFixedConn("02_NYC_BatteryPark","ToBatteryPark", "02_NYC_Street","ToStreet");
    AddDoubleXfer("02_NYC_Bar","ToBarBackEntrance","02_NYC_Street","FromBarBackEntrance");
    AddDoubleXfer("02_NYC_Bar","ToBarFrontEntrance","02_NYC_Street","FromBarFrontEntrance");
    AddDoubleXfer("02_NYC_FreeClinic","FromStreet","02_NYC_Street","FromClinic");
    AddDoubleXfer("02_NYC_Hotel","ToHotelBedroom","02_NYC_Street","BedroomWindow");
    AddDoubleXfer("02_NYC_Hotel","ToHotelFrontDoor","02_NYC_Street","FromHotelFrontDoor");
    AddDoubleXfer("02_NYC_Smug","ToSmugFrontDoor","02_NYC_Street","FromSmugFrontDoor");
    AddDoubleXfer("02_NYC_Smug","ToSmugBackDoor","02_NYC_Street","FromSmugBackDoor");
    AddDoubleXfer("02_NYC_Underground","ToNYCUndergroundSewer2","02_NYC_Street","FromNYCUndergroundSewer2");
    AddDoubleXfer("02_NYC_Underground","ToNYCSump","02_NYC_Street","FromNYCSump");
    AddDoubleXfer("02_NYC_Warehouse","ToRoofTop","02_NYC_Street","FromRoofTop");
    AddDoubleXfer("02_NYC_Warehouse","ToWarehouseAlley","02_NYC_Street","FromWarehouseAlley");

    GenerateConnections(2);
}

function RandoMission3()
{
    AddFixedConn("03_NYC_BatteryPark","x", "03_NYC_BatteryPark","x");//just make sure the traversal in ValidateConnections starts from the same place the player starts at
    AddDoubleXfer("03_NYC_BatteryPark","BBSExit","03_NYC_BrooklynBridgeStation","FromNYCStreets");
    AddDoubleXfer("03_NYC_BrooklynBridgeStation","MoleExit","03_NYC_MolePeople","MoleEnt");
    AddDoubleXfer("03_NYC_MolePeople","SewerExit","03_NYC_AirfieldHeliBase","SewerEnt");
    AddDoubleXfer("03_NYC_AirfieldHeliBase","BHElevatorEnt","03_NYC_Airfield","BHElevatorExit");
    AddDoubleXfer("03_NYC_AirfieldHeliBase","FromOcean","03_NYC_Airfield","ToOcean");
    AddDoubleXfer("03_NYC_Airfield","HangarExit","03_NYC_Hangar","HangarEnt");
    AddDoubleXfer("03_NYC_Hangar","747PassExit","03_NYC_747","747PassEnt");
    
    GenerateConnections(3);
}

function RandoMission4()
{
    AddFixedConn("04_NYC_Street","x", "04_NYC_Street","x");
    AddDoubleXfer("04_NYC_BATTERYPARK","ToBatteryPark","04_NYC_Street","ToStreet");
    AddDoubleXfer("04_NYC_STREET","FromSmugBackDoor","04_NYC_Smug","ToSmugBackDoor");
    AddDoubleXfer("04_NYC_STREET","FromSmugFrontDoor","04_NYC_Smug","ToSmugFrontDoor");
    AddDoubleXfer("04_NYC_STREET","FromBarBackEntrance","04_NYC_Bar","ToBarBackEntrance");
    AddDoubleXfer("04_NYC_STREET","FromBarFrontEntrance","04_NYC_Bar","ToBarFrontEntrance");
    AddDoubleXfer("04_NYC_STREET","FromHotelFrontDoor","04_NYC_Hotel","ToHotelFrontDoor");
    AddDoubleXfer("04_NYC_STREET","BedroomWindow","04_NYC_Hotel","ToHotelBedroom");
    AddDoubleXfer("04_NYC_STREET","FromNSFHQ","04_NYC_NSFHQ","ToNSFHQ");
    AddDoubleXfer("04_NYC_STREET","FromNYCUndergroundSewer2","04_NYC_Underground","ToNYCUndergroundSewer2");
    AddDoubleXfer("04_NYC_STREET","FromNYCSump","04_NYC_Underground","ToNYCSump");

    GenerateConnections(4);
}

function RandoMission6()
{
    AddFixedConn("06_HONGKONG_HELIBASE","Helibase","06_HongKong_WanChai_Market","cargoup");
    AddDoubleXfer("06_HONGKONG_MJ12LAB","cathedral","06_HongKong_VersaLife","secret");
    AddDoubleXfer("06_HONGKONG_MJ12LAB","tubeend","06_HongKong_Storage","basement");
    AddDoubleXfer("06_HONGKONG_STORAGE","waterpipe","06_HongKong_WanChai_Canal","canal");
    //AddDoubleXfer("06_HONGKONG_STORAGE","basement","06_HongKong_MJ12lab","tubeend");
    //AddXfer("06_HongKong_Storage","BackDoor","06_HONGKONG_WANCHAI_GARAGE#Teleporter");//one way
    AddFixedConn("06_HONGKONG_TONGBASE","lab","06_HongKong_WanChai_Market","compound");
    AddDoubleXfer("06_HONGKONG_VERSALIFE","Lobby","06_HongKong_WanChai_Market","market");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","Street","06_HongKong_WanChai_Street","Canal");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","market01","06_HongKong_WanChai_Market","canal01");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","double","06_HongKong_WanChai_Market","chinahand");
    AddDoubleXfer("06_HONGKONG_WANCHAI_GARAGE","market04","06_HongKong_WanChai_Market","garage01");
    AddDoubleXfer("06_HONGKONG_WANCHAI_MARKET","canal03","06_HongKong_WanChai_Underworld","market03");
    AddDoubleXfer("06_HongKong_WanChai_Street","alleyout","06_HongKong_WanChai_Canal","alleyin");

    GenerateConnections(6);
}

function RandoMission8()
{
    AddFixedConn("08_NYC_Street","x", "08_NYC_Street","x");
    AddDoubleXfer("08_NYC_BAR","ToBarFrontEntrance","08_NYC_Street","FromBarFrontEntrance");
    AddDoubleXfer("08_NYC_BAR","ToBarBackEntrance","08_NYC_Street","FromBarBackEntrance");
    AddDoubleXfer("08_NYC_FREECLINIC","FromStreet","08_NYC_Street","FromClinic");
    AddDoubleXfer("08_NYC_HOTEL","ToHotelFrontDoor","08_NYC_Street","FromHotelFrontDoor");
    AddDoubleXfer("08_NYC_HOTEL","ToHotelBedroom","08_NYC_Street","BedroomWindow");
    AddDoubleXfer("08_NYC_SMUG","ToSmugFrontDoor","08_NYC_Street","FromSmugFrontDoor");
    AddDoubleXfer("08_NYC_SMUG","ToSmugBackDoor","08_NYC_Street","FromSmugBackDoor");
    AddDoubleXfer("08_NYC_UNDERGROUND","ToNYCSump","08_NYC_Street","FromNYCSump");
    AddDoubleXfer("08_NYC_UNDERGROUND","ToNYCUndergroundSewer2","08_NYC_Street","FromNYCUndergroundSewer2");

    GenerateConnections(8);
}

function RandoMission9()
{
    AddFixedConn("09_NYC_DOCKYARD","x", "09_NYC_DOCKYARD","x");
    AddDoubleXfer("09_NYC_DOCKYARD","ToDockyardSewer","09_NYC_Ship","FromDockyardSewer");
    AddDoubleXfer("09_NYC_DOCKYARD","FromAircondDuct","09_NYC_ShipFan","ToAircondDuct");
    AddDoubleXfer("09_NYC_DOCKYARD","ExitShip","09_NYC_Ship","EnterShip");
    //AddDoubleXfer("09_NYC_DOCKYARD","","09_NYC_Graveyard","");
    //AddDoubleXfer("09_NYC_GRAVEYARD","","10_Paris_Catacombs","");
    AddDoubleXfer("09_NYC_SHIP","FromFanRoom","09_NYC_ShipFan","ToFanRoom");
    AddDoubleXfer("09_NYC_SHIP","FromDuctRoom","09_NYC_ShipFan","ToDuctRoom");
    AddDoubleXfer("09_NYC_SHIP","FromBelow","09_NYC_ShipBelow","FromAbove");

    GenerateConnections(9);
}

function RandoMission10()
{
    AddFixedConn("10_PARIS_CATACOMBS","x", "10_PARIS_CATACOMBS","x");
    AddDoubleXfer("10_PARIS_CATACOMBS","spiralstair","10_Paris_Catacombs_Tunnels","spiralstair");//same tag on both sides?
    AddFixedConn("10_PARIS_CATACOMBS_TUNNELS","?toname=AmbientSound10","10_Paris_Metro","sewer");//one way, I could maybe use separate teleporters for each side of the sewers to make more options?
    AddFixedConn("10_Paris_Metro","","10_PARIS_CHATEAU","x");//one way
    //AddDoubleXfer("10_PARIS_CHATEAU","","11_Paris_Cathedral","cathedralstart");//one way
    AddDoubleXfer("10_PARIS_CLUB","Paris_Club1","10_Paris_Metro","Paris_Metro1");
    AddDoubleXfer("10_PARIS_CLUB","Paris_Club2","10_Paris_Metro","Paris_Metro2");
    //AddDoubleXfer("11_PARIS_CATHEDRAL","Paris_Underground","11_Paris_Underground","Paris_Underground");
    //AddDoubleXfer("11_PARIS_EVERETT","","12_Vandenberg_cmd");

    GenerateConnections(10);
}

function RandoMission11()
{
    //AddFixedConn("11_PARIS_CATHEDRAL","x","11_PARIS_CATHEDRAL", "x");
    AddDoubleXfer("11_PARIS_CATHEDRAL","Paris_Underground","11_Paris_Underground","Paris_Underground");
    //AddDoubleXfer("11_PARIS_EVERETT","","12_Vandenberg_cmd");

    GenerateConnections(11);
}

function RandoMission12()
{
    local DeusExMover d;

    AddFixedConn("12_VANDENBERG_CMD","x","12_VANDENBERG_CMD", "x");
    AddDoubleXfer("12_VANDENBERG_CMD","commstat","12_vandenberg_tunnels","start");
    AddDoubleXfer("12_VANDENBERG_CMD","storage","12_vandenberg_tunnels","end");
    AddDoubleXfer("12_VANDENBERG_CMD","hall","12_vandenberg_computer","computer");

    if( dxr.localURL == "12_VANDENBERG_CMD" ) {
        foreach AllActors(class'DeusExMover', d) {
            switch(d.Tag) {
                case 'door_controlroom':
                case 'security_tunnels':
                    class'DXRKeys'.static.MakePickable(d);
                    class'DXRKeys'.static.MakeDestructible(d);
                    break;
            }
        }
    }
    //AddDoubleXfer("12_VANDENBERG_CMD","","12_Vandenberg_gas","");
    //AddDoubleXfer("12_VANDENBERG_GAS","gas_start","","");
    //AddDoubleXfer("12_VANDENBERG_GAS","","14_Vandenberg_sub","");

    /*AddFixedConn("12_vandenberg_computer","x","14_Vandenberg_sub.dx", "x");//jock takes you to the gas station after 12_vandenberg_computer, then to vandenberg sub... this causes issues

    AddDoubleXfer("14_OCEANLAB_LAB","Sunkentunnel","14_OceanLab_UC.dx ","UC");//strange formatting, some even have a space
    AddDoubleXfer("14_OCEANLAB_LAB","Sunkenlab","14_Vandenberg_sub.dx","subbay");*/
    //AddDoubleXfer("14_OCEANLAB_SILO","frontgate","","");
    //AddDoubleXfer("14_OCEANLAB_SILO","","15_area51_bunker.dx ","bunker_start");
    //AddDoubleXfer("14_Vandenberg_sub.dx","","14_Oceanlab_silo.dx ","frontgate");

    GenerateConnections(12);
}

function RandoMission14()
{
    AddFixedConn("14_Vandenberg_sub.dx","x","14_Vandenberg_sub.dx", "x");
    AddDoubleXfer("14_OCEANLAB_LAB","Sunkentunnel","14_OceanLab_UC.dx ","UC");//strange formatting, some even have a space
    AddDoubleXfer("14_OCEANLAB_LAB","Sunkenlab","14_Vandenberg_sub.dx","subbay");
    //AddDoubleXfer("14_OCEANLAB_SILO","frontgate","","");
    //AddDoubleXfer("14_OCEANLAB_SILO","","15_area51_bunker.dx ","bunker_start");
    //AddDoubleXfer("14_Vandenberg_sub.dx","","14_Oceanlab_silo.dx ","frontgate");

    GenerateConnections(14);
}

function RandoMission15()
{
    AddFixedConn("15_AREA51_BUNKER","x","15_AREA51_BUNKER", "x");
    //AddDoubleXfer("15_AREA51_BUNKER","commstat","","");
    AddDoubleXfer("15_AREA51_BUNKER","?toname=Light188","15_Area51_entrance","start");
    AddDoubleXfer("15_Area51_entrance","?toname=Light73","15_AREA51_FINAL","start");
    AddDoubleXfer("15_AREA51_FINAL","final_end","15_Area51_page","page_start");
    //AddDoubleXfer("15_AREA51_FINAL","Start","");

    GenerateConnections(15);
}

function EntranceRando(int missionNum)
{   
    numConns = 0;
    numXfers = 0;
    numFixedConns = 0;
    //if( missionNum == 11 ) missionNum = 10;//combine paris 10 and 11
    //if( missionNum == 14 ) missionNum = 12;//combine vandenberg and oceanlab?
    dxr.SetSeed( dxr.seed + dxr.Crc("entrancerando") + missionNum );

    switch(missionNum)
    {
        case 2:
            RandoMission2();
            break;
        case 3:
            RandoMission3();
            break;
        case 4:
            RandoMission4();
            break;
        case 6:
            RandoMission6();
            break;
        case 8:
            RandoMission8();
            break;
        case 9:
            RandoMission9();
            break;
        case 10:
            RandoMission10();
            break;
        case 11:
            //RandoMission11();
            break;
        case 12:
            RandoMission12();
            break;
        case 14:
            //RandoMission14();
            break;
        case 15:
            RandoMission15();
            break;
    }
}


function ApplyEntranceRando()
{
    local Teleporter t;
    local MapExit m;
    local string newDest;
    local string curDest;
    local string destTag;
    local int i;
    local int hashPos;

    foreach AllActors(class'Teleporter',t)
    {
        AdjustTeleporter(t);
    }
    
    foreach AllActors(class'MapExit',m)
    {
        AdjustTeleporter(m);
    }
    
}

function AdjustTeleporter(NavigationPoint p)
{
    local Teleporter t;
    local MapExit m;
    local string newDest;
    local string curDest;
    local string destTag;
    local int i;
    local int hashPos;

    t = Teleporter(p);
    m = MapExit(p);
    if( t != None ) curDest = t.URL;
    else if( m != None ) curDest = m.DestMap;

    if( curDest == "" ) return;

    hashPos = InStr(curDest,"#");
    destTag = Caps(Mid(curDest,hashPos+1));

    for (i = 0;i<numConns;i++)
    {
        if (conns[i].a.mapname == dxr.localURL && destTag == conns[i].a.outTag)
        {
            newDest = conns[i].b.mapname$"#"$conns[i].b.inTag;
        }
        else if (conns[i].b.mapname == dxr.localURL && destTag == conns[i].b.outTag)
        {
            newDest = conns[i].a.mapname$"#"$conns[i].a.inTag;
        }
        else
            continue;

        if( t != None ) t.URL = newDest;
        else if( m != None ) m.DestMap = newDest;
        l("Found " $ p $ " with destination " $ curDest $ ", changed to " $ newDest);
    }
}

function FirstEntry()
{
    Super.FirstEntry();

    if( dxr.flags.gamemode != 1 ) return;
    
    //Randomize entrances for this mission
    EntranceRando(dxr.dxInfo.missionNumber);
    ApplyEntranceRando();
    LogConnections();
}

function LogConnections()
{
    local int i;
    for (i = 0;i<numConns;i++)
    {
        l("conns["$i$"]:");
        l( "    "$ conns[i].a.mapname $"#"$ conns[i].a.outTag $" goes to "$ conns[i].b.mapname $"#"$ conns[i].b.inTag );
        l( "    "$ conns[i].b.mapname $"#"$ conns[i].b.outTag $" goes to "$ conns[i].a.mapname $"#"$ conns[i].a.inTag );
    }
}

function int RunTests()
{
    local int results, i;
    results = Super.RunTests();

    if( dxr.flags.gamemode != 1 ) return results;

    results += BasicTests();
    results += OneWayTests();

    for(i=0; i <= 100; i++) {
        dxr.SetSeed( 123 + i + dxr.Crc("entrancerando") );
        EntranceRando(i);
        if( numXfers > 0 && numConns > 0 ) {
            LogConnections();
            results += testbool(ValidateConnections(), true, "RandoMission" $ i $ " validation");
        }
    }

    numXfers = 0;
    numConns = 0;
    numFixedConns = 0;

    return results;
}

function int BasicTests()
{
    local int results, i;
    local string old_dead_end;

    results += test(min_connections_selfconnect >= 3, "min_connections_selfconnect needs to be at least 3");

    numXfers = 0;
    numFixedConns = 0;
    old_dead_end = dead_ends[0];
    dead_ends[0] = "HELIPAD#HELIPAD_TO_WANCHAI";

    AddDoubleXfer("helipad","helipad_to_wanchai","wanchai_market","wanchai_from_helipad");
    AddDoubleXfer("wanchai_market","to_tong","tong","tong_from_wanchai");
    AddDoubleXfer("wanchai_market","to_versalife","versalife","versalife_from_wanchai");
    AddDoubleXfer("versalife","to_versalife2","versalife2","from_versalife");
    
    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[1];
    conns[1].b = xfers[0];
    numConns = 2;
    //LogConnections();
    results += testbool(ValidateConnections(), false, "ValidateConnections test 1");

    //need tests for 2 things linking to the same teleporter, maps linking to themselves, short isolated loops, testing that all maps are reachable
    //need to log the results
    //I just got warehouse -> sewers -> bar -> warehouse
    //also a weird one where walking the wrong way after teleporting took me somewhere else probably because both the in and out teleporter were tagged?
    //need to support 1-way maps, and a test for it

    conns[0].a = xfers[1];//don't do the deadend first
    conns[0].b = xfers[0];
    conns[1].a = xfers[2];
    conns[1].b = xfers[3];
    conns[2].a = xfers[4];
    conns[2].b = xfers[5];
    conns[3].a = xfers[6];
    conns[3].b = xfers[7];
    numConns = 4;
    //LogConnections();
    results += testbool(ValidateConnections(), true, "ValidateConnections test 2");

    conns[0].a = xfers[0];
    conns[0].b = xfers[4];
    conns[1].a = xfers[3];
    conns[1].b = xfers[5];
    conns[2].a = xfers[7];
    conns[2].b = xfers[2];
    conns[3].a = xfers[6];
    conns[3].b = xfers[1];
    numConns = 4;
    //LogConnections();
    results += testbool(ValidateConnections(), true, "ValidateConnections test 3");

    conns[0].a = xfers[7];
    conns[0].b = xfers[0];
    conns[1].a = xfers[6];
    conns[1].b = xfers[5];
    conns[2].a = xfers[4];
    conns[2].b = xfers[3];
    conns[1].a = xfers[2];
    conns[1].b = xfers[1];
    numConns = 4;
    //LogConnections();
    results += testbool(ValidateConnections(), false, "ValidateConnections dead_end test");

    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[4];
    conns[1].b = xfers[5];
    numConns = 2;
    //LogConnections();
    results += testbool(ValidateConnections(), false, "ValidateConnections island test");

    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[2];
    conns[1].b = xfers[3];
    conns[2].a = xfers[4];
    conns[2].b = xfers[5];
    conns[3].a = xfers[4];
    conns[3].b = xfers[5];
    numConns = 4;
    //LogConnections();
    results += testbool(ValidateConnections(), false, "ValidateConnections duplicate test");

    dxr.SetSeed( 123 + dxr.Crc("entrancerando") );
    GenerateConnections(3);
    //LogConnections();
    results += testbool(ValidateConnections(), true, "GenerateConnections validation");

    dead_ends[0] = old_dead_end;

    return results;
}

function int OneWayTests()
{
    local int results,i;

    numXfers = 0;
    numFixedConns = 0;
    AddDoubleXfer("PARIS_CATACOMBS","spiralstair","Paris_Catacombs_Tunnels","spiralstair");
    AddXfer("PARIS_CATACOMBS_TUNNELS","","sewer");
    AddXfer("Paris_Metro","sewer","");
    //AddDoubleXfer("PARIS_CLUB","Paris_Club1","Paris_Metro","Paris_Metro1");
    //AddDoubleXfer("PARIS_CLUB","Paris_Club2","Paris_Metro","Paris_Metro2");
    
    conns[0].a = xfers[0];
    conns[0].b = xfers[2];
    conns[1].a = xfers[3];
    conns[1].b = xfers[1];
    numConns = 2;
    LogConnections();
    results += testbool(ValidateConnections(), false, "ValidateConnections one-way test 1");

    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[2];
    conns[1].b = xfers[3];
    numConns = 2;
    LogConnections();
    results += testbool(ValidateConnections(), true, "ValidateConnections one-way test 2");

    dxr.SetSeed( 123 + dxr.Crc("entrancerando") );
    EntranceRando(10);
    numConns=0;
    for(i=0;i<numFixedConns;i++) {
        conns[numConns] = fixed_conns[i];
        numConns++;
    }
    for(i=0;i<numXfers;i+=2) {
        conns[numConns].a = xfers[i];
        conns[numConns].b = xfers[i+1];
        numConns++;
    }
    LogConnections();
    results += testbool(ValidateConnections(), true, "manual Paris validation");

    return results;
}

defaultproperties
{
    min_connections_selfconnect=999
}
