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

    StartMapSpecificFlags(p, p.flagbase, dxr.flags.settings.starting_map, dxr.localURL);
}

function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local string m;
    p.strStartMap = GetStartMap(self, dxr.flags.settings.starting_map); // this also calls DXRMapVariants.VaryURL()
#ifdef vmd
    if(dxr.flags.settings.starting_map != 0)
        p.CampaignNewGameMap = p.strStartMap;
#endif
}

function PreFirstEntry()
{
    local #var(PlayerPawn) p;
    local string startMapName;
    local ScriptedPawn sp;

    p = player();
    DeusExRootWindow(p.rootWindow).hud.startDisplay.AddMessage("Mission " $ dxr.dxInfo.missionNumber);

    startMapName = _GetStartMap(dxr.flags.settings.starting_map);
    startMapName = Left(startMapName, class'DXRMapVariants'.static.SplitMapName(startMapName));

    if (startMapName ~= dxr.localURL){
        StartMapSpecificFlags(p, p.flagbase, dxr.flags.settings.starting_map, dxr.localURL);
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

static function string _GetStartMap(int start_map_val, optional out string friendlyName, optional out int bShowInMenu)
{
    friendlyName = ""; // clear the out param to protect against reuse by the caller

    if (#defined(allstarts))
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
        case 41:
            friendlyName = "NSF Defection (Streets)";
            return "04_NYC_Street";
        case 42:
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
            friendlyName = "Vandenberg (Inside Command)";
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

static function StartMapSpecificFlags(#var(PlayerPawn) player, FlagBase flagbase, int start_flag, string start_map)
{
    local bool bEmptyNotes;

    bEmptyNotes = player.FirstNote == None;

    switch(start_flag/10) {
        case 4:
            flagbase.SetBool('DL_SeeManderley_Played',true,,-1);
            break;
        case 5:
            if(start_flag > 50) {
                AddNote(player, bEmptyNotes, "Facility exit: 1125.");
                AddNote(player, bEmptyNotes, "Until the grid is fully restored, the detention block door code has been reset to 4089 while _all_ detention cells have been reset to 4679.");
                flagbase.SetBool('DL_NoPaul_Played',true,,6);
                flagbase.SetBool('MS_InventoryRemoved',true,,6);
            }
        case 7:
            flagbase.SetBool('Have_ROM',true,,-1);
            flagbase.SetBool('MeetTracerTong_Played',true,,-1);// do we need FemJC versions for these?
            flagbase.SetBool('TriadCeremony_Played',true,,-1);
            break;
        case 8:
            flagbase.SetBool('KnowsSmugglerPassword',true,,-1);
            flagbase.SetBool('MetSmuggler',true,,-1);
            break;
        case 9:
            flagbase.SetBool('M08WarnedSmuggler',true,,-1);
            flagbase.SetBool('DL_BadNews_Played',true,,-1);
            flagbase.SetBool('HelpSailor',true,,-1);
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            break;
        case 10:
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            break;
        case 11:
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            break;
        case 12:
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            break;
        case 14:
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);//Make sure Sandra spawns at the gas station
            flagbase.SetBool('Heliosborn',true,,-1);//Make sure Daedalus and Icarus have merged
            break;
        case 15:
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!
            break;
    }

    switch(start_flag) {
        case 21:
            flagbase.SetBool('EscapeSuccessful',true,,-1);
            flagbase.SetBool('DL_SubwayComplete_Played',true,,-1);
            flagbase.SetBool('SubTerroristsDead',true,,-1);
            flagbase.SetBool('MS_DL_Played',true,, 3);
            break;

        case 45:
            flagbase.SetBool('PaulInjured_Played',true,,-1);
            flagbase.SetBool('KnowsSmugglerPassword',true,,-1); // Paul ordinarily tells you the password if you don't know it
            flagbase.SetBool('GatesOpen',true,,5);
            break;

        case 75:
        case 71:// anything greater than 70 should get these, even though this isn't an actual value currently
            AddNote(player, bEmptyNotes, "Access code to the Versalife nanotech research wing on Level 2: 55655.  There is a back entrance at the north end of the Canal Road Tunnel, which is just east of the temple.");
            flagbase.SetBool('M07Briefing_Played',true,,-1);// also spawns big spider in MJ12Lab
        case 70://fallthrough
        case 68:
            AddNote(player, bEmptyNotes, "VersaLife elevator code: 6512.");
        case 67://fallthrough
            AddNote(player, bEmptyNotes, "Versalife employee ID: 06288.  Use this to access the VersaLife elevator north of the market.");
            flagbase.SetBool('MeetTracerTong_Played',true,,-1);
            flagbase.SetBool('MeetTracerTong2_Played',true,,-1);
        case 66://fallthrough
            AddNote(player, bEmptyNotes, "Luminous Path door-code: 1997.");
            flagbase.SetBool('QuickLetPlayerIn',true,,-1);
            flagbase.SetBool('QuickConvinced',true,,-1);
        case 65://fallthrough
            flagbase.SetBool('Have_Evidence',true,,-1); // found the DTS, evidence against Maggie Chow
            flagbase.SetBool('DL_Tong_00_Played',true,,7); // disable "Now take the sword to Max Chen" infolink you would have heard already
            flagbase.SetBool('PaidForLuckyMoney',true,,-1);
            break;

        case 115:
            flagbase.SetBool('templar_upload',true,,-1);
            flagbase.SetBool('GuntherHermann_Dead',true,,-1);
            break;

        case 129:
            flagbase.SetBool('GaryHostageBriefing_Played',true,,-1);
            flagbase.SetBool('Heliosborn',true,,-1); //Make sure Daedalus and Icarus have merged
            break;
        case 145:
            flagbase.SetBool('schematic_downloaded',true,,-1); //Make sure the oceanlab UC schematics are downloaded
            break;
    }

    switch(start_map)
    {
        case "11_Paris_Everett":
            //First Toby conversation happened
            flagbase.SetBool('MeetTobyAtanwe_played',true,,-1);
            flagbase.SetBool('FemJCMeetTobyAtanwe_played',true,,-1);
            break;
    }
}

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
        case "KnowYourEnemy":
        case "SimonsAssassination":
            return start_map > 31;

        case "CleanerBot_ClassDead":
        case "AlexCloset":
        case "CommsPit":
        case "BathroomFlags":
        case "ReadJCEmail":
        case "Shannon_Dead":
        case "SlippingHazard":
        case "un_PrezMeadPic_peepedtex":
        case "WaltonConvos":
        case "un_bboard_peepedtex":
        case "UNATCOHandbook":
        case "ManderleyMail":
        case "LetMeIn":
        case "ViewPortraits": // next location is 04_NYC_Bar
            return start_map > 31 && start_map < 36 && end_mission <= 3;// you can do these m03 unatco goals in m04 unatco, but if you start in helibase it's far
        }

    case 4: // Paul and NSFHQ
        switch(bingo_event)
        {
        case "CommsPit":
        case "BathroomFlags":
        case "ReadJCEmail":
        case "Shannon_Dead":
        case "WaltonConvos":
        case "un_PrezMeadPic_peepedtex":
        case "un_bboard_peepedtex":
        case "UNATCOHandbook":
        case "ManderleyMail":
        case "LetMeIn":
        case "AlexCloset":
        case "TrophyHunter":
            return start_map > 41 && end_mission <= 4;
        }
        break;

    case 5: // escape from MJ12 Jail
        switch(bingo_event)
        {
        }
        break;

    case 6: // Hong Kong
        switch(bingo_event)
        {
        // // these two goals can actually be done with the way these starts currently work, but would normally be impossible
        // case "ClubEntryPaid":
        // case "M06JCHasDate":
        //     return start_map > 65;
        }
    case 7: // fallthrough to 2nd half of Hong Kong
        switch(bingo_event)
        {
        case "MaggieCanFly":
        case "PoliceVaultBingo": // TODO: remove once a datacube with the vault code is added
            return start_map > 70;
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
                return start_map < 99 || start_map > 100;
        }
    case 11: // fallthrough to the rest of Paris
        switch(bingo_event)
        {
        case "GuntherHermann_Dead":
            return start_map >= 115;
        case "TrainTracks":
            return start_map > 115;
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
            break;
        case "PaulToTong":
            // This goal is impossible with a 50+ start because he is then always alive
            return start_map>=50 || end_mission < 6;
        case "MetSmuggler":
            return start_map>=80; //Mission 8 and later starts you should already know Smuggler (see StartMapSpecificFlags)
        case "KnowsGuntherKillphrase":
            if (end_mission < 12){
                return True;
            }
            return start_map>=60; //Have to have told Jaime to meet you in Paris in mission 5 to get Gunther's killphrase
        case "FordSchick_Dead":
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
        case "WarehouseEntered":
        case "Antoine_Dead":
        case "Chad_Dead":
        case "paris_hostage_Dead":
        case "Hela_Dead":
        case "Renault_Dead":
        case "lemerchant_Dead":
        case "aimee_Dead":
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
        default:
            return False;
    }

    return False;
}


static function bool BingoGoalPossible(string bingo_event, int start_map, int end_mission)
{
    // TODO: any of the exceptions in GetStartingMissionMask, and will also need to add them to GetMaybeMissionMask
    switch(start_map) {
    case 119:
        switch(bingo_event) {
        case "TobyAtanwe_Dead":
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
        case 1: return 121;
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


static function AddStartingCredits(DXRando dxr, #var(PlayerPawn) p)
{
    local int i;
    for(i=0;i<GetStartMapMission(dxr.flags.settings.starting_map);i++){
        p.Credits += 100 + dxr.rng(100);
    }
}

static function AddStartingAugs(DXRando dxr, #var(PlayerPawn) player)
{
    local int i, startMission, numAugs;

    if (dxr.flags.settings.starting_map !=0 ){
        startMission=GetStartMapMission(dxr.flags.settings.starting_map);
        numAugs = startMission * 0.4;
        class'DXRAugmentations'.static.AddRandomAugs(dxr,player,numAugs);

        for (i=0; i<numAugs; i++){
            if(i%4==0){
                GiveItem( player, class'AugmentationUpgradeCannister' );
            } else {
                class'DXRAugmentations'.static.UpgradeRandomAug(dxr,player);
            }
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
