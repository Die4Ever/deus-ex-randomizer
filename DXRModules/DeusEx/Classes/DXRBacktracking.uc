class DXRBacktracking extends DXRActorsBase transient;
// backtracking specific fixes that might be too extreme for the more generic DXRFixup? or move the stuff from DXRFixup into here?

function PreFirstEntry()
{
    local Teleporter t;
    local DynamicTeleporter dt;
    local BlockPlayer bp;
    Super.PreFirstEntry();

    switch(dxr.localURL) {
        case "04_NYC_BATTERYPARK":
            foreach AllActors(class'Teleporter', t) {
                if( DynamicTeleporter(t) != None ) continue;
                if( ! t.bEnabled ) continue;
                if( t.URL != "04_NYC_Street#ToStreet" ) continue;
                dt = class'DynamicTeleporter'.static.ReplaceTeleporter(t);
                dt.SetDestination("04_NYC_Street", 'PathNode194');
            }
            break;
        
        case "10_PARIS_METRO":
            foreach AllActors(class'BlockPlayer', bp) {
                if( bp.Name == 'BlockPlayer0' ) {
                    bp.bBlockPlayers=false;
                }
            }
            dt = Spawn(class'DynamicTeleporter',,'sewers_backtrack',vect(1599.971558, -4694.342773, 13.399302));
            dt.SetDestination("10_PARIS_CATACOMBS_TUNNELS", 'AmbientSound10');
            dt.Radius = 160;
            AddSwitch(vect(1602.826904, -4318.841309, -250.365067), rot(0, 16384, 0), 'sewers_backtrack');
            break;
        case "15_AREA51_ENTRANCE":
            dt = Spawn(class'DynamicTeleporter',,,vect(4384.407715, -2483.292236, -41.900017));
            dt.SetDestination("15_area51_bunker", 'Light188');
            dt.Radius = 160;
            break;
        case "15_AREA51_FINAL":
            dt = Spawn(class'DynamicTeleporter',,,vect(-5714.406250, -1977.827881, -1358.711304));
            dt.SetDestination("15_area51_entrance", 'Light73');
            dt.Radius = 160;
            break;
    }

    class'DynamicTeleporter'.static.CheckTeleport(dxr.player);
}

function PreTravel()
{
    log("PreTravel");
    checknextmap();
}

function checknextmap()
{
    local int oldMissionNum, newMissionNum;

    oldMissionNum = dxr.dxInfo.missionNumber;
    newMissionNum = class'DXRTestAllMaps'.static.GetMissionNumber(Human(dxr.Player).nextMap);

    //do this for paris (10/11) and vandenberg (12/14)
    if( oldMissionNum == 10 && newMissionNum == 11
        ||
        oldMissionNum == 11 && newMissionNum == 10
        ||
        oldMissionNum == 12 && newMissionNum == 14
        ||
        oldMissionNum == 14 && newMissionNum == 12 )
    {
        info( "keeping save files, dxr.Player.nextMap: "$ Human(dxr.Player).nextMap );
        dxr.dxInfo.missionNumber = newMissionNum;
    }
}

function ReEntry(bool IsTravel)
{
    Super.ReEntry(IsTravel);
    //need to make sure this doesn't happen when loading a save
    if ( IsTravel ) class'DynamicTeleporter'.static.CheckTeleport(dxr.player);
}

function DeusExDecoration AddSwitch(vector loc, rotator rotate, name Event)
{
    return class'DXRFixup'.static._AddSwitch(Self, loc, rotate, Event);
}
