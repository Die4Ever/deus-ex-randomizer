//=============================================================================
// DXREntranceRando.
//=============================================================================
class DXREntranceRando expands DXRBase;

var int curMission;


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

function Init(DXRando txdr)
{
    Super.Init(txdr);
    
    curMission = txdr.flags.f.GetInt('Rando_Entrance_CurMission');
    txdr.flags.f.SetBool('Rando_Entrance_Enabled',True);
    
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

function bool IsConnectionValid(int missionNum, MapTransfer a, MapTransfer b)
{
    switch(missionNum)
    {
        case 2:
            if (a.mapname == "02_NYC_BatteryPark")
            {
                if (b.mapname == "02_NYC_FreeClinic")
                {
                    return False;
                }
            }
            else if (b.mapname == "02_NYC_BatteryPark")
            {
                if (a.mapname == "02_NYC_FreeClinic")
                {
                    return False;
                }
            }         
            else if (a.mapname == b.mapname)
            {
                //We allow this on street
                if (a.mapname!="02_NYC_Street")
                {
                    return False;
                }
            }
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
    
    l("Can visit "$visitable$" maps");
    for (i=0;i<visitable;i++)
    {
        l(canvisit[i]);
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
    numConns = connsMade;

}

function RandoMission2()
{
    //This is just because I am too lazy to retype the map name a lot of times
    local string mapName;
    
    numXfers = 24;
    
    mapName = "02_NYC_BatteryPark";
    xfers[0].mapname = mapname;
    xfers[0].inTag = "ToBatteryPark";
    xfers[0].outTag = "ToStreet";
    xfers[0].used = False;

    mapName = "02_NYC_Bar";
    xfers[1].mapname = mapname;
    xfers[1].inTag = "ToBarBackEntrance";
    xfers[1].outTag = "FromBarBackEntrance";
    xfers[1].used = False;

    xfers[2].mapname = mapname;
    xfers[2].inTag = "ToBarFrontEntrance";
    xfers[2].outTag = "FromBarFrontEntrance";
    xfers[2].used = False;

    mapName = "02_NYC_FreeClinic";
    xfers[3].mapname = mapname;
    xfers[3].inTag = "FromStreet";
    xfers[3].outTag = "FromClinic";
    xfers[3].used = False;

    mapName = "02_NYC_Hotel";
    xfers[4].mapname = mapname;
    xfers[4].inTag = "ToHotelBedroom";
    xfers[4].outTag = "BedroomWindow";
    xfers[4].used = False;

    xfers[5].mapname = mapname;
    xfers[5].inTag = "ToHotelFrontDoor";
    xfers[5].outTag = "FromHotelFrontDoor";
    xfers[5].used = False;

    mapName = "02_NYC_Smug";
    xfers[6].mapname = mapname;
    xfers[6].inTag = "ToSmugFrontDoor";
    xfers[6].outTag = "FromSmugFrontDoor";
    xfers[6].used = False;

    xfers[7].mapname = mapname;
    xfers[7].inTag = "ToSmugBackDoor";
    xfers[7].outTag = "FromSmugBackDoor";
    xfers[7].used = False;

    mapName = "02_NYC_Underground";
    xfers[8].mapname = mapname;
    xfers[8].inTag = "ToNYCUndergroundSewer2";
    xfers[8].outTag = "FromNYCUndergroundSewer2";
    xfers[8].used = False;

    xfers[9].mapname = mapname;
    xfers[9].inTag = "ToNYCSump";
    xfers[9].outTag = "FromNYCSump";
    xfers[9].used = False;

    mapName = "02_NYC_Warehouse";
    xfers[10].mapname = mapname;
    xfers[10].inTag = "ToRoofTop";
    xfers[10].outTag = "FromRoofTop";
    xfers[10].used = False;

    xfers[11].mapname = mapname;
    xfers[11].inTag = "ToWarehouseAlley";
    xfers[11].outTag = "FromWarehouseAlley";
    xfers[11].used = False;

    mapName = "02_NYC_Street";
    xfers[12].mapname = mapname;
    xfers[12].inTag = "ToStreet";
    xfers[12].outTag = "ToBatteryPark";
    xfers[12].used = False;

    xfers[13].mapname = mapname;
    xfers[13].inTag = "FromSmugBackDoor";
    xfers[13].outTag = "ToSmugBackDoor";
    xfers[13].used = False;

    xfers[14].mapname = mapname;
    xfers[14].inTag = "FromSmugFrontDoor";
    xfers[14].outTag = "ToSmugFrontDoor";
    xfers[14].used = False;

    xfers[15].mapname = mapname;
    xfers[15].inTag = "FromBarBackEntrance";
    xfers[15].outTag = "ToBarBackEntrance";
    xfers[15].used = False;

    xfers[16].mapname = mapname;
    xfers[16].inTag = "FromBarFrontEntrance";
    xfers[16].outTag = "ToBarFrontEntrance";
    xfers[16].used = False;

    xfers[17].mapname = mapname;
    xfers[17].inTag = "FromHotelFrontDoor";
    xfers[17].outTag = "ToHotelFrontDoor";
    xfers[17].used = False;

    xfers[18].mapname = mapname;
    xfers[18].inTag = "FromClinic";
    xfers[18].outTag = "FromStreet";
    xfers[18].used = False;

    xfers[19].mapname = mapname;
    xfers[19].inTag = "BedroomWindow";
    xfers[19].outTag = "ToHotelBedroom";
    xfers[19].used = False;

    xfers[20].mapname = mapname;
    xfers[20].inTag = "FromWarehouseAlley";
    xfers[20].outTag = "ToWarehouseAlley";
    xfers[20].used = False;

    xfers[21].mapname = mapname;
    xfers[21].inTag = "FromRoofTop";
    xfers[21].outTag = "ToRoofTop";
    xfers[21].used = False;

    xfers[22].mapname = mapname;
    xfers[22].inTag = "FromNYCUndergroundSewer2";
    xfers[22].outTag = "ToNYCUndergroundSewer2";
    xfers[22].used = False;

    xfers[23].mapname = mapname;
    xfers[23].inTag = "FromNYCSump";
    xfers[23].outTag = "ToNYCSump";
    xfers[23].used = False;


    GenerateConnections(2);
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
    
    curMission = dxr.flags.f.GetInt('Rando_Entrance_CurMission');
    
    if (dxr.flags.f.GetBool('Rando_Entrance_Enabled'))
    {
        curMission = dxr.dxInfo.missionNumber;
        dxr.flags.f.SetInt('Rando_Entrance_CurMission',curMission,,999);
        
        //Randomize entrances for this mission
        EntranceRando(curMission);
        
    }
}

defaultproperties
{
}
