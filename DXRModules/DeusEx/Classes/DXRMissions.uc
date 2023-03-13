class DXRMissions extends DXRActorsBase;

struct RemoveActor {
    var string map_name;
    var name actor_name;
};
var config RemoveActor remove_actors[32];

const NORMAL_GOAL = 1;
const GOAL_TYPE1 = 2;
const GOAL_TYPE2 = 4;
const GOAL_TYPE3 = 8;
const GOAL_TYPE4 = 16;
const SITTING_GOAL = 268435456;
const VANILLA_GOAL = 536870912;
const START_LOCATION = 1073741824;
const VANILLA_START = 2147483648;
const PLAYER_LOCATION = 7; // keep in sync with length of GoalLocation.positions array

var bool RandodMissionGoals;

struct GoalActor {
    var name actorName;
    var EPhysics physics;
    var Actor a;// for caching
};

struct Goal {
    var string mapName;
    var string name;
    var int bitMask;
    var GoalActor actors[8];
};

struct GoalActorLocation {
    var vector pos;
    var rotator rot;
};

struct GoalLocation {
    var string mapName;
    var string name;
    var int bitMask;
    var GoalActorLocation positions[8]; // keep in sync with PLAYER_LOCATION
};

struct MutualExclusion {
    var int L1, L2;
};

struct Spoiler {
    var string goalName;
    var string goalLocation;
};

var Goal goals[32];
var Spoiler spoilers[32];
var GoalLocation locations[64];
var MutualExclusion mutually_exclusive[20];
var int num_goals, num_locations, num_mututally_exclusives;

var config bool allow_vanilla;

var vector rando_start_loc;
var bool b_rando_start;

var bool WaltonAppeared;

function CheckConfig()
{
    local class<Actor> a;
    local int i;
    local string map;

    if( ConfigOlderThan(2,0,3,7) ) {
        allow_vanilla = false;

        for(i=0; i<ArrayCount(remove_actors); i++) {
            remove_actors[i].map_name = "";
            remove_actors[i].actor_name = '';
        }

#ifndef revision
        vanilla_remove_actors();
#endif
    }

    for(i=0; i<ArrayCount(remove_actors); i++) {
        remove_actors[i].map_name = Caps(remove_actors[i].map_name);
    }

    Super.CheckConfig();
}

function vanilla_remove_actors()
{
    local int i;
    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'OrdersTrigger2';//the order that makes Paul run to you
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger0';//find Paul
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger8';//the "don't leave without talking to Paul" datalink
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger10';//DL_MissedHermann
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger5';//DL_NearTop
    i++;

    remove_actors[i].map_name = "01_NYC_unatcoisland";
    remove_actors[i].actor_name = 'DataLinkTrigger12';//DL_Top
    i++;

    remove_actors[i].map_name = "09_NYC_GRAVEYARD";
    remove_actors[i].actor_name = 'Barrel0';//barrel next to the transmitter thing, idk what it does but it explodes when I move it
    i++;
}

function Spoiler GetSpoiler(int goalID)
{
    return spoilers[goalID];
}

function AddGoalActor(int goalID, int index, name actorName, EPhysics physics)
{
    goals[goalID].actors[index].actorName = actorName;
    goals[goalID].actors[index].physics = physics;
}

function int AddGoal(string mapName, string goalName, int bitMask, name actorName, EPhysics physics)
{
    mapName = Caps(mapName);
    goals[num_goals].mapName = mapName;
    goals[num_goals].name = goalName;
    goals[num_goals].bitMask = bitMask;
    AddGoalActor(num_goals, 0, actorName, physics);
    return num_goals++;
}

function AddActorLocation(int LocID, int index, vector loc, rotator r)
{
    locations[LocID].positions[index].pos = loc;
    locations[LocID].positions[index].rot = r;
}

function int AddGoalLocation(string mapName, string name, int bitMask, vector loc, rotator r)
{
    local int i;
    local Lightbulb a;
    mapName = Caps(mapName);
    locations[num_locations].mapName = mapName;
    locations[num_locations].name = name;
    locations[num_locations].bitMask = bitMask;
    for(i=0; i<ArrayCount(locations[num_locations].positions); i++) {
        AddActorLocation(num_locations, i, loc, r);
    }

    if(name == "" && mapName == dxr.localURL) {
        a = Lightbulb(_AddActor(self, class'Lightbulb', loc, r));
        a.bInvincible = true;
        DebugMarkKeyPosition(a, num_locations @ loc);
    }
    return num_locations++;
}

function String generateGoalLocationList()
{
    local int i,j;
    local String goalList;

    goalList = "";

    for (i=0;i<num_goals;i++){
        goalList = goalList $ goals[i].name $ ":|n";
        goalList = goalList $ "-----------------------------|n";

        for (j=0;j<num_locations;j++){
            if ((goals[i].bitMask & locations[j].bitMask) != 0) {
                goalList = goalList $ locations[j].name $ " (" $ locations[j].mapName $ ")";

                //For missions with multiple "Vanilla" locations in a single pool (eg mission 8),
                //this isn't actually as useful as it seems otherwise.  If we added unique "Vanilla Goal"
                //masks, it would be useful again
                //if ((locations[j].bitMask & VANILLA_GOAL) != 0){
                //    goalList = goalList $ " (Vanilla)";
                //}
                goalList = goalList $ "|n";
            }
        }
        goalList = goalList $ "|n";

    }

    return goalList;
}

function AddMutualExclusion(int L1, int L2)
{
    mutually_exclusive[num_mututally_exclusives].L1 = L1;
    mutually_exclusive[num_mututally_exclusives].L2 = L2;
    num_mututally_exclusives++;
}

function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;
    // return a salt for the seed, the default return at the end is fine if you only have 1 set of goals in the whole mission
    num_goals = 0;
    num_locations = 0;
    num_mututally_exclusives = 0;
    switch(map) {
    case "01_NYC_UNATCOISLAND":
        AddGoal("01_NYC_UNATCOISLAND", "Terrorist Commander", NORMAL_GOAL, 'TerroristCommander0', PHYS_Falling);
        AddGoal("01_NYC_UNATCOISLAND", "Police Boat", GOAL_TYPE1, 'NYPoliceBoat0', PHYS_None);

        loc = AddGoalLocation("01_NYC_UNATCOISLAND", "UNATCO HQ", START_LOCATION, vect(-6348.445313, 1912.637207, -111.428482), rot(0, 0, 0));
        loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Dock", NORMAL_GOAL | VANILLA_START, vect(-4760.569824, 10430.811523, -280.674988), rot(0, -7040, 0));
        AddMutualExclusion(loc, loc2);
        loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Hut", NORMAL_GOAL, vect(-2407.206787, 205.915558, -128.899979), rot(0, 30472, 0));
        AddMutualExclusion(loc, loc2);

        loc = AddGoalLocation("01_NYC_UNATCOISLAND", "Harley Filben Dock", START_LOCATION, vect(1297.173096, -10257.972656, -287.428131), rot(0, 0, 0));
        loc2 = AddGoalLocation("01_NYC_UNATCOISLAND", "Electric Bunker", NORMAL_GOAL | START_LOCATION, vect(6552.227539, -3246.095703, -447.438049), rot(0, 0, 0));
        AddMutualExclusion(loc, loc2);

        AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", NORMAL_GOAL | START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, 0, 0));

        loc = AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Base", NORMAL_GOAL, vect(2980.058105, -669.242554, 1056.577271), rot(0, 0, 0));
        loc2 = AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(2931.230957, 27.495235, 2527.800049), rot(0, 14832, 0));
        AddMutualExclusion(loc, loc2);

        //Boat locations
        AddGoalLocation("01_nyc_unatcoisland", "South Dock", GOAL_TYPE1 | VANILLA_GOAL , vect(-5122.414551, 10138.813477, -269.806213), rot(0, 0, 0));
        AddGoalLocation("01_nyc_unatcoisland", "North Dock", GOAL_TYPE1 , vect(4535.585938, -10046.186523, -269.806213), rot(0, 0, 0));
        AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", GOAL_TYPE1 , vect(3682.585449, 231.813477, 2108.193848), rot(0, 0, 0));
        AddGoalLocation("01_nyc_unatcoisland", "Behind UNATCO", GOAL_TYPE1 , vect(-4578.414551, 267.813477, 24.193787), rot(0, 0, 0));

        return 11;

    case "02_NYC_BATTERYPARK":
        goal = AddGoal("02_NYC_BATTERYPARK", "Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia0', PHYS_Falling);
        AddGoalActor(goal, 1, 'SkillAwardTrigger0', PHYS_None);
        AddGoalActor(goal, 2, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'FlagTrigger1', PHYS_None); //Sets AmbrosiaTagged
        AddGoalActor(goal, 4, 'DataLinkTrigger1', PHYS_None);

        AddGoalLocation("02_NYC_BATTERYPARK", "Dock", START_LOCATION | VANILLA_START, vect(-619.571289, -3679.116455, 255.099762), rot(0, 29856, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Ventilation system", NORMAL_GOAL | START_LOCATION, vect(-4310.507813, 2237.952637, 189.843536), rot(0, 0, 0));

        loc = AddGoalLocation("02_NYC_BATTERYPARK", "Ambrosia Vanilla", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(507.282898, -1066.344604, -403.132751), rot(0, 16536, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(81.434570, -1123.060547, -384.397644), rot(0, 8000, 0));

        AddGoalLocation("02_NYC_BATTERYPARK", "In the command room", NORMAL_GOAL, vect(650.060547, -989.234863, -160.095200), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Behind the cargo", NORMAL_GOAL, vect(58.725319, -446.887207, -405.899323), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "By the desk", NORMAL_GOAL, vect(-615.152161, -665.281738, -397.581146), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Walkway by the water", NORMAL_GOAL, vect(-420.000000, -2222.000000, -400), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway stairs", NORMAL_GOAL, vect(-5106.205078, 1813.453003, -82.239639), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway", NORMAL_GOAL, vect(-4727.703613, 3116.336670, -321.900604), rot(0, 0, 0));
        return 21;

    case "02_NYC_WAREHOUSE":
        // NORMAL_GOAL is Jock, GOAL_TYPE1 is the generator, GOAL_TYPE2 is the computers
        AddGoal("02_NYC_WAREHOUSE", "Jock", NORMAL_GOAL, 'BlackHelicopter1', PHYS_None);
        AddGoalLocation("02_NYC_WAREHOUSE", "Vanilla Jock", NORMAL_GOAL | VANILLA_GOAL, vect(-222.402451,-294.757233,1132.798828), rot(0,-24128,0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Holy Smokes", NORMAL_GOAL, vect(-566.249695, 305.599731, 1207.798462), rot(0, -32800, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Back Door", NORMAL_GOAL, vect(1656.467041, -1658.624268, 357.798462), rot(0, -32800, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Dumpster", NORMAL_GOAL, vect(1665.240112, 91.544250, 126.798462), rot(0, 0, 0));
        loc2 = AddGoalLocation("02_NYC_WAREHOUSE", "Sewer", NORMAL_GOAL, vect(-1508.833008, 322, -216.201538), rot(0, 16400, 0));

        goal = AddGoal("02_NYC_WAREHOUSE", "Generator", GOAL_TYPE1, 'BreakableWall2', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'CrateExplosiveSmall0', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall6', PHYS_None);
        AddGoalLocation("02_NYC_WAREHOUSE", "Warehouse", GOAL_TYPE1 | VANILLA_GOAL, vect(576.000000, -512.000000, 71.999939), rot(32768, -16384, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Alley", GOAL_TYPE1, vect(-640.000000, 1760.000000, 128.000000), rot(0,32768,-16384));
        AddGoalLocation("02_NYC_WAREHOUSE", "Apartment", GOAL_TYPE1, vect(368.000000, 1248.000000, 992.000000), rot(0,32768,-16384));
        AddGoalLocation("02_NYC_WAREHOUSE", "Basement", GOAL_TYPE1, vect(300, -560, -120), rot(0,-16384,-16384));
        loc = AddGoalLocation("02_NYC_WAREHOUSE", "Sewer", GOAL_TYPE1, vect(-1600.000000, 784.000000, -256.000000), rot(32768,-32768,0));
        AddMutualExclusion(loc, loc2);// can't put Jock and the generator both in the sewers
        // pawns run into these and break them
        //AddGoalLocation("02_NYC_WAREHOUSE", "3rd Floor", GOAL_TYPE1, vect(1360.000000, -512.000000, 528.000000), rot(32768, -16384, 0));
        //AddGoalLocation("02_NYC_WAREHOUSE", "3rd Floor Corner", GOAL_TYPE1, vect(1600, -1136.000000, 540), rot(32768, 16384, 0));

        AddGoal("02_NYC_WAREHOUSE", "Generator Computer", GOAL_TYPE2, 'ComputerPersonal5', PHYS_Falling);
        AddGoal("02_NYC_WAREHOUSE", "Email Computer", GOAL_TYPE2, 'ComputerPersonal0', PHYS_Falling);
        AddGoalLocation("02_NYC_WAREHOUSE", "Warehouse Computer Room", GOAL_TYPE2 | VANILLA_GOAL, vect(1277.341797, -864.810913, 311.500397), rot(0, 16712, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Basement", GOAL_TYPE2 | VANILLA_GOAL, vect(1002.848999, -897.071167, -136.499573), rot(0, -17064, 0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Break room", GOAL_TYPE2, vect(1484.731934, -917.463257, 73.499916), rot(0,-16384,0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Apartment", GOAL_TYPE2, vect(-239.501144, 1441.699951, 1151.502930), rot(0,0,0));
        AddGoalLocation("02_NYC_WAREHOUSE", "Holy Smokes", GOAL_TYPE2, vect(-846.480957, 919.700012, 1475.486938), rot(0,32768,0));
        return 22;

    case "03_NYC_BATTERYPARK":
        AddGoal("03_NYC_BATTERYPARK", "Harley Filben", NORMAL_GOAL, 'HarleyFilben0', PHYS_Falling);
        goal = AddGoal("03_NYC_BATTERYPARK", "Curly", NORMAL_GOAL, 'BumMale4', PHYS_Falling);
        AddGoalActor(goal, 1, 'BumFemale2', PHYS_Falling);

        AddGoalLocation("03_NYC_BATTERYPARK", "Jock", START_LOCATION | VANILLA_START, vect(-1226.699951, 2215.864258, 400.663818), rot(0, -25672, 0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Castle Clinton Entrance", NORMAL_GOAL | START_LOCATION, vect(1082.374023, 1458.807617, 334.248260), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(1161.899657, 1559.100464, 331.741821), rot(0,0,0));

        AddGoalLocation("03_NYC_BATTERYPARK", "Ventilation System", START_LOCATION, vect(-4340.930664, 2332.365234, 244.506165), rot(0, 0, 0));
        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Eagle Statue", NORMAL_GOAL | START_LOCATION, vect(-2968.101563, -1407.404419, 334.242554), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-2888.101563, -1307.404419, 332.242554), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Dock", NORMAL_GOAL | START_LOCATION, vect(-1079.890625, -3412.052002, 270.581390), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-999.890625, -3312.052002, 268), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Hut", NORMAL_GOAL | VANILLA_GOAL, vect(-2763.231689,1370.594604,373.603882), rot(0,7272,0));
        AddActorLocation(loc, 1, vect(-2683.231689, 1470.594604, 371), rot(0,0,0));

        loc = AddGoalLocation("03_NYC_BATTERYPARK", "Subway", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(-4819.345215,3478.138916,-304.225006), rot(0,0,0));
        AddActorLocation(loc, 1, vect(-4739.345215, 3578.138916, -306), rot(0,0,0));
        return 31;

    case "03_NYC_BROOKLYNBRIDGESTATION":
        // GOAL_TYPE1 is only for people that can safely go up into the Rooks territory
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Rock (Drug Dealer)", NORMAL_GOAL, 'ThugMale13', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Lenny (Junkie)", NORMAL_GOAL | GOAL_TYPE1, 'JunkieMale1', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Charlie", NORMAL_GOAL | GOAL_TYPE1, 'BumMale2', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "El Rey", NORMAL_GOAL | GOAL_TYPE1, 'ThugMale3', PHYS_Falling);
        AddGoal("03_NYC_BROOKLYNBRIDGESTATION", "Ex-Mole Person", NORMAL_GOAL | GOAL_TYPE1, 'BumMale3', PHYS_Falling);
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Water pipes", NORMAL_GOAL, vect(2893.466064, -4513.004395, 104.099274), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Rooks East Side", GOAL_TYPE1, vect(1755.025391, -847.637695, 382.144287), rot(0, 0, 0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Men's Restroom", NORMAL_GOAL | VANILLA_GOAL, vect(-1248.503662,-2870.117432,109.675003), rot(0,-21080,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "Rooks West Side", GOAL_TYPE1 | VANILLA_GOAL, vect(-2978.629639,-2281.836670,415.774994), rot(0,0,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "SE Corner", NORMAL_GOAL | VANILLA_GOAL, vect(975.220337,1208.224854,111.775002), rot(0,-22408,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "NE Corner", NORMAL_GOAL | VANILLA_GOAL, vect(1003.048767,-2519.280762,111.775002), rot(0,13576,0));
        AddGoalLocation("03_NYC_BROOKLYNBRIDGESTATION", "NW Corner", NORMAL_GOAL | VANILLA_GOAL, vect(-988.025696,-3381.119385,111.775002), rot(0,-22608,0));
        return 32;

    case "03_NYC_AIRFIELD":
        AddGoal("03_NYC_AIRFIELD", "Terrorist with the East Gate key", NORMAL_GOAL, 'Terrorist13', PHYS_Falling);
        AddGoalLocation("03_NYC_AIRFIELD", "South Gate", NORMAL_GOAL, vect(223.719452, 3689.905273, 15.100115), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "SW Security Tower", NORMAL_GOAL, vect(-2103.891113, 3689.706299, 15.091076), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "West Security Tower", NORMAL_GOAL, vect(-2060.626465, -2013.138672, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "NW Security Tower", NORMAL_GOAL, vect(729.454651, -4151.924805, 15.079981), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "NE Security Tower", NORMAL_GOAL, vect(5215.076660, -4134.674316, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "Hanger Door", NORMAL_GOAL, vect(941.941895, 283.418152, 15.090023), rot(0, 0, 0));
        AddGoalLocation("03_NYC_AIRFIELD", "Dock", NORMAL_GOAL | VANILLA_GOAL, vect(-2687.128662,2320.010986,63.774998), rot(0,0,0));

        goal = AddGoal("03_NYC_AIRFIELD", "Ambrosia", GOAL_TYPE1, 'BarrelAmbrosia0', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger0',PHYS_None); //Reduced radius, sets BoatDocksAmbrosia
        AddGoalLocation("03_NYC_AIRFIELD", "Docks", GOAL_TYPE1 | VANILLA_GOAL, vect(-2482.986816,1924.479126,44.869865), rot(0,0,0));
        AddGoalLocation("03_NYC_AIRFIELD", "Hangar Door", GOAL_TYPE1, vect(1069,289,45), rot(0,16328,0));
        AddGoalLocation("03_NYC_AIRFIELD", "Near Electrical", GOAL_TYPE1, vect(5317,-2405,45), rot(0,16328,0));
        AddGoalLocation("03_NYC_AIRFIELD", "Near Satellite", GOAL_TYPE1, vect(5317,3189,45), rot(0,16328,0));
        AddGoalLocation("03_NYC_AIRFIELD", "Cargo Container", GOAL_TYPE1, vect(-220,3012,373), rot(0,25344,0));

        return 33;

    case "03_NYC_AIRFIELDHELIBASE":
        goal = AddGoal("03_NYC_AIRFIELDHELIBASE", "Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia1', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger0',PHYS_None); //Reduced radius, sets HelicopterBaseAmbrosia

        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Main Entrance", NORMAL_GOAL | VANILLA_GOAL, vect(47.421066,1102.545044,40.869644), rot(0,0,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Womens Bathroom", NORMAL_GOAL, vect(1362,677,41), rot(0,32872,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Office", NORMAL_GOAL, vect(-1403,215,41), rot(0,49152,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Secret Room", NORMAL_GOAL, vect(-1149,626,215), rot(0,81896,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Helipad", NORMAL_GOAL, vect(508,-399,192), rot(0,71560,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Catwalk", NORMAL_GOAL, vect(1394,-1221,800), rot(0,71560,0));
        AddGoalLocation("03_NYC_AIRFIELDHELIBASE", "Break Room", NORMAL_GOAL, vect(895,1257,206), rot(0,32856,0));

        return 34;

    case "03_NYC_747":
    case "03_NYC_HANGAR":
        goal = AddGoal("03_NYC_747", "747 Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia1', PHYS_Falling);
        AddGoalActor(goal,1,'FlagTrigger1',PHYS_None); //Reduced radius, sets 747Ambrosia

        AddGoalLocation("03_NYC_747", "Cargo", NORMAL_GOAL | VANILLA_GOAL, vect(-147.147064,-511.348846,158.870544), rot(0,15760,0));
        AddGoalLocation("03_NYC_747", "Office", NORMAL_GOAL, vect(6,-736,339), rot(0,-32,0));
        AddGoalLocation("03_NYC_747", "Flight Deck", NORMAL_GOAL, vect(1339,-513,484), rot(0,16480,0));
        AddGoalLocation("03_NYC_747", "Bedroom", NORMAL_GOAL, vect(1594,-710,368), rot(0,0,0));
        AddGoalLocation("03_NYC_HANGAR", "Near Trailers", NORMAL_GOAL, vect(1867,-1318,29), rot(0,0,0));
        AddGoalLocation("03_NYC_HANGAR", "Near Engine", NORMAL_GOAL, vect(4140,-1554,29), rot(0,32776,0));

        return 35;

    case "04_NYC_NSFHQ":
        AddGoal("04_NYC_NSFHQ", "Computer", NORMAL_GOAL, 'ComputerPersonal3', PHYS_Falling);
        AddGoalLocation("04_NYC_NSFHQ", "Third Floor", NORMAL_GOAL, vect(-460.091187, 1011.083496, 551.367859), rot(0, 16672, 0));
        AddGoalLocation("04_NYC_NSFHQ", "Second Floor", NORMAL_GOAL, vect(206.654617, 1340.000000, 311.652832), rot(0, 0, 0));
        AddGoalLocation("04_NYC_NSFHQ", "Garage", NORMAL_GOAL, vect(381.117371, -696.875671, 63.615902), rot(0, 32768, 0));
        AddGoalLocation("04_NYC_NSFHQ", "Break Room", NORMAL_GOAL, vect(42.340145, 1104.667480, 73.610352), rot(0, 0, 0));
        AddGoalLocation("04_NYC_NSFHQ", "Basement Exit", NORMAL_GOAL, vect(1290.299927, 1385.000000, -185.000000), rot(0, 16384, 0));
        AddGoalLocation("04_NYC_NSFHQ", "Basement Entrance", NORMAL_GOAL, vect(-617.888855, 141.699875, -208.000000), rot(0, 16384, 0));
        AddGoalLocation("04_NYC_NSFHQ", "Rooftop", NORMAL_GOAL | VANILLA_GOAL, vect(187.265259,315.583862,1032.054199), rot(0,16672,0));
        return 41;

    case "05_NYC_UNATCOMJ12LAB":
        goal = AddGoal("05_NYC_UNATCOMJ12LAB", "Paul", NORMAL_GOAL, 'PaulDenton0', PHYS_Falling);
        AddGoalActor(goal, 1, 'PaulDentonCarcass0', PHYS_Falling);
        AddGoalActor(goal, 2, 'DataLinkTrigger6', PHYS_None);
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Armory", NORMAL_GOAL, vect(-8548.773438, 1074.370850, -20.860909), rot(0, 0, 0));
        loc = AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Surgery Ward", NORMAL_GOAL | VANILLA_GOAL, vect(2281.708008, -617.352478, -224.400238), rot(0,35984,0));
        AddActorLocation(loc, 1, vect(2177.405273, -552.487671, -200.899811), rot(0, 16944, 0));
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Greasel Pit", NORMAL_GOAL, vect(375,3860,-604), rot(0, 8048, 0));
        AddGoalLocation("05_NYC_UNATCOMJ12LAB", "Robotics Bay Office", NORMAL_GOAL, vect(-4297,1083,210), rot(0, 16392, 0));

        return 51;

    case "05_NYC_UNATCOHQ":
        AddGoal("05_NYC_UNATCOHQ", "Alex Jacobson", NORMAL_GOAL, 'AlexJacobson0', PHYS_Falling);
        AddGoal("05_NYC_UNATCOHQ", "Jaime Reyes", NORMAL_GOAL, 'JaimeReyes0', PHYS_Falling);
        AddGoalLocation("05_NYC_UNATCOHQ", "Jail", NORMAL_GOAL, vect(-2478.156738, -1123.645874, -16.399887), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Bathroom", NORMAL_GOAL, vect(121.921074, 287.711243, 39.599487), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Manderley's Bathroom", NORMAL_GOAL, vect(261.019775, -403.939575, 287.600586), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Break Room", NORMAL_GOAL, vect(718.820068, 1411.137451, 287.598999), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "West Office", NORMAL_GOAL, vect(-666.268066, -460.813965, 463.598083), rot(0, 0, 0));
        AddGoalLocation("05_NYC_UNATCOHQ", "Computer Ops", NORMAL_GOAL | VANILLA_GOAL, vect(2001.611206,-801.088379,-16.225000), rot(0,23776,0));
        return 52;

    case "06_HONGKONG_VERSALIFE":
        AddGoal("06_HONGKONG_VERSALIFE", "Gary Burkett", NORMAL_GOAL | SITTING_GOAL, 'Male2', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "Data Entry Worker", NORMAL_GOAL | SITTING_GOAL, 'Male0', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "John Smith", NORMAL_GOAL | SITTING_GOAL, 'Male9', PHYS_Falling);
        AddGoal("06_HONGKONG_VERSALIFE", "Mr. Hundley", NORMAL_GOAL, 'Businessman0', PHYS_Falling);
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Break room", NORMAL_GOAL | VANILLA_GOAL, vect(-952.069763, 246.924271, 207.600281), rot(0, -25708, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Break room", NORMAL_GOAL | VANILLA_GOAL, vect(-971.477234, 352.951782, 463.600586), rot(0,0,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Cubicle", SITTING_GOAL | VANILLA_GOAL, vect(209.333740, 1395.673584, 466.101288), rot(0,18572,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "3rd Floor Corner", NORMAL_GOAL | VANILLA_GOAL, vect(-68.717262, 2165.082031, 465.039124), rot(0,15816,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "1st Floor Cubicle", SITTING_GOAL, vect(13.584339, 1903.127441, -48.399910), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "1st Floor Water Cooler", NORMAL_GOAL, vect(846.994751, 1754.889526, -48.398872), rot(0, 30000, 0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Cubicle", SITTING_GOAL, vect(16.111176, 1888.993774, 207.596893), rot(0,16384,0));
        AddGoalLocation("06_HONGKONG_VERSALIFE", "2nd Floor Water Cooler", NORMAL_GOAL, vect(858.500061, 1747.315918, 207.601013), rot(0, 30000, 0));
        return 61;

    case "06_HONGKONG_MJ12LAB":
        goal = AddGoal("06_HONGKONG_MJ12LAB", "Nanotech Blade ROM", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'DataLinkTrigger0', PHYS_None);// DL_Tong_07: I have uploaded the component the Triads need to complete the sword.
        AddGoalActor(goal, 2, 'DataLinkTrigger3', PHYS_None);// DL_Tong_07 but with Tag TongHasTheROM
        AddGoalActor(goal, 3, 'DataLinkTrigger8', PHYS_None);// DL_Tong_08: The ROM-encoding should be in this wing of the laboratory.
        AddGoalActor(goal, 4, 'FlagTrigger0', PHYS_None);
        AddGoalActor(goal, 5, 'FlagTrigger1', PHYS_None);
        AddGoalActor(goal, 6, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 7, 'SkillAwardTrigger10', PHYS_None);

        /*AddGoalActor(goal, 1, 'DataLinkTrigger4', PHYS_None);// DL_Tong_07
        AddGoalActor(goal, 1, 'DataLinkTrigger5', PHYS_None);// DL_Tong_07
        AddGoalActor(goal, 1, 'DataLinkTrigger6', PHYS_None);// DL_Tong_07*/

        AddGoal("06_HONGKONG_MJ12LAB", "Radiation Controls", NORMAL_GOAL, 'ComputerPersonal1', PHYS_Falling);
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Barracks", NORMAL_GOAL, vect(-140.163544, 1705.130127, -583.495483), rot(0, 0, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Radioactive Chamber", NORMAL_GOAL, vect(-1273.699951, 803.588745, -792.499512), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Lab", NORMAL_GOAL, vect(-1712.699951, -809.700012, -744.500610), rot(0, 16384, 0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "ROM Encoding Room", NORMAL_GOAL | VANILLA_GOAL, vect(-0.995101,-260.668579,-311.088989), rot(0,32824,0));
        AddGoalLocation("06_HONGKONG_MJ12LAB", "Radioactive Lab", NORMAL_GOAL | VANILLA_GOAL, vect(-723.018677,591.498901,-743.972717), rot(0,49160,0));
        return 62;

    case "06_HONGKONG_WANCHAI_STREET":
    case "06_HONGKONG_WANCHAI_CANAL":
    case "06_HONGKONG_WANCHAI_MARKET":
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        SetDTSGoalLocations();
        goal = AddGoal("06_HONGKONG_WANCHAI_UNDERWORLD","Max Chen",GOAL_TYPE1 | SITTING_GOAL,'MaxChen0',PHYS_FALLING);
        AddGoalActor(goal, 1, 'TriadRedArrow5', PHYS_Falling); //Maybe I should actually find these guys by bindname?  They're "RightHandMan"
        AddGoalActor(goal, 2, 'TriadRedArrow6', PHYS_Falling);

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Office",GOAL_TYPE1 | SITTING_GOAL | VANILLA_GOAL,vect(426.022644,-2469.105957,-336.399414),rot(0,0,0));
        AddActorLocation(loc, 1, vect(488.291809, -2581.964355, -336.402618), rot(0,32620,0));
        AddActorLocation(loc, 2, vect(484.913330,-2345.247559,-336.401306), rot(0,32620,0));

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Bathroom",GOAL_TYPE1,vect(-1725.911133,-565.364746,-339),rot(0,16368,0));
        AddActorLocation(loc, 1, vect(-1794.911133,-572.364746,-339), rot(0,16368,0));
        AddActorLocation(loc, 2, vect(-1658.911133,-568.364746,-339), rot(0,16368,0));

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Bar",GOAL_TYPE1,vect(-772,-2220,-144),rot(0,-16352,0));
        AddActorLocation(loc, 1, vect(-755,-2326,-136), rot(0,16508,0));
        AddActorLocation(loc, 2, vect(-617,-2280,-136), rot(0,32620,0));

        loc=AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD","Sailors",GOAL_TYPE1,vect(-1392,-2539,18),rot(0,-6414,0));
        AddActorLocation(loc, 1, vect(-1161,-2550,21), rot(0,39348,0));
        AddActorLocation(loc, 2, vect(-1204,-2758,21), rot(0,23892,0));

        return 63;


    case "08_NYC_Bar":
    case "08_NYC_FreeClinic":
    case "08_NYC_Hotel":
    case "08_NYC_Smug":
    case "08_NYC_Street":
    case "08_NYC_Underground":
        AddGoal("08_NYC_Bar", "Harley Filben", NORMAL_GOAL, 'HarleyFilben0', PHYS_Falling);
        goal = AddGoal("08_NYC_Bar", "Vinny", NORMAL_GOAL, 'NathanMadison0', PHYS_Falling);
        //AddGoalActor(goal, 1, 'SandraRenton0', PHYS_Falling); TODO: move Sandra with Vinny?
        //AddGoalActor(goal, 2, 'CoffeeTable0', PHYS_Falling);
        AddGoal("08_NYC_FreeClinic", "Joe Greene", NORMAL_GOAL, 'JoeGreene0', PHYS_Falling);

        AddGoalLocation("08_NYC_Street", "Hotel Roof", START_LOCATION | VANILLA_START | NORMAL_GOAL, vect(-354.250427, 795.071594, 594.411743), rot(0, -18600, 0));
        AddGoalLocation("08_NYC_Bar", "Bar Table", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-1689.125122, 337.159912, 63.599533), rot(0,-10144,0));
        AddGoalLocation("08_NYC_Bar", "Bar", NORMAL_GOAL | VANILLA_GOAL, vect(-931.038086, -488.537109, 47.600464), rot(0,9536,0));
        AddGoalLocation("08_NYC_FreeClinic", "Clinic", NORMAL_GOAL | VANILLA_GOAL, vect(904.356262, -1229.045166, -272.399506), rot(0,31640,0));
        AddGoalLocation("08_NYC_Underground", "Sewers", NORMAL_GOAL, vect(591.048462, -152.517639, -560.397888), rot(0,32768,0));
        AddGoalLocation("08_NYC_Hotel", "Hotel", NORMAL_GOAL | SITTING_GOAL, vect(-108.541245, -2709.490479, 111.600838), rot(0,20000,0));
        AddGoalLocation("08_NYC_Street", "Basketball Court", NORMAL_GOAL | START_LOCATION, vect(2694.934082, -2792.844971, -448.396637), rot(0,32768,0));
        return 81;

    case "09_NYC_GRAVEYARD":
        goal = AddGoal("09_NYC_GRAVEYARD", "Jammer", NORMAL_GOAL, 'BreakableWall1', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'SkillAwardTrigger2', PHYS_None);
        AddGoalActor(goal, 2, 'FlagTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'TriggerLight0', PHYS_None);
        AddGoalActor(goal, 4, 'TriggerLight1', PHYS_None);
        AddGoalActor(goal, 5, 'TriggerLight2', PHYS_None);
        AddGoalActor(goal, 6, 'AmbientSoundTriggered0', PHYS_None);
        AddGoalLocation("09_NYC_GRAVEYARD", "Main Tunnel", NORMAL_GOAL, vect(-283.503448, -787.867920, -184.000000), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "Open Grave", NORMAL_GOAL, vect(-766.879333, 501.505676, -88.109619), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "Tunnel Ledge", NORMAL_GOAL, vect(-1530.000000, 845.000000, -107.000000), rot(0, 0, -32768));
        AddGoalLocation("09_NYC_GRAVEYARD", "Behind Bookshelf", NORMAL_GOAL | VANILLA_GOAL, vect(1103.000000,728.000000,48.000000), rot(0,0,-32768));
        return 91;

    case "09_NYC_SHIPBELOW":
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 1", NORMAL_GOAL, 'DeusExMover40', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator10', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall1', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger8', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered5', PHYS_None);
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 2", NORMAL_GOAL, 'DeusExMover16', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator4', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall0', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger0', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered0', PHYS_None);
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 3", NORMAL_GOAL, 'DeusExMover33', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator7', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall2', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger3', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered3', PHYS_None);
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 4", NORMAL_GOAL, 'DeusExMover31', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator5', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall4', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger1', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered1', PHYS_None);
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point 5", NORMAL_GOAL, 'DeusExMover32', PHYS_MovingBrush);
        AddGoalActor(goal, 1, 'ParticleGenerator6', PHYS_None);
        AddGoalActor(goal, 2, 'CrateExplosiveSmall3', PHYS_None);
        AddGoalActor(goal, 3, 'DataLinkTrigger2', PHYS_None);
        //AddGoalActor(goal, 3, 'AmbientSoundTriggered2', PHYS_None);

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "North Engine Room", NORMAL_GOAL, vect(-384.000000, 1024.000000, -272.000000), rot(0, 49152, 0));
        AddActorLocation(loc, 2, vect(-378, 978, -272), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Balcony", NORMAL_GOAL, vect(-3296.000000, -1664.000000, -112.000000), rot(0, 81920, 0));
        AddActorLocation(loc, 2, vect(-3300, -1619, -112), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Hallway", NORMAL_GOAL, vect(-2480.000000, -448.000000, -144.000000), rot(0, 32768, 0));
        AddActorLocation(loc, 2, vect(-2522, -464, -144), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "SE Electrical Room", NORMAL_GOAL, vect(-3952.000000, 768.000000, -416.000000), rot(0, 0, 0));
        AddActorLocation(loc, 2, vect(-3908, 766, -416), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "South Helipad", NORMAL_GOAL, vect(-5664.000000, -928.000000, -432.000000), rot(0, 16384, 0));
        AddActorLocation(loc, 2, vect(-5664, -889, -432), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Storage Room", NORMAL_GOAL, vect(-4080.000000, -816.000000, -128.000000), rot(0, 32768, 0));
        AddActorLocation(loc, 2, vect(-4120, -816, -128), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Air Control", NORMAL_GOAL, vect(-4720.000000, 1536.000000, -144.000000), rot(0, -16384, 0));
        AddActorLocation(loc, 2, vect(-4717, 1501, -144), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Fan Room", NORMAL_GOAL, vect(-3200.000000, -48.000000, -96.000000), rot(0, 0, 0));
        AddActorLocation(loc, 2, vect(-3157, -48, -96), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Engine Control Room", NORMAL_GOAL, vect(-288.000000, -432.000000, 112.000000), rot(-16384, 16384, 0));
        AddActorLocation(loc, 2, vect(-288, -426, 62), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "NW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(832.000000,1024.000000,-432.000000), rot(0,49152,0));
        AddActorLocation(loc, 2, vect(833.449036, 993.195618, -490.899567), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "NE Electical Room", NORMAL_GOAL | VANILLA_GOAL, vect(-3680.000000,1647.000000,-416.000000), rot(0,49152,0));
        AddActorLocation(loc, 2, vect(-3680.022217, 1616.057861, -490.899567), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "East Helipad", NORMAL_GOAL | VANILLA_GOAL, vect(-6528.000000,200.000000,-448.000000), rot(0,65536,0));
        AddActorLocation(loc, 2, vect(-6499.218750, 200.039917, -490.899567), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps", NORMAL_GOAL | VANILLA_GOAL, vect(-3296.000000,-1662.000000,-416.000000), rot(0,81920,0));
        AddActorLocation(loc, 2, vect(-3296.133789, -1632.118652, -490.899567), rot(0,0,0));

        loc = AddGoalLocation("09_NYC_SHIPBELOW", "SW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(832.000000,-1024.000000,-416.000000), rot(0,16384,0));
        AddActorLocation(loc, 2, vect(831.944641, -996.442627, -490.899567), rot(0,0,0));

        return 92;

    case "10_PARIS_METRO":
    case "10_PARIS_CLUB":
        AddGoal("10_PARIS_METRO", "Jaime", NORMAL_GOAL, 'JaimeReyes1', PHYS_Falling);
        AddGoal("10_PARIS_CLUB", "Nicolette", NORMAL_GOAL, 'NicoletteDuClare0', PHYS_Falling);
        AddGoalLocation("10_PARIS_CLUB", "Club", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-673.488708, -1385.685059, 43.097466), rot(0, 17368, 0));
        AddGoalLocation("10_PARIS_CLUB", "Back Room TV", NORMAL_GOAL, vect(-1939.340942, -478.474091, -180.899628), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Apartment Balcony", NORMAL_GOAL, vect(2403.117676, 957.270508, 863.598877), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Hostel", NORMAL_GOAL, vect(2315.102295, 2511.724365, 651.103638), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Bakery", NORMAL_GOAL, vect(922.178833, 2382.884521, 187.105133), rot(0, 16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Stairs", NORMAL_GOAL, vect(-802.443115, 2434.175781, -132.900146), rot(0, 35000, 0));
        AddGoalLocation("10_PARIS_METRO", "Pillars", NORMAL_GOAL, vect(-3614.988525, 2406.175293, 235.101135), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Media Store", NORMAL_GOAL, vect(1006.833252, 1768.635620, 187.101196), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Alcove Behind Pillar", NORMAL_GOAL, vect(1924.965210, -1234.666016, 187.101776), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Cafe", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-2300.492920, 1459.889160, 333.215088), rot(0, 0, 0));
        return 101;

    case "11_PARIS_CATHEDRAL":
        goal = AddGoal("11_PARIS_CATHEDRAL", "Templar Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoalActor(goal, 1, 'GuntherHermann0', PHYS_Falling);
        AddGoalActor(goal, 2, 'OrdersTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 4, 'SkillAwardTrigger3', PHYS_None);
        AddGoalActor(goal, 5, 'FlagTrigger2', PHYS_None);
        AddGoalActor(goal, 6, 'DataLinkTrigger8', PHYS_None);
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Barracks", NORMAL_GOAL, vect(2990.853516, 30.971684, -392.498993), rot(0, 16384, 0));
        AddActorLocation(loc, 1, vect(2971.853516, 144.971680, -392.498993), rot(0,-8000,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Chapel", NORMAL_GOAL, vect(1860.275635, -9.666374, -371.286804), rot(0, 16384, 0));
        AddActorLocation(loc, 1, vect(2127, -143.666382, -350), rot(0, 32768, 0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Kitchen", NORMAL_GOAL, vect(1511.325317, -3204.465088, -680.498413), rot(0, 32768, 0));
        AddActorLocation(loc, 1, vect(1511.325317, -3123.465088, -680.498413), rot(0,65536,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Gold Vault", NORMAL_GOAL, vect(3480.141602, -3180.397949, -704.496704), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(3879.141602, -2890.397949, -704.496704), rot(0,32768,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "WiB Bedroom", NORMAL_GOAL, vect(3458.506592, -2423.655029, -104.499863), rot(0, -16384, 0));
        AddActorLocation(loc, 1, vect(3433.506592, -2536.655029, -104.499863), rot(0,16384,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Bridge", NORMAL_GOAL, vect(2659.672852, -1515.583862, 393.494843), rot(0, 10720, 0));
        AddActorLocation(loc, 1, vect(2632.672852, -1579.583862, 431.494843), rot(0,12000,0));
        loc = AddGoalLocation("11_PARIS_CATHEDRAL", "Basement", NORMAL_GOAL | VANILLA_GOAL, vect(5193.660645,-1007.544922,-838.674988), rot(0,-17088,0));
        AddActorLocation(loc, 1, vect(4926.411133, -627.878662, -845.294189), rot(0,45728,0));
        return 111;

    case "12_VANDENBERG_CMD":
        AddGoal("12_VANDENBERG_CMD", "Backup Power Keypad", NORMAL_GOAL, 'Keypad0', PHYS_None);
        AddGoal("12_VANDENBERG_CMD", "Backup Power Keypad", NORMAL_GOAL, 'Keypad1', PHYS_None);
        AddGoalLocation("12_VANDENBERG_CMD", "Command Center Second Floor", NORMAL_GOAL, vect(1895.174561, 1405.394287, -1656.404175), rot(0, 32768, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "Third Floor Elevator", NORMAL_GOAL, vect(444.509338, 1503.229126, -1415.007568), rot(0, -16384, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Near Pipes", NORMAL_GOAL | START_LOCATION, vect(-288.769806, 1103.257813, -1984.334717), rot(0, -16384, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(-214.927200, 888.034485, -2043.409302), rot(0, 0, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Globe Room", NORMAL_GOAL | START_LOCATION, vect(-1276.664063, 1168.599854, -1685.868042), rot(0, 16384, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(-1879.828003, 1820.156006, -1777.113892), rot(0, 0, 0));

        loc = AddGoalLocation("12_VANDENBERG_CMD", "Roof", NORMAL_GOAL | START_LOCATION | VANILLA_START, vect(927.361328, 2426.330811, -867.404114), rot(0, 32768, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(657.233215, 2501.673096, -908.798096), rot(0, -16384, 0));

        AddGoalLocation("12_VANDENBERG_CMD", "Front Gate", START_LOCATION, vect(6750.350586, 7763.461426, -3092.699951), rot(0, 0, 0));
        AddGoalLocation("12_VANDENBERG_CMD", "Outdoor Power Generator", NORMAL_GOAL | VANILLA_GOAL, vect(-2371.028564,-96.179214,-2070.390625), rot(0,-32768,0));
        AddGoalLocation("12_VANDENBERG_CMD", "Command Center Power Generator", NORMAL_GOAL | VANILLA_GOAL, vect(1628.947754,1319.745483,-2014.406982), rot(0,-65536,0));
        return 121;

    case "14_VANDENBERG_SUB":
    case "14_OCEANLAB_LAB":
    case "14_OCEANLAB_UC":
        AddGoal("14_OCEANLAB_LAB", "Walton Simons", GOAL_TYPE1, 'WaltonSimons0', PHYS_Falling);
        AddGoalLocation("14_OCEANLAB_LAB", "Vanilla Digger", GOAL_TYPE1 | VANILLA_GOAL, vect(5294.391113,3422.380127,-1775.600830), rot(0,33056,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Construction Sidepath", GOAL_TYPE1, vect(4158,2125,-1775), rot(0,0,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Crew Module", GOAL_TYPE1, vect(2380,3532,-2233), rot(0,0,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Greasel Lab", GOAL_TYPE1, vect(2920,454,-1486), rot(0,50000,0));
        AddGoalLocation("14_OCEANLAB_LAB", "Outside Karkian Lab", GOAL_TYPE1, vect(116,-61,-1967), rot(0,50000,0));
        AddGoalLocation("14_VANDENBERG_SUB", "Rooftop", GOAL_TYPE1, vect(2450,2880,776), rot(0,33080,0));
        AddGoalLocation("14_VANDENBERG_SUB", "Sub Bay", GOAL_TYPE1, vect(5372,-1626,-1424), rot(0,-16368,0));
        AddGoalLocation("14_OCEANLAB_UC", "UC Entry 1", GOAL_TYPE1, vect(945,6230,-4160), rot(0,0,0));
        AddGoalLocation("14_OCEANLAB_UC", "UC Entry 2", GOAL_TYPE1, vect(945,5250,-4160), rot(0,0,0));

        AddGoal("14_OCEANLAB_UC", "UC Computer", NORMAL_GOAL, 'ComputerPersonal0', PHYS_Falling);
        AddGoal("14_OCEANLAB_UC", "Bait Computer", NORMAL_GOAL, 'ComputerPersonal1', PHYS_Falling);
        AddGoalLocation("14_OCEANLAB_UC", "UC", NORMAL_GOAL | VANILLA_GOAL, vect(264.363281, 6605.039551, -3173.865967), rot(0,32720,0));
        AddGoalLocation("14_OCEANLAB_UC", "Bait Station", NORMAL_GOAL | VANILLA_GOAL, vect(-264.784027, 8735.982422, -2904.487549), rot(0,8816,0));
        AddGoalLocation("14_OCEANLAB_UC", "South Wing", NORMAL_GOAL | VANILLA_GOAL, vect(-1133.915039, 6690.755371, -3800.472168), rot(0,16384,0));// non-radioactive
        AddGoalLocation("14_OCEANLAB_UC", "North Wing", NORMAL_GOAL | VANILLA_GOAL, vect(1832.621338, 6919.640137, -3764.490234), rot(0,16384,0));// outside radioactive room
        return 141;

    case "14_OCEANLAB_SILO":
        AddGoal("14_OCEANLAB_SILO", "Howard Strong", NORMAL_GOAL, 'HowardStrong0', PHYS_Falling);

        AddGoalLocation("14_OCEANLAB_SILO", "Third Floor", NORMAL_GOAL, vect(-220.000000, -6829.463379, 55.600639), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Fourth Floor", NORMAL_GOAL, vect(-259.846710, -6848.406250, 326.598969), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Fifth Floor", NORMAL_GOAL, vect(-271.341187, -6832.150391, 535.596741), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Sixth Floor", NORMAL_GOAL, vect(-266.569397, -6868.054199, 775.592590), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Cherry Picker", NORMAL_GOAL | VANILLA_GOAL, vect(-52.397560,-6767.679199,-320.225006), rot(0,-7512,0));

        AddGoal("14_OCEANLAB_SILO", "Jock Escape", GOAL_TYPE1, 'BlackHelicopter0', PHYS_None);
        AddGoalLocation("14_OCEANLAB_SILO", "Vanilla Escape", GOAL_TYPE1 | VANILLA_GOAL, vect(-194.602554, -5680.964355, 1507.895020), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Sniper Tower", GOAL_TYPE1, vect(-842.344604, -3827.978027, 2039.993286), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Cherry Picker", GOAL_TYPE1, vect(-13.000000, -6790.000000, -542.000000), rot(0, 32768, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Computer Room", GOAL_TYPE1, vect(-100.721497, -1331.947754, 904.364380), rot(0, 32768, 0));
        return 142;

    case "15_AREA51_BUNKER":
    case "15_AREA51_ENTRANCE":
    case "15_AREA51_FINAL":
        AddGoalLocation("15_AREA51_BUNKER", "Jock", START_LOCATION | VANILLA_START, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Bunker", START_LOCATION, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Behind the Van", START_LOCATION, vect(-493.825836, 3099.697510, -512.897827), rot(0, 0, 0));

        goal = AddGoal("15_AREA51_BUNKER", "Walton Simons A51", NORMAL_GOAL, 'WaltonSimons0', PHYS_Falling);
        AddGoalActor(goal, 1, 'Trigger0', PHYS_None); //Triggers WaltonTalks
        AddGoalActor(goal, 2, 'OrdersTrigger1', PHYS_None); //WaltonTalks -> Conversation triggers WaltonAttacks
        AddGoalActor(goal, 3, 'AllianceTrigger0', PHYS_None); //WaltonAttacks

        loc = AddGoalLocation("15_AREA51_BUNKER", "Command 24", NORMAL_GOAL | VANILLA_GOAL, vect(1125.623779,3076.459961,-462.398041), rot(0, -33064, 0));
        AddActorLocation(loc, 1, vect(471.648193, 2674.075439, -487.900055), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Behind Supply Shed", NORMAL_GOAL, vect(-1563,3579,-198), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-1358,2887,-160), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Behind Tower", NORMAL_GOAL, vect(-1136,-137,-181), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-1344,740,-160), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Hangar", NORMAL_GOAL, vect(1182,-1140,-478), rot(0, -33064, 0));
        AddActorLocation(loc, 1, vect(781,-235,-487), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_BUNKER", "Bunker Entrance", NORMAL_GOAL, vect(3680,1875,-848), rot(0, -18224, 0));
        AddActorLocation(loc, 1, vect(3470,1212,-800), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_ENTRANCE", "Sector 3 Access", NORMAL_GOAL, vect(-456,124,-16), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-20,80,-180), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_FINAL", "Heliowalton", NORMAL_GOAL, vect(-4400,750,-1475), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-3720,730,-1105), rot(0,0,0));
        loc = AddGoalLocation("15_AREA51_FINAL", "Reactor Lab", NORMAL_GOAL, vect(-3960,-3266,-1552), rot(0, 0, 0));
        AddActorLocation(loc, 1, vect(-3455,-3261,-1560), rot(0,0,0));

        AddGoal("15_AREA51_BUNKER", "Area 51 Blast Door Computer", GOAL_TYPE1, 'ComputerSecurity0', PHYS_None);
        AddGoalLocation("15_AREA51_BUNKER", "the tower", GOAL_TYPE1 | VANILLA_GOAL, vect(-1248.804321,137.393707,442.793121), rot(0, 0, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Command 24", GOAL_TYPE1, vect(1125.200562,2887.646484,-432.319794), rot(0, 0, 0));
        AddGoalLocation("15_AREA51_BUNKER", "the hangar", GOAL_TYPE1, vect(1062.942261,-2496.865723,-443.252533), rot(0, 16384, 0));
        AddGoalLocation("15_AREA51_BUNKER", "the supply shed", GOAL_TYPE1, vect(-1527.608521,3280.824219,-158.588562), rot(0, -16384, 0));

        return 151;
    }

    return mission+1000;
}

function SetDTSGoalLocations()
{
    local int goal;

    goal = AddGoal("06_HONGKONG_WANCHAI_STREET", "Dragon's Tooth Sword", NORMAL_GOAL, 'WeaponNanoSword0', PHYS_None);
    AddGoalActor(goal, 1, 'DataLinkTrigger0', PHYS_None);// DL_Tong_00: Now bring the sword to Max Chen at the Lucky Money Club

    AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "Sword Case", NORMAL_GOAL | VANILLA_GOAL, vect(-1857.841064, -158.911865, 2051.345459), rot(0, 0, 0));
    AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "in Maggie's shower", NORMAL_GOAL, vect(-1294.841064, -1861.911865, 2190.345459), rot(0, 0, 0));
    AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "on Jock's couch", NORMAL_GOAL, vect(836.923828, -1779.652588, 1706.345459), rot(0, 10816, 0));
    AddGoalLocation("06_HONGKONG_WANCHAI_STREET", "in the sniper nest", NORMAL_GOAL, vect(257.923828, -200.652588, 1805.345459), rot(0, 10816, 0));
    AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "in the hold of the boat", NORMAL_GOAL, vect(2293, 2728, -598), rot(0, 10808, 0));
    AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "with the boatperson", NORMAL_GOAL, vect(1775, 2065, -317), rot(0, 0, 0));
    AddGoalLocation("06_HONGKONG_WANCHAI_CANAL", "in the Old China Hand kitchen", NORMAL_GOAL, vect(-1623, 3164, -393), rot(0, -49592, 0));
    AddGoalLocation("06_HONGKONG_WANCHAI_UNDERWORLD", "in the Lucky Money freezer", NORMAL_GOAL, vect(-1780, -2750, -333), rot(0, 27104, 0));
    AddGoalLocation("06_HONGKONG_WANCHAI_MARKET", "in the police vault", NORMAL_GOAL, vect(-480, -720, -107), rot(0, -5564, 0));
}

function AddMission1Goals()
{
    local DeusExGoal newGoal;

    //The MeetPaul conversation would normally give you several goals.
    //Give them manually instead of via that conversation.
    newGoal=player().AddGoal('DefeatNSFCommandCenter',True);
    newGoal.SetText("The NSF seem to be directing the attack from somewhere on the island.  Find the commander.");

    newGoal=player().AddGoal('RescueAgent',False);
    newGoal.SetText("One of UNATCO's top agents is being held inside the Statue.  Break him out, and he'll back you up against the NSF.");

    newGoal=player().AddGoal('MeetFilben',False);
    newGoal.SetText("Meet UNATCO informant Harley Filben at the North Docks.  He has a key to the Statue doors.");

}

function ReplaceBatteryParkSubwayTNT()
{
    local CrateExplosiveSmall tnt;
    local #var(prefix)Barrel1 barrel;
    local class<#var(prefix)Barrel1> barrelclass;
    local bool destroyTNT;
    local int choice;

#ifdef injections
    barrelclass = class'Barrel1';
#else
    barrelclass = class'DXRBarrel1';
#endif

    //The front crates have their tag set to ExplosiveCrate.
    //Since we're changing their types, they should all be set off
    choice = rng(8);
    foreach AllActors(class'CrateExplosiveSmall',tnt){
        destroyTNT = True;
        barrel = None;
        switch(choice){
            case 0:
            case 1:
                //Keep TNT crate - 300 explosion damage
                destroyTNT=False;
                tnt.bIsSecretGoal=True;
                tnt.Tag='ExplosiveCrate';
                break;
            case 2:
                //Explosive barrel - 400 explosion damage
                barrel = Spawn(barrelclass,,,tnt.Location);
                barrel.SkinColor=SC_Explosive;
                break;
            case 3:
                //Flammable Solid barrel - 200 explosion damage
                barrel = Spawn(barrelclass,,,tnt.Location);
                barrel.SkinColor=SC_FlammableSolid;
                break;
            case 4:
            case 5:
                //Poison Barrel
                barrel = Spawn(barrelclass,,,tnt.Location);
                barrel.SkinColor=SC_Poison;
                break;
            case 6:
            case 7:
                //Biohazard Barrel
                barrel = Spawn(barrelclass,,,tnt.Location);
                barrel.SkinColor=SC_Biohazard;
                break;
        }

        if (barrel!=None){
            barrel.bIsSecretGoal=True;
            barrel.BeginPlay();
            barrel.Tag='ExplosiveCrate';
        }

        if(destroyTNT){
            tnt.destroy();
        }
    }
}

function PreFirstEntry()
{
    local #var(prefix)AnnaNavarre anna;
    local #var(prefix)PaulDenton paul;
    local #var(prefix)PaulDentonCarcass paulcarc;
    local FlagTrigger ft;
    local #var(prefix)Barrel1 barrel;
    local #var(prefix)ComputerPersonal cp;
    local Trigger t;
    local int seed;

    Super.PreFirstEntry();
#ifndef revision
    seed = InitGoals(dxr.dxInfo.missionNumber, dxr.localURL);
#endif

    if( dxr.localURL == "01_NYC_UNATCOISLAND" ) {
        dxr.flags.f.SetBool('MeetPaul_Played', true,, 2);
        dxr.flags.f.SetBool('FemJCMeetPaul_Played', true,, 2);
        dxr.flags.f.SetBool('PaulGaveWeapon', true,, 2);
#ifdef revision
        dxr.flags.f.SetBool('PaulGiveWeapon_Played', true,, 2);
        dxr.flags.f.SetBool('FemJCPaulGiveWeapon_Played', true,, 2);
        dxr.flags.f.SetBool('GotFreeWeapon', true,, 2);
#endif
    }
    else if( dxr.localURL == "02_NYC_BATTERYPARK" ) {
        foreach AllActors(class'#var(prefix)AnnaNavarre', anna) {
            anna.SetOrders('Standing');
            anna.SetLocation( vect(1082.845703, 1807.538818, 335.101776) );
            anna.SetRotation( rot(0, -16608, 0) );
            anna.HomeLoc = anna.Location;
            anna.HomeRot = vector(anna.Rotation);
        }
        ReplaceBatteryParkSubwayTNT();
    }
    else if( dxr.localURL == "03_NYC_AIRFIELDHELIBASE" ) {
        foreach AllActors(class'FlagTrigger',ft){
            if (ft.Name=='FlagTrigger0'){
                ft.SetCollisionSize(150, ft.CollisionHeight);
            }
        }
    }
    else if( dxr.localURL == "03_NYC_AIRFIELD" ) {
        foreach AllActors(class'FlagTrigger',ft){
            if (ft.Name=='FlagTrigger0'){
                ft.SetCollisionSize(150, ft.CollisionHeight);
            }
        }
    }
    else if( dxr.localURL == "03_NYC_747" ) {
        foreach AllActors(class'FlagTrigger',ft){
            if (ft.Name=='FlagTrigger1'){
                ft.SetCollisionSize(100, ft.CollisionHeight);
            }
        }
    }
    else if( dxr.localURL == "05_NYC_UNATCOMJ12LAB" ) {
        foreach AllActors(class'#var(prefix)PaulDentonCarcass',paulcarc){
            paulcarc.bInvincible=true;
        }
        foreach AllActors(class'#var(prefix)PaulDenton',paul){
            paul.bDetectable=false;
            paul.bIgnore=true;
            paul.RaiseAlarm=RAISEALARM_Never;
            paul.ChangeAlly('mj12',0,true,false);
        }
    }
    else if( dxr.localURL == "09_NYC_GRAVEYARD" ) {
        foreach AllActors(class'#var(prefix)Barrel1', barrel, 'BarrelOFun') {
            barrel.bExplosive = false;
            barrel.Destroy();
        }
    } else if ( dxr.localURL == "14_OCEANLAB_UC" ) {
        foreach AllActors(class'#var(prefix)ComputerPersonal',cp){
            if (cp.UserList[0].UserName=="USER" || cp.UserList[0].UserName=="UC"){
                cp.UserList[0].UserName="JEBAITED"; //Just to make it a bit more clear this is a bait computer
            }
        }
    } else if ( dxr.localURL == "15_AREA51_BUNKER" ) {
        foreach AllActors(class'Trigger',t){
            if (t.Name=='Trigger1' || t.Name=='Trigger2'){
                t.Destroy(); //Just rely on one trigger for Walton
            }
        }
    }
    SetGlobalSeed( "DXRMissions" $ seed );
    ShuffleGoals();
}

function ShuffleGoals()
{
    local int goalsToLocations[32];

    if( ArrayCount(goalsToLocations) != ArrayCount(goals) ) err("ArrayCount(goalsToLocations) != ArrayCount(goals)");

    if(num_goals == 0 && num_locations == 0) return;
    if(dxr.flags.settings.startinglocations <= 0 && dxr.flags.settings.goals <= 0)
        return;

    MoveActorsOut();
    ChooseGoalLocations(goalsToLocations);
    MoveActorsIn(goalsToLocations);
}

function MoveActorsOut()
{
    local int g, i;
    local Actor a;
    local bool success;

    if(dxr.flags.settings.goals <= 0) return;

    for(g=0; g<num_goals; g++) {
        if( dxr.localURL != goals[g].mapName ) continue;

        for(i=0; i<ArrayCount(goals[g].actors); i++) {
            a = GetActor(goals[g].actors[i]);
            if(a == None) continue;
            a.bCollideWorld = false;
            a.bMovable = True;
            success = a.SetLocation(a.Location + vect(0,0,20000));
            if (!success){
                l("Failed to move "$a.Name$" out");
            }
        }
    }
}

function MoveActorsIn(int goalsToLocations[32])
{
    local int g, i;
    local #var(PlayerPawn) p;

    g = goalsToLocations[num_goals];
    if( dxr.flags.settings.startinglocations > 0 && g > -1 ) {
        p = player();
        l("Moving player to " $ locations[g].name);
        i = PLAYER_LOCATION;
        p.SetLocation(locations[g].positions[i].pos);
        p.SetRotation(locations[g].positions[i].rot);
        rando_start_loc = p.Location;
        b_rando_start = true;
    }

    if( dxr.flags.settings.goals > 0 ) {
        for(g=0; g<num_goals; g++) {
            MoveGoalToLocation(goals[g], locations[goalsToLocations[g]]);
        }
    }
}

function bool _ChooseGoalLocations(out int goalsToLocations[32])
{
    local int i, g1, g2, r, _num_locs, _num_starts;
    local int availLocs[64], goalsOrder[64];

    // build list of availLocs based on flags, also count _num_starts
    _num_locs = 0;
    _num_starts = 0;
    for(i=0; i<num_locations; i++) {
        // exclude the vanilla start locations if randomized starting locations are disabled
        if( dxr.flags.settings.startinglocations <= 0 && (VANILLA_START & locations[i].bitMask) != 0 )
            continue;
        // exclude the vanilla goal locations if randomized goal locations are disabled
        if( dxr.flags.settings.goals <= 0 && (VANILLA_GOAL & locations[i].bitMask) != 0 )
            continue;
        availLocs[_num_locs++] = i;

        if( (START_LOCATION & locations[i].bitMask) != 0)
            _num_starts++;
    }

    // choose a starting location
    goalsToLocations[num_goals] = -1;
    if(_num_starts > 0) {
        for(i=0; i<20; i++) {
            r = rng(_num_locs);
            if( (START_LOCATION & locations[availLocs[r]].bitMask) == 0)
                continue;

            goalsToLocations[num_goals] = availLocs[r];
            _num_locs--;
            availLocs[r] = availLocs[_num_locs];
            break;
        }
        if(goalsToLocations[num_goals] == -1)
            return false;
    }

    // do the goals in a random order
    for(i=0; i<num_goals; i++) {
        goalsOrder[i] = i;
    }
    for(i=0; i<num_goals; i++) {
        r = rng(num_goals);
        g1 = goalsOrder[i];
        goalsOrder[i] = goalsOrder[r];
        goalsOrder[r] = g1;
    }

    // choose the goal locations
    for(g1=0; g1<num_goals; g1++) {
        r = rng(_num_locs);
        i = goalsOrder[g1];
        goalsToLocations[i] = availLocs[r];
        if( (goals[i].bitMask & locations[availLocs[r]].bitMask) == 0)
            return false;

        spoilers[i].goalName=goals[i].name;
        spoilers[i].goalLocation=locations[availLocs[r]].name;

        _num_locs--;
        availLocs[r] = availLocs[_num_locs];
    }

    // check mutual exclusions
    for(i=0; i<num_mututally_exclusives; i++) {
        for(g1=0; g1<num_goals; g1++) {
            // num_goals is the player start, so we use <= instead of <
            for(g2=g1+1; g2<=num_goals; g2++) {
                if( mutually_exclusive[i].L1 == goalsToLocations[g1] && mutually_exclusive[i].L2 == goalsToLocations[g2] )
                    return false;
                if( mutually_exclusive[i].L2 == goalsToLocations[g1] && mutually_exclusive[i].L1 == goalsToLocations[g2] )
                    return false;
            }
        }
    }
    return true;
}

function ChooseGoalLocations(out int goalsToLocations[32])
{
    local int attempts;
    for(attempts=0; attempts<1000; attempts++) {
        if(_ChooseGoalLocations(goalsToLocations)) return;
    }
    err("ChooseGoalLocations took too many attempts!");
}

function Actor GetActor(out GoalActor ga)
{
    local Actor a;
    if( ga.actorName == '' ) return None;

    foreach AllActors(class'Actor', a) {
#ifdef hx
        if(a.GetPropertyText("PrecessorName") == string(ga.actorName)) {
#else
        if(a.name == ga.actorName) {
#endif
            ga.a = a;
            return a;
        }
    }
    return None;
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;
    local BarrelAmbrosia ambrosia;
    local FlagTrigger ft;
    local SkillAwardTrigger st;
    local OrdersTrigger ot;
    local AllianceTrigger at;
    local Trigger t;
    local Inventory inv;
    local Ammo a;
    local WeaponNanoSword dts;
    local DataLinkTrigger dlt;

    local FlagBase f;

    if( dxr == None ){
        log("Couldn't find DXRando while creating goal");
        return;
    }
    f = dxr.flagbase;

    info("CreateGoal " $ g.name @ Loc.name);

    switch(g.name) {
    case "Nicolette":
        sp = Spawn(class'#var(prefix)NicoletteDuClare',, 'DXRMissions', Loc.positions[0].pos);
        g.actors[0].a = sp;
        RemoveReactions(sp);
        sp.BindName = "NicoletteDuClare";
        sp.FamiliarName = "Young Woman";
        sp.UnfamiliarName = "Young Woman";
        sp.bInvincible = true;
        sp.SetOrders('Dancing');
        sp.ConBindEvents();
        sp.RaiseAlarm = RAISEALARM_Never;
        break;

    case "Jaime":
        if(dxr.flagbase.GetBool('JaimeLeftBehind')) {
            sp = Spawn(class'#var(prefix)JaimeReyes',, 'DXRMissions', Loc.positions[0].pos);
            g.actors[0].a = sp;
            RemoveReactions(sp);
            sp.SetOrders('Standing');
            sp.RaiseAlarm = RAISEALARM_Never;
        }
        break;

    case "Harley Filben":
        // Harley Filben is also randomized in mission 3, but not across maps
        sp = Spawn(class'#var(prefix)HarleyFilben',, 'DXRMissions', Loc.positions[0].pos);
        g.actors[0].a = sp;
        sp.UnfamiliarName = "Harley Filben";
        sp.bInvincible = true;
        sp.bImportant = true;
        sp.SetOrders('Standing');
        RemoveReactions(sp);
        break;

    case "Vinny":
        sp = Spawn(class'#var(prefix)NathanMadison',, 'DXRMissions', Loc.positions[0].pos);
        g.actors[0].a = sp;
        sp.BindName = "Sailor";
        sp.FamiliarName = "Vinny";
        sp.UnfamiliarName = "Soldier";
        sp.SetOrders('Standing');
        sp.ConBindEvents();
        RemoveReactions(sp);
        break;

    case "Joe Greene":
        sp = Spawn(class'#var(prefix)JoeGreene',, 'DXRMissions', Loc.positions[0].pos);
        g.actors[0].a = sp;
        sp.BarkBindName = "Male";
        sp.SetOrders('Standing');
        sp.ConBindEvents();
        break;

    case "Walton Simons":
        sp = Spawn(class'#var(prefix)WaltonSimons',, 'DXRMissions', Loc.positions[0].pos);
        ot = Spawn(class'OrdersTrigger',,'simonsattacks',Loc.positions[0].pos);
        g.actors[0].a = sp;
        g.actors[1].a = ot;

        sp.BarkBindName = "WaltonSimons";
        sp.Tag='WaltonSimons';
        sp.SetOrders('WaitingFor');
        sp.bInvincible=False;

        //scuba in the OceanLab, probably needs to be mj12 on shore, maybe something else if in UC area?
        if (Loc.mapName == "14_OCEANLAB_LAB"){
            sp.SetAlliance('scuba');
        } else if (Loc.mapName=="14_VANDENBERG_SUB"){
            sp.SetAlliance('mj12');
        } else if (Loc.mapName=="14_OCEANLAB_UC"){
            sp.SetAlliance('spider');
        }

        GiveItem(sp,class'WeaponPlasmaRifle',100);
        GiveItem(sp,class'WeaponNanoSword');

        sp.ConBindEvents();
        sp.bInWorld=False;

        ot.Event='WaltonSimons';
        ot.Orders='Attacking';
        ot.SetCollision(False,False,False);

        break;

    case "Walton Simons A51": //Much the same as above, but he could be dead already
        if (f.GetBool('WaltonSimons_Dead')){
            log("Walton Simons dead, not spawning");
            return;
        }

        sp = Spawn(class'#var(prefix)WaltonSimons',, 'DXRMissions', Loc.positions[0].pos);
        ot = Spawn(class'OrdersTrigger',,'WaltonTalks',Loc.positions[0].pos);
        at = Spawn(class'AllianceTrigger',,'WaltonAttacks',Loc.positions[0].pos);
        t = Spawn(class'Trigger',,,Loc.positions[1].pos);
        g.actors[0].a = sp;
        g.actors[1].a = ot;
        g.actors[2].a = at;
        g.actors[3].a = t;

        sp.BarkBindName = "WaltonSimons";
        sp.Tag='WaltonSimons';
        sp.SetOrders('WaitingFor');
        sp.bInvincible=False;

        sp.SetAlliance('mj12');

        GiveItem(sp,class'WeaponPlasmaRifle',100);
        GiveItem(sp,class'WeaponNanoSword');
        GiveItem(sp,class'WeaponLAM',3); //A bomb!

        sp.ConBindEvents();

        ot.Event='WaltonSimons';
        ot.Orders='RunningTo';
        ot.SetCollision(False,False,False);

        at.Event='WaltonSimons';
        at.Alliances[0].AllianceLevel=-1;
        at.Alliances[0].AllianceName='Player';
        at.Alliances[0].bPermanent=True;
        at.SetCollision(False,False,False);

        t.Event='WaltonTalks';
        t.SetCollisionSize(1024,300);

        break;

    case "747 Ambrosia":
        ambrosia = Spawn(class'BarrelAmbrosia',, 'DXRMissions', Loc.positions[0].pos);
        ft = Spawn(class'FlagTrigger',, '747BarrelUsed', Loc.positions[1].pos);
        st = Spawn(class'SkillAwardTrigger',, 'skills', Loc.positions[2].pos);
        g.actors[0].a = ambrosia;
        g.actors[1].a = ft;
        g.actors[2].a = st;

        //Nothing particularly special about the barrel, all the magic is in the FlagTrigger
        ambrosia.bPushable = False;

        ft.SetCollisionSize(100,40);
        ft.Event = 'skills';
        ft.bInitiallyActive = True;
        ft.bTriggerOnceOnly = True;
        ft.bSetFlag = True;
        ft.bTrigger = True;
        ft.flagExpiration = 999;
        ft.FlagName = '747Ambrosia';
        ft.flagValue = True;

        st.SetCollision(False,False,False);
        st.awardMessage="Goal Accomplishment Bonus";
        st.skillPointsAdded = 100;
        break;

    case "Dragon's Tooth Sword":
        dts = Spawn(class'WeaponNanoSword',,,Loc.positions[0].pos,Loc.positions[0].rot);
        dlt = Spawn(class'DataLinkTrigger',,,Loc.positions[0].pos);

        g.actors[0].a=dts;
        g.actors[1].a=dlt;

        dlt.SetCollision(True,False,False);
        dlt.Tag='';
        dlt.datalinkTag='DL_Tong_00';
        dlt.SetCollisionSize(100,20);

        break;
    }
}

function AnyEntry()
{
    Super.AnyEntry();
    SetTimer(1, true);
}

function Timer()
{
    local FlagBase f;
    local #var(prefix)NicoletteDuClare nico;
    local #var(prefix)WaltonSimons Walton;
    local #var(prefix)BlackHelicopter chopper;
    local #var(prefix)ParticleGenerator gen;
    local int count;

    Super.Timer();
    if( dxr == None ) return;
    f = dxr.flagbase;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        if (!RandodMissionGoals && !dxr.flagbase.GetBool('PlayerTraveling')){
            //Secondary objectives get cleared if added in pre/postFirstEntry due to the MissionScript, the MissionsScript also clears the PlayerTraveling flag
            AddMission1Goals();
            RandodMissionGoals=true;
        }
        break;
    case "03_NYC_HANGAR":
        // copied from Mission03.uc, check for Ambrosia Barrels being tagged
        if (!f.GetBool('Barrel3Checked'))
        {
            if (f.GetBool('747Ambrosia'))
            {
                count = 1;
                if (f.GetBool('HelicopterBaseAmbrosia'))
                    count++;
                if (f.GetBool('BoatDocksAmbrosia'))
                    count++;

                if (count == 1)
                    Player().StartDataLinkTransmission("DL_TaggedOne");
                else if (count == 2)
                    Player().StartDataLinkTransmission("DL_TaggedTwo");
                else if (count == 3)
                    Player().StartDataLinkTransmission("DL_TaggedThree");

                f.SetBool('Barrel3Checked', True,, 4);
            }
        }
        break;
    case "10_PARIS_METRO":
        if (f.GetBool('MeetNicolette_Played') &&
            !f.GetBool('NicoletteLeftClub'))
        {
            f.SetBool('NicoletteLeftClub', True,, 11);

            foreach AllActors(class'#var(prefix)NicoletteDuClare', nico, 'DXRMissions') {
                nico.Event = '';
                nico.Destroy();
                player().ClientFlash(1,vect(2000,2000,2000));
                gen = Spawn(class'#var(prefix)ParticleGenerator',,, nico.Location);
                gen.SetCollision(false, false, false);
                gen.SetLocation(nico.Location);
                gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
                gen.LifeSpan = 2;
                gen.particleDrawScale = 5;
                gen.riseRate = 1;
                player().PlaySound(Sound'DeusExSounds.Weapons.GasGrenadeExplode');
            }

            foreach AllActors(class'#var(prefix)NicoletteDuClare', nico)
                nico.EnterWorld();

            foreach AllActors(class'#var(prefix)BlackHelicopter', chopper, 'BlackHelicopter')
                chopper.EnterWorld();
        }
        break;

    case "14_VANDENBERG_SUB":
    case "14_OCEANLAB_UC":
        if (!WaltonAppeared && f.GetBool('DL_downloaded_Played'))
        {
            foreach AllActors(class'#var(prefix)WaltonSimons', Walton){
                Walton.EnterWorld();
            }
            WaltonAppeared=True;

        }
        break;
    }
}

function GenerateDTSHintCube(Goal g, GoalLocation Loc)
{
#ifdef injections
    local #var(prefix)DataCube dc;
    dc = Spawn(class'#var(prefix)DataCube',,, vect(-1857.841064, -158.911865, 2051.345459));
#else
    local DXRInformationDevices dc;
    dc = Spawn(class'DXRInformationDevices',,, vect(-1857.841064, -158.911865, 2051.345459));
#endif

    if (dc!=None){
        dc.plaintext = "I borrowed the sword but forgot it somewhere...  Maybe "$Loc.name$"?";
        dc.bIsSecretGoal=True; //So it doesn't move
    }

}

function MoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local int i;
    local Actor a;
    local ScriptedPawn sp;
    local #var(Mover) m;
    local string result;
    local #var(prefix)DataCube dc1;
#ifdef injections
    local #var(prefix)DataCube dc2;
#else
    local DXRInformationDevices dc2;
#endif

    result = g.name $ " to " $ Loc.name;
    info("Moving " $ result $ " (" $ Loc.mapName @ Loc.positions[0].pos $")");

    if(g.mapName == dxr.localURL && Loc.mapName != dxr.localURL) {
        // delete from map
        for(i=0; i<ArrayCount(g.actors); i++) {
            a = g.actors[i].a;
            if(a == None) continue;
            a.Event = '';
            a.Destroy();
        }

        if (g.name=="Dragon's Tooth Sword"){
            GenerateDTSHintCube(g,Loc);
        }

        return;
    }
    else if(g.mapName != dxr.localURL && Loc.mapName == dxr.localURL) {
        CreateGoal(g, Loc);
    }

    for(i=0; i<ArrayCount(g.actors); i++) {
        a = g.actors[i].a;
        if(a == None) continue;
        a.bVisionImportant = true;
        if(ElectronicDevices(a) != None)
            ElectronicDevices(a).ItemName = g.name;
        MoveActor(a, Loc.positions[i].pos, Loc.positions[i].rot, g.actors[i].physics);
    }

    if( (Loc.bitMask & SITTING_GOAL) != 0) {
        for(i=0; i<ArrayCount(g.actors); i++) {
            sp = ScriptedPawn(g.actors[i].a);
            if(sp == None) continue;
            sp.SetOrders('Sitting');
        }
    }

    // hardcoded cleanup stuff
    if(g.name == "Generator" && Loc.name != "Warehouse") {
        a = AddBox(class'#var(prefix)CrateUnbreakableLarge', vect(505.710449, -605, 162.091278), rot(16384,0,0));
        a.SetCollisionSize(a.CollisionRadius * 4, a.CollisionHeight * 4);
        a.bMovable = false;
        a.DrawScale = 4;
        a = AddBox(class'#var(prefix)CrateUnbreakableLarge', vect(677.174988, -809.484558, 114.097824), rot(0,0,0));
        a.SetCollisionSize(a.CollisionRadius * 2, a.CollisionHeight * 2);
        a.bMovable = false;
        a.DrawScale = 2;

        foreach AllActors(class'#var(Mover)', m, 'Debris') {
            m.Tag = '';
            m.Event = '';
        }
    } else if (g.name=="Area 51 Blast Door Computer" && Loc.name != "the tower") {
        foreach AllActors(class'#var(prefix)DataCube',dc1){
            if(dc1.TextTag=='15_Datacube07'){
#ifdef injections
                dc2 = Spawn(class'#var(prefix)DataCube',,, dc1.Location, dc1.Rotation);
#else
                dc2 = Spawn(class'DXRInformationDevices',,, dc1.Location, dc1.Rotation);
#endif
                if( dc2 != None ){
                     dc2.plaintext = "Yusef:|n|nThey've jammed all communications, even narrow band microcasts, so this is the only way I could pass a message to you.  ";
                     dc2.plaintext = dc2.plaintext $ "I don't know who these guys are -- they're not ours, not any of ours I've ever seen at least -- but they're slaughtering us.  ";
                     dc2.plaintext = dc2.plaintext $ "I managed to hack the first layer of the Dreamland systems, but the best I could do was lock the bunker doors and reroute control to the security console in "$Loc.name$".  ";
                     dc2.plaintext = dc2.plaintext $ "Should take them awhile to figure that one out, and the moment they do I'll nail the first bastard that sticks his head out of the hole.  If something happens to me, the login is ";
                     dc2.plaintext = dc2.plaintext $ "\"a51\" and the password is \"xx15yz\".|n|n";
                     dc2.plaintext = dc2.plaintext $ "BTW, be careful -- a squad made it out before I managed to lock the doors: they headed for the warehouse and then I lost contact with them.|n|n--Hawkins";
                     l("DXRMissions spawned "$dc2 @ dc2.plaintext @ dc1.Location);
                     dc1.Destroy();
                }
                else warning("failed to spawn tower datacube at "$dc1.Location);


            }

        }
    } else if (g.name=="Dragon's Tooth Sword"){
        g.actors[0].a.bIsSecretGoal=True; //We'll use this to stop it from being swapped
        if (Loc.name!="Sword Case"){
            g.actors[1].a.Tag=''; //Change the tag so it doesn't get hit if the case opens

            //Make the datalink trigger actually bumpable
            g.actors[1].a.SetCollision(True,False,False);
            g.actors[1].a.SetCollisionSize(100,20);

            if ( dxr.localURL == "06_HONGKONG_WANCHAI_STREET" ){
                GenerateDTSHintCube(g,Loc);
            }

        }
    } else if (g.name=="Jock Escape") {
        if(Loc.name=="Cherry Picker") {
            g.actors[0].a.DrawScale = 0.5;
            g.actors[0].a.SetCollisionSize(200, 50);
        } else {
            g.actors[0].a.DrawScale = 1;
            g.actors[0].a.SetCollisionSize(320, 87);
        }
        Vehicles(g.actors[0].a).FamiliarName="Jock Escape";
        Vehicles(g.actors[0].a).UnFamiliarName="Jock Escape";
    }
}

function bool MoveActor(Actor a, vector loc, rotator rotation, EPhysics p)
{
    local #var(prefix)ScriptedPawn sp;
    local Mover m;
    local bool success, oldbCollideWorld;
    local #var(prefix)Vehicles v;

    l("moving " $ a $ " from (" $ a.location $ ") to (" $ loc $ ")" );
    oldbCollideWorld = a.bCollideWorld;
    if(p == PHYS_None || p == PHYS_MovingBrush) a.bCollideWorld = false;
    a.bMovable=True;
    success = a.SetLocation(loc);
    if( success == false ) {
        a.bCollideWorld = oldbCollideWorld;
        warning("failed to move "$a$" to "$loc);
        return false;
    }
    a.SetRotation(rotation);
    a.SetPhysics(p);
    if(p == PHYS_None || p == PHYS_MovingBrush) a.bCollideWorld = oldbCollideWorld;

    sp = #var(prefix)ScriptedPawn(a);
    v = #var(prefix)Vehicles(a);
    m = Mover(a);

    if( sp != None ) {
        if(sp.Orders == 'Patrolling')
            sp.SetOrders('Wandering');
        if(sp.Orders == 'Sitting')
            sp.SetOrders('Standing');
        sp.HomeLoc = sp.Location;
        sp.HomeRot = vector(sp.Rotation);
        sp.DesiredRotation = rotation;
        if (!sp.bInWorld){
            sp.WorldPosition = sp.Location;
            sp.SetLocation(sp.Location+vect(0,0,20000));
        }
        else a.bCollideWorld = true;
    }
    else if ( v != None ) {
#ifndef hx
        if (!v.bInWorld){
            v.WorldPosition = v.Location;
            v.SetLocation(v.Location+vect(0,0,20000));
        }
        else a.bCollideWorld = true;
#endif
    }
    else if( m != None ) {
        m.BasePos = a.Location;
        m.BaseRot = a.Rotation;
    } else {
        a.bCollideWorld = true;
    }

    return true;
}

function bool MoveGoalTo(string goalName, int locNumber)
{
    local int i;

    for(i=0; i<num_goals; i++) {
        if(goalName == goals[i].name) {
            MoveGoalToLocation(goals[i], locations[locNumber]);
            player().ClientMessage("Goal Location: "$locations[locNumber].name);
            return true;
        }
    }
    return false;
}

static function bool IsCloseToStart(DXRando dxr, vector loc)
{
    local PlayerStart ps;
    local Teleporter t;
    local float too_close, dist;
    local DXRMissions m;

    too_close = 90*16;

    m = DXRMissions(dxr.FindModule(class'DXRMissions'));
    if( dxr.localURL == "12_VANDENBERG_GAS" ) {
        if ( VSize(vect(168.601334, 607.866882, -980.902832) - loc) < too_close ) return true;
    }
    if( m != None && m.b_rando_start ) {
        if ( VSize(m.rando_start_loc - loc) < too_close ) return true;
        else return false;
    }
    else {
        foreach dxr.RadiusActors(class'PlayerStart', ps, too_close, loc) {
            dist = VSize(loc-ps.location);
            if( dist < too_close ) return true;
        }
    }

    foreach dxr.RadiusActors(class'Teleporter', t, too_close, loc) {
        if( t.Tag == '' ) continue;
        dist = VSize(loc-t.location);
        if( dist < too_close ) return true;
    }

    return false;
}

//tests to ensure that there are more goal locations than movable actors for each map
function RunTests()
{
    local int i, total;
    Super.RunTests();
}
