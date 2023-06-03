class DXRBacktracking extends DXRActorsBase transient;
// backtracking specific fixes that might be too extreme for the more generic DXRFixup? or move the stuff from DXRFixup into here?

function PreFirstEntry()
{
    local Teleporter t;
    local DynamicTeleporter dt;
    local BlockPlayer bp;
    local MapExit exit;
    local FlagTrigger ft;

    Super.PreFirstEntry();

    switch(dxr.localURL) {
        case "04_NYC_BATTERYPARK":
            foreach AllActors(class'Teleporter', t) {
                if( DynamicTeleporter(t) != None ) continue;
                if( ! t.bEnabled ) continue;
                if( t.URL != "04_NYC_Street#ToStreet" ) continue;
                dt = class'DynamicTeleporter'.static.ReplaceTeleporter(t);
                SetDestination(dt, "04_NYC_Street", 'PathNode194');
            }
            break;

        case "10_PARIS_METRO":
            foreach AllActors(class'BlockPlayer', bp) {
                if( bp.Name == 'BlockPlayer0' ) {
                    bp.bBlockPlayers=false;
                }
            }
            dt = Spawn(class'DynamicTeleporter',,'sewers_backtrack',vectm(1599.971558, -4694.342773, 13.399302));
            SetDestination(dt, "10_PARIS_CATACOMBS_TUNNELS", 'AmbientSound10');
            dt.SetCollisionSize(160,dt.CollisionHeight);
            AddSwitch(vectm(1602.826904, -4318.841309, -250.365067), rotm(0, 16384, 0), 'sewers_backtrack');

            foreach AllActors(class'MapExit', exit, 'ChopperExit') {
                SetDestination(exit, "10_PARIS_CHATEAU", '', "Chateau_start");
            }
            break;

        case "11_PARIS_CATHEDRAL":
            dt = Spawn(class'DynamicTeleporter',,'cathedral_backtrack',vectm(-2268.337891, 3042.279297, -866.726196));
            SetDestination(dt, "10_PARIS_CHATEAU", 'Light135');
            dt.SetCollisionSize(160,dt.CollisionHeight);
            foreach AllActors(class'BlockPlayer', bp) {
                switch(bp.Name) {
                    case 'BlockPlayer90':
                    case 'BlockPlayer91':
                    case 'BlockPlayer117':
                        bp.bBlockPlayers=false;
                }
            }
            break;

        case "12_VANDENBERG_CMD":
            foreach AllActors(class'MapExit', exit, 'mission_done') {
                SetDestination(exit, "12_Vandenberg_gas", '', "gas_start");
            }
            break;

        case "12_VANDENBERG_GAS":
            foreach AllActors(class'MapExit', exit, 'UN_BlackHeli') {
                SetDestination(exit, "14_Vandenberg_sub", '', "PlayerStart");
            }
            break;

        case "15_AREA51_ENTRANCE":
            dt = Spawn(class'DynamicTeleporter',,,vectm(4384.407715, -2483.292236, -41.900017));
            SetDestination(dt, "15_area51_bunker", 'Light188');
            dt.SetCollisionSize(160,dt.CollisionHeight);
            break;

        case "15_AREA51_FINAL":
            dt = Spawn(class'DynamicTeleporter',,,vectm(-5714.406250, -1977.827881, -1358.711304));
            SetDestination(dt, "15_area51_entrance", 'Light73');
            dt.SetCollisionSize(160,dt.CollisionHeight);

            AddSwitch(vectm(-3907,-1116,-1958), rotm(0, 32800, 0), 'mainblastopencheck');

            //Switch triggers the doors if the Helios datalink has played (Talked to Helios)
            ft = Spawn(class'FlagTrigger',,,vectm(-3907,-1116,-1958));
            ft.tag = 'mainblastopencheck';
            ft.bInitiallyActive=True;
            ft.bTriggerOnceOnly=False;
            ft.SetCollision(false,false,false);
            ft.FlagName='DL_Helios_Door2_Played';
            ft.bSetFlag=False;
            ft.flagValue=True;
            ft.bTrigger=True;
            ft.Event='Page_Blastdoors';

            //Switch triggers the "not yet" datalink if the Helios datalink has not played (Talked to Helios)
            ft = Spawn(class'FlagTrigger',,,vectm(-3907,-1116,-1958));
            ft.tag = 'mainblastopencheck';
            ft.bInitiallyActive=True;
            ft.bTriggerOnceOnly=False;
            ft.SetCollision(false,false,false);
            ft.FlagName='DL_Helios_Door2_Played';
            ft.bSetFlag=False;
            ft.flagValue=False;
            ft.bTrigger=True;
            ft.Event='heliosdoorfail';


            break;

    }
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);
    FixInterpolating(p);
    if( ! class'DynamicTeleporter'.static.CheckTeleport(p) ) {
        err("DynamicTeleporter failed");
    }
}

function PostFirstEntry()
{
    switch(dxr.localURL) {
        case "11_PARIS_CATHEDRAL":
            AddBox(class'CrateUnbreakableSmall', vectm(-2130.379639, 3345.327881, -1151.909180));
            AddBox(class'CrateUnbreakableLarge', vectm(-2234.959473, 3227.824951, -1127.913330));
            break;
    }
}

function PreTravel()
{
    Super.PreTravel();
    CheckNextMap(player().nextMap);
}

function CheckNextMap(string nextMap)
{
    local int oldMissionNum, newMissionNum;
    local string combo;

    oldMissionNum = dxr.dxInfo.missionNumber;
    newMissionNum = class'DXRMapInfo'.static.GetMissionNumber(nextMap);

    if( oldMissionNum == newMissionNum ) return;

    combo = oldMissionNum $ " to " $ newMissionNum;
    switch(combo) {
        case "10 to 11":
        case "11 to 10":
        case "12 to 14":
        case "14 to 12":
            RetainSaves(oldMissionNum, newMissionNum, nextMap);
            break;
        default:
            if( dxr.flags.gamemode == 100 )// some type of open world mode? always retain saves across all missions
                RetainSaves(oldMissionNum, newMissionNum, nextMap);
    }
}

function RetainSaves(int oldMissionNum, int newMissionNum, string nextMap)
{
    info( "keeping save files, nextMap: "$ nextMap );
    dxr.dxInfo.missionNumber = newMissionNum;
}

static function LevelInit(DXRando dxr)
{
    local int newMissionNum;

    dxr.dxInfo.mapName = class'DXRMapVariants'.static.CleanupMapName(dxr.dxInfo.mapName);
    dxr.localURL = Caps(dxr.dxInfo.mapName);

    newMissionNum = class'DXRMapInfo'.static.GetMissionNumber(dxr.localURL);
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
    local #var(PlayerPawn) p;// we wanna make sure we get all the player objects, even in multiplayer?
    local DeusExDecoration d;
    local ScriptedPawn s;
    Super.AnyEntry();
    foreach AllActors(class'#var(PlayerPawn)', p) {
        p.ConBindEvents();
        FixInterpolating(p);
    }
    foreach AllActors(class'DeusExDecoration', d)
        d.ConBindEvents();

    foreach AllActors(class'ScriptedPawn', s) {
        if(s.BindName!="JCDenton"){ //Re-binding a JCDenton during ENDGAME4 knocks you out of camera mode and kills you
            s.ConBindEvents();      //I don't think we *need* this ever?
        }
    }

    SetSeed("DXRBacktracking AnyEntry");// just in case we do randomized interpolationpoints

    switch(dxr.localURL) {
        case "10_PARIS_METRO":
            ParisMetroAnyEntry();
            break;
        case "10_PARIS_CHATEAU":
            ParisChateauAnyEntry();
            break;

        case "12_VANDENBERG_CMD":
            VandCmdAnyEntry();
            break;
        case "12_VANDENBERG_GAS":
            VandGasAnyEntry();
            break;
        case "14_VANDENBERG_SUB":
            VandSubAnyEntry();
            break;
        case "14_OCEANLAB_LAB":
            VandOceanLabAnyEntry();
            break;
        case "14_OCEANLAB_SILO":
            VandSiloAnyEntry();
            break;
        case "15_AREA51_FINAL":
            Area51FinalAnyEntry();
            break;
    }
}

function FixInterpolating(#var(PlayerPawn) p)
{
    p.bDetectable = true;
    p.bHidden = false;
    p.Visibility = p.Default.Visibility;
    //err(player()$" state: "$player().GetStateName()$", Tag: "$player().tag$", NextState: "$player().NextState$", bInterpolating: "$player().bInterpolating);
    if( p.NextState != 'Interpolating' ) return;
    info("FixInterpolating(), "$p$" state: "$p.GetStateName()$", Tag: "$p.tag$", NextState: "$p.NextState$", bInterpolating: "$p.bInterpolating);
    p.NextState = '';
    p.NextLabel = '';
    p.GotoState('PlayerWalking');
}

function ParisMetroAnyEntry()
{
    local InterpolateTrigger t;
    local GuntherHermann gunther;
    local NicoletteDuClare nicolette;
    local FlagBase flags;
    local MapExit exit;

    flags = dxr.flagbase;

    foreach AllActors(class'InterpolateTrigger', t, 'ChopperExit') {
        t.bTriggerOnceOnly = false;
    }

    if( flags.GetBool('NicoletteDoneFollowing') ) {
        foreach AllActors(class'NicoletteDuClare', nicolette)
            nicolette.Destroy();
    }

    if( flags.GetBool('JockReady_Played') ) {
        flags.SetBool('JockReady_Played', false,, 11);
        flags.SetBool('MS_GuntherUnhidden', false,, 11);

        foreach AllActors(class'GuntherHermann', gunther) {
            gunther.SetLocation( vectm(3790.952637, 1990.542969, 199.763168) );
            gunther.LeaveWorld();
        }

        RemoveChoppers();

        SpawnChopper( 'BlackHelicopter', 'choppertrack', "Jock", vectm(3134.682373, 1101.204956, 304.756897), rotm(0, -24944, 0) );
    }

    /*if( flags.GetBool('ClubComplete') ) {
        // switch back to her dialog when she's ready to get in the chopper
        flags.SetBool('ClubComplete', false,, 12);
    }*/
}

function ParisChateauAnyEntry()
{
    local InterpolateTrigger t;
    local FlagBase flags;

    flags = dxr.flagbase;
    flags.SetBool('NicoletteReadyToLeave', true,, 12);
    flags.SetBool('NicoletteOutside_Played', true,, 12);
    flags.SetBool('NicoletteLeftClub', true,, 12);
    flags.SetBool('ClubComplete', true,, 12);
    flags.SetBool('MeetNicolette_Played', true,, 12);

    foreach AllActors(class'InterpolateTrigger', t)
        t.Destroy();

    RemoveChoppers();

    CreateCameraInterpolationPoints( 'UN_BlackHeli_Fly', 'Camera1', vectm(-500,250,0) );
    BacktrackChopper( 'ChopperExit', 'BlackHelicopter', 'UN_BlackHeli_Fly', "Jock", 'Camera1', "10_PARIS_METRO", 'PathNode447', "", vectm(-825.793274, 1976.029297, 176.545380), rotm(0, -10944, 0) );
}

function VandCmdAnyEntry()
{
    local InterpolateTrigger t;
    local FlagBase flags;
    local Vehicles chopper;
    local DXRMissions missions;

    foreach AllActors(class'InterpolateTrigger', t, 'mission_done') {
        t.bTriggerOnceOnly = false;
    }

    // I could also give Jock a "Let's go" conversation instead
    ConversationFrobOnly(GetConversation('TongTrigger'));
    ConversationFrobOnly(GetConversation('M12JockFinal'));
    ConversationFrobOnly(GetConversation('M12JockFinal2'));

    flags = dxr.flagbase;
    flags.SetBool('TongTrigger_Played', false,, 1);
    if ( flags.GetBool('GaryHostageBriefing_Played') )
    {
        RemoveChoppers('Helicopter');
        chopper = SpawnChopper( 'Helicopter', 'helicopter_path', "Jock", vectm(7014.185059, 7540.296875, -2884.704102), rotm(0, -19840, 0) );
        missions = DXRMissions(dxr.FindModule(class'DXRMissions'));
        if(missions != None) {
            missions.UpdateLocation(chopper);
        }
    }
}

function VandGasAnyEntry()
{
    local BlackHelicopter chopper;
    local InterpolateTrigger t;
    local DeusExMover M;
    local FlagBase flags;
    flags = dxr.flagbase;

    ConversationFrobOnly(GetConversation('M12JockFinal'));
    ConversationFrobOnly(GetConversation('M12JockFinal2'));

    // backtracking to CMD
    flags.SetBool('GaryHostageBriefing_Played', true,, 15);

    RemoveChoppers('backtrack_chopper');

    foreach AllActors(class'BlackHelicopter', chopper, 'Heli')
        chopper.Event = 'UN_BlackHeli';

    CreateInterpolationPoints( 'backtrack_exit', vectm(2520.256836, -2489.873535, -1402.078857) );
    CreateCameraInterpolationPoints( 'backtrack_exit', 'backtrack_camera', vectm(-500,250,0) );

    // I could also give Jock a "Let's go" conversation
    BacktrackChopper('backtrack_exit', 'backtrack_chopper', 'backtrack_exit', "", 'backtrack_camera', "12_VANDENBERG_CMD", 'PathNode8', "", vectm(2520.256836, -2489.873535, -1402.078857), rotm(0,0,0) );


    // repeat flights to the sub base
    foreach AllActors(class'InterpolateTrigger', t, 'UN_BlackHeli')
        t.bTriggerOnceOnly = false;

    foreach AllActors(Class'DeusExMover', M, 'junkyard_doors') {
        M.bLocked = true;
        class'DXRDoors'.static.StaticMakeDestructible(M);
        M.doorStrength = 0.1;
        M.minDamageThreshold = 1;
    }

    if( flags.GetBool('MS_ChopperGasUnhidden') ) {
        RemoveChoppers('Heli');
        SpawnChopper( 'Heli', 'UN_BlackHeli', "Jock", vectm(-3207.999756, 135.342285, -905.545044), rotm(0, -63104, 0) );

        foreach AllActors(Class'DeusExMover', M, 'junkyard_doors')
            M.BlowItUp(None);
    }
    else if( flags.GetBool('TiffanyRescued') ) {
        foreach AllActors(class'BlackHelicopter', chopper)
            chopper.EnterWorld();

        foreach AllActors(Class'DeusExMover', M, 'junkyard_doors')
            M.BlowItUp(None);

        flags.SetBool('MS_ChopperGasUnhidden', True,, 15);
    }
}

function VandSubAnyEntry()
{
    local InterpolateTrigger t;
    local InterpolationPoint p;
    local FlagTrigger ft;
    local FlagBase flags;
    local DataLinkTrigger dt;
    local Conversation c;
    local MapExit exit;
    flags = dxr.flagbase;

    // backtracking to gas station
    flags.SetBool('TiffanyRescued', true,, 15);// despite the name, this really just means the rescue has been attempted

    foreach AllActors(class'DataLinkTrigger', dt, 'DataLinkTrigger') {
        if( dt.datalinkTag == 'dl_start') {
            dt.CheckFlag = 'dl_start_Played';
            dt.bCheckFalse = true;
        }
    }

    foreach AllActors(class'InterpolateTrigger', t, 'InterpolateTrigger')
        if( t.Event == 'UN_BlackHeli' ) {
            t.Event = '';
            t.Destroy();
        }

    RemoveChoppers('UN_BlackHeli');
    RemoveChoppers('backtrack_chopper');

    foreach AllActors(class'InterpolationPoint', p, 'UN_BlackHeli_Fly') {
        p.RateModifier = 0.25;
        if( p.Position > 4 ) p.bEndOfPath = true;
        if( p.Position > 2 ) continue;
        p.SetLocation(vectm(7035.433594, 3841.281250, -379.008362));
        if( p.Position < 2 ) p.SetRotation(rotm(0, -15720, 0));
    }

    CreateCameraInterpolationPoints( 'UN_BlackHeli_Fly', 'backtrack_camera', vectm(200,600,0) );
    BacktrackChopper('UN_BlackHeli_Fly', 'backtrack_chopper', 'UN_BlackHeli_Fly', "", 'backtrack_camera', "12_VANDENBERG_GAS", 'PathNode98', "", vectm(7035.433594, 3841.281250, -379.008362), rotm(0, -15720, 0) );

    // need to backtrack with the sub too
    foreach AllActors(class'FlagTrigger', ft, 'flag2') {
        if(ft.Event == 'reallysubexit') {
            ft.Tag = '';
            ft.Event = '';
            ft.Destroy();
            break;
        }
    }
    foreach AllActors(class'FlagTrigger', ft, 'subexit') {
        if( ft.Event == 'flag2' ) {
            ft.Event = 'reallysubexit';
            break;
        }
    }
    // TODO: there are unused InterpolationPoints for the submarine

    // repeat flights to silo
    foreach AllActors(class'InterpolateTrigger', t, 'ChopperExit')
        t.bTriggerOnceOnly = false;

    if( flags.GetBool('DL_downloaded_Played') ) {
        RemoveChoppers('BlackHelicopter');
        SpawnChopper( 'BlackHelicopter', 'Jockpath', "Jock", vectm(2104.722168, 3647.967773, 896.197144), rotm(0, 0, 0) );
    }

    // ability to fly to the silo even after howard strong is dead
    c = GetConversation('JockArea51');
    c.bDisplayOnce = false;

    foreach AllActors(class'MapExit', exit, 'SiloExit') {
        exit.event = '';
        exit.Destroy();
    }
    exit = Spawn(class'MapExit',, 'SiloExit', vectm(2620, 3284.822754, 743.136780) );
    SetDestination(exit, "14_Oceanlab_silo", '', "frontgate");
    exit.event = 'BlackHelicopter';
    exit.SetCollision(false,false,false);
    exit.bPlayTransition = true;
    exit.cameraPathTag = 'Camera2';

    foreach AllActors(class'InterpolateTrigger', t, 'SiloExit') {
        t.event = '';
        t.Destroy();
    }
    t = Spawn(class'InterpolateTrigger',, 'SiloExit', vectm(2680, 3332.543213, 768.108032) );
    t.event = 'BlackHelicopter';
    t.SetCollision(false,false,false);
}

function VandOceanLabAnyEntry()
{
    local Actor a;
    local FlagTrigger ft;
    local MiniSub s;
    local InterpolateTrigger it;
    local DataLinkTrigger dlt;
    local MapExit me;
    local Conversation c;

    // fix shared tags https://github.com/Die4Ever/deus-ex-randomizer/issues/224
    foreach AllActors(class'Actor', a) {
        if(a.Tag == 'subexit')
            a.Tag = 'subexit2';
        if(a.Event == 'subexit')
            a.Event = 'subexit2';
        if(a.Tag == 'flag2') {
            a.Tag = 'oldflag2';
            a.Event = '';
        }
    }

    // reentry with the sub
    foreach AllActors(class'FlagTrigger', ft, 'subexit2') {
        if( ft.Event == 'flag2' || ft.Event == 'reallysubexit' )
            ft.Event = 'reallysubexit2';
    }

    foreach AllActors(class'DataLinkTrigger', dlt, 'subexit2') {
        if( dlt.datalinkTag == 'dl_subnotready' )
            dlt.Destroy();
    }

    foreach AllActors(class'InterpolateTrigger', it, 'reallysubexit') {
        //it.bTriggerOnceOnly = false;
        //it.SetCollision(false,false,false);
        it.Destroy();
    }

    foreach AllActors(class'MiniSub', s, 'MiniSub') {
        s.Event = '';
        s.Destroy();
    }

    foreach AllActors(class'MapExit', me, 'reallysubexit') {
        // HACK: can't figure out how to fix the camera transition starting immediately when you enter the level sometimes
        me.Tag = 'reallysubexit2';
        me.bPlayTransition = false;
        me.SetCollision(false,false,false);
    }

    s = Spawn(class'MiniSub',, 'MiniSub', vectm(186.735916, 243.355240, -2217.393555), rotm(0, -16408, 0) );
    s.Event = 'subexit2';
    s.bFloating = true;
    s.SetPhysics(PHYS_Swimming);
    s.SetRotation(rotm(0, -16408, 0));
    s.DesiredRotation = rotm(0, -16408, 0);
    s.origRot = rotm(0, -16408, 0);

    foreach AllActors(class'DataLinkTrigger', dlt) {
        if( dlt.datalinkTag != 'dl_seconddoors' ) continue;
        dlt.SetCollision(false);
        dlt.Tag = 'subexit2';
    }
    c = GetConversation('DL_SecondDoors');
    c.bDisplayOnce = false;
    class'DXRFixup'.static.FixConversationFlag(c, 'schematic_downloaded', true, 'door_open', false);
}

function VandSiloAnyEntry()
{
    local FlagBase flags;
    local Conversation c;
    local Vehicles chopper;
    flags = dxr.flagbase;

    // back to sub base
    flags.SetBool('DL_downloaded_Played', true,, 15);
    CreateInterpolationPoints( 'backtrack_path', vectm(507, -2500, 1600) );
    CreateCameraInterpolationPoints( 'backtrack_path', 'backtrack_camera', vectm(-500,250,0) );

    RemoveChoppers('backtrack_chopper');
    chopper = BacktrackChopper('backtrack_path', 'backtrack_chopper', 'backtrack_path', "", 'backtrack_camera', "14_Vandenberg_Sub", 'InterpolationPoint39', "", vectm(507, -2500, 1600), rotm(0,0,0) );
    chopper.FamiliarName = "Backtrack";
    chopper.UnFamiliarName = "Backtrack";

    c = GetConversation('JockArea51');
    c.bDisplayOnce = false;
}

function Area51FinalAnyEntry()
{
    local DataLinkTrigger dlt;
    local Conversation c;

    foreach AllActors(class'DataLinkTrigger', dlt) {
        if( dlt.datalinkTag != 'DL_Helios_Door1' ) continue;
        dlt.Tag = 'heliosdoorfail';
    }
    c = GetConversation('DL_Helios_Door1');
    c.bDisplayOnce = false;
}

function RemoveChoppers(optional Name ChopperTag)
{
    local BlackHelicopter chopper;
    foreach AllActors(class'BlackHelicopter', chopper) {
        if( ChopperTag == '' || chopper.Tag == ChopperTag ) {
            info("RemoveChoppers("$ChopperTag$") found " $ chopper @ chopper.Tag);
            chopper.Event = '';// in the Decoration class, the Destroy function triggers the Event
            chopper.Destroy();
        }
    }
}

function Vehicles SpawnChopper(Name ChopperTag, Name PathTag, string BindName, vector loc, rotator rot)
{
    local BlackHelicopter chopper;
    local bool bOldCollideWorld;

    bOldCollideWorld = class'BlackHelicopter'.default.bCollideWorld;
    class'BlackHelicopter'.default.bCollideWorld = false;

    chopper = Spawn(class'BlackHelicopter',, ChopperTag, loc, rot );
    chopper.Event = PathTag;
    chopper.BindName = BindName;
    chopper.FamiliarName = "Jock";
    chopper.UnFamiliarName = "Jock";
    chopper.ConBindEvents();

    class'BlackHelicopter'.default.bCollideWorld = bOldCollideWorld;
    info("SpawnChopper("$ChopperTag$", "$PathTag$", "$BindName$", ("$loc$"), ("$rot$") ) spawned "$chopper);
    return chopper;
}

function Vehicles BacktrackChopper(Name event, Name ChopperTag, Name PathTag, string BindName, Name CameraPath, string DestMap, Name DestName, string DestTag, vector loc, rotator rot)
{
    local InterpolateTrigger t;
    local MapExit exit;
    local Vehicles chopper;

    info("BacktrackChopper("$event$", "$ChopperTag$", "$PathTag$", "$BindName$"...)");

    if( event != '' ) {
        t = Spawn(class'InterpolateTrigger',, event, loc);
        t.bTriggerOnceOnly = false;
        t.Event = ChopperTag;
        t.SetCollision(false,false,false);
        info("BacktrackChopper spawned "$t);
    }

    chopper = SpawnChopper(ChopperTag, PathTag, BindName, loc, rot);

    foreach AllActors(class'MapExit', exit, event)
        return chopper;

    exit = Spawn(class'MapExit',, event, loc );
    exit.SetCollision(false,false,false);
    SetDestination(exit, DestMap, DestName, DestTag);
    exit.bPlayTransition = true;
    exit.cameraPathTag = CameraPath;
    info("BacktrackChopper spawned "$exit);
    return chopper;
}

function CreateInterpolationPoints(Name PathTag, vector loc)
{
    local InterpolationPoint p;
    local int i;

    foreach AllActors(class'InterpolationPoint', p, PathTag)
        return;// don't do anything if PathTag already exists

    for(i=0; i<10 ; i++) {
        p = Spawn(class'InterpolationPoint',, PathTag, loc, rotm(0,0,0) );
        p.Position = i;
        p.RateModifier = 2;
        loc.Z += 20*i;

        if( i > 6 ) p.bEndOfPath = true;
    }

    foreach AllActors(class'InterpolationPoint', p, PathTag)
        p.BeginPlay();// find the Prev and Next

    info("CreateInterpolationPoints "$PathTag$" spawned points");
}

function CreateCameraInterpolationPoints(Name oldtag, Name newtag, vector offset)
{
    local InterpolationPoint p, pnew;
    local vector loc;
    local rotator rot;

    foreach AllActors(class'InterpolationPoint', p, newtag)
        return;// don't do anything if newtag already exists

    foreach AllActors(class'InterpolationPoint', p, oldtag) {
        loc = (10+p.Position) * 0.1 * offset;
        loc += p.Location;
        rot = Rotator(p.Location - loc);
        pnew = Spawn(class'InterpolationPoint',, newtag, loc, rot);
        pnew.bEndOfPath = p.bEndOfPath;
        pnew.bSkipNextPath = p.bSkipNextPath;
        pnew.Position = p.Position;
        pnew.RateModifier = p.RateModifier;
    }

    foreach AllActors(class'InterpolationPoint', pnew, newtag)
        pnew.BeginPlay();// find the Prev and Next

    info("CreateCameraInterpolationPoints "$oldtag@newtag$" spawned camera points");
}

function ConversationFrobOnly(Conversation c)
{
    info("ConversationFrobOnly "$c);
    if( c == None ) return;

    c.bInvokeBump = false;
    c.bInvokeSight = false;
    c.bInvokeRadius = false;
}

function SetDestination(NavigationPoint p, string destURL, name dest_actor_name, optional string tag)
{
    local DXREntranceRando entrancerando;
    local DXRMapVariants maps;
    local MapExit m;
    local DynamicTeleporter t;

    l("SetDestination "$p@p.tag@destURL@dest_actor_name@tag);
    maps = DXRMapVariants(dxr.FindModule(class'DXRMapVariants'));
    if(maps != None)
        destURL = maps.VaryURL(destURL);

    m = MapExit(p);
    t = DynamicTeleporter(p);
    if( m != None )
        m.SetDestination(destURL, dest_actor_name, tag);
    else if( t != None )
        t.SetDestination(destURL, dest_actor_name, tag);
    else
        err("SetDestination failed for "$p);

    entrancerando = DXREntranceRando(dxr.FindModule(class'DXREntranceRando'));
    if(entrancerando != None)
        entrancerando.AdjustTeleporter(p);
}
