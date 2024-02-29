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

    foreach AllActors(class'#var(PlayerPawn)',p){break;}

    startMapName = GetStartMap(p,dxr.flags.settings.starting_map);
    startMapName = class'DXRMapVariants'.static.CleanupMapName(startMapName);
    startMapName = Caps(startMapName);

    if (InStr(startMapName,dxr.localURL)!=-1){
        StartMapSpecificFlags(p, p.flagbase, dxr.flags.settings.starting_map, dxr.localURL);
    }

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
    switch(val){
        case 0:
        case 10:
            return "Liberty Island";
        case 20:
            return "NSF Generator";
        case 30:
            return "Hunting Lebedev";
        case 40:
            return "NSF Defection";
        case 50:
            return "MJ12 Jail";
        case 61:
            return "Wan Chai Market";
        case 81:
            return "Return to NYC";
        case 90:
            return "Superfreighter";
        case 99:
            return "Graveyard";
        case 109:
            return "Chateau DuClare";
        case 119:
            return "Everett's House";
        case 140:
            return "Ocean Lab";
        case 150:
            return "Area 51";
        default:
            return "UNKNOWN STARTING MAP "$val$"!";
    }
}

static function string GetStartMap(Actor a, int start_map_val)
{
    local string startMap;
    local DXRMapVariants mapvariants;

    startMap="01_NYC_UNATCOIsland";

    switch(start_map_val)
    {
        case 0:
        case 10:
            startMap="01_NYC_UNATCOIsland";
            break;
        case 20:
            startMap="02_NYC_BatteryPark";
            break;
        case 21:
            startMap="02_NYC_Street";
            break;
        case 30:
            startMap="03_NYC_UNATCOIsland";
            break;
        case 31:
            startMap="03_NYC_UNATCOHQ";
            break;
        case 32:
            startMap="03_NYC_BatteryPark";
            break;
        case 33:
            startMap="03_NYC_BrooklynBridgeStation";
            break;
        case 34:
            startMap="03_NYC_MolePeople";
            break;
        case 35:
            startMap="03_NYC_AirfieldHeliBase";
            break;
        case 36:
            startMap="03_NYC_Airfield";
            break;
        case 37:
            startMap="03_NYC_Hangar";
            break;
        case 40:
            startMap="04_NYC_UNATCOHQ";
            break;
        case 41:
            startMap="04_NYC_Street";
            break;
        case 42:
            startMap="04_NYC_Hotel";
            break;
        case 45:
            startMap="04_NYC_NSFHQ";
            break;
        case 50:
            startMap="05_NYC_UNATCOMJ12lab";
            break;
        case 55:
            startMap="05_NYC_UNATCOHQ#UN_med";
            break;
        case 60:
            startMap="06_HongKong_Helibase";
            break;
        case 61:
            startMap="06_HongKong_WanChai_Market#cargoup";// OH it's not "car goup", it's "cargo up"!
            break;
        case 62:
            startMap="06_HongKong_WanChai_Canal";
            break;
        case 63:
            startMap="06_HongKong_WanChai_Street";
            break;
        case 64:
            startMap="06_HongKong_WanChai_Garage";
            break;
        case 65:// start here with Have_Evidence
            startMap="06_HongKong_WanChai_Underworld";
            break;
        case 66:
            startMap="06_HongKong_TongBase";
            break;
        case 67:
            startMap="06_HongKong_VersaLife";
            break;
        case 68:
            startMap="06_HongKong_MJ12lab";
            break;
        case 70:// after versalife 1
            startMap="06_HongKong_TongBase";
            break;
        case 75:
            startMap="06_HongKong_Storage";
            break;
        case 81:
            startMap="08_NYC_Smug#ToSmugFrontDoor";
            break;
        case 82:
            startMap="08_NYC_Underground";
            break;
        case 83:
            startMap="08_NYC_Bar";
            break;
        case 84:
            startMap="08_NYC_FreeClinic";
            break;
        case 85:
            startMap="08_NYC_Hotel";
            break;
        case 90:
            startMap="09_NYC_Dockyard";
            break;
        case 91:
            startMap="09_NYC_ShipFan";
            break;
        case 92:
            startMap="09_NYC_Ship";
            break;
        case 95:
            startMap="09_NYC_ShipBelow";
            break;
        case 99:
            startMap="09_NYC_Graveyard";
            break;
        case 100:
            startMap="10_Paris_Catacombs";
            break;
        case 101:
            startMap="10_Paris_Catacombs_Tunnels";
            break;
        case 105:
            startMap="10_Paris_Metro";
            break;
        case 106:
            startMap="10_Paris_Club";
            break;
        case 109:
            startMap="10_Paris_Chateau";
            break;
        case 110:
            startMap="11_Paris_Cathedral";
            break;
        case 115:// maybe with the cathedral already completed and gunther dead
            startMap="11_Paris_Underground";
            break;
        case 119:
            startMap="11_Paris_Everett";
            break;
        case 120:
            startMap="12_Vandenberg_Cmd";
            break;
        case 121:
            startMap="12_Vandenberg_Cmd#commstat";
            break;
        case 122:
            startMap="12_Vandenberg_Tunnels";
            break;
        case 125:
            startMap="12_Vandenberg_Computer";
            break;
        case 129:
            startMap="12_Vandenberg_Gas";// give it your best shot
            break;
        case 140:
            startMap="14_Vandenberg_Sub";
            break;
        case 141:
            startMap="14_OceanLab_Lab";
            break;
        case 142:
            startMap="14_OceanLab_UC";
            break;
        case 145:
            startMap="14_Oceanlab_Silo";
            break;
        case 150:
            startMap="15_Area51_Bunker";
            break;
        case 151:
            startMap="15_Area51_Entrance";
            break;
        case 152:
            startMap="15_Area51_Final";
            break;
        case 153:
            startMap="15_Area51_Page";
            break;
        default:
            //There's always a place for you on Liberty Island
            startMap="01_NYC_UNATCOIsland";
            break;
    }

    foreach a.AllActors(class'DXRMapVariants', mapvariants) {
        startMap = mapvariants.VaryURL(startMap);
        break;
    }

    return startMap;
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

static function int GetStartMapSkillBonus(int start_map_val)
{
    local int skillBonus, mission;
    skillBonus = 1200;

    mission = GetStartMapMission(start_map_val);

    return skillBonus * (mission-1);
}

static function StartMapSpecificFlags(#var(PlayerPawn) player, FlagBase flagbase, int start_flag, string start_map)
{
    local DeusExNote note;

    switch(start_flag/10) {
        case 4:
            flagbase.SetBool('DL_SeeManderley_Played',true,,-1);
            break;
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
            break;
        case 15:
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!
            break;
    }

    switch(start_flag) {
        case 45:
            flagbase.SetBool('PaulInjured_Played',true,,-1);
            break;

        case 65:
            flagbase.SetBool('Have_Evidence',true,,-1); // found the DTS, evidence against Maggie Chow
            break;

        case 75:
        case 70:
        case 68:
        case 67:
        case 66://fallthrough
            if(!flagbase.GetBool('QuickLetPlayerIn')) {// easier than checking if you already have the note
                player.AddNote("Luminous Path door-code: 1997.", false, false);
                flagbase.SetBool('QuickLetPlayerIn',true,,-1);
            }
            flagbase.SetBool('QuickConvinced',true,,-1);
            break;

        case 115:
            flagbase.SetBool('templar_upload',true,,-1);
            flagbase.SetBool('GuntherHermann_Dead',true,,-1);
            break;

        case 129:
            flagbase.SetBool('GaryHostageBriefing_Played',true,,-1);
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
    switch(bingo_event)
    {
        case "GuntherHermann_Dead":
            return start_map>=115;
        case "LeoToTheBar":
            //Only possible if you started in the first level
            return start_map!=0;
            break;
        case "MetSmuggler":
            return start_map>=80; //Mission 8 and later starts you should already know Smuggler (see StartMapSpecificFlags)
        case "KnowsGuntherKillphrase":
            if (end_mission < 12){
                return True;
            }
            return start_map>=60; //Have to have told Jaime to meet you in Paris in mission 5 to get Gunther's killphrase
        case "FordSchick_Dead":
            return start_map>=20;
        case "M07MeetJaime_Played":
            if (end_mission < 8){
                return True;
            }
            return start_map>=60; //Have to have told Jaime to meet you in Hong Kong in mission 5
        case "VialAmbrosia_Activated":
            return start_map>=96; //Have to have started before the superfreighter upper decks (Arbitrarily chose 96 as that point)
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
            return start_map>100; //All these early Paris things - if we were to add a "Streets" starting location, this would need to be split more accurately
        case "ManWhoWasThursday":// in 10_Paris_Catacombs, and then 12_Vandenberg_Cmd, but nothing in M11
            return start_map > 100 && end_mission <= 11;
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
            return start_map>100; //Last phone is in the building before the catacombs (Where Icarus calls)
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
            return true;
        }
        break;
    }

    return false;
}

static function int ChooseRandomStartMap(DXRBase m, int avoidStart)
{
    local int i;
    local int startMap;
    local int attempts;

    startMap=avoidStart;
    attempts=0;
    m.SetGlobalSeed("randomstartmap");

    //Don't try forever.  If we manage to grab the avoided map 50 times, it was meant to be.
    //the widest span is Hong Kong: Helipad is 60, Storage is 75, a span of 15
    while (Abs(startMap-avoidStart) <= 15 && attempts < 50){
        startMap = _ChooseRandomStartMap(m);
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
        return 40;
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
