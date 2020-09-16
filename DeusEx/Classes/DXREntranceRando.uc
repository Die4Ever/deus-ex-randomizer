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

var MapTransfer xfers[50];
var int numXfers;

struct BanConnection
{
    var string map_a;
    var string map_b;
};
var config BanConnection BannedConnections[32];

function CheckConfig()
{
    local int i;
    if( config_version == 0 ) {
        for(i=0; i < ArrayCount(BannedConnections); i++) {
            BannedConnections[i].map_a = "";
            BannedConnections[i].map_b = "";
        }
        BannedConnections[0].map_a = "02_NYC_BatteryPark";
        BannedConnections[0].map_b = "02_NYC_Underground";
        BannedConnections[1].map_a = "02_NYC_BatteryPark";
        BannedConnections[1].map_b = "02_NYC_Warehouse";
    }
    else {
        for(i=0; i < ArrayCount(BannedConnections); i++) {
            BannedConnections[i].map_a = Caps(BannedConnections[i].map_a);
            BannedConnections[i].map_b = Caps(BannedConnections[i].map_b);
        }
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

function bool IsDeadEnd(string mapname)
{
    return GetNumXfersByMap(mapname)==1;
}

function bool CanSelfConnect(string mapname)
{
    return GetNumXfersByMap(mapname)>2;
}

function bool IsConnectionValid(int missionNum, MapTransfer a, MapTransfer b)
{
    local int i;

    if ( IsDeadEnd(a.mapname) && IsDeadEnd(b.mapname) )
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
    
    //Determine what maps can be visited from each map
    for (i=0;i<numConns;i++)
    {
        MarkMapsConnected(mapdests, numMaps, conns[i].a.mapname, conns[i].b.mapname);
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
    return visitable == numMaps;
}

function int GetAllMapNames(out MapConnection mapdests[15])
{
    local int i, j, numMaps;
    local bool found;
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

function MarkMapsConnected(out MapConnection mapdests[15], int numMaps, string map_a, string map_b)
{
    local int mapidx;
    mapidx = FindMapDestinations(mapdests, numMaps, map_a);
    if(mapidx == -1) {
        err("failed MarkMapsConnected("$numMaps$", "$map_a$", "$map_b$") find A");
        return;
    }
    AddDestination( mapdests[mapidx], map_b);
    
    mapidx = FindMapDestinations(mapdests, numMaps, map_b);
    if(mapidx == -1) {
        err("failed MarkMapsConnected("$numMaps$", "$map_a$", "$map_b$") find B");
        return;
    }
    AddDestination( mapdests[mapidx], map_a);
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
    
    maxAttempts = 10;
    
    for(i=0;i<numXfers;i++)
    {
        xfers[i].used = False;
    }
    xfersUsed = 0;
    connsMade = 0;

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
    xfers[numXfers].inTag = inTag;
    xfers[numXfers].outTag = outTag;
    xfers[numXfers].used = False;
    
    numXfers++;
}

function AddDoubleXfer(string mapname_a, string inTag, string mapname_b, string outTag)
{
    AddXfer(mapname_a, inTag, outTag);
    AddXfer(mapname_b, outTag, inTag);
}

function RandoMission2()
{
    AddDoubleXfer("02_NYC_BatteryPark","ToBatteryPark","02_NYC_Street", "ToStreet");
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
    AddDoubleXfer("06_HONGKONG_HELIBASE","Helibase","06_HongKong_WanChai_Market","cargoup");
    AddDoubleXfer("06_HONGKONG_MJ12LAB","cathedral","06_HongKong_VersaLife","secret");
    AddDoubleXfer("06_HONGKONG_MJ12LAB","tubeend","06_HongKong_Storage","basement");
    AddDoubleXfer("06_HONGKONG_STORAGE","waterpipe","06_HongKong_WanChai_Canal","canal");
    AddDoubleXfer("06_HONGKONG_STORAGE","basement","06_HongKong_MJ12lab","tubeend");
    //AddXfer("06_HongKong_Storage","BackDoor","06_HONGKONG_WANCHAI_GARAGE#Teleporter");//one way
    AddDoubleXfer("06_HONGKONG_TONGBASE","lab","06_HongKong_WanChai_Market","compound");
    AddDoubleXfer("06_HONGKONG_VERSALIFE","Lobby","06_HongKong_WanChai_Market","market");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","Street","06_HongKong_WanChai_Street","Canal");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","market01","06_HongKong_WanChai_Market","canal01");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","double","06_HongKong_WanChai_Market","chinahand");
    AddDoubleXfer("06_HONGKONG_WANCHAI_GARAGE","market04","06_HongKong_WanChai_Market","garage01");
    AddDoubleXfer("06_HONGKONG_WANCHAI_MARKET","canal03","06_HongKong_WanChai_Underworld","market03");
    AddDoubleXfer("06_HongKong_WanChai_Street","alleyout","06_HongKong_WanChai_Canal","alleyin");

    GenerateConnections(6);
}

function EntranceRando(int missionNum)
{   
    numConns = 0;
    numXfers = 0;
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
            break;
        case 9:
            break;
        case 10:
            break;
        case 12:
            break;
        case 15:
            break;
    
    }
    ApplyEntranceRando();
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
    destTag = Mid(curDest,hashPos+1);

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

}

function int RunTests()
{
    local int results, i;
    results = Super.RunTests();

    numXfers = 0;

    AddDoubleXfer("wanchai_market","to_tong","tong","from_wanchai");
    AddDoubleXfer("wanchai_market","to_versalife","versalife","from_wanchai");
    AddDoubleXfer("versalife","to_versalife2","versalife2","from_versalife");
    
    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[1];
    conns[1].b = xfers[0];
    numConns = 2;
    results += testbool(ValidateConnections(), false, "ValidateConnections test 1");

    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[2];
    conns[1].b = xfers[3];
    conns[2].a = xfers[4];
    conns[2].b = xfers[5];
    numConns = 3;
    results += testbool(ValidateConnections(), true, "ValidateConnections test 2");

    conns[0].a = xfers[5];
    conns[0].b = xfers[4];
    conns[1].a = xfers[3];
    conns[1].b = xfers[2];
    conns[2].a = xfers[1];
    conns[2].b = xfers[0];
    numConns = 3;
    results += testbool(ValidateConnections(), true, "ValidateConnections test 3");

    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[4];
    conns[1].b = xfers[5];
    numConns = 2;
    results += testbool(ValidateConnections(), false, "ValidateConnections island test");

    GenerateConnections(3);
    results += testbool(ValidateConnections(), true, "AddDoubleXfer validation");

    for(i=0; i <= 100; i++) {
        EntranceRando(i);
        if( numXfers > 0 )
            results += testbool(ValidateConnections(), true, "RandoMission" $ i $ " validation");
    }

    numXfers = 0;
    numConns = 0;

    return results;
}

defaultproperties
{
}
