//=============================================================================
// DXREntranceRando.
//=============================================================================
class DXREntranceRando expands DXRActorsBase transient;

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
    var() string depends[15]; //The map each dest depends on
};
var Connection conns[20];
var int numConns;

var Connection fixed_conns[8];
var int numFixedConns;

var MapTransfer xfers[50];
var int numXfers;
// caches
var int numInvalids[50];
var int numXfersMaps[50];
var int invalidCons[2500];// 2d array of xfers[a] to xfers[b], cache of IsConnectionValid

struct BanConnection
{
    var string map_a;
    var string map_b;
};
var config BanConnection BannedConnections[32];

var config string dead_ends[32];
//var config string unreachable_conns[16];
var DXRMapVariants mapvariants;

struct Dependency
{
    // this is mostly for keys that are needed from other areas
    // the key would be inside the map dependency
    // dependent would be the teleporter that is behind the locked door, which may end up going to a different map
    var string dependent;
    var string dependency;
};

var config Dependency dependencies[16];

var config int min_connections_selfconnect;

function CheckConfig()
{
    local int i, k;
    if( ConfigOlderThan(1,6,0,1) ) {
        for(i=0; i < ArrayCount(BannedConnections); i++) {
            BannedConnections[i].map_a = "";
            BannedConnections[i].map_b = "";
        }

        min_connections_selfconnect = 999;
        i = 0;
        //dead_ends[i++] = "06_HONGKONG_WANCHAI_GARAGE#Teleporter";
        dead_ends[i++] = "06_HONGKONG_Storage#waterpipe";
        //dead_ends[i++] = "06_HONGKONG_MJ12LAB#tubeend";

        /*i=0;
        unreachable_conns[i++] = "12_VANDENBERG_CMD#storage";*/

        i=0;// dependencies[i].dependent = source map and outTag
        dependencies[i].dependent = "02_NYC_Street#ToNYCUndergroundSewer2";
        dependencies[i].dependency = "02_NYC_Smug";
        i++;

        dependencies[i].dependent = "02_NYC_Street#ToNYCSump";
        dependencies[i].dependency = "02_NYC_Smug";
        i++;

        dependencies[i].dependent = "04_NYC_STREET#ToNSFHQ";
        dependencies[i].dependency = "04_NYC_HOTEL";
        i++;

        dependencies[i].dependent = "06_HongKong_WanChai_Market#Lobby";
        dependencies[i].dependency = "06_HongKong_WanChai_Street";
        i++;

        dependencies[i].dependent = "06_HongKong_WanChai_Market#Lobby";
        dependencies[i].dependency = "06_HongKong_WanChai_Underworld";
        i++;

        dependencies[i].dependent = "06_HONGKONG_STORAGE#CANAL";
        dependencies[i].dependency = "06_HongKong_WanChai_Underworld";
        i++;

        dependencies[i].dependent = "06_HONGKONG_MJ12LAB#basement";
        dependencies[i].dependency = "06_HongKong_WanChai_Underworld";
        i++;

        /*dependencies[i].dependent = "06_HONGKONG_wanchai_garage#BackDoor";
        dependencies[i].dependency = "06_HongKong_WanChai_Underworld";
        i++;*/

        dependencies[i].dependent = "06_HongKong_Storage#canal";
        dependencies[i].dependency = "06_HongKong_WanChai_MJ12Lab";
        i++;

        dependencies[i].dependent = "10_paris_metro#?toname=PathNode447";
        dependencies[i].dependency = "10_PARIS_CLUB";
        i++;

        dependencies[i].dependent = "12_VANDENBERG_CMD#gas_start";
        dependencies[i].dependency = "12_VANDENBERG_COMPUTER";
        i++;

        dependencies[i].dependent = "12_VANDENBERG_CMD#computer";
        dependencies[i].dependency = "12_VANDENBERG_TUNNELS";
        i++;

        dependencies[i].dependent = "14_Vandenberg_Sub#frontgate";
        dependencies[i].dependency = "14_OceanLab_UC";//format has to match the connection not the teleporter
        i++;
    }
    k=0;
    for(i=0; i < ArrayCount(BannedConnections); i++) {
        if( BannedConnections[i].map_a == "" ) continue;
        BannedConnections[k].map_a = Caps(BannedConnections[i].map_a);
        BannedConnections[k].map_b = Caps(BannedConnections[i].map_b);
        k++;
    }
    k=0;
    for(i=0; i < ArrayCount(dead_ends); i++) {
        if( dead_ends[i] == "" ) continue;
        dead_ends[k++] = Caps(dead_ends[i]);
    }
    k=0;
    for(i=0; i < ArrayCount(dependencies); i++) {
        if( dependencies[i].dependent == "" ) continue;
        dependencies[k].dependent = Caps(dependencies[i].dependent);
        dependencies[k].dependency = Caps(dependencies[i].dependency);
        k++;
    }
    Super.CheckConfig();
}

function Connection GetConnection(int idx, optional bool fixed)
{
    if (fixed){
        return fixed_conns[idx];
    } else {
        return conns[idx];
    }
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


function int GetNextPickiestTransfer()
{
    local int idx, pickiestIdx, pickiestCount;

    pickiestCount = -1;
    for(idx=0;idx<numXfers;idx++)
    {
        if( (!xfers[idx].used) && numInvalids[idx] > pickiestCount ) {
            pickiestIdx = idx;
            pickiestCount = numInvalids[idx];
        }
    }

    return pickiestIdx;
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

//This gets the <offset>th unused transfer for a connection and returns its index
function int GetNextUnusedTransferByOffset(int nextAvailIdx, int offset)
{
    local int idx;
    local int numUnused;

    idx = 0;
    numUnused = 0;

    for(idx=0;idx<numXfers;idx++)
    {
        if (xfers[idx].used == False && invalidCons[ (nextAvailIdx*ArrayCount(xfers)) + idx ] == 0 )
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

function bool IsDeadEndMap(int idx)
{
    return numXfersMaps[idx]==1;
}

function bool CanSelfConnect(int idx)
{
    return numXfersMaps[idx] >= min_connections_selfconnect;
}

function bool IsConnectionValid(int idx_a, int idx_b)
{
    local int i;
    local MapTransfer a,b;

    a = xfers[idx_a];
    b = xfers[idx_b];

    if( a.mapname == b.mapname && a.inTag == b.inTag && a.outTag == b.outTag ) {
        err("IsConnectionValid got duplicate MapTransfers? mapname: " $ a.mapname $", inTag: " $ a.inTag $", outTag: " $a.outTag);
        return False;
    }

    if ( IsDeadEndMap(idx_a) && IsDeadEndMap(idx_b) )
    {
        return False;
    }

    if ( a.mapname == b.mapname)
    {
        if ( !CanSelfConnect(idx_a))
        {
            return False;
        }
    }

    for(i=0; i < ArrayCount(BannedConnections); i++) {
        if( BannedConnections[i].map_a == "" ) break;
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
    local int visitable, oldVisitable;

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
    oldVisitable = 0;
    canvisit[visitable]=mapdests[0].mapname;
    visitable++;

    for( i=0;i<numPasses;i++)
    {
        for ( j=0;j<numMaps;j++)
        {
            //See if map j can be visited
            canVisitMap = False;
            for (k=0;k<visitable;k++)
            {
                if (mapdests[j].mapname == canvisit[k])
                {
                    canVisitMap = true;
                }
            }

            //If map can be visited, go through all the places it can go
            if (canVisitMap)
            {
                MarkMapDestinationsVisitible(mapdests[j], canvisit, visitable);
            }
        }

        if( visitable == numMaps ) break;
        if( visitable == oldVisitable ) break;
        oldVisitable = visitable;
    }

    //Theoretically I should probably actually check to see if the maps match,
    //but this is fairly safe...
    if( visitable != numMaps )
        debug("ValidateConnections visitable: " $ visitable $", numMaps: " $ numMaps $", i: "$i$", numConns: "$numConns);
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
    // can you get from A to B?
    _MarkMapConnected(mapdests, numMaps, a, b);

    // can you get from B to A?
    _MarkMapConnected(mapdests, numMaps, b, a);
}

function bool _MarkMapConnected(out MapConnection mapdests[15], int numMaps, MapTransfer a, MapTransfer b)
{
    local int mapidx, i;
    local string maptag, depends;

    // can you get from A to B?
    if( IsDeadEndConnection(b, a) ) return false;

    mapidx = FindMapDestinations(mapdests, numMaps, a.mapname);
    if(mapidx == -1) {
        err("failed _MarkMapConnected("$numMaps$", "$a.mapname$", "$b.mapname$")");
        return false;
    }

    maptag = a.mapname $ "#" $ a.outTag;
    for(i=0;i<ArrayCount(dependencies);i++) {
        if( dependencies[i].dependent == "" ) break;
        if( maptag == dependencies[i].dependent ) {
            depends = dependencies[i].dependency;
            break;
        }
    }

    // write B into the destinations of A
    AddDestination( mapdests[mapidx], b.mapname, depends);

    return true;
}

function bool IsDeadEndConnection(MapTransfer m, MapTransfer from)
{
    local int i;
    local string s;

    if(from.outTag == "") return true;
    if(m.inTag == "") return true;
    s = Caps(m.mapname $"#"$ m.inTag);
    for(i=0; i < ArrayCount(dead_ends); i++) {
        if( dead_ends[i] == "" ) break;
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

function AddDestination( out MapConnection map, string mapname, string depends )
{
    local int i;
    for(i=0; i < map.numDests; i++) {
        if( map.dest[i] == mapname ) {
            if( depends != "" ) map.depends[i] = depends;
            return;
        }
    }
    map.dest[map.numDests] = mapname;
    map.depends[map.numDests] = depends;
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

function bool CheckDependencies(string depends, string canvisit[15], int visitable)
{
    local int i;

    if( depends == "" ) return true;

    for(i=0;i<visitable;i++) {
        if( depends == canvisit[i] ) {
            return true;
        }
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
        if (canVisitDest == False && CheckDependencies(m.depends[k], canvisit, visitable) )
        {
            canvisit[visitable] = m.dest[k];
            visitable++;
        }
    }
}

function GenerateConnections(int missionNum)
{
    local int attempts, genconsfails, validatefails;
    local bool isValid;
    isValid = False;

    BuildCache();

    for(attempts=0; attempts<200; attempts++)
    {
        if( ! _GenerateConnections(missionNum) ) {
            genconsfails++;
            continue;// save a bunch of loops if we know we failed?
        }
        if(ValidateConnections()) {
            if( attempts > 20 ) warning("GenerateConnections("$missionNum$") succeeded but took "$attempts$" attempts! seed: "$dxr.seed $", genconsfails: "$genconsfails$", validatefails: "$validatefails);
            return;
        }
        validatefails++;
    }
    err("GenerateConnections("$missionNum$") failed after "$attempts$" attempts! seed: "$dxr.seed $", genconsfails: "$genconsfails$", validatefails: "$validatefails);
    numConns = 0;// vanilla on failure
}

function BuildCache()
{
    local int idx, destIdx;

    for(idx=0; idx<numXfers; idx++) {
        numXfersMaps[idx] = GetNumXfersByMap(xfers[idx].mapname);
        // don't link to self
        invalidCons[ (idx*ArrayCount(xfers)) + idx ] = 1;
        numInvalids[idx] = 1;
    }

    //2d loop
    for(idx=0; idx<numXfers; idx++) {
        for(destIdx=idx+1; destIdx<numXfers; destIdx++) {
            // check validity, also reversed
            invalidCons[ (idx*ArrayCount(xfers)) + destIdx ] = 0;
            invalidCons[ (destIdx*ArrayCount(xfers)) + idx ] = 0;
            if ( ! IsConnectionValid(idx, destIdx) ) {
                invalidCons[ (idx*ArrayCount(xfers)) + destIdx ] = 1;
                invalidCons[ (destIdx*ArrayCount(xfers)) + idx ] = 1;
                numInvalids[idx]++;
                numInvalids[destIdx]++;
            }
            //
        }
    }
}

function bool _GenerateConnections(int missionNum)
{
    local int xfersUsed;
    local int connsMade;
    local int nextAvailIdx;
    local int destIdx;
    local int i;

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
        nextAvailIdx = GetNextPickiestTransfer();

        conns[connsMade].a = xfers[nextAvailIdx];

        xfers[nextAvailIdx].used = True;
        xfersUsed++;

        //Get a random unused transfer
        destIdx = _FindConnectionFor(xfersUsed, nextAvailIdx);
        if( destIdx == -1 ) {
            return false;
        }
        xfers[destIdx].used = True;
        xfersUsed++;

        conns[connsMade].b = xfers[destIdx];
        connsMade++;
    }
    numConns = connsMade;
    return true;
}

function int _FindConnectionFor(int xfersUsed, int nextAvailIdx)
{
    local int xferOffset, destIdx;

    //count how many invalidCons we have
    for(destIdx=0; destIdx<numXfers; destIdx++) {
        if( xfers[destIdx].used ) {
            continue;
        }
        else if( invalidCons[ (nextAvailIdx*ArrayCount(xfers)) + destIdx ] == 1 ) {
            xfersUsed++;
        }
    }

    //Get a random unused transfer
    for (destIdx=-1; xfersUsed <= numXfers; xfersUsed++)
    {
        xferOffset = rng(numXfers-xfersUsed);
        destIdx = GetNextUnusedTransferByOffset(nextAvailIdx, xferOffset);

        if( destIdx == -1 )
            break;

        return destIdx;
    }

    l("didn't find valid connection for "
        $ xfers[nextAvailIdx].mapname $ "#" $ xfers[nextAvailIdx].inTag $ " / #" $ xfers[nextAvailIdx].outTag
        $ " with "$numXfers$" numXfers" );
    return -1;
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
                w.ZoneVelocity = vectm(0,0,0);
        }
        break;*/

    case "12_VANDENBERG_CMD":
        FixVandebergCmd();
        break;

    case "14_OceanLab_Lab":
        FixOceanLab();
        break;
    }
}

function FixHongKongCanal()
{
    local HKTukTuk tuktuk;
    local #var(prefix)Containers box;
    local DynamicBlockPlayer dbp;
    local vector loc;
    local int i;

    foreach AllActors(class'HKTukTuk', tuktuk) {
        if( tuktuk.Name != 'HKTukTuk0' ) continue;
        tuktuk.SetCollision(false,false,false);
        tuktuk.bCollideWorld = false;
        tuktuk.SetLocation(vectm(1162.203735, 1370, -482.995361));
        break;
    }
    loc = vectm(1074.268188, 1368.834106, -535);
    for(i=0; i < 5; i++) {
        dbp = Spawn(class'DynamicBlockPlayer',,, loc);
        dbp.SetBase(tuktuk);
        dbp.SetCollisionSize(dbp.CollisionRadius*4, dbp.CollisionHeight*4);

        if( i == 2 )// only the middle one will collide with the box
            dbp.SetCollision(true, true, true);
        if( i == 3 )// the roof thing on the boat is a bit higher
            dbp.SetLocation(loc+vectm(0,0,16));

        loc += vectm(38, 0, 0);
    }

    box = AddBox(class'#var(prefix)BoxMedium', vectm(1151.214355, 1370, -400));
    box.bCollideWorld = false;
    box.bPushable = false;
    box.bHighlight = false;
}

function FixVandebergCmd()
{
    local DeusExMover d;
    local #var(prefix)Nanokey n;
    local DXRKeys dxrk;

    foreach AllActors(class'DeusExMover', d, 'security_tunnels') {
        d.KeyIDNeeded = 'storage_door';
    }

    /*foreach AllActors(class'DeusExMover', d) {
        switch(d.Tag) {
            case 'security_tunnels':
                d.KeyIDNeeded = 'storage_door';
            case 'door_controlroom':
                class'DXRDoors'.static.StaticMakePickable(d);
                class'DXRDoors'.static.StaticMakeDestructible(d);
                break;
        }
    }*/

    n = Spawn(class'#var(prefix)NanoKey',,, vectm(2048.289063, 4712.830078, -2052.789551) );
    n.Description = "Storage door key";
    n.KeyID = 'storage_door';

    // this is called from PostFirstEntry, so it's after DXRKeys already ran
    dxrk = DXRKeys(dxr.FindModule(class'DXRKeys'));
    if( dxrk != None ) dxrk.RandoKey(n);
}

function FixOceanLab()
{
    local NanoKey n;

    n = Spawn(class'NanoKey',,, vectm(1913.437012, 3191.914063, -2282.776855) );
    n.Description = "Crew Module Access";
    n.KeyID = 'crewkey';

    n = Spawn(class'NanoKey',,, vectm(1583.074585, 462.036804, -1762.375610) );
    n.Description = "Greasel Laboratory Key";
    n.KeyID = 'Glab';
}

function RandoMission2()
{
    AddFixedConn("02_NYC_BatteryPark","ToBatteryPark", "02_NYC_Street","ToStreet");
    AddDoubleXfer("02_NYC_Bar","ToBarBackEntrance","02_NYC_Street","FromBarBackEntrance");
    AddDoubleXfer("02_NYC_Bar","ToBarFrontEntrance","02_NYC_Street","FromBarFrontEntrance");
    AddDoubleXfer("02_NYC_FreeClinic","FromStreet","02_NYC_Street","FromClinic");
    AddDoubleXfer("02_NYC_Hotel","ToHotelBedroom","02_NYC_Street","BedroomWindow");
    AddDoubleXfer("02_NYC_Hotel","ToHotelFrontDoor","02_NYC_Street","FromHotelFrontDoor");
    AddDoubleXfer("02_NYC_Smug","?toname=PathNode83","02_NYC_Street","FromSmugFrontDoor");
    AddDoubleXfer("02_NYC_Smug","ToSmugBackDoor","02_NYC_Street","FromSmugBackDoor");
    AddDoubleXfer("02_NYC_Underground","ToNYCUndergroundSewer2","02_NYC_Street","FromNYCUndergroundSewer2");
    AddDoubleXfer("02_NYC_Underground","ToNYCSump","02_NYC_Street","FromNYCSump");
    AddDoubleXfer("02_NYC_Warehouse","ToRoofTop","02_NYC_Street","FromRoofTop");
    AddDoubleXfer("02_NYC_Warehouse","ToWarehouseAlley","02_NYC_Street","FromWarehouseAlley");
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
}

function RandoMission4()
{
    AddFixedConn("04_NYC_Street","x", "04_NYC_Street","x");
    //AddDoubleXfer("04_NYC_BATTERYPARK","ToBatteryPark","04_NYC_Street","ToStreet");
    AddDoubleXfer("04_NYC_STREET","FromSmugBackDoor","04_NYC_Smug","ToSmugBackDoor");
    AddDoubleXfer("04_NYC_STREET","FromSmugFrontDoor","04_NYC_Smug","?toname=PathNode83");
    AddDoubleXfer("04_NYC_STREET","FromBarBackEntrance","04_NYC_Bar","ToBarBackEntrance");
    AddDoubleXfer("04_NYC_STREET","FromBarFrontEntrance","04_NYC_Bar","ToBarFrontEntrance");
    AddDoubleXfer("04_NYC_STREET","FromHotelFrontDoor","04_NYC_Hotel","ToHotelFrontDoor");
    AddDoubleXfer("04_NYC_STREET","BedroomWindow","04_NYC_Hotel","ToHotelBedroom");
    AddDoubleXfer("04_NYC_STREET","FromNSFHQ","04_NYC_NSFHQ","ToNSFHQ");
    AddDoubleXfer("04_NYC_STREET","FromNYCUndergroundSewer2","04_NYC_Underground","ToNYCUndergroundSewer2");
    AddDoubleXfer("04_NYC_STREET","FromNYCSump","04_NYC_Underground","ToNYCSump");
}

function RandoMission6()
{
    AddFixedConn("06_HONGKONG_HELIBASE","Helibase","06_HongKong_WanChai_Market","cargoup");
    AddDoubleXfer("06_HONGKONG_MJ12LAB","cathedral","06_HongKong_VersaLife","secret");
    AddDoubleXfer("06_HONGKONG_MJ12LAB","tubeend","06_HongKong_Storage","basement");
    AddDoubleXfer("06_HONGKONG_STORAGE","waterpipe","06_HongKong_WanChai_Canal","canal");
    //AddXfer("06_HongKong_Storage","BackDoor","06_HONGKONG_WANCHAI_GARAGE#Teleporter");//one way
    //AddFixedConn("06_HONGKONG_TONGBASE","lab","06_HongKong_WanChai_Market","compound");
    AddDoubleXfer("06_HONGKONG_VERSALIFE","Lobby","06_HongKong_WanChai_Market","market");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","Street","06_HongKong_WanChai_Street","Canal");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","market01","06_HongKong_WanChai_Market","canal01");
    AddDoubleXfer("06_HONGKONG_WANCHAI_CANAL","double","06_HongKong_WanChai_Market","chinahand");
    AddDoubleXfer("06_HONGKONG_WANCHAI_GARAGE","market04","06_HongKong_WanChai_Market","garage01");
    AddDoubleXfer("06_HONGKONG_WANCHAI_MARKET","canal03","06_HongKong_WanChai_Underworld","market03");
    AddDoubleXfer("06_HongKong_WanChai_Street","alleyout","06_HongKong_WanChai_Canal","alleyin");
}

function RandoMission8()
{
    AddFixedConn("08_NYC_Street","x", "08_NYC_Street","x");
    AddDoubleXfer("08_NYC_BAR","ToBarFrontEntrance","08_NYC_Street","FromBarFrontEntrance");
    AddDoubleXfer("08_NYC_BAR","ToBarBackEntrance","08_NYC_Street","FromBarBackEntrance");
    AddDoubleXfer("08_NYC_FREECLINIC","FromStreet","08_NYC_Street","FromClinic");
    AddDoubleXfer("08_NYC_HOTEL","ToHotelFrontDoor","08_NYC_Street","FromHotelFrontDoor");
    AddDoubleXfer("08_NYC_HOTEL","ToHotelBedroom","08_NYC_Street","BedroomWindow");
    AddDoubleXfer("08_NYC_SMUG","?toname=PathNode83","08_NYC_Street","FromSmugFrontDoor");
    AddDoubleXfer("08_NYC_SMUG","ToSmugBackDoor","08_NYC_Street","FromSmugBackDoor");
    AddDoubleXfer("08_NYC_UNDERGROUND","ToNYCSump","08_NYC_Street","FromNYCSump");
    AddDoubleXfer("08_NYC_UNDERGROUND","ToNYCUndergroundSewer2","08_NYC_Street","FromNYCUndergroundSewer2");
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
}

function RandoMission12()
{
    // I'm not sure what arrangements I would want for vandenberg? maybe I should just make a key for the storage door and stick it somewhere in cmd?
    AddFixedConn("12_VANDENBERG_CMD","x","12_VANDENBERG_CMD", "x");
    AddDoubleXfer("12_VANDENBERG_CMD","commstat","12_vandenberg_tunnels","start");
    AddDoubleXfer("12_VANDENBERG_CMD","storage","12_vandenberg_tunnels","end");
    AddDoubleXfer("12_VANDENBERG_CMD","hall","12_vandenberg_computer","computer");
    AddDoubleXfer("12_VANDENBERG_CMD","?toname=PathNode8", "12_Vandenberg_gas","gas_start");

    AddDoubleXfer("12_VANDENBERG_GAS","?toname=PathNode98", "14_Vandenberg_sub","PlayerStart");
    AddDoubleXfer("14_OCEANLAB_LAB","Sunkentunnel","14_OceanLab_UC","UC");//we don't care about what map name the teleporter says, the real map name is what matters
    AddDoubleXfer("14_OCEANLAB_LAB","Sunkenlab","14_Vandenberg_sub","subbay");
    AddDoubleXfer("14_Vandenberg_Sub","?toname=InterpolationPoint39", "14_Oceanlab_silo","frontgate");
}

function RandoMission15()
{
    AddFixedConn("15_AREA51_BUNKER","x","15_AREA51_BUNKER", "x");
    //AddDoubleXfer("15_AREA51_BUNKER","commstat","","");
    AddDoubleXfer("15_AREA51_BUNKER","?toname=Light188","15_Area51_entrance","start");
    AddDoubleXfer("15_Area51_entrance","?toname=Light73","15_AREA51_FINAL","start");
    AddDoubleXfer("15_AREA51_FINAL","final_end","15_Area51_page","page_start");
    //AddDoubleXfer("15_AREA51_FINAL","Start","");
}

function GenerateXfers(int missionNum)
{
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

function EntranceRando(int missionNum)
{
    numConns = 0;
    numXfers = 0;
    numFixedConns = 0;
    SetGlobalSeed("entrancerando " $ missionNum);

    GenerateXfers(missionNum);

    if( numXfers > 0 )
        GenerateConnections(missionNum);
}

function BindEntrances(PlayerDataItem ds, bool writing)
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

function LoadConns(optional int missionNum)
{
    local PlayerDataItem ds;

    if(missionNum == 0) {
        missionNum = dxr.dxInfo.missionNumber;
        if( missionNum == 11 ) missionNum = 10;//combine paris 10 and 11
        if( missionNum == 14 ) missionNum = 12;//combine vandenberg and oceanlab
    }

    ds = class'PlayerDataItem'.static.GiveItem(Player());
    l("LoadConns "$missionNum@ds.EntranceRandoMissionNumber@ds.numConns@numConns);
    if( ds.EntranceRandoMissionNumber == missionNum && ds.numConns > 0 ) {
        BindEntrances(ds, false);
    } else {
        ds.EntranceRandoMissionNumber = missionNum;
        BindEntrances(ds, true);
    }
}

function ApplyEntranceRando(int missionNum)
{
    local NavigationPoint newnp, last;
    local Teleporter t;
    local MapExit m;

    LoadConns(missionNum);

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

static function AdjustTeleporterStatic(DXRando dxr, NavigationPoint p)
{
    local DXREntranceRando entrancerando;
    entrancerando = DXREntranceRando(dxr.FindModule(class'DXREntranceRando'));
    if(entrancerando != None)
        entrancerando.AdjustTeleporter(p);
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
    if( dt != None ){
        curDest = dt.URL;
        if (dt.destName!=''){
            curDest = curDest $ "?toname=" $ dt.destName;
        }
    }
#ifdef injections
    else if( m != None && m.destName != '' ) curDest = m.DestMap $ "?toname=" $ m.destName;
#endif
    else if( m != None )  curDest = m.DestMap;
    else if( t != None ) {
        if( ! t.bEnabled ) return None;
        curDest = t.URL;
    }

    if( curDest == "" ) return None;

    hashPos = InStr(curDest,"#");
    destTag = Caps(Mid(curDest,hashPos+1));

    l("AdjustTeleporter("$p$") curDest: "$curDest$", destTag: "$destTag$", numConns: "$numConns);
    if(mapvariants == None)
        mapvariants = DXRMapVariants(dxr.FindModule(class'DXRMapVariants'));
    if(mapvariants != None)
        curDest = mapvariants.CleanupMapName(curDest);

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

        if(mapvariants != None)
            newMap = mapvariants.VaryMap(newMap);
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
#ifdef injections
                m.SetDestination(newMap, StringToName(newName));
#endif
            }
        }
        else {
            if( dt != None )
                dt.SetDestination(newMap, '', newTag);
#ifdef injections
            else if( m != None )
                m.SetDestination(newMap, '', newTag);
#endif
            else if( t != None )
                t.URL = newMap $ "#" $ newTag;
        }
        if( newdt != None )
            info("AdjustTeleporter found " $ p $ " with destination " $ curDest $ ", changed to " $ newMap$"#"$newTag$", newdt: "$newdt );
        else
            info("AdjustTeleporter found " $ p $ " with destination " $ curDest $ ", changed to " $ newMap$"#"$newTag );
        break;
    }

    return newdt;
}

function PostFirstEntry()
{
    local int missionNum;
    Super.PostFirstEntry();
    if( !dxr.flags.IsEntranceRando() ) return;

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
            debug("conns["$i$"]:");
            debug( "    "$ conns[i].a.mapname $"#"$ conns[i].a.outTag $" goes to "$ conns[i].b.mapname $"#"$ conns[i].b.inTag );
            debug( "    "$ conns[i].b.mapname $"#"$ conns[i].b.outTag $" goes to "$ conns[i].a.mapname $"#"$ conns[i].a.inTag );
        }
    }
}

function RunTests()
{
    Super.RunTests();

    test(min_connections_selfconnect >= 3, "min_connections_selfconnect needs to be at least 3");
    TestAllMissions(dxr.seed);

    teststring( class'DXRMapInfo'.static.GetTeleporterName("01_NYC_UNATCOHQ", "ToOcean"), "01_NYC_UNATCOHQ (ToOcean) - Report me!", "GetTeleporterName" );
}

function ExtendedTests()
{
    local int i;
    Super.ExtendedTests();

    BasicTests();
    OneWayTests();
    TestDependencies();

    TestAllMissions(21);

    for(i=1; i<50; i++) {
        // reduce this if we start getting runaway loops, or make it so extended tests can run across multiple frames
        TestAllMissions( dxr.seed + i );
    }
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

function TestAllMissions(int newseed)
{
    local int oldseed, i;

    oldseed = dxr.seed;
    dxr.seed = newseed;

    for(i=0; i <= 50; i++) {
        EntranceRando(i);
        if( numXfers > 0 ) {
            if( ! testbool( numConns > 0, true, "RandoMission" $ i $ " validation, seed: "$newseed) ) {
                LogConnections();
            }
        }
    }

    numXfers = 0;
    numConns = 0;
    numFixedConns = 0;
    dxr.seed = oldseed;
}

function TestDependencies()
{
    local int i;

    numXfers = 0;
    numFixedConns = 0;

    AddFixedConn("12_VANDENBERG_CMD","x","12_VANDENBERG_CMD", "x");
    AddFixedConn("12_VANDENBERG_CMD","x2","12_VANDENBERG_TUNNELS","x2");
    AddDoubleXfer("12_VANDENBERG_CMD","hall","12_vandenberg_computer","computer");
    AddDoubleXfer("12_VANDENBERG_CMD","?toname=PathNode8", "12_Vandenberg_gas","gas_start");
    AddDoubleXfer("12_VANDENBERG_GAS","?toname=PathNode98", "14_Vandenberg_sub","PlayerStart");

    //vanilla test
    conns[0] = fixed_conns[0];
    //cmd to gas, test order of operations
    conns[1].a = xfers[2];
    conns[1].b = xfers[3];
    //cmd to comp
    conns[2].a = xfers[0];
    conns[2].b = xfers[1];
    //gas to sub
    conns[3].a = xfers[4];
    conns[3].b = xfers[5];

    conns[4] = fixed_conns[1];
    numConns = 5;
    testbool(ValidateConnections(), true, "Test Dependencies vanilla");

    numFixedConns=1;
    numConns=4;
    testbool(ValidateConnections(), false, "Test Dependencies vanilla but without tunnels");
    numFixedConns=2;

    //bad good
    conns[0] = fixed_conns[0];
    //cmd hall to gas (which goes to comp)
    conns[1].a = xfers[0];
    conns[1].b = xfers[3];
    //cmd heli to sub
    conns[2].a = xfers[2];
    conns[2].b = xfers[5];
    //gas to comp
    conns[3].a = xfers[4];
    conns[3].b = xfers[1];

    conns[4] = fixed_conns[1];
    numConns = 5;
    testbool(ValidateConnections(), true, "Test Dependencies good");

    numFixedConns=1;
    numConns=4;
    testbool(ValidateConnections(), false, "Test Dependencies good but without tunnels");
    numFixedConns=2;

    //bad test
    conns[0] = fixed_conns[0];
    //cmd hall to gas
    conns[1].a = xfers[0];
    conns[1].b = xfers[3];
    //cmd heli to comp
    conns[2].a = xfers[2];
    conns[2].b = xfers[1];
    //gas to sub
    conns[3].a = xfers[4];
    conns[3].b = xfers[5];

    conns[4] = fixed_conns[1];
    numConns = 5;
    testbool(ValidateConnections(), false, "Test Dependencies bad");

    numFixedConns=1;
    numConns=4;
    testbool(ValidateConnections(), false, "Test Dependencies bad but without tunnels");

    numXfers = 0;
    numConns = 0;
    numFixedConns = 0;
}
