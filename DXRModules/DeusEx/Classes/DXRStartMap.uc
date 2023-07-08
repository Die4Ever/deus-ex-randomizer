/////////////////////////////////////////////////////////////////
// DXRStartMap
//   Mostly just to contain some magic number conversions
//
/////////////////////////////////////////////////////////////////

class DXRStartMap extends DXRActorsBase;

function PlayerLogin(#var(PlayerPawn) p)
{
    local int startBonus;

    Super.PlayerLogin(p);

    if (dxr.flags.settings.starting_map == 0) return;

    //Add extra skill points to make available once you enter the game
    startBonus = GetStartMapSkillBonus(dxr.flags.settings.starting_map);
    p.SkillPointsAvail += startBonus;
    p.SkillPointsTotal += startBonus;

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

static simulated function int GetStartingMissionMask(int start_map)
{
    switch(start_map)
    {// these numbers are basically mission number * 10, with some extra for progress within the mission
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
        case 61:
            //startMap="06_HongKong_WanChai_Market";
            return 65472;
            break;
        case 81:
            //startMap="08_NYC_Smug";
            return 65280;
            break;
        case 99:
            //startMap="09_NYC_Graveyard";
            return 64512; //Mission 10 onwards (you're at the end of mission 9)
            break;
        case 119:
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
            return "Liberty Island";
        case 40:
            return "NSF Defection";
        case 50:
            return "MJ12 Jail";
        case 61:
            return "Wan Chai Market";
        case 81:
            return "Return to NYC";
        case 99:
            return "Graveyard";
        case 119:
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
        case 61:
            startMap="06_HongKong_WanChai_Market#cargoup";// OH it's not "car goup", it's "cargo up"!
            break;
        case 81:
            startMap="08_NYC_Smug#ToSmugFrontDoor";
            break;
        case 99:
            startMap="09_NYC_Graveyard";
            break;
        case 119:
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
        case 99:
            mission=10; //Mission 9 graveyard, basically mission 10
            break;
        case 119:
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
            flagbase.SetBool('FemJCMeetTobyAtanwe_played',true);
            break;
        case "14_Vandenberg_Sub":
            flagbase.SetBool('Ray_dead',true);  //Save Jock!
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
        case "MetSmuggler":
            return start_map>=80; //Mission 8 and later starts you should already know Smuggler (see StartMapSpecificFlags)
        case "KnowsGuntherKillphrase":
            return start_map>=60; //Have to have told Jaime to meet you in Paris in mission 5 to get Gunther's killphrase
        case "FordSchick_Dead":
            return start_map>=20;
        case "M07MeetJaime_Played":
            return start_map>=60; //Have to have told Jaime to meet you in Hong Kong in mission 50a
        case "VialAmbrosia_Activated":
            return start_map>=96; //Have to have started before the superfreighter upper decks (Arbitrarily chose 96 as that point)
        default:
            return False;
    }

    return False;
}

static function int ChooseRandomStartMap(DXRando dxr)
{
    local int i;

    i = staticrng(dxr,7);

    //Should be able to legitimately return Liberty Island (even if that's as a value of 10), but needs additional special handling
    switch(i)
    {
        case 0:
            return 40;
        case 1:
            return 50;
        case 2:
            return 61;
        case 3:
            return 81;
        case 4:
            return 99;
        case 5:
            return 119;
        case 6:
            return 140;
        default:
            dxr.err("Random Starting Map picked value "$i$" which is unhandled!");
            return 0; //Fall back on Liberty Island
    }
}
