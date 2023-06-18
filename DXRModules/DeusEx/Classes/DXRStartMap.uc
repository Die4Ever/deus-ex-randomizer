/////////////////////////////////////////////////////////////////
// DXRStartMap
//   Mostly just to contain some magic number conversions
//
/////////////////////////////////////////////////////////////////

class DXRStartMap extends DXRActorsBase;


static simulated function int GetStartingMissionMask(DXRando dxr)
{
    local int start_map;

    start_map = dxr.flagbase.GetInt('Rando_starting_map');

    switch(start_map)
    {
        case 0:
            //startMap="01_NYC_UNATCOIsland";
            return 65535;
            break;
        case 40:
            //startMap="04_NYC_UNATCOHQ"
            return 65520;
        case 50:
            //startMap="05_NYC_UNATCOMJ12lab";
            return 65504;
            break;
        case 60:
            //startMap="06_HongKong_WanChai_Market";
            return 65472;
            break;
        case 80:
            //startMap="08_NYC_Smug";
            return 65280;
            break;
        case 90:
            //startMap="09_NYC_Graveyard";
            return 64512; //Mission 10 onwards (you're at the end of mission 9)
            break;
        case 110:
            //startMap="11_Paris_Everett";
            return 61440; //Mission 12 onwards
            break;
        case 140:
            //startMap="14_Vandenberg_Sub";
            return 49152;
            break;
        default:
            //There's always a place for you on Liberty Island
            //startMap="01_NYC_UNATCOIsland";
            return 65535;
            break;
    }
}

static function string GetStartingMapName(int val)
{
    switch(val){
        case 0:
            return "Liberty Island";
        case 40:
            return "NSF Defection";
        case 50:
            return "MJ12 Jail";
        case 60:
            return "Wan Chai Market";
        case 80:
            return "Return to NYC";
        case 90:
            return "Graveyard";
        case 110:
            return "Everett's House";
        case 140:
            return "Ocean Lab";
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
            startMap="01_NYC_UNATCOIsland";
            break;
        case 40:
            startMap="04_NYC_UNATCOHQ";
            break;
        case 50:
            startMap="05_NYC_UNATCOMJ12lab";
            break;
        case 60:
            startMap="06_HongKong_WanChai_Market";
            break;
        case 80:
            startMap="08_NYC_Smug";
            break;
        case 90:
            startMap="09_NYC_Graveyard";
            break;
        case 110:
            startMap="11_Paris_Everett";
            break;
        case 140:
            startMap="14_Vandenberg_Sub";
            break;
        default:
            //There's always a place for you on Liberty Island
            startMap="01_NYC_UNATCOIsland";
            break;
    }

    foreach a.AllActors(class'DXRMapVariants', mapvariants) {
        startMap = mapvariants.VaryMap(startMap);
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
        case 40:
            mission=4;
            break;
        case 50:
            mission=5; //Mission 5 start
            break;
        case 60:
            mission=6;
            break;
        case 80:
            mission=8;
            break;
        case 90:
            mission=10; //Mission 9 graveyard, basically mission 10
            break;
        case 110:
            mission=12; //Mission 11 Everett, but basically mission 12
            break;
        case 140:
            mission=14;
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
    skillBonus = 1000;

    mission = GetStartMapMission(start_map_val);

    return skillBonus * (mission-1);
}

static function StartMapSpecificFlags(FlagBase flagbase, string start_map)
{
    switch(start_map)
    {
        case "08_NYC_Smug":
            flagbase.SetBool('KnowsSmugglerPassword',true);
            flagbase.SetBool('MetSmuggler',true);
            break;
        case "11_Paris_Everett":
            //First Toby conversation happened
            flagbase.SetBool('MeetTobyAtanwe_played',true);
            break;
    }
}

static function bool BingoGoalImpossible(string bingo_event, int start_map)
{
    switch(bingo_event)
    {
        case "LeoToTheBar":
            //Only possible if you started in the first level
            return start_map!=0;
            break;
        default:
            return False;
    }

    return False;
}
