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

    StartMapSpecificFlags(p.flagbase, dxr.localURL);
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
        StartMapSpecificFlags(p.flagbase, dxr.localURL);
    }

}

static simulated function int GetStartingMissionMask(int start_map)
{
    switch(start_map)
    {// these numbers are basically mission number * 10, with some extra for progress within the mission
        case 0:
        case 10:
            //startMap="01_NYC_UNATCOIsland";
            return 65535;
            break;
        case 20:
            return 65532;
            break;
        case 30:
            return 65528;
            break;
        case 40:
            //startMap="04_NYC_UNATCOHQ"
            return 65520;
        case 50:
            //startMap="05_NYC_UNATCOMJ12lab";
            return 65504;
            break;
        case 61:
            //startMap="06_HongKong_WanChai_Market";
            return 65472;
            break;
        case 81:
            //startMap="08_NYC_Smug";
            return 65280;
            break;
        case 90:
            return 65024;
            break;
        case 99:
            //startMap="09_NYC_Graveyard";
            return 64512; //Mission 10 onwards (you're at the end of mission 9)
            break;
        case 109:
            //startMap="10_Paris_Chateau";
            return 64512; //Mission 10 onwards (but mark most mission 10 goals as impossilbe)
            break;
        case 119:
            //startMap="11_Paris_Everett";
            return 61440; //Mission 12 onwards
            break;
        case 140:
            //startMap="14_Vandenberg_Sub";
            return 49152;
            break;
        case 150:
            //startMap="15_Area51_Bunker";
            return 32768;
            break;
        default:
            //There's always a place for you on Liberty Island
            //startMap="01_NYC_UNATCOIsland";
            return 65535;
            break;
    }
}

static simulated function int GetMaybeMissionMask(int start_map)
{
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
        case 30:
            startMap="03_NYC_UNATCOIsland";
            break;
        case 40:
            startMap="04_NYC_UNATCOHQ";
            break;
        case 50:
            startMap="05_NYC_UNATCOMJ12lab";
            break;
        case 61:
            startMap="06_HongKong_WanChai_Market#cargoup";// OH it's not "car goup", it's "cargo up"!
            break;
        case 81:
            startMap="08_NYC_Smug#ToSmugFrontDoor";
            break;
        case 90:
            startMap="09_NYC_Dockyard";
            break;
        case 99:
            startMap="09_NYC_Graveyard";
            break;
        case 109:
            startMap="10_Paris_Chateau";
            break;
        case 119:
            startMap="11_Paris_Everett";
            break;
        case 140:
            startMap="14_Vandenberg_Sub";
            break;
        case 150:
            startMap="15_Area51_Bunker";
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
        case 10:
            mission=1; //Mission 1 start, nothing
            break;
        case 20:
            mission=2;
            break;
        case 30:
            mission=3;
            break;
        case 40:
            mission=4;
            break;
        case 50:
            mission=5; //Mission 5 start
            break;
        case 61:
            mission=6;
            break;
        case 81:
            mission=8;
            break;
        case 90:
            mission=9;
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
        case 140:
            mission=14;
            break;
        case 150:
            mission=15;
            break;
        default:
            //There's always a place for you on Liberty Island
            mission=1;
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

static function StartMapSpecificFlags(FlagBase flagbase, string start_map)
{
    switch(start_map)
    {
        case "04_NYC_UNATCOHQ":
            flagbase.SetBool('DL_SeeManderley_Played',true,,-1);
            break;
        case "08_NYC_Smug":
            flagbase.SetBool('KnowsSmugglerPassword',true,,-1);
            flagbase.SetBool('MetSmuggler',true,,-1);
            break;
        case "09_NYC_Dockyard":
            flagbase.SetBool('M08WarnedSmuggler',true,,-1);
            flagbase.SetBool('DL_BadNews_Played',true,,-1);
            break;
        case "10_Paris_Chateau":
            //Make sure Sandra spawns at the gas station
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);
            break;
        case "11_Paris_Everett":
            //First Toby conversation happened
            flagbase.SetBool('MeetTobyAtanwe_played',true,,-1);
            flagbase.SetBool('FemJCMeetTobyAtanwe_played',true,,-1);

            //Make sure Sandra spawns at the gas station
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);
            break;
        case "14_Vandenberg_Sub":
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!

            //Make sure Sandra spawns at the gas station (In case you backtrack - shouldn't matter, but...)
            flagbase.SetBool('SandraWentToCalifornia',true,,-1);

            break;
        case "15_Area51_Bunker":
            flagbase.SetBool('Ray_dead',true,,-1);  //Save Jock!
            break;
    }
}

static function bool BingoGoalImpossible(string bingo_event, int start_map, int end_mission)
{
    switch(bingo_event)
    {
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
        default:
            return False;
    }

    return False;
}


static function bool BingoGoalPossible(string bingo_event, int start_map, int end_mission)
{
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

static function int ChooseRandomStartMap(DXRando dxr, int avoidStart)
{
    local int i;
    local int startMap;
    local int attempts;

    startMap=-1;
    attempts=0;

    //Don't try forever.  If we manage to grab the avoided map 5 times, it was meant to be.
    while ((startMap==-1 || startMap==avoidStart) && attempts<5){
        i = staticrng(dxr,13);

        //Should be able to legitimately return Liberty Island (even if that's as a value of 10), but needs additional special handling
        switch(i)
        {
            case 0:
                startMap = 10;
                break;
            case 1:
                startMap = 20;
                break;
            case 2:
                startMap = 30;
                break;
            case 3:
                startMap = 40;
                break;
            case 4:
                startMap = 50;
                break;
            case 5:
                startMap = 61;
                break;
            case 6:
                startMap = 81;
                break;
            case 7:
                startMap = 90;
                break;
            case 8:
                startMap = 99;
                break;
            case 9:
                startMap = 109;
                break;
            case 10:
                startMap = 119;
                break;
            case 11:
                startMap = 140;
                break;
            case 12:
                startMap = 150;
                break;
            default:
                dxr.err("Random Starting Map picked value "$i$" which is unhandled!");
                startMap = 0; //Fall back on Liberty Island
                break;
        }
        log("Start map selection attempt "$attempts$" was "$startMap);
    }

    return startMap;
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
        numAugs = startMission / 2;
        class'DXRAugmentations'.static.AddRandomAugs(dxr,player,numAugs);
        for (i=0;i<startMission;i++){
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
