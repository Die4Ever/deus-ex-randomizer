//=============================================================================
// DXREntranceRando.
//=============================================================================
class DXREntranceRando expands DXRActorsBase;

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
var Connection conns[20];
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

var config string dead_ends[32];
/*var config string unreachable_conns[16];

struct Dependency
{
    // this is mostly for keys that are needed from other areas
    // the key would be inside the map dependency
    // dependent would be the teleporter that is behind the locked door, which may end up going to a different map
    var string dependent;
    var string dependency;
};

var config Dependency dependencies[16];*/

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
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,7) ) {
        min_connections_selfconnect = 999;
        i = 0;
        dead_ends[i++] = "06_HONGKONG_WANCHAI_GARAGE#Teleporter";
        dead_ends[i++] = "06_HONGKONG_Storage#waterpipe";
        //dead_ends[i++] = "12_VANDENBERG_CMD#storage";//it's actually backwards from this, instead of this teleporter being a dead end, the door before the teleporter is the dead end
        //dead_ends[i++] = "12_VANDENBERG_TUNNELS#End";//this isn't right either, because if you can get to this teleporter then you can get through the map

        /*i=0;
        unreachable_conns[i++] = "12_VANDENBERG_CMD#storage";

        i=0;
        dependencies[i].dependent = "12_vandenberg_computer#computer";
        dependencies[i].dependency = "12_VANDENBERG_TUNNELS";
        i++;

        dependencies[i].dependent = "12_vandenberg_gas";
        dependencies[i].dependency = "12_VANDENBERG_COMPUTER";
        i++;*/
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

    // can we get from A to B?
    if( IsDeadEndConnection(b, a) == false ) {
        mapidx = FindMapDestinations(mapdests, numMaps, a.mapname);
        if(mapidx == -1) {
            err("failed MarkMapsConnected("$numMaps$", "$a.mapname$", "$b.mapname$") find A");
            return;
        }
        // write B into the destinations of A
        AddDestination( mapdests[mapidx], b.mapname);
    }

    // can we get from B to A?
    if( IsDeadEndConnection(a, b) == false ) {
        mapidx = FindMapDestinations(mapdests, numMaps, b.mapname);
        if(mapidx == -1) {
            err("failed MarkMapsConnected("$numMaps$", "$a.mapname$", "$b.mapname$") find B");
            return;
        }
        // write A into the destinations of B
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

    for(attempts=0; attempts<200; attempts++)
    {
        _GenerateConnections(missionNum);
        if(ValidateConnections()) {
            if( attempts > 40 ) warning("GenerateConnections("$missionNum$") succeeded but took "$attempts$" attempts! seed: "$dxr.seed);
            return;
        }
    }
    err("GenerateConnections("$missionNum$") failed after "$attempts$" attempts! seed: "$dxr.seed);
}

function _GenerateConnections(int missionNum)
{
    local int xfersUsed;
    local int connsMade;
    local int nextAvailIdx;
    local int xferOffset;
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
        xferOffset = rng(numXfers-xfersUsed);
        nextAvailIdx = GetUnusedTransferByOffset(xferOffset);
        conns[connsMade].a = xfers[nextAvailIdx];
    
        xfers[nextAvailIdx].used = True;
        xfersUsed++;
    
        //Get a random unused transfer
        for (i=0;i<maxAttempts;i++)
        {
            xferOffset = rng(numXfers-xfersUsed);
            destIdx = GetUnusedTransferByOffset(xferOffset);
        
            if (IsConnectionValid(missionNum,xfers[nextAvailIdx],xfers[destIdx]))
            {
                break;
            }
        }
        if( i >= maxAttempts ) {
            l("failed to find valid connection for " $ xfers[nextAvailIdx].mapname $ "#" $ xfers[nextAvailIdx].inTag $ " / #" $ xfers[nextAvailIdx].outTag );
            return;
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

// ApplyFixes is for backtracking that we don't want in the normal game
function ApplyFixes()
{
    switch(dxr.localURL) {
        case "06_HONGKONG_WANCHAI_CANAL":
            FixHongKongCanal();
            break;
        
        /*case "06_HONGKONG_STORAGE":
            foreach AllActors(class'WaterZone', w) {
                //if( w.Name == 'WaterZone5' || w.Name == 'WaterZone1' )
                    w.ZoneVelocity = vect(0,0,0);
            }
            break;*/

        case "12_VANDENBERG_CMD":
            FixVandebergCmd();
            break;
    }
}

function FixHongKongCanal()
{
    local HKTukTuk tuktuk;
    local Containers box;
    local DynamicBlockPlayer dbp;
    local vector loc;
    local int i;

    foreach AllActors(class'HKTukTuk', tuktuk) {
        if( tuktuk.Name != 'HKTukTuk0' ) continue;
        tuktuk.SetCollision(false,false,false);
        tuktuk.bCollideWorld = false;
        tuktuk.SetLocation(vect(1162.203735, 1370, -482.995361));
        break;
    }
    loc = vect(1074.268188, 1368.834106, -535);
    for(i=0; i < 5; i++) {
        dbp = Spawn(class'DynamicBlockPlayer',,, loc);
        dbp.SetBase(tuktuk);
        dbp.SetCollisionSize(dbp.CollisionRadius*4, dbp.CollisionHeight*4);

        if( i == 2 )// only the middle one will collide with the box
            dbp.SetCollision(true, true, true);
        if( i == 3 )// the roof thing on the boat is a bit higher
            dbp.SetLocation(loc+vect(0,0,16));

        loc += vect(38, 0, 0);
    }

    box = AddBox(class'BoxMedium', vect(1151.214355, 1370, -400));
    box.bCollideWorld = false;
    box.bPushable = false;
    box.bHighlight = false;
}

function FixVandebergCmd()
{
    local DeusExMover d;

    foreach AllActors(class'DeusExMover', d) {
        switch(d.Tag) {
            case 'door_controlroom':
            case 'security_tunnels':
                class'DXRKeys'.static.StaticMakePickable(d);
                class'DXRKeys'.static.StaticMakeDestructible(d);
                break;
        }
    }
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
    AddDoubleXfer("10_PARIS_CATACOMBS_TUNNELS","?toname=AmbientSound10","10_Paris_Metro","sewer");
    AddDoubleXfer("10_PARIS_CHATEAU","Chateau_start", "10_paris_metro","?toname=PathNode447");
    AddDoubleXfer("10_PARIS_CHATEAU","?toname=Light135","11_Paris_Cathedral","cathedralstart");
    AddDoubleXfer("10_PARIS_CLUB","Paris_Club1","10_Paris_Metro","Paris_Metro1");
    AddDoubleXfer("10_PARIS_CLUB","Paris_Club2","10_Paris_Metro","Paris_Metro2");
    AddDoubleXfer("11_PARIS_CATHEDRAL","Paris_Underground","11_Paris_Underground","Paris_Underground");

    GenerateConnections(10);
}

function RandoMission12()
{
    // I'm not sure what arrangements I would want for vandenberg? maybe I should just make a key for the storage door and stick it somewhere in cmd?
    AddFixedConn("12_VANDENBERG_CMD","x","12_VANDENBERG_CMD", "x");
    AddDoubleXfer("12_VANDENBERG_CMD","commstat","12_vandenberg_tunnels","start");
    //AddDoubleXfer("12_VANDENBERG_CMD","storage","12_vandenberg_tunnels","end");// this needs to be marked as one way somehow, not just AddXfer, because it does go both ways, but only after opening the door
    AddDoubleXfer("12_VANDENBERG_CMD","hall","12_vandenberg_computer","computer");

    AddFixedConn("12_vandenberg_computer","x","14_Vandenberg_sub.dx", "x");//jock takes you to the gas station after 12_vandenberg_computer, then to vandenberg sub... this causes issues
    AddDoubleXfer("14_OCEANLAB_LAB","Sunkentunnel","14_OceanLab_UC.dx ","UC");//strange formatting, some even have a space
    AddDoubleXfer("14_OCEANLAB_LAB","Sunkenlab","14_Vandenberg_sub.dx","subbay");

    GenerateConnections(12);
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

function BindEntrances(DataStorage ds, bool writing)
{
    local int i;

    if(writing) ds.numConns = numConns;
    else numConns = ds.numConns;

    for (i = 0;i<numConns;i++)
    {
        ds.BindConn(i, 0, conns[i].a.mapname, writing);
        ds.BindConn(i, 1, conns[i].a.inTag, writing);
        ds.BindConn(i, 2, conns[i].a.outTag, writing);

        ds.BindConn(i, 3, conns[i].b.mapname, writing);
        ds.BindConn(i, 4, conns[i].b.inTag, writing);
        ds.BindConn(i, 5, conns[i].b.outTag, writing);
    }
}

function ApplyEntranceRando(int missionNum)
{
    local NavigationPoint newnp, last;
    local Teleporter t;
    local MapExit m;
    local DataStorage ds;

    ds = class'DataStorage'.static.GetObj(dxr.Player);
    if( ds.EntranceRandoMissionNumber == missionNum ) {
        BindEntrances(ds, false);
    } else {
        ds.EntranceRandoMissionNumber = missionNum;
        BindEntrances(ds, true);
    }

    last = None;
    foreach AllActors(class'Teleporter',t)
    {
        if( t == last ) break;
        newnp = AdjustTeleporter(t);
        if( last == None ) last = newnp;
    }
    
    foreach AllActors(class'MapExit',m)
    {
        AdjustTeleporter(m);
    }
    
}

function NavigationPoint AdjustTeleporter(NavigationPoint p)
{
    local Teleporter t;
    local MapExit m;
    local DynamicTeleporter dt, newdt;
    local string curDest, destTag;
    local string newMap, newTag, newName;
    local int i;
    local int hashPos;
    local int namePos;

    t = Teleporter(p);
    m = MapExit(p);
    dt = DynamicTeleporter(p);
    if( dt != None ) curDest = dt.URL $ "?toname=" $ dt.destName;
    else if( m != None && m.destName != '' ) curDest = m.DestMap $ " ?toname=" $ m.destName;
    else if( m != None )  curDest = m.DestMap;
    else if( t != None ) {
        if( ! t.bEnabled ) return None;
        curDest = t.URL;
    }

    if( curDest == "" ) return None;

    hashPos = InStr(curDest,"#");
    destTag = Caps(Mid(curDest,hashPos+1));

    for (i = 0;i<numConns;i++)
    {
        if (conns[i].a.mapname == dxr.localURL && destTag == conns[i].a.outTag)
        {
            newMap = conns[i].b.mapname;
            newTag = conns[i].b.inTag;
        }
        else if (conns[i].b.mapname == dxr.localURL && destTag == conns[i].b.outTag)
        {
            newMap = conns[i].a.mapname;
            newTag = conns[i].a.inTag;
        }
        else
            continue;

        namePos = InStr(newTag, "?TONAME=");
        if( namePos > 0 ) err("AdjustTeleporter "$p$", newMap: "$newMap$", newTag: "$newTag$", namePos: "$namePos);
        if( namePos == 0 ) {
            newName = Mid(newTag, Len("?TONAME=") );
            if( dt == None && t != None ) {
                newdt = class'DynamicTeleporter'.static.ReplaceTeleporter(t);
                newdt.SetDestination(newMap, StringToName(newName));
            }
            else if( dt != None ) {
                dt.SetDestination(newMap, StringToName(newName));
            }
            else if( m != None ) {
                m.SetDestination(newMap, StringToName(newName));
            }
        }
        else {
            if( dt != None )
                dt.SetDestination(newMap, '', newTag);
            else if( m != None )
                m.SetDestination(newMap, '', newTag);
            else if( t != None )
                t.URL = newMap $ "#" $ newTag;
        }
        info("Found " $ p $ " with destination " $ curDest $ ", changed to " $ newMap$"#"$newTag$", newdt: "$newdt );
        break;
    }

    return newdt;
}

function PostFirstEntry()
{
    local int missionNum;
    Super.PostFirstEntry();
    if( dxr.flags.gamemode != 1 ) return;
    
    missionNum = dxr.dxInfo.missionNumber;
    if( missionNum == 11 ) missionNum = 10;//combine paris 10 and 11
    if( missionNum == 14 ) missionNum = 12;//combine vandenberg and oceanlab
    //Randomize entrances for this mission
    EntranceRando(missionNum);
    ApplyEntranceRando(missionNum);
    LogConnections(true);
    ApplyFixes();
}

function LogConnections(optional bool bInfo)
{
    local int i;
    for (i = 0;i<numConns;i++)
    {
        if( bInfo ) {
            info("conns["$i$"]:");
            info( "    "$ conns[i].a.mapname $"#"$ conns[i].a.outTag $" goes to "$ conns[i].b.mapname $"#"$ conns[i].b.inTag );
            info( "    "$ conns[i].b.mapname $"#"$ conns[i].b.outTag $" goes to "$ conns[i].a.mapname $"#"$ conns[i].a.inTag );
        }
        else {
            l("conns["$i$"]:");
            l( "    "$ conns[i].a.mapname $"#"$ conns[i].a.outTag $" goes to "$ conns[i].b.mapname $"#"$ conns[i].b.inTag );
            l( "    "$ conns[i].b.mapname $"#"$ conns[i].b.outTag $" goes to "$ conns[i].a.mapname $"#"$ conns[i].a.inTag );
        }
    }
}

function RunTests()
{
    local int i;
    Super.RunTests();

    test(min_connections_selfconnect >= 3, "min_connections_selfconnect needs to be at least 3");

    for(i=0; i <= 50; i++) {
        EntranceRando(i);
        if( numXfers > 0 && numConns > 0 ) {
            LogConnections();
            testbool(ValidateConnections(), true, "RandoMission" $ i $ " validation");
        }
    }

    numXfers = 0;
    numConns = 0;
    numFixedConns = 0;
}

function ExtendedTests()
{
    Super.ExtendedTests();

    BasicTests();
    OneWayTests();
    //VandenbergTests();
}

function BasicTests()
{
    local int i;
    local string old_dead_end;

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
    testbool(ValidateConnections(), false, "ValidateConnections test 1");

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
    testbool(ValidateConnections(), true, "ValidateConnections test 2");

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
    testbool(ValidateConnections(), true, "ValidateConnections test 3");

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
    testbool(ValidateConnections(), false, "ValidateConnections dead_end test");

    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[4];
    conns[1].b = xfers[5];
    numConns = 2;
    //LogConnections();
    testbool(ValidateConnections(), false, "ValidateConnections island test");

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
    testbool(ValidateConnections(), false, "ValidateConnections duplicate test");

    dxr.SetSeed( 123 + dxr.Crc("entrancerando") );
    GenerateConnections(3);
    //LogConnections();
    testbool(ValidateConnections(), true, "simple GenerateConnections validation");

    dead_ends[0] = old_dead_end;

    numXfers = 0;
    numConns = 0;
    numFixedConns = 0;
}

function OneWayTests()
{
    local int i;

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
    testbool(ValidateConnections(), false, "ValidateConnections one-way test 1");

    conns[0].a = xfers[0];
    conns[0].b = xfers[1];
    conns[1].a = xfers[2];
    conns[1].b = xfers[3];
    numConns = 2;
    LogConnections();
    testbool(ValidateConnections(), true, "ValidateConnections one-way test 2");

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
    testbool(ValidateConnections(), true, "manual Paris validation");

    numXfers = 0;
    numConns = 0;
    numFixedConns = 0;
}

/*function VandenbergTests()
{
    local int i;

    numXfers = 0;
    numFixedConns = 0;

    AddFixedConn("12_VANDENBERG_CMD","x","12_VANDENBERG_CMD", "x");
    AddDoubleXfer("12_VANDENBERG_CMD","commstat","12_vandenberg_tunnels","start");
    AddDoubleXfer("12_VANDENBERG_CMD","storage","12_vandenberg_tunnels","end");// this needs to be marked as one way somehow, not just AddXfer, because it does go both ways, but only after opening the door
    AddDoubleXfer("12_VANDENBERG_CMD","hall","12_vandenberg_computer","computer");

    conns[0] = fixed_conns[0];
    //comsat to tunnels
    conns[1].a = xfers[0];
    conns[1].b = xfers[1];
    //storage to computer
    conns[2].a = xfers[2];
    conns[2].b = xfers[5];
    //hall to tunnels end
    conns[3].a = xfers[4];
    conns[3].b = xfers[3];
    //cmd to gas
    conns[4].a = xfers[6];
    conns[4].b = xfers[7];
    numConns = 5;
    LogConnections();
    testbool(ValidateConnections(), false, "VandenbergTests 1");

    conns[0] = fixed_conns[0];
    //comsat to computer
    conns[1].a = xfers[0];
    conns[1].b = xfers[5];
    //storage to tunnel
    conns[2].a = xfers[2];
    conns[2].b = xfers[1];
    //hall to tunnels end
    conns[3].a = xfers[4];
    conns[3].b = xfers[3];
    //cmd to gas
    conns[4].a = xfers[6];
    conns[4].b = xfers[7];
    numConns = 5;
    LogConnections();
    testbool(ValidateConnections(), true, "VandenbergTests 1");

    numXfers = 0;
    numConns = 0;
    numFixedConns = 0;
}*/

defaultproperties
{
    min_connections_selfconnect=999
}
