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
    var() config string mapname;
    var() config string inTag;
    var() config string outTag;
    var() config bool used;
};

//Defines a connection between two MapTransfer points
struct Connection
{
    var() config MapTransfer a;
    var() config MapTransfer b;
};

//This structure is used for rando validation
struct MapConnection
{
    var() config string mapname;
    var() config int    numDests;
    var() config string dest[15]; //List of maps that can be reached from this one
};
var Connection conns[50];
var int numConns;

var MapTransfer xfers[50];
var int numXfers;


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

    switch(missionNum)
    {
        case 2:
            break;
    
    }
    
    return True;
}


function bool ValidateConnections()
{
    local MapConnection mapdests[15];
    local int numMaps;
    local int numPasses;
    local int i,j,k,p;
    local string curMapName;
    local bool foundMap;
    local int mapidx;
    
    local string canvisit[15];
    local int visitable;
    
    local bool canVisitMap;
    local bool canVisitDest;
    
    numPasses = numConns;
    curMapName = "";
    
    numMaps = 0;
    
    //Get all the map names
    for (i=0;i<numXfers;i++)
    {
        if (xfers[i].mapname !=curMapName)
        {
            mapdests[numMaps].mapname = xfers[i].mapname;
            mapdests[numMaps].numDests = 0;
            curMapName = xfers[i].mapname;
            numMaps++;
        }
    }
    
    //Determine what maps can be visited from each map
    for (i=0;i<numConns;i++)
    {
        //Check if b.mapname is in the destinations of a.mapname
        mapidx=0;
        for (j=0;j<numMaps;j++)
        {
            if (mapdests[j].mapname == conns[i].a.mapname)
            {
                mapidx=j;
                break;
            }
        }
        foundMap = False;
        for (j=0;j<mapdests[mapidx].numDests;j++)
        {
            if(mapdests[mapidx].dest[j]==conns[i].b.mapname)
            {
                foundMap = True;
            }
        }
        
        if (!foundMap)
        {
            mapdests[mapidx].dest[mapdests[mapidx].numDests] = conns[i].b.mapname;
            mapdests[mapidx].numDests++;
        }
        
        //Check if a.mapname is in the destinations of b.mapname
        mapidx=0;
        for (j=0;j<numMaps;j++)
        {
            if (mapdests[j].mapname == conns[i].b.mapname)
            {
                mapidx=j;
                break;
            }
        }
        foundMap = False;
        for (j=0;j<mapdests[mapidx].numDests;j++)
        {
            if(mapdests[mapidx].dest[j]==conns[i].a.mapname)
            {
                foundMap = True;
            }
        }
        
        if (!foundMap)
        {
            mapdests[mapidx].dest[mapdests[mapidx].numDests] = conns[i].a.mapname;
            mapdests[mapidx].numDests++;
        }
    }
    
    //Start finding out what maps we can visit
    visitable = 0;
    canvisit[visitable]=mapdests[0].mapname;
    visitable++;
    
    for( i=0;i<numPasses;i++){
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
                for (k=0;k<mapdests[j].numDests;k++)
                {
                    //If any of those destinations are not in the places we can visit, add them
                    canVisitDest = False;
                    for (p=0;p<visitable;p++)
                    {
                        if ( canvisit[p]==mapdests[j].dest[k] )
                        {
                            canVisitDest = True;
                        }
                    }
                    if (canVisitDest == False)
                    {
                        canvisit[visitable] = mapdests[j].dest[k];
                        visitable++;
                    }
                    

                }
            
            }
        }
    }
    
    //Theoretically I should probably actually check to see if the maps match,
    //but this is fairly safe...
    return visitable == numMaps;
    
}

function GenerateConnections(int missionNum)
{
    local int xfersUsed;
    local int connsMade;
    local int nextAvailIdx;
    local int destOffset;
    local int destIdx;
    local int maxAttempts;
    local int i;
    local bool isValid;
    
    isValid = False;
    
    maxAttempts = 10;
    
    while (!isValid)
    {
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
        isValid = ValidateConnections();
    }

}

function AddXfer(string mapname, string inTag, string outTag)
{
    xfers[numXfers].mapname = mapname;
    xfers[numXfers].inTag = inTag;
    xfers[numXfers].outTag = outTag;
    xfers[numXfers].used = False;
    
    numXfers++;
}

function RandoMission2()
{
    
    AddXfer("02_NYC_BatteryPark","ToBatteryPark","ToStreet");
    AddXfer("02_NYC_Bar","ToBarBackEntrance","FromBarBackEntrance");
    AddXfer("02_NYC_Bar","ToBarFrontEntrance","FromBarFrontEntrance");
    AddXfer("02_NYC_FreeClinic","FromStreet","FromClinic");
    AddXfer("02_NYC_Hotel","ToHotelBedroom","BedroomWindow");
    AddXfer("02_NYC_Hotel","ToHotelFrontDoor","FromHotelFrontDoor");
    AddXfer("02_NYC_Smug","ToSmugFrontDoor","FromSmugFrontDoor");
    AddXfer("02_NYC_Smug","ToSmugBackDoor","FromSmugBackDoor");
    AddXfer("02_NYC_Underground","ToNYCUndergroundSewer2","FromNYCUndergroundSewer2");
    AddXfer("02_NYC_Underground","ToNYCSump","FromNYCSump");
    AddXfer("02_NYC_Warehouse","ToRoofTop","FromRoofTop");
    AddXfer("02_NYC_Warehouse","ToWarehouseAlley","FromWarehouseAlley");
    AddXfer("02_NYC_Street","ToStreet","ToBatteryPark");
    AddXfer("02_NYC_Street","FromSmugBackDoor","ToSmugBackDoor");
    AddXfer("02_NYC_Street","FromSmugFrontDoor","ToSmugFrontDoor");
    AddXfer("02_NYC_Street","FromBarBackEntrance","ToBarBackEntrance");
    AddXfer("02_NYC_Street","FromBarFrontEntrance","ToBarFrontEntrance");
    AddXfer("02_NYC_Street","FromHotelFrontDoor","ToHotelFrontDoor");
    AddXfer("02_NYC_Street","FromClinic","FromStreet");
    AddXfer("02_NYC_Street","BedroomWindow","ToHotelBedroom");
    AddXfer("02_NYC_Street","FromWarehouseAlley","ToWarehouseAlley");
    AddXfer("02_NYC_Street","FromRoofTop","ToRoofTop");
    AddXfer("02_NYC_Street","FromNYCUndergroundSewer2","ToNYCUndergroundSewer2");
    AddXfer("02_NYC_Street","FromNYCSump","ToNYCSump");    
        
    GenerateConnections(2);
}

function RandoMission3()
{
    AddXfer("03_NYC_BatteryPark","BBSExit","FromNYCStreets");
    AddXfer("03_NYC_BrooklynBridgeStation","FromNYCStreets","BBSExit");
    AddXfer("03_NYC_BrooklynBridgeStation","MoleExit","MoleEnt");
    AddXfer("03_NYC_MolePeople","SewerExit","SewerEnt");
    AddXfer("03_NYC_MolePeople","MoleEnt","MoleExit");
    AddXfer("03_NYC_AirfieldHeliBase","SewerEnt","SewerExit");
    AddXfer("03_NYC_AirfieldHeliBase","BHElevatorEnt","BHElevatorExit");
    AddXfer("03_NYC_AirfieldHeliBase","FromOcean","ToOcean");
    AddXfer("03_NYC_Airfield","HangarExit","HangarEnt");
    AddXfer("03_NYC_Airfield","BHElevatorExit","BHElevatorEnt");
    AddXfer("03_NYC_Airfield","ToOcean","FromOcean");
    AddXfer("03_NYC_Hangar","HangarEnt","HangarExit");
    AddXfer("03_NYC_Hangar","747PassExit","747PassEnt");
    AddXfer("03_NYC_747","747PassEnt","747PassExit");
    
    GenerateConnections(3);
}

function EntranceRando(int missionNum)
{   
    numConns = 0;
    dxr.SetSeed( dxr.seed + dxr.Crc("entrancerando") );
     
    switch(missionNum)
    {
        case 2:
            RandoMission2();
            break;
        case 3:
            RandoMission3();
            break;
        case 4:
            break;
        case 6:
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
       //Figure out if the teleporter needs to be changed
       
       //Only teleporters with the default tag are actually going somewhere
       if (t.URL != "")
       {
           hashPos = InStr(t.URL,"#");
           destTag = Mid(t.URL,hashPos+1); //Mid includes the character at the offset provided
           for (i = 0;i<numConns;i++)
           {
               if (Caps(conns[i].a.mapname) == dxr.localURL && destTag == conns[i].a.outTag)
               {
                   l("Found teleporter with URL "$t.URL);
                   t.URL = conns[i].b.mapname$"#"$conns[i].b.inTag;
                   l("Changed teleporter URL to "$t.URL);

                   break;
               }
               else if (Caps(conns[i].b.mapname) == dxr.localURL && destTag == conns[i].b.outTag)
               {
                   l("Found teleporter with URL "$t.URL);
                   t.URL = conns[i].a.mapname$"#"$conns[i].a.inTag;
                   l("Changed teleporter URL to "$t.URL);
                   break;

               }

           }

       }
       
       
    }
    
    foreach AllActors(class'MapExit',m)
    {
        //Figure out if the map exit needs to be changed
        hashPos = InStr(m.DestMap,"#");
        destTag = Mid(m.DestMap,hashPos+1); //Mid includes the character at the offset provided
        for (i = 0;i<numConns;i++)
        {
            if (Caps(conns[i].a.mapname) == dxr.localURL && destTag == conns[i].a.outTag)
            {
                l("Found MapExit with URL "$m.DestMap);
                m.DestMap = conns[i].b.mapname$"#"$conns[i].b.inTag;
                l("Changed MapExit URL to "$m.DestMap);
                break;
            }
            else if (Caps(conns[i].b.mapname) == dxr.localURL && destTag == conns[i].b.outTag)
            {
                l("Found MapExit with URL "$m.DestMap);
                m.DestMap = conns[i].a.mapname$"#"$conns[i].a.inTag;
                l("Changed MapExit URL to "$m.DestMap);
                break;
            }

        }
    }
    
}

function FirstEntry()
{
    
    Super.FirstEntry();

    if( dxr.flags.gamemode != 1 ) return;
    
    //Randomize entrances for this mission
    EntranceRando(dxr.dxInfo.missionNumber);

}

defaultproperties
{
}
