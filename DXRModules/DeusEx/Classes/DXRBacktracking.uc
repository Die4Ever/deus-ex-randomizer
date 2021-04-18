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

        case "11_PARIS_CATHEDRAL":
            dt = Spawn(class'DynamicTeleporter',,'cathedral_backtrack',vect(-2268.337891, 3042.279297, -866.726196));
            dt.SetDestination("10_PARIS_CHATEAU", 'Light135');
            dt.Radius = 160;
            foreach AllActors(class'BlockPlayer', bp) {
                switch(bp.Name) {
                    case 'BlockPlayer90':
                    case 'BlockPlayer91':
                    case 'BlockPlayer117':
                        bp.bBlockPlayers=false;
                }
            }
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

function PostFirstEntry()
{
    switch(dxr.localURL) {
        case "11_PARIS_CATHEDRAL":
            AddBox(class'CrateUnbreakableSmall', vect(-2130.379639, 3345.327881, -1151.909180));
            AddBox(class'CrateUnbreakableLarge', vect(-2234.959473, 3227.824951, -1127.913330));
            break;
    }
}

function PreTravel()
{
    Super.PreTravel();
    CheckNextMap(Human(dxr.Player).nextMap);
}

function CheckNextMap(string nextMap)
{
    local int oldMissionNum, newMissionNum;

    oldMissionNum = dxr.dxInfo.missionNumber;
    newMissionNum = class'DXRTestAllMaps'.static.GetMissionNumber(nextMap);

    //do this for paris (10/11) and vandenberg (12/14)
    if( (oldMissionNum == 10 && newMissionNum == 11) || (oldMissionNum == 11 && newMissionNum == 10)
            ||
        (oldMissionNum == 12 && newMissionNum == 14) || (oldMissionNum == 14 && newMissionNum == 12) )
    {
        RetainSaves(oldMissionNum, newMissionNum, nextMap);
    }
}

function RetainSaves(int oldMissionNum, int newMissionNum, string nextMap)
{
    info( "keeping save files, dxr.Player.nextMap: "$ nextMap );
    dxr.dxInfo.missionNumber = newMissionNum;
}

static function LevelInit(DXRando dxr)
{
    local int newMissionNum;

    newMissionNum = class'DXRTestAllMaps'.static.GetMissionNumber(dxr.localURL);
    if( newMissionNum != 0 && newMissionNum != dxr.dxInfo.missionNumber ) {
        log("LevelInit("$dxr$") dxr.localURL: "$dxr.localURL$", newMissionNum: "$ newMissionNum $", dxr.dxInfo.missionNumber: "$dxr.dxInfo.missionNumber, 'DXRBacktracking');
        dxr.dxInfo.missionNumber = newMissionNum;
    }
}

static function DeleteExpiredFlags(FlagBase flags, int missionNumber)
{
    switch(missionNumber) {
        case 11:
            missionNumber = 10;
            break;
        case 14:
            missionNumber = 12;
            break;
    }
    flags.DeleteExpiredFlags(missionNumber);
}

function AnyEntry()
{
    local DeusExPlayer p;// we wanna make sure we get all the player objects, even in multiplayer?
    local DeusExDecoration d;
    local ScriptedPawn s;
    Super.AnyEntry();
    foreach AllActors(class'DeusExPlayer', p)
        p.ConBindEvents();
    foreach AllActors(class'DeusExDecoration', d)
        d.ConBindEvents();
    foreach AllActors(class'ScriptedPawn', s)
        s.ConBindEvents();

    FixInterpolating();

    switch(dxr.localURL) {
        case "10_PARIS_METRO":
            ParisMetroAnyEntry();
            break;
        case "10_PARIS_CHATEAU":
            ParisChateauAnyEntry();
            break;
    }
}

function ReEntry(bool IsTravel)
{
    Super.ReEntry(IsTravel);
    //need to make sure this doesn't happen when loading a save
    if ( IsTravel ) class'DynamicTeleporter'.static.CheckTeleport(dxr.player);
}

function FixInterpolating()
{
    //err(dxr.player$" state: "$dxr.player.GetStateName()$", Tag: "$dxr.player.tag$", NextState: "$dxr.player.NextState$", bInterpolating: "$dxr.player.bInterpolating);
    if( dxr.player.NextState != 'Interpolating' ) return;
    info("FixInterpolating(), "$dxr.player$" state: "$dxr.player.GetStateName()$", Tag: "$dxr.player.tag$", NextState: "$dxr.player.NextState$", bInterpolating: "$dxr.player.bInterpolating);
    dxr.player.NextState = '';
    dxr.player.NextLabel = '';
    dxr.player.GotoState('PlayerWalking');
    dxr.player.bDetectable = true;
}

function ParisMetroAnyEntry()
{
    local InterpolateTrigger t;
    local GuntherHermann gunther;
    local BlackHelicopter chopper;
    local NicoletteDuClare nicolette;
    local FlagBase flags;
    local MapExit exit;

    flags = dxr.player.flagBase;

    foreach AllActors(class'InterpolateTrigger', t, 'ChopperExit') {
        t.bTriggerOnceOnly = false;
    }

    foreach AllActors(class'MapExit', exit, 'ChopperExit') {
        exit.SetDestination("10_PARIS_CHATEAU", '', "Chateau_start");
    }

    if( flags.GetBool('NicoletteDoneFollowing') ) {
        foreach AllActors(class'NicoletteDuClare', nicolette)
            nicolette.Destroy();
    }

    if( flags.GetBool('JockReady_Played') ) {
        flags.SetBool('JockReady_Played', false,, 11);
        flags.SetBool('MS_GuntherUnhidden', false,, 11);

        foreach AllActors(class'GuntherHermann', gunther) {
            gunther.SetLocation( vect(3790.952637, 1990.542969, 199.763168) );
            gunther.LeaveWorld();
        }

        foreach AllActors(class'BlackHelicopter', chopper) {
            chopper.Destroy();
        }

        chopper = Spawn(class'BlackHelicopter',, 'BlackHelicopter', vect(3134.682373, 1101.204956, 304.756897), rot(0, -24944, 0) );
        chopper.Event = 'choppertrack';
        chopper.BindName = "Jock";
        chopper.FamiliarName = "Black Helicopter";
        chopper.UnFamiliarName = "Black Helicopter";
        chopper.ConBindEvents();
    }

    /*if( flags.GetBool('ClubComplete') ) {
        // switch back to her dialog when she's ready to get in the chopper
        flags.SetBool('ClubComplete', false,, 12);
    }*/
}

function ParisChateauAnyEntry()
{
    local InterpolateTrigger t;
    local BlackHelicopter chopper;
    local MapExit exit;
    local FlagBase flags;

    flags = dxr.player.flagBase;
    flags.SetBool('NicoletteReadyToLeave', true,, 12);
    flags.SetBool('NicoletteOutside_Played', true,, 12);
    flags.SetBool('NicoletteLeftClub', true,, 12);
    flags.SetBool('ClubComplete', true,, 12);
    flags.SetBool('MeetNicolette_Played', true,, 12);

    foreach AllActors(class'InterpolateTrigger', t) {
        t.Destroy();
    }

    t = Spawn(class'InterpolateTrigger',, 'ChopperExit', vect(-825.793274, 1976.029297, 176.545380));
    t.bTriggerOnceOnly = false;
    t.Event = 'BlackHelicopter';
    t.SetCollision(false);

    foreach AllActors(class'BlackHelicopter', chopper)
        chopper.Destroy();

    chopper = Spawn(class'BlackHelicopter',, 'BlackHelicopter', vect(-825.793274, 1976.029297, 176.545380), rot(0, -10944, 0) );
    chopper.Event = 'UN_BlackHeli_Fly';
    chopper.BindName = "Jock";
    chopper.FamiliarName = "Black Helicopter";
    chopper.UnFamiliarName = "Black Helicopter";
    chopper.ConBindEvents();

    CloneInterpolationPoints( 'UN_BlackHeli_Fly', 'Camera1', vect(-500,250,0) );

    foreach AllActors(class'MapExit', exit, 'ChopperExit') { return; }
    exit = Spawn(class'MapExit',, 'ChopperExit', vect(-825.793274, 1976.029297, 176.545380) );
    exit.SetCollision(false,false,false);
    exit.SetDestination("10_PARIS_METRO", 'PathNode447');
    exit.bPlayTransition = true;
    exit.cameraPathTag = 'Camera1';
}

function CloneInterpolationPoints(Name oldtag, Name newtag, vector offset)
{
    local InterpolationPoint p, pnew;

    foreach AllActors(class'InterpolationPoint', p, newtag)
        return;// don't do anything if newtag already exists

    foreach AllActors(class'InterpolationPoint', p, oldtag) {
        pnew = Spawn(class'InterpolationPoint',, newtag, p.Location+offset, p.Rotation);
        pnew.bEndOfPath = p.bEndOfPath;
        pnew.bSkipNextPath = p.bSkipNextPath;
        pnew.Position = p.Position;
        pnew.RateModifier = p.RateModifier;
    }

    foreach AllActors(class'InterpolationPoint', pnew, newtag)
        pnew.BeginPlay();// find the Prev and Next
}
