/////////////////////////////////////////////////////////////////
// DXRStartMap
//   Mostly just to contain some magic number conversions
//
/////////////////////////////////////////////////////////////////

class DXRStartMap extends DXRActorsBase;

function PlayerLogin(#var(PlayerPawn) p)
{
    Super.PlayerLogin(p);

    if (dxr.flags.settings.starting_map == 0) return;

    //Add extra skill points to make available once you enter the game
    AddStartingSkillPoints(dxr,p);

    PreFirstEntryStartMapFixes(p, p.flagbase, dxr.flags.settings.starting_map);
}

function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local string m;
    if(dxr.flags.IsHordeMode()) return;// let horde mode handle it, partly because we don't want to give skillpoints and augs
    p.strStartMap = GetStartMap(self, dxr.flags.settings.starting_map); // this also calls DXRMapVariants.VaryURL()
#ifdef vmd
    if(dxr.flags.settings.starting_map != 0)
        p.CampaignNewGameMap = p.strStartMap;
#endif
}

function PreFirstEntry()
{
    local #var(PlayerPawn) p;
    local ScriptedPawn sp;
    local ElevatorMover eMover;
    local #var(DeusExPrefix)Mover dxMover;
    local Dispatcher disp;
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)OrdersTrigger ot;

    p = player();
    DeusExRootWindow(p.rootWindow).hud.startDisplay.AddMessage("Mission " $ dxr.dxInfo.missionNumber);

    if(IsStartMap()) {
        PreFirstEntryStartMapFixes(p, p.flagbase, dxr.flags.settings.starting_map);
    }

    switch(dxr.localURL) {
    case "02_NYC_BATTERYPARK":
        if(dxr.flags.settings.starting_map > 20) {
            foreach AllActors(class'ScriptedPawn', sp, 'SubTerrorist') {
                sp.Destroy();
            }
            foreach AllActors(class'ScriptedPawn', sp, 'hostageMan') {
                sp.Destroy();
            }
            foreach AllActors(class'ScriptedPawn', sp, 'hostageWoman') {
                sp.Destroy();
            }
        }
        break;

    case "03_NYC_BatteryPark":
        if (dxr.flags.settings.starting_map > 32) {
            RemoveJock('UNATCOChopper');
        }
        break;

    case "04_NYC_STREET":
        if (dxr.flags.settings.starting_map > 42) {
            RemoveJock('EntranceCopter');
        }
        break;

    case "05_NYC_UNATCOMJ12LAB":
        if(dxr.flags.settings.starting_map > 50) {
            foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {
                anna.Destroy();
            }
        }
        break;

    case "06_HONGKONG_TONGBASE":
        if (dxr.flags.settings.starting_map > 66) {
            // set Tong to patrol his control room, which is his correct behavior after talking to him after he deactivates your killswitch
            foreach AllActors(class'#var(prefix)OrdersTrigger', ot, 'TracerWanders') {
                ot.Trigger(self, None);
                break;
            }
        }
        break;

    case "08_NYC_Street":
        if (dxr.flags.settings.starting_map > 80) {
            RemoveJock('EntranceCopter');
        }
        break;

    case "09_NYC_Dockyard":
        if (dxr.flags.settings.starting_map > 90) {
            RemoveJock('EntryCopter');
        }
        break;

    case "10_Paris_Catacombs":
        if (dxr.flags.settings.starting_map > 100) {
            RemoveJock('UN_BlackHeli');
        }
        break;

    case "12_VANDENBERG_CMD":
        if (dxr.flags.settings.starting_map >= 121) {
            RemoveJock('UN_BlackHeli');
            foreach AllActors(class'#var(DeusExPrefix)Mover', dxMover, 'comhqdoor') {
                dxMover.bTriggerOnceOnly = true;
                dxMover.Trigger(self, None);
                break;
            }
            dxr.flagbase.SetBool('DL_TonyScared_Played', true,, 15); // You won't find cover in the comm building.
        }
        break;

    case "12_VANDENBERG_GAS":
        if (!dxr.flags.IsEntranceRando() && dxr.flags.settings.starting_map > 129) {
            dxr.flagbase.SetBool('DL_JockTiffanyDead_Played', true,, 15);
        }
        break;

    case "14_VANDENBERG_SUB":
        if (dxr.flags.settings.starting_map == 141 || dxr.flags.settings.starting_map == 142) {
            foreach AllActors(class'#var(DeusExPrefix)Mover', dxMover, 'Elevator1') {
                dxMover.InterpolateTo(1, 0.0);
                break;
            }
        }
        break;

    case "14_OCEANLAB_LAB":
        if (dxr.flags.settings.starting_map == 142) {
            foreach AllActors(class'ElevatorMover', eMover, 'lift') {
                eMover.InterpolateTo(1, 0.0);
                break;
            }
        }
        break;

    case "15_Area51_Bunker":
        if (dxr.flags.settings.starting_map > 150) {
            foreach AllActors(class'ElevatorMover', eMover, 'elevator_shaft') {
                eMover.InterpolateTo(1, 0.0);
                break;
            }
        }
        if (dxr.flags.settings.starting_map < 151) {
            player().DeleteAllGoals();
        }
        break;

    case "15_Area51_Final":
        if (dxr.flags.settings.starting_map >= 153) {
            foreach AllActors(class'#var(DeusExPrefix)Mover', dxMover) {
                if (dxMover.tag == 'Page_Blastdoors' || dxMover.tag == 'door_pagearea')
                    dxMover.InterpolateTo(1, 0.0);
            }
            foreach AllActors(class'Dispatcher', disp, 'Raid_start') {
                disp.Trigger(self, p);
            }
        }
        break;
    }
}

function PostFirstEntry()
{
    local AllianceTrigger at;
    local #var(prefix)NicoletteDuclare nico;

    if(IsStartMap()) {
        PostFirstEntryStartMapFixes(player(), dxr.flagbase, dxr.flags.settings.starting_map);
    }

    switch(dxr.localURL) {
    case "03_NYC_MOLEPEOPLE":
        if (dxr.flags.settings.starting_map >= 35) {
            foreach AllActors(class'AllianceTrigger', at, 'surrender') {
                at.Trigger(None, None);
                break;
            }
        }
        break;
    case "10_PARIS_METRO":
    case "10_PARIS_CLUB":
        if (dxr.flags.settings.starting_map >= 109) {
            foreach AllActors(class'#var(prefix)NicoletteDuclare', nico) {
                nico.LeaveWorld();
            }
        }
        break;
    }
}

function RemoveJock(name jockTag)
{
    local #var(prefix)BlackHelicopter jock;

    foreach AllActors(class'#var(prefix)BlackHelicopter', jock, jockTag) {
        log("Removing a BlackHelicopter from " $ dxr.localURL $ " with tag '" $ jock.tag $ "'");
        jock.Event='';
        jock.Destroy();
        break;
    }
}

static function int GetStartMapMission(int start_map_val)
{
    local int mission;

    switch(start_map_val)
    {
        case 0:
            mission=1; //Mission 1 start, nothing
            break;
        case 70:
        case 75:
            mission = 6;// 2nd half of hong kong, but really still mission 6
            break;
        case 99:
            mission=10; //Mission 9 graveyard, basically mission 10
            break;
        case 109:
            mission=11; //Mission 10 Chateau, but basically mission 11
            break;
        case 119:
            mission=12; //Mission 11 Everett, but basically mission 12
            break;
        default:
            mission=start_map_val/10;
            break;
    }
    return mission;
}

static simulated function int GetStartingMissionMask(int start_map)
{
    local int mask, i;

    switch(start_map)
    {// these numbers are basically mission number * 10, with some extra for progress within the mission
        case 70:// 2nd half of hong kong, but maybe we should actually give bingo goals the mission 7 mask?
        case 75:
            start_map = 60;
            break;
        case 99:
            //startMap="09_NYC_Graveyard";
            start_map = 100; //Mission 10 onwards (you're at the end of mission 9)
            break;
        case 109:
            //startMap="10_Paris_Chateau";
            start_map = 100; //Mission 10 onwards (but mark most mission 10 goals as impossible, TODO: would this be easier using GetMaybeMissionMask for a whitelist instead of blacklist?)
            break;
        case 119:
            //startMap="11_Paris_Everett";
            start_map = 120;//Mission 12 onwards
            break;
    }

    mask = 0xFFFF;
    for(i=0; i < (start_map/10); i++) {
        mask -= (1<<i);
    }
    return mask;
}

static simulated function int GetMaybeMissionMask(int start_map)
{// TODO: maybe add some half-missions? like 35 could get some stuff from M04 unatco
    switch(start_map)
    {// these numbers are basically mission number * 10, with some extra for progress within the mission
        case 119:
            //startMap="11_Paris_Everett";
            return 1 << 11; //maybe Mission 11, for Everett's stuff
    }
    return 0;
}

//This could certainly be done a much more clever way, but this is literally good enough
static simulated function int GetEndMissionMask(int end_mission)
{
    switch(end_mission){
        case 1:
            return 2;
        case 2:
            return 6;
        case 3:
            return 14;
        case 4:
            return 30;
        case 5:
            return 62;
        case 6:
            return 126;
        case 7://Doesn't exist, fall down to 8
        case 8:
            return 382;
        case 9:
            return 894;
        case 10:
            return 1918;
        case 11:
            return 3966;
        case 12:
            return 8062;
        case 13: //Doesn't exist, fall down to 14
        case 14:
            return 24446;
        case 15:
            return 57214;
    }
    return 57214;
}

static function string GetStartingMapName(int val)
{
    local string friendlyName;
    local int bShowInMenu;
    _GetStartMap(val, friendlyName, bShowInMenu);
    if(bShowInMenu == 0) return "";
    return friendlyName;
}

static function string GetStartingMapNameCredits(int val)
{
    local string friendlyName, map;
    map = _GetStartMap(val, friendlyName);
    if(friendlyName != "") return friendlyName;
    return "UNKNOWN STARTING MAP "$val$"! " $ map;
}

static function string GetStartMap(Actor a, int start_map_val)
{
    local string startMap, friendlyName;
    local DXRMapVariants mapvariants;

    startMap = _GetStartMap(start_map_val, friendlyName);

    foreach a.AllActors(class'DXRMapVariants', mapvariants) {
        startMap = mapvariants.VaryURL(startMap);
        break;
    }

    return startMap;
}

static function int GetEndMission(int starting_map, int bingo_duration)
{
    local int starting_mission, end_mission;

    starting_mission = GetStartMapMission(starting_map);
    if (bingo_duration!=0){
        end_mission = starting_mission + bingo_duration - 1; //The same mission is the first mission

        //Missions 7 and 13 don't exist, so don't count them
        if (starting_mission<7 && end_mission>=7){
            end_mission+=1;
        }
        if (starting_mission<13 && end_mission>=13){
            end_mission+=1;
        }
        if(end_mission > 15) end_mission = 15;
    } else {
        end_mission = 15;
    }

    return end_mission;
}

static function bool _IsStartMap(DXRando dxr)
{
    local string startMapName;

    startMapName = _GetStartMap(dxr.flags.settings.starting_map);
    startMapName = Left(startMapName, class'DXRMapVariants'.static.SplitMapName(startMapName));

    return startMapName ~= dxr.localURL;
}

function bool IsStartMap()
{
    return _IsStartMap(dxr);
}

//#region _GetStartMap
static function string _GetStartMap(int start_map_val, optional out string friendlyName, optional out int bShowInMenu)
{
    friendlyName = ""; // clear the out param to protect against reuse by the caller

    if (#bool(allstarts))
        bShowInMenu=1;
    switch(start_map_val)
    {
        case 0:
            bShowInMenu=1;
        case 10: // fall through
            friendlyName = "Liberty Island";
            return "01_NYC_UNATCOIsland";
        case 20:
            bShowInMenu=1;
            friendlyName = "NSF Generator (Battery Park)";
            return "02_NYC_BatteryPark";
        case 21:
            bShowInMenu=1;
            friendlyName = "NSF Generator (Streets)";
            return "02_NYC_Street";
        case 30:
            bShowInMenu=1;
            friendlyName = "Hunting Lebedev (Liberty Island)";
            return "03_NYC_UNATCOIsland";
        case 31:
            friendlyName = "Hunting Lebedev (UNATCO HQ)";
            return "03_NYC_UNATCOHQ";
        case 32:
            friendlyName = "Hunting Lebedev (Battery Park)";
            return "03_NYC_BatteryPark";
        case 33:
            friendlyName = "Hunting Lebedev (Brooklyn Bridge Station)";
            return "03_NYC_BrooklynBridgeStation";
        case 34:
            friendlyName = "Hunting Lebedev (Mole People)";
            return "03_NYC_MolePeople";
        case 35:
            friendlyName = "Hunting Lebedev (Helibase)";
            return "03_NYC_AirfieldHeliBase";
        case 36:
            friendlyName = "Hunting Lebedev (Airfield)";
            return "03_NYC_Airfield";
        case 37:
            friendlyName = "Hunting Lebedev (Hangar)";
            return "03_NYC_Hangar";
        case 40:
            friendlyName = "NSF Defection (Liberty Island)";
            return "04_NYC_UNATCOISLAND";
        case 41:
            bShowInMenu=1;
            friendlyName = "NSF Defection (UNATCO HQ)";
            return "04_NYC_UNATCOHQ";
        case 42:
            friendlyName = "NSF Defection (Streets)";
            return "04_NYC_Street";
        case 43:
            friendlyName = "NSF Defection (Hotel)";
            return "04_NYC_Hotel";
        case 45:
            friendlyName = "NSF Defection (NSF HQ)";
            return "04_NYC_NSFHQ";
        case 50:
            bShowInMenu=1;
            friendlyName = "MJ12 Jail";
            return "05_NYC_UNATCOMJ12lab";
        case 55:
            friendlyName = "Escaping UNATCO HQ";
            return "05_NYC_UNATCOHQ#UN_med";
        case 60:
            friendlyName = "Hong Kong (Helibase)";
            return "06_HongKong_Helibase";
        case 61:
            bShowInMenu=1;
            friendlyName = "Hong Kong (Market)";
            return "06_HongKong_WanChai_Market#cargoup";// OH it's not "car goup", it's "cargo up"!
        case 62:
            friendlyName = "Hong Kong (Canals)";
            return "06_HongKong_WanChai_Canal";
        case 63:
            friendlyName = "Hong Kong (Tonnochi Road)";
            return "06_HongKong_WanChai_Street";
        case 64:
            friendlyName = "Hong Kong (Canal Road)";
            return "06_HongKong_WanChai_Garage";
        case 65:// start here with Have_Evidence
            friendlyName = "Hong Kong (Lucky Money)";
            return "06_HongKong_WanChai_Underworld";
        case 66:
            friendlyName = "Hong Kong (Tong's Base)";
            return "06_HongKong_TongBase";
        case 67:
            friendlyName = "Hong Kong (Versalife Office)";
            return "06_HongKong_VersaLife";
        case 68:
            friendlyName = "Hong Kong (Level 1 Labs)";
            return "06_HongKong_MJ12lab";
        case 70:// after versalife 1
            friendlyName = "Hong Kong (Tong's Base after Versalife)";
            return "06_HongKong_TongBase";
        case 75:
            friendlyName = "Hong Kong (Level 2 Labs)";
            return "06_HongKong_Storage";
        case 80:
            friendlyName = "Return to NYC (Streets)";
            return "08_NYC_Street";
        case 81:
            bShowInMenu=1;
            friendlyName = "Return to NYC (Smuggler)";
            return "08_NYC_Smug#ToSmugFrontDoor";
        case 82:
            friendlyName = "Return to NYC (Sewers)";
            return "08_NYC_Underground";
        case 83:
            friendlyName = "Return to NYC (Bar)";
            return "08_NYC_Bar";
        case 84:
            friendlyName = "Return to NYC (Free Clinic)";
            return "08_NYC_FreeClinic";
        case 85:
            friendlyName = "Return to NYC (Hotel)";
            return "08_NYC_Hotel";
        case 90:
            bShowInMenu=1;
            friendlyName = "Superfreighter (Dockyard)";
            return "09_NYC_Dockyard";
        case 91:
            friendlyName = "Superfreighter (Ventilation System)";
            return "09_NYC_ShipFan";
        case 92:
            friendlyName = "Superfreighter (Upper Decks)";
            return "09_NYC_Ship";
        case 95:
            friendlyName = "Superfreighter (Lower Decks)";
            return "09_NYC_ShipBelow";
        case 99:
            bShowInMenu=1;
            friendlyName = "Graveyard";
            return "09_NYC_Graveyard";
        case 100:
            friendlyName = "Paris (Denfert-Rochereau)";
            return "10_Paris_Catacombs";
        case 101:
            friendlyName = "Paris (Catacombs)";
            return "10_Paris_Catacombs_Tunnels";
        case 105:
            friendlyName = "Paris (Streets)";
            return "10_Paris_Metro";
        case 106:
            friendlyName = "Paris (Club)";
            return "10_Paris_Club";
        case 109:
            bShowInMenu=1;
            friendlyName = "Chateau DuClare";
            return "10_Paris_Chateau";
        case 110:
            friendlyName = "Cathedral";
            return "11_Paris_Cathedral";
        case 115:// maybe with the cathedral already completed and gunther dead
            friendlyName = "Paris Metro Station";
            return "11_Paris_Underground";
        case 119:
            bShowInMenu=1;
            friendlyName = "Everett's House";
            return "11_Paris_Everett";
        case 120:
            friendlyName = "Vandenberg (Command)";
            return "12_Vandenberg_Cmd";
        case 121:
            friendlyName = "Vandenberg (Inside Commsat)";
            return "12_Vandenberg_Cmd#commstat";
        case 122:
            friendlyName = "Vandenberg (Tunnels)";
            return "12_Vandenberg_Tunnels";
        case 125:
            friendlyName = "Vandenberg (Computer)";
            return "12_Vandenberg_Computer";
        case 129:
            friendlyName = "Gas Station";
            return "12_Vandenberg_Gas";// give it your best shot
        case 140:
            bShowInMenu=1;
            friendlyName = "Ocean Lab (Sub Base)";
            return "14_Vandenberg_Sub";
        case 141:
            friendlyName = "Ocean Lab (Main Lab)";
            return "14_OceanLab_Lab";
        case 142:
            friendlyName = "Ocean Lab (UC)";
            return "14_OceanLab_UC";
        case 145:
            friendlyName = "Silo";
            return "14_Oceanlab_Silo";
        case 150:
            bShowInMenu=1;
            friendlyName = "Area 51 (Exterior)";
            return "15_Area51_Bunker";
        case 151:
            friendlyName = "Area 51 (Sector 2)";
            return "15_Area51_Entrance";
        case 152:
            friendlyName = "Area 51 (Sector 3)";
            return "15_Area51_Final";
        case 153:
            friendlyName = "Area 51 (Sector 4)";
            return "15_Area51_Page";
        default:
            //There's always a place for you on Liberty Island
            bShowInMenu=0; // just in case
            //friendlyName = "Unknown Start Map "$start_map_val;
            return "01_NYC_UNATCOIsland";
    }
}

static function int GetStartMapSkillBonus(int start_map_val)
{
    local int skillBonus, mission;
    skillBonus = 1200;

    mission = GetStartMapMission(start_map_val);

    return skillBonus * (mission-1);
}

static function AddNote(#var(PlayerPawn) player, bool bEmptyNotes, string text)
{
    if(bEmptyNotes) {
        player.AddNote(text);
    }
}

function DeusExNote AddNoteFromConv(#var(PlayerPawn) player, bool bEmptyNotes, name convname, optional int which)
{
    local Conversation con;
    local ConEvent ce;
    local ConEventAddNote cean;
    local DeusExNote note;

    if (bEmptyNotes == false) {
        return None;
    }

    con = GetConversation(convname);

    // passing a negative value for `which` adds all notes, and returns None
    for (ce = con.eventList; ce != None; ce = ce.nextEvent) {
        cean = ConEventAddNote(ce);
        if (cean != None) {
            if (which <= 0) {
                note = player.Addnote(cean.noteText);
                if (which == 0) {
                    return note;
                }
            }
            which--;
        }
    }
    return None;
}

//#region PreFirstEntryStartMapFixes
function PreFirstEntryStartMapFixes(#var(PlayerPawn) player, FlagBase flagbase, int start_flag)
{
    local bool bEmptyNotes, bFemale;
    local name blockerFlag;

    bEmptyNotes = player.FirstNote == None;
    bFemale = flagbase.GetBool('LDDPJCIsFemale');

    switch(start_flag/10) {
        case 4:
            MarkConvPlayed("DL_SeeManderley", bFemale);
            break;
        case 5:
            flagbase.SetBool('KnowsSmugglerPassword',true,,-1);
            break;
        case 6:
            flagbase.SetBool('KnowsSmugglerPassword',true,,-1);
            break;
        case 7:
            flagbase.SetBool('Have_ROM',true,,-1);
            MarkConvPlayed("MeetTracerTong", bFemale);// do we need FemJC versions for these?
            MarkConvPlayed("TriadCeremony", bFemale);
            flagbase.SetBool('DragonHeadsInLuckyMoney', true);
            flagbase.SetBool('KnowsSmugglerPassword',true,,-1);
            break;
        case 8:
            flagbase.SetBool('KnowsSmugglerPassword',true,,-1);
            break;
        case 9:
            GiveImage(player, class'Image09_NYC_Ship_Bottom');
            GiveImage(player, class'Image09_NYC_Ship_Top');
            flagbase.SetBool('M08WarnedSmuggler',true,,-1);
            MarkConvPlayed("DL_BadNews", bFemale);
            flagbase.SetBool('HelpSailor',true,,-1);
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            break;
        case 10:
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            break;
        case 11:
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            class'DXRBingoCampaign'.static.GetBingoMissionBlockerFlags(10, blockerFlag);
            flagbase.SetBool(blockerFlag, true,, 12);
            break;
        case 12:
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            break;
        case 14:
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            flagbase.SetBool('Heliosborn',true,,-1);//Make sure Daedalus and Icarus have merged
            class'DXRBingoCampaign'.static.GetBingoMissionBlockerFlags(12, blockerFlag);
            flagbase.SetBool(blockerFlag, true,, 15);
            break;
        case 15:
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!
            break;
    }

    switch(start_flag) {
        case 21:
            flagbase.SetBool('EscapeSuccessful',true,,-1);
            MarkConvPlayed("DL_SubwayComplete", bFemale);
            flagbase.SetBool('SubTerroristsDead',true,,-1);
            MarkConvPlayed("MS_DL", bFemale);
            GiveImage(player, class'Image02_Ambrosia_Flyer');
            break;

        case 37:
            GiveImage(player, class'Image03_NYC_Airfield');
            MarkConvPlayed("DL_LebedevKill", bFemale);
        case 36: // fallthrough
            GiveKey(player, 'Sewerdoor', "Sewer Door");
        case 35: // fallthrough
            GiveKey(player, 'MoleRestroomKey', "Molepeople Bathroom Key");
            MarkConvPlayed("M03MeetTerroristLeader", bFemale);
        case 34: // fallthrough
        case 33:
            AddNoteFromConv(player, bEmptyNotes, 'MeetCurly', 0); // 6653 -- Code to the phone-booth entrance
            MarkConvPlayed("dl_batterypark", bFemale); // We're dropping you off in Battery Park
            break;
        case 31:
            MarkConvPlayed("DL_WelcomeBack", bFemale);
            break;

        case 45:
            flagbase.SetBool('KnowsSmugglerPassword',true,,-1); // Paul ordinarily tells you the password if you don't know it
            flagbase.SetBool('GatesOpen',true,,5);
            MarkConvPlayed("PaulInjured", bFemale);
            GiveImage(player, class'Image04_NSFHeadquarters');
            AddNoteFromConv(player, bEmptyNotes, 'PaulInjured');
        case 43: // fallthrough
            MarkConvPlayed("DL_JockParkStart", bFemale);
            break;

        case 55:
            AddNoteFromConv(player, bEmptyNotes, 'PaulInMedLab', 0); // Anna Navarre's killphrase is stored in two pieces on two computers
            AddNoteFromConv(player, bEmptyNotes, 'DL_paul', 0); // Facility exit: 1125
            MarkConvPlayed("DL_NoPaul", bFemale);
            MarkConvPlayed("PaulInMedLab", bFemale);
            MarkConvPlayed("DL_Paul", bFemale);
            flagbase.SetBool('MS_InventoryRemoved',true,,6);
            break;

        case 75:// anything greater than 70 should get these, even though this isn't an actual value currently
            AddNoteFromConv(player, bEmptyNotes, 'M07Briefing'); // Access code to the Versalife nanotech research wing on Level 2: 55655
            MarkConvPlayed("M07Briefing", bFemale);// also spawns big spider in MJ12Lab
        case 70://fallthrough
            flagbase.SetBool('Disgruntled_Guy_Dead', true);
            MarkConvPlayed("Meet_MJ12Lab_Supervisor", bFemale);
        case 68://fallthrough
            AddNoteFromConv(player, bEmptyNotes, 'M06SupervisorConvos', 0); // VersaLife elevator code: 6512
        case 67://fallthrough
            AddNoteFromConv(player, bEmptyNotes, 'MeetTracerTong2', -1); // VersaLife employee ID: 06288
            MarkConvPlayed("MeetTracerTong", bFemale);
            MarkConvPlayed("MeetTracerTong2", bFemale);
            flagbase.SetBool('KillswitchFixed',true,,-1);
        case 66://fallthrough
            AddNoteFromConv(player, bEmptyNotes, 'Gate_Guard2', 1); // Luminous Path door-code: 1997
            flagbase.SetBool('MaxChenConvinced',true,,-1);
            flagbase.SetBool('QuickLetPlayerIn',true,,-1);
            flagbase.SetBool('QuickConvinced',true,,-1);
            MarkConvPlayed("Gate_Guard2", bFemale);
            MarkConvPlayed("MeetMaxChen", bFemale);
            MarkConvPlayed("DL_Jock_05", bFemale); // Okay, you need to find Tracer Tong
            MarkConvPlayed("DL_Jock_04", bFemale); // You're next to the compound Paul used to visit
            MarkConvPlayed("DL_Tong_00", bFemale); // disable "Now take the sword to Max Chen" infolink you would have heard already, start 65 plays this
        case 65://fallthrough
            flagbase.SetBool('Have_Evidence',true,,-1); // found the DTS, evidence against Maggie Chow
            flagbase.SetBool('PaidForLuckyMoney',true,,-1);
        case 64:// fallthroughs
        case 63:
        case 62:
        case 61:
            MarkConvPlayed("DL_Jock_01", bFemale); // I blew it, JC, I'm sorry.  MJ12 must want you bad
            MarkConvPlayed("DL_Jock_02", bFemale); // Come on down and stay clear of the blast doors to the south
            MarkConvPlayed("DL_Jock_03", bFemale); // I have to get clear!  Head for the exit, and I'll link up with you when I can.
            break;

        case 81:
            flagbase.setBool('DXRSmugglerElevatorUsed', true,, 9); // else the elevator will move to the top and bring the player with it
            flagbase.SetBool('MetSmuggler',true,,-1);
            break;

        case 95:
            GiveKey(player, 'EngineRoomDoor', "Below Decks key");
            MarkConvPlayed("DL_ShipEntry", bFemale); // find a way to get below decks
            break;

        case 119:
            // don't do the conversation from 11_Paris_Underground
            MarkConvPlayed("MeetTobyAtanwe",bFemale);

            //Make sure, if you backtrack, Toby is set up to be there and ready to take you back
            dxr.flagbase.SetBool('MS_LetTobyTakeYou_Rando',false,,-1);
            dxr.flagbase.SetBool('MS_PlayerTeleported',true,,-1);

        case 115:
            flagbase.SetBool('templar_upload',true,,-1);
            flagbase.SetBool('GuntherHermann_Dead',true,,-1);
            GiveKey(player, 'cathedralgatekey', "Gatekeeper's Key");
            GiveImage(player, class'Image11_Paris_Cathedral');
            GiveImage(player, class'Image11_Paris_CathedralEntrance');
            MarkConvPlayed("DL_intro_cathedral", bFemale);
        case 109:
            GiveImage(player, class'Image10_Paris_Metro');
        case 106:
        case 105:
            GiveImage(player, class'Image10_Paris_CatacombsTunnels');
            GiveKey(player, 'catacombs_blastdoor', "Blast Door Key");
            GiveKey(player, 'catacombs_blastdoor02', "Catacombs Sewer Entry Key");
            break;

        case 145:
            flagbase.SetBool('schematic_downloaded',true,,-1); //Make sure the oceanlab UC schematics are downloaded
        case 142: // fallthrough
            GiveKey(player, 'Glab', "Greasel Laboratory Key");
            GiveKey(player, 'crewkey', "Crew Module Access");
        case 141: // fallthrough
            MarkConvPlayed("DL_Underwater", bFemale); // The URV bay is in this module.  You might not hear from me again.
        case 140: // fallthrough
            flagbase.SetBool('TiffanySavage_Dead',true,,15);
        // FALLTHROUGH from mission 14 to 12
        case 129:
            MarkConvPlayed("GaryHostageBriefing", bFemale);
            flagbase.SetBool('Heliosborn',true,,-1); //Make sure Daedalus and Icarus have merged
        case 125: // fallthrough
            GiveKey(player, 'control_room', "Control Room Key");
        case 122: // fallthrough
            AddNoteFromConv(player, bEmptyNotes, 'MeetTonyMares', 0); // Gary savage is thought to be in the control room
        case 121: // fallthrough
            AddNoteFromConv(player, bEmptyNotes, 'MeetCarlaBrown', 0); // Backup power for the bot security system
            MarkConvPlayed("DL_no_carla", bFemale);
            break;

        case 153:
            MarkConvPlayed("DL_Helios_Door1", bFemale);         // Not yet.  No... I will not allow you to enter Sector 4 until you have received my instructions.
            MarkConvPlayed("DL_Helios_Intro", bFemale);         // I will now explain why you have been allowed to reach Sector 3.
            MarkConvPlayed("DL_Final_Page03", bFemale);         // Don't get your hopes up; my compound is quite secure.
            flagbase.SetBool('MS_PaulOrGaryAppeared',true,,-1); // It let me through... I can't believe it.
            MarkConvPlayed("MeetHelios", bFemale);              // You will go to Sector 4 and deactivate the uplink locks, yes.
            flagbase.SetBool('MS_TongAppeared',true,,-1);       // We can get you into Sector 3 -- but no further.
            GiveImage(player, class'Image15_Area51_Sector3');
        case 152: // fallthrough
            MarkConvPlayed("DL_Final_Page02", bFemale);         // Barely a scratch.
            MarkConvPlayed("DL_elevator", bFemale);             // Bet you didn't know your mom and dad tried to protest when we put you in training.
            MarkConvPlayed("DL_conveyor_room", bFemale);        // Page is further down.  Find the elevator.
            // MarkConvPlayed("M15MeetEverett", bFemale);          // Not far.  You will reach Page. I just wanted to let you know that Alex hacked the Sector 2 security grid
            flagbase.SetBool('MS_EverettAppeared',true,,-1);
            AddNoteFromConv(player, bEmptyNotes, 'M15MeetEverett', 0); // Crew-complex security code: 8946; TODO: figure out why Everett refuses to appear for this conversation on later starts
        case 151: // fallthrough
            MarkConvPlayed("DL_tong1", bFemale);                // Here's a satellite image of the damage from the missile.
            MarkConvPlayed("DL_tong_reached_bunker", bFemale);  // Good work.  You've reached the bunker.
            MarkConvPlayed("DL_JockDeathTongComment", bFemale); // I don't believe it!  JC!  We lost Jock!
            MarkConvPlayed("DL_JockDeath", bFemale);            // JC!  Got a problem.  Someone planted a bo-----
            MarkConvPlayed("DL_Bunker_Start", bFemale);         // Just spotted a sniper in the tower.
            MarkConvPlayed("DL_Bunker_PowerRoom", bFemale);     // You're nearing the power room.
            MarkConvPlayed("DL_Bunker_Power", bFemale);         // The elevator power is online.
            MarkConvPlayed("DL_Bunker_Hangar", bFemale);        // I saw some soldiers running away from the hangar.
            // MarkConvPlayed("DL_Bunker_Fan", bFemale);        // Jump!  You can make it!
            MarkConvPlayed("DL_Bunker_Elevator", bFemale);      // The power to the elevator is down.
            MarkConvPlayed("DL_Bunker_blastdoor", bFemale);     // The schematics show an elevator to the west, but utility power is down.
            MarkConvPlayed("DL_blastdoor_shut", bFemale);       // These blast doors are the reason I don't have to worry about nukes -- or you.
            GiveImage(player, class'Image15_Area51Bunker');
            break;
    }
}

function SkillAwardCrate SpawnSkillAwardCrate(#var(PlayerPawn) player)
{
    local SkillAwardCrate crate;
    local int credits;

    crate = SkillAwardCrate(SpawnInFrontOnFloor(
        player,
        class'SkillAwardCrate',
        80.0,
        MakeRotator(0, (2047 - rng(4095)), 0)
    ));

    if (crate == None) {
        return None;
    }

    if (dxr.flags.newgameplus_loops == 0) {
        crate.ItemName = "Later Start Supply Crate";
        crate.SkillAwardMessage = "Mission " $ dxr.dxInfo.missionNumber $ " Later Start Bonus";
    } else  {
        crate.ItemName = "New Game Plus Supply Crate";
        crate.SkillAwardMessage = "Mission " $ dxr.dxInfo.missionNumber $ " New Game Plus Bonus";
    }

    crate.Skin = Texture'WaltonWareCrate';

    credits = GetStartMapCreditsBonus(dxr);
    if (credits > 0) {
        crate.AddContent(class'Credits', credits);
    }
    crate.AddContent(class'BioelectricCell', 1);
    crate.NumSkillPoints = GetStartMapSkillBonus(dxr.flags.settings.starting_map);

    return crate;
}

function SkillAwardCrate SpawnWaltonWareCrate(#var(PlayerPawn) player)
{
    local SkillAwardCrate crate;

    crate = SpawnSkillAwardCrate(player);

    if (crate != None) {
        crate.ItemName = "Walton's Care Package";
        crate.SkillAwardMessage = "Mission " $ dxr.dxInfo.missionNumber $ " New Loop Bonus";
    }

    return crate;
}

//#region PostFirstEntryStartMapFixes
function PostFirstEntryStartMapFixes(#var(PlayerPawn) player, FlagBase flagbase, int start_flag)
{
    local DeusExGoal goal;
    local SkillAwardCrate crate;

    if (dxr.flags.IsWaltonWare()) {
        crate = SpawnWaltonWareCrate(player);
    } else if (dxr.flags.settings.starting_map > 10 || dxr.flags.newgameplus_loops > 0) {
        crate = SpawnSkillAwardCrate(player);
    } else {
        AddStartingCredits(dxr, player);
        AddStartingSkillPoints(dxr, player);
    }
    AddStartingAugs(dxr, player, crate);

    switch(start_flag) {
        case 21:
            AddGoalFromConv(player, 'ReportToPaul', 'DL_SubwayComplete');
            break;

        case 31:
            AddGoalFromConv(player, 'ReportToManderley', 'DL_WelcomeBack');
            break;
        case 32:
        case 33:
        case 34:
        case 35:
            AddGoalFromConv(player, 'LocateAirfield', 'ManderleyDebriefing02');
            break;
        case 36:
            player.StartDataLinkTransmission("DL_LebedevKill");
            break;
        case 37:
            AddGoalFromConv(player, 'AssassinateLebedev', 'DL_LebedevKill');
            break;

        case 45:
            AddGoalFromConv(player, 'InvestigateNSF', 'PaulInjured');
            break;
        case 43:
            player.StartDataLinkTransmission("DL_JockParkStart");
            break;
        case 41:
            AddGoalFromConv(player, 'SeeManderley', 'DL_SeeManderley');
            break;

        case 55:
            AddGoalFromConv(player, 'FindEquipment', 'DL_Choice');
            AddGoalFromConv(player, 'FindAnnasKillprhase', 'PaulInMedLab');
            break;

        case 75:
            AddGoalFromConv(player, 'GetVirusSchematic', 'M07Briefing');
            AddGoalFromConv(player, 'HaveDrinksWithDragonHeads', 'TriadCeremony');
            break;
        case 70:
            AddGoalFromConv(player, 'ReportToTong', 'TriadCeremony');
            AddGoalFromConv(player, 'HaveDrinksWithDragonHeads', 'TriadCeremony');
            break;
        case 68:
        case 67:
            AddGoalFromConv(player, 'GetROM', 'MeetTracerTong2');
            break;
        case 66:
            AddGoalFromConv(player, 'FindTracerTong', 'DL_Jock_05');
            break;
        case 65:
            AddGoalFromConv(player, 'FindTracerTong', 'DL_Jock_05');
            AddGoalFromConv(player, 'CheckCompound', 'DL_Jock_05');
            player.StartDataLinkTransmission("DL_Tong_00"); // Good.  Now take the sword to Max Chen at the Lucky Money Club.
            break;
        case 64:
        case 63:
        case 62:
            player.StartDataLinkTransmission("DL_Jock_05");
            break;

        case 90:
        case 91:
        case 92:
        case 95:
            // the conversation that gives you this goal is in M08, and it says "PCS" instead of "PRCS"
            if (player.FindGoal('ScuttleShip') == None) {
                goal = player.AddGoal('ScuttleShip', true);
                goal.SetText("Scuttle the PRCS Wall Cloud by destroying the 5 tri-hull welds with explosives and by reversing the bilge-pump flow.  Pumping water into the bilges will destabilize the ship's weight distribution and cause the hull to split open.");
            }
            break;

        case 101:
            AddGoalFromConv(player, 'FindSilhouette', 'DL_paris_10_start');
            AddGoalFromConv(player, 'ContactIlluminati', 'DL_paris_10_start');
            break;
        case 105:
        case 106:
            AddGoalFromConv(player, 'ContactIlluminati', 'DL_paris_10_start');
            AddGoalFromConv(player, 'FindNicolette', 'DL_tunnels_down');
            break;
        case 109:
            AddGoalFromConv(player, 'ContactIlluminati', 'DL_paris_10_start');
            AddGoalFromConv(player, 'FindEverett', 'NicoletteOutside');
            break;

        case 119:
            goal = player.AddGoal('ContactIlluminati', true);
            goal.SetText("Make contact with the Illuminati in Paris, where the former Illuminati leader, Morgan Everett, is rumored to be in hiding.");
            break;
        case 115:
            goal = player.AddGoal('ContactIlluminati', true);
            goal.SetText("Make contact with the Illuminati in Paris, where the former Illuminati leader, Morgan Everett, is rumored to be in hiding.");
            AddGoalFromConv(player, 'GoToMetroStation', 'DL_morgan_uplink');
            AddGoalFromConv(player, 'RecoverGold', 'DL_intro_cathedral');
            break;
        case 110:
            goal = player.AddGoal('ContactIlluminati', true);
            goal.SetText("Make contact with the Illuminati in Paris, where the former Illuminati leader, Morgan Everett, is rumored to be in hiding.");
            goal = player.AddGoal('AccessTemplarComputer', true);
            goal.SetText("Access the Templar computer system so that Morgan Everett can complete work on a cure for the Gray Death.");
            break;

        case 129:
            AddGoalFromConv(player, 'RescueTiffany', 'GaryHostageBriefing');
            break;
        case 125:
        case 122:
            AddGoalFromConv(player, 'FindGarySavage', 'MeetTonyMares');
            break;
        case 121:
            AddGoalFromConv(player, 'GoToCommunicationsCenter', 'DL_command_bots_destroyed');
            break;

        case 153:
            AddGoalFromConv(player, 'DestroyArea51', 'M15MeetTong');
            AddGoalFromConv(player, 'DeactivateLocks', 'MeetHelios');
        case 152: // fallthrough
            AddGoalFromConv(player, 'KillPage', 'M15MeetEverett');
            break;
    }
}

//#region BingoGoalImpossible
static function bool BingoGoalImpossible(string bingo_event, int start_map, int end_mission)
{// TODO: probably mid-mission starts for M03 and M04 need to exclude some unatco goals, some hong kong starts might need exclusions too
    switch(start_map/10)
    {
    case 1: // Liberty Island
        switch(bingo_event)
        {
        }
        break;

    case 2: // NSF Generator
        switch(bingo_event)
        {
        case "SubwayHostagesSaved":
            return start_map > 20;
        }
        break;

    case 3: // Airfield
        switch(bingo_event)
        {
        case "SimonsAssassination":
        case "MeetInjuredTrooper2_Played":
            return start_map > 31;

        case "surrender": //We make the mole people NSF pre-surrendered on 35+ starts
            return start_map >=35;

        case "CleanerBot_ClassDead":
        case "AlexCloset":
        case "CommsPit":
        case "BathroomFlags":
        case "ReadJCEmail":
        case "Shannon_PlayerDead":
        case "SlippingHazard":
        case "un_PrezMeadPic_peepedtex":
        case "WaltonConvos":
        case "un_bboard_peepedtex":
        case "UNATCOHandbook":
        case "ManderleyMail":
        case "LetMeIn":
        case "KnowYourEnemy":
        case "ViewPortraits": // next location is 04_NYC_Bar
            return start_map > 31 && start_map < 36 && end_mission <= 3;// you can do these m03 unatco goals in m04 unatco, but if you start in helibase it's far
        }

    case 4: // Paul and NSFHQ
        switch(bingo_event)
        {
        case "CommsPit":
        case "BathroomFlags":
        case "ReadJCEmail":
        case "Shannon_PlayerDead":
        case "WaltonConvos":
        case "un_PrezMeadPic_peepedtex":
        case "un_bboard_peepedtex":
        case "UNATCOHandbook":
        case "ManderleyMail":
        case "LetMeIn":
        case "AlexCloset":
        case "TrophyHunter":
            return start_map > 41 && end_mission <= 4;
        case "KnowYourEnemy":
            return start_map > 41;
        }
        break;

    case 5: // escape from MJ12 Jail
        switch(bingo_event)
        {
        }
        break;

    case 6: // Hong Kong
    case 7:
        switch(bingo_event)
        {
        case "MaggieCanFly":
            return start_map >= 66; // can technically be done still by carrying her body out of VersaLife but it's not really sensible to have as a goal at this point
        case "M06JCHasDate":
        case "ClubEntryPaid":
            return start_map > 65; //Impossible after the raid starts
        }
        break;

    case 8: // return to NYC
        switch(bingo_event)
        {
        }
        break;

    case 9: // Dockyard and Ship
        switch(bingo_event)
        {
        }
        break;

    case 10: // Paris
        switch(bingo_event)
        {
            case "AimeeLeMerchantLived":
                return start_map > 100;
        }
    case 11: // fallthrough to the rest of Paris
        switch(bingo_event)
        {
        case "GuntherHermann_Dead":
            return start_map >= 115;
        case "TrainTracks":
            return start_map > 115;
        case "JockBlewUp":
            return end_mission < 15;
        }
        break;

    case 12: // Vandenberg
        switch(bingo_event)
        {
        }
    case 14: // fallthrough to the rest of Vandenberg
        switch(bingo_event)
        {
        }
        break;

    case 15: // Area 51
        switch(bingo_event)
        {
        }
        break;
    }

    // goals that are spread across many missions, like LeoToTheBar
    // TODO: need to reconsider all of these
    switch(bingo_event)
    {
        case "LeoToTheBar":
            //Only possible if you started in the first level
            return start_map>10 || end_mission < 2;
        case "PaulToTong":
            // This goal is impossible with a 50+ start because he is then always alive
            return start_map>=50 || end_mission < 6;
        case "MetSmuggler":
            return start_map>=80; //Mission 8 and later starts you should already know Smuggler (see PreFirstEntryStartMapFixes)
        case "KnowsGuntherKillphrase":
            if (end_mission < 12){
                return True;
            }
            return start_map>=60; //Have to have told Jaime to meet you in Paris in mission 5 to get Gunther's killphrase
        case "FordSchick_PlayerDead":
            return start_map>=30;
        case "M07MeetJaime_Played":
            if (end_mission < 8){
                return True;
            }
            return start_map>=60; //TODO: Have to have told Jaime to meet you in Hong Kong in mission 5
        case "MaggieLived":// not actually impossible, just really far
            return start_map < 70 && end_mission < 8;
        case "Terrorist_ClassDead":
        case "Terrorist_ClassUnconscious":
        case "Terrorist_peeptime":
            return start_map>=40; //Miguel is the only Terrorist after mission 3 - easier to just block this
        case "Supervisor_Paid":
            return start_map >= 70;
        case "AimeeLeMerchantLived":
            return end_mission < 10;
        case "WarehouseEntered":
        case "Antoine_PlayerDead":
        case "Chad_PlayerDead":
        case "paris_hostage_Dead":
        case "Hela_PlayerDead":
        case "Renault_PlayerDead":
        case "lemerchant_PlayerDead":
        case "aimee_PlayerDead":
        case "M10EnteredBakery":
        case "assassinapartment":
        case "CamilleConvosDone":
        case "SilhouetteHostagesAllRescued":
        case "LouisBerates":
        case "IcarusCalls_Played":
        case "roof_elevator":
        case "MeetRenault_Played":
            return start_map>=110; //early Paris things
        case "ManWhoWasThursday":// TODO: in 10_Paris_Catacombs, and then 12_Vandenberg_Cmd, but nothing in M11
            return start_map >= 110 && end_mission <= 11;
        case "PresentForManderley":
            //Have to be able to get Juan from mission 3 and bring him to the start of mission 4
            if (end_mission < 4){
                return True;
            }
            return start_map>=40;
        case "SmugglerDied":
            if (end_mission < 9){
                return True;
            }
            return start_map>=90;
        case "PhoneCall":
            return start_map>100; //TODO: Last phone is in the building before the catacombs (Where Icarus calls)
        case "JustAFleshWound":
            //This requires removing both arms and legs.  Arms are easy to knock off anywhere with height,
            //but arms are harder to consistently remove.  Flaming barrels are the easiest way I can think
            //of, but missions 5, 9, 14, 15 do not have any (accessible, at least).  Treat the goal as
            //impossible in those missions.
            //Blocking it here rather than via mission mask on the goal itself means it won't show up
            //as impossible in a mission, or be marked as failed as you get towards the end of the game,
            //while still blocking it from showing up in those missions.
            if (start_map>=50 && end_mission<=5) return true;
            if (start_map>=90 && end_mission<=9) return true;
            return (start_map>=140);
        default:
            return False;
    }

    return False;
}

// #region BingoGoalPossible
static function bool BingoGoalPossible(string bingo_event, int start_map, int end_mission)
{
    // TODO: any of the exceptions in GetStartingMissionMask, and will also need to add them to GetMaybeMissionMask
    switch(start_map) {
    case 119:
        switch(bingo_event) {
        case "TobyAtanwe_PlayerDead":
        case "MeetAI4_Played":
        case "DeBeersDead":
        case "GotHelicopterInfo":
        case "EverettAquarium":
        case "GoneFishing":
            return true;
        }
        break;
    }

    return false;
}

static function int SquishMission(int m)
{
    if(m > 12) m--;// remove M13
    if(m > 6) m--;// remove M07
    return m;
}

static function int ChooseRandomStartMap(DXRBase m, int avoidStart)
{
    local int i;
    local int startMap, startMission, avoidMission;
    local int attempts;

    startMap = avoidStart;
    avoidMission = GetStartMapMission(avoidStart);
    avoidMission = SquishMission(avoidMission);
    startMission = avoidMission;
    attempts=0;
    m.SetGlobalSeed("randomstartmap");

    //Don't try forever.  If we manage to grab the avoided map 50 times, it was meant to be.
    //the widest span is Hong Kong: Helipad is 60, Storage is 75, a span of 15
    while (Abs(startMission-avoidMission) <= 1 && attempts < 50){
        startMap = _ChooseRandomStartMap(m);
        startMission = GetStartMapMission(startMap);
        startMission = SquishMission(startMission);
        m.l("Start map selection attempt "$ ++attempts $" was "$startMap);
    }

    return startMap;
}

//#region _ChooseRandomStartMap
static function int _ChooseRandomStartMap(DXRBase m)
{
    local int i;
    i = m.rng(13);

    //Should be able to legitimately return Liberty Island (even if that's as a value of 10), but needs additional special handling
    switch(i)
    {
    case 0:// mission 1
        return 10;
    case 1:// mission 2
        if(m.rngb()) return 21;
        return 20;
    case 2:// mission 3
        i = m.rng(3);
        switch(i) {
        case 0: return 30;
        case 1: return 35;
        case 2: return 37;
        }
        return 30; // just in case the switch misses
    case 3:// mission 4
        if(m.rngb()) return 45;
        return 41;
    case 4:// mission 5
        if(m.rngb()) return 55;
        return 50;
    case 5:// mission 6
        i = m.rng(6);
        switch(i) {
        case 0: return 60;
        case 1: return 61;
        case 2: return 65;
        case 3: return 67;
        case 4: return 70;
        case 5: return 75;
        }
        return 61;
    case 6:// mission 8
        i = m.rng(5);
        switch(i) {
        case 0: return 81;
        case 1: return 82;
        case 2: return 83;
        case 3: return 84;
        case 4: return 85;
        }
        return 81;
    case 7:// mission 9
        i = m.rng(3);
        switch(i) {
        case 0: return 90;
        case 1: return 92;
        case 2: return 95;
        }
        return 90;
    case 8:// mission 10
        i = m.rng(3);
        switch(i) {
        case 0: return 99;
        case 1: return 101;
        case 2: return 106;
        }
        return 99;
    case 9:// mission 11
        if(m.rngb()) return 115;
        return 109;
    case 10:// mission 12
        i = m.rng(3);
        switch(i) {
        case 0: return 119;
        case 1: return 122;
        case 2: return 129;
        }
        return 119;
    case 11:// mission 14
        i = m.rng(4);
        switch(i) {
        case 0: return 140;
        case 1: return 141;
        case 2: return 142;
        case 3: return 145;
        }
        return 140;
    case 12:// mission 15
        i = m.rng(4);
        switch(i) {
        case 0: return 150;
        case 1: return 151;
        case 2: return 152;
        case 3: return 153;
        }
        return 150;
    }
    m.err("Random Starting Map picked value "$i$" which is unhandled!");
    return 0; //Fall back on Liberty Island
}

static function int GetStartMapCreditsBonus(DXRando dxr)
{
    local int startMapMission, numCredits, i;

    startMapMission = GetStartMapMission(dxr.flags.settings.starting_map);
    for(i = 0; i < startMapMission; i++) {
        numCredits += 100 + dxr.rng(100);
    }

    return numCredits;
}

static function AddStartingCredits(DXRando dxr, #var(PlayerPawn) p)
{
    p.Credits += GetStartMapCreditsBonus(dxr);
}

static function int GetStartMapAugBonus(DXRando dxr)
{
    return GetStartMapMission(dxr.flags.settings.starting_map) * 0.4;
}

static function AddStartingAugs(DXRando dxr, #var(PlayerPawn) player, SkillAwardCrate crate)
{
    local int i, numAugs, numUpgrades;

    if (dxr.flags.settings.starting_map !=0 ){
        numAugs = GetStartMapAugBonus(dxr);
        class'DXRAugmentations'.static.AddRandomAugs(dxr,player,numAugs);

        for (i=0; i<numAugs; i++){
            if(i%4==0){
                if(crate != None) numUpgrades++;
                else GiveItem( player, class'#var(prefix)AugmentationUpgradeCannister' );
            } else {
                class'DXRAugmentations'.static.UpgradeRandomAug(dxr,player);
            }
        }

        if(numUpgrades > 0 && crate != None) {
            crate.AddContent(class'#var(prefix)AugmentationUpgradeCannister', numUpgrades);
        }
    }
}

static function AddStartingSkillPoints(DXRando dxr, #var(PlayerPawn) p)
{
    local int startBonus;
    startBonus = GetStartMapSkillBonus(dxr.flags.settings.starting_map);
    log("AddStartingSkillPoints before "$ p.SkillPointsAvail $ ", bonus: "$ startBonus $", after: " $ (p.SkillPointsAvail + startBonus));
    p.SkillPointsAvail += startBonus;
    //Don't add to the total.  It isn't used in the base game, but we use it for scoring.
    //These starting points are free, so don't count them towards your score
    //p.SkillPointsTotal += startBonus;
}
