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

var Goal goals[32];
var GoalLocation locations[64];
var MutualExclusion mutually_exclusive[20];
var int num_goals, num_locations, num_mututally_exclusives;

var config bool allow_vanilla;

var vector rando_start_loc;
var bool b_rando_start;

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
        // TODO: allow Leo to spawn on the dock only if the player did not spawn at unatco, need to make mutual_exclusions work first
        //AddGoalLocation("01_NYC_UNATCOISLAND", "Dock", START_LOCATION | VANILLA_START, vect(-4760.569824, 10430.811523, -280.674988), rot(0, -7040, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "UNATCO HQ", START_LOCATION, vect(-6348.445313, 1912.637207, -111.428482), rot(0, 0, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Harley Filben Dock", START_LOCATION, vect(1297.173096, -10257.972656, -287.428131), rot(0, 0, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Electric Bunker", NORMAL_GOAL | START_LOCATION, vect(6552.227539, -3246.095703, -447.438049), rot(0, 0, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Jail", NORMAL_GOAL | START_LOCATION, vect(2127.692139, -1774.869141, -149.140366), rot(0, 0, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Hut", NORMAL_GOAL, vect(-2407.206787, 205.915558, -128.899979), rot(0, 30472, 0));
        AddGoalLocation("01_NYC_UNATCOISLAND", "Top of the Base", NORMAL_GOAL, vect(2980.058105, -669.242554, 1056.577271), rot(0, 0, 0));
        AddGoalLocation("01_nyc_unatcoisland", "Top of the Statue", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(2931.230957, 27.495235, 2527.800049), rot(0, 14832, 0));
        return 11;

    case "02_NYC_BATTERYPARK":
        goal = AddGoal("02_NYC_BATTERYPARK", "Ambrosia", NORMAL_GOAL, 'BarrelAmbrosia0', PHYS_Falling);
        AddGoalActor(goal, 1, 'SkillAwardTrigger0', PHYS_None);
        AddGoalActor(goal, 2, 'GoalCompleteTrigger0', PHYS_None);
        AddGoalActor(goal, 3, 'FlagTrigger1', PHYS_None);
        AddGoalActor(goal, 4, 'DataLinkTrigger1', PHYS_None);

        AddGoalLocation("02_NYC_BATTERYPARK", "Dock", START_LOCATION | VANILLA_START, vect(-619.571289, -3679.116455, 255.099762), rot(0, 29856, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Ventilation system", NORMAL_GOAL | START_LOCATION, vect(-4310.507813, 2237.952637, 189.843536), rot(0, 0, 0));

        loc = AddGoalLocation("02_NYC_BATTERYPARK", "Ambrosia Vanilla", NORMAL_GOAL | VANILLA_GOAL | START_LOCATION, vect(507.282898, -1066.344604, -403.132751), rot(0, 16536, 0));
        AddActorLocation(loc, PLAYER_LOCATION, vect(81.434570, -1123.060547, -384.397644), rot(0, 8000, 0));

        AddGoalLocation("02_NYC_BATTERYPARK", "In the command room", NORMAL_GOAL, vect(650.060547, -989.234863, -178.095200), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Behind the cargo", NORMAL_GOAL, vect(58.725319, -446.887207, -416.899323), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "On the desk", NORMAL_GOAL, vect(-644.152161, -676.281738, -379.581146), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Walkway by the water", NORMAL_GOAL, vect(-420.000000, -2222.000000, -420.899750), rot(0, 0, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway stairs", NORMAL_GOAL, vect(-4993.205078, 1919.453003, -73.239639), rot(0, 16384, 0));
        AddGoalLocation("02_NYC_BATTERYPARK", "Subway", NORMAL_GOAL, vect(-4727.703613, 3116.336670, -336.900604), rot(0, 0, 0));
        return 21;

    case "02_NYC_WAREHOUSE":
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
        return 33;

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
        return 51;

    case "05_NYC_UNATCOHQ":
        AddGoal("05_NYC_UNATCOHQ", "Alex Jacobson", NORMAL_GOAL, 'AlexJacobson0', PHYS_Falling);
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
        AddGoal("06_HONGKONG_VERSALIFE", "Mr. Hundly", NORMAL_GOAL, 'Businessman0', PHYS_Falling);
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

    case "08_NYC_Bar":
    case "08_NYC_FreeClinic":
    case "08_NYC_Hotel":
    case "08_NYC_Smug":
    case "08_NYC_Street":
    case "08_NYC_Underground":
        AddGoal("08_NYC_Bar", "Harley Filben", NORMAL_GOAL, 'HarleyFilben0', PHYS_Falling);
        goal = AddGoal("08_NYC_Bar", "Vinny", NORMAL_GOAL, 'NathanMadison0', PHYS_Falling);
        //AddGoalActor(goal, 1, 'SandraRenton0', PHYS_Falling); TODO?
        //AddGoalActor(goal, 2, 'CoffeeTable0', PHYS_Falling);
        AddGoal("08_NYC_FreeClinic", "Joe Greene", NORMAL_GOAL, 'JoeGreene0', PHYS_Falling);
        AddGoalLocation("08_NYC_Bar", "Bar Table", NORMAL_GOAL | VANILLA_GOAL | SITTING_GOAL, vect(-1689.125122, 337.159912, 63.599533), rot(0,-10144,0));
        AddGoalLocation("08_NYC_Bar", "Bar", NORMAL_GOAL | VANILLA_GOAL, vect(-931.038086, -488.537109, 47.600464), rot(0,9536,0));
        AddGoalLocation("08_NYC_FreeClinic", "Clinic", NORMAL_GOAL | VANILLA_GOAL, vect(904.356262, -1229.045166, -272.399506), rot(0,31640,0));
        AddGoalLocation("08_NYC_Underground", "Sewers", NORMAL_GOAL, vect(1012.048462, -303.517639, -560.397888), rot(0,16384,0));
        AddGoalLocation("08_NYC_Hotel", "Hotel", NORMAL_GOAL | SITTING_GOAL, vect(-108.541245, -2709.490479, 111.600838), rot(0,20000,0));
        AddGoalLocation("08_NYC_Street", "Basketball Court", NORMAL_GOAL, vect(2694.934082, -2792.844971, -448.396637), rot(0,32768,0));
        return 81;

    case "09_NYC_GRAVEYARD":
        goal = AddGoal("09_NYC_GRAVEYARD", "Jammer", NORMAL_GOAL, 'BreakableWall1', PHYS_Falling);
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
        goal = AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover40', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator10', PHYS_None);
        AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover16', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator4', PHYS_None);
        AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover33', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator7', PHYS_None);
        AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover31', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator5', PHYS_None);
        AddGoal("09_NYC_SHIPBELOW", "Weld Point", NORMAL_GOAL, 'DeusExMover32', PHYS_None);
        AddGoalActor(goal, 1, 'ParticleGenerator6', PHYS_None);

        AddGoalLocation("09_NYC_SHIPBELOW", "North Engine Room", NORMAL_GOAL, vect(-384.000000, 1024.000000, -272.000000), rot(0, 49152, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Balcony", NORMAL_GOAL, vect(-3296.000000, -1664.000000, -112.000000), rot(0, 81920, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps Hallway", NORMAL_GOAL, vect(-2480.000000, -448.000000, -144.000000), rot(0, 32768, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "SE Electrical Room", NORMAL_GOAL, vect(-3952.000000, 768.000000, -416.000000), rot(0, 0, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "South Helipad", NORMAL_GOAL, vect(-5664.000000, -928.000000, -432.000000), rot(0, 16384, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Storage Room", NORMAL_GOAL, vect(-4080.000000, -816.000000, -128.000000), rot(0, 32768, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "Helipad Air Control", NORMAL_GOAL, vect(-4720.000000, 1536.000000, -144.000000), rot(0, -16384, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "Fan Room", NORMAL_GOAL, vect(-3200.000000, -48.000000, -96.000000), rot(0, 0, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "Engine Control Room", NORMAL_GOAL, vect(-288.000000, -432.000000, 112.000000), rot(-16384, 16384, 0));
        AddGoalLocation("09_NYC_SHIPBELOW", "NW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(832.000000,1024.000000,-432.000000), rot(0,49152,0));
        AddGoalLocation("09_NYC_SHIPBELOW", "NE Electical Room", NORMAL_GOAL | VANILLA_GOAL, vect(-3680.000000,1647.000000,-416.000000), rot(0,49152,0));
        AddGoalLocation("09_NYC_SHIPBELOW", "East Helipad", NORMAL_GOAL | VANILLA_GOAL, vect(-6528.000000,200.000000,-448.000000), rot(0,65536,0));
        AddGoalLocation("09_NYC_SHIPBELOW", "Bilge Pumps", NORMAL_GOAL | VANILLA_GOAL, vect(-3296.000000,-1664.000000,-416.000000), rot(0,81920,0));
        AddGoalLocation("09_NYC_SHIPBELOW", "SW Engine Room", NORMAL_GOAL | VANILLA_GOAL, vect(832.000000,-1024.000000,-416.000000), rot(0,16384,0));
        return 92;

    case "10_PARIS_METRO":
    case "10_PARIS_CLUB":
        AddGoal("10_PARIS_CLUB", "Nicolette", NORMAL_GOAL, 'NicoletteDuClare0', PHYS_Falling);
        AddGoalLocation("10_PARIS_CLUB", "Club", NORMAL_GOAL | VANILLA_GOAL, vect(-673.488708, -1385.685059, 43.097466), rot(0, 17368, 0));
        AddGoalLocation("10_PARIS_CLUB", "Back Room TV", NORMAL_GOAL, vect(-1939.340942, -478.474091, -180.899628), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Apartment", NORMAL_GOAL, vect(868.070190, 1178.463989, 507.092682), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Hostel", NORMAL_GOAL, vect(2315.102295, 2511.724365, 651.103638), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Bakery", NORMAL_GOAL, vect(922.178833, 2382.884521, 187.105133), rot(0, 16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Stairs", NORMAL_GOAL, vect(-802.443115, 2434.175781, -132.900146), rot(0, 35000, 0));
        AddGoalLocation("10_PARIS_METRO", "Pillars", NORMAL_GOAL, vect(-3614.988525, 2406.175293, 235.101135), rot(0, -16384, 0));
        AddGoalLocation("10_PARIS_METRO", "Media Store", NORMAL_GOAL, vect(1006.833252, 1768.635620, 187.101196), rot(0, 0, 0));
        AddGoalLocation("10_PARIS_METRO", "Alcove Behind Pillar", NORMAL_GOAL, vect(1924.965210, -1234.666016, 187.101776), rot(0, 0, 0));
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
        AddActorLocation(loc, 1, vect(2114.275635, -143.666382, -371.286804), rot(0, 32768, 0));
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

    case "14_OCEANLAB_UC":
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
        AddGoalLocation("14_OCEANLAB_SILO", "Water", GOAL_TYPE1, vect(-94.721497, -6812.947754, -1168.635620), rot(0, 0, 0));
        AddGoalLocation("14_OCEANLAB_SILO", "Computer Room", GOAL_TYPE1, vect(-100.721497, -1331.947754, 904.364380), rot(0, 32768, 0));
        return 142;

    case "15_AREA51_BUNKER":
        AddGoalLocation("15_AREA51_BUNKER", "Jock", START_LOCATION | VANILLA_START, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Bunker", START_LOCATION, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
        AddGoalLocation("15_AREA51_BUNKER", "Behind the Van", START_LOCATION, vect(-493.825836, 3099.697510, -512.897827), rot(0, 0, 0));
        return 151;
    }

    return mission+1000;
}

function PreFirstEntry()
{
    local #var(prefix)AnnaNavarre anna;
    local int goalsToLocations[32];
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
    }

    SetGlobalSeed( "DXRMissions" $ seed );

    if( ArrayCount(goalsToLocations) != ArrayCount(goals) ) err("ArrayCount(goalsToLocations) != ArrayCount(goals)");

    if(num_goals == 0) return;
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

    if(dxr.flags.settings.goals <= 0) return;

    for(g=0; g<num_goals; g++) {
        if( dxr.localURL != goals[g].mapName ) continue;

        for(i=0; i<ArrayCount(goals[g].actors); i++) {
            a = GetActor(goals[g].actors[i]);
            if(a == None) continue;
            a.bCollideWorld = false;
            a.SetLocation(a.Location + vect(0,0,20000));
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
    local int availLocs[64];

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
        for(i=0; i<10; i++) {
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

    // choose the goal locations
    for(i=0; i<num_goals; i++) {
        r = rng(_num_locs);
        goalsToLocations[i] = availLocs[r];
        if( (goals[i].bitMask & locations[availLocs[r]].bitMask) == 0)
            return false;

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
        if(a.name == ga.actorName) {
            ga.a = a;
            return a;
        }
    }
    return None;
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;

    switch(g.name) {
    case "Nicolette":
        sp = Spawn(class'#var(prefix)NicoletteDuClare',, 'DXRMissions');
        g.actors[0].a = sp;
        sp.BindName = "NicoletteDuClare";
        sp.FamiliarName = "Young Woman";
        sp.UnfamiliarName = "Young Woman";
        sp.bInvincible = true;
        sp.SetOrders('Dancing');
        sp.ConBindEvents();
        break;

    case "Harley Filben":
        // Harley Filben is also randomized in mission 3, but not across maps
        sp = Spawn(class'#var(prefix)HarleyFilben',, 'DXRMissions');
        g.actors[0].a = sp;
        sp.UnfamiliarName = "Harley Filben";
        sp.bInvincible = true;
        sp.bImportant = true;
        sp.SetOrders('Standing');
        break;

    case "Vinny":
        sp = Spawn(class'#var(prefix)NathanMadison',, 'DXRMissions');
        g.actors[0].a = sp;
        sp.BindName = "Sailor";
        sp.FamiliarName = "Vinny";
        sp.UnfamiliarName = "Soldier";
        sp.SetOrders('Standing');
        sp.ConBindEvents();
        break;

    case "Joe Greene":
        sp = Spawn(class'#var(prefix)JoeGreene',, 'DXRMissions');
        g.actors[0].a = sp;
        sp.BarkBindName = "Male";
        sp.SetOrders('Standing');
        sp.ConBindEvents();
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
    local NicoletteDuClare nico;
    local BlackHelicopter chopper;
    local ParticleGenerator gen;

    Super.Timer();
    if( dxr == None ) return;
    f = dxr.flagbase;

    switch(dxr.localURL) {
    case "10_PARIS_METRO":
        if (f.GetBool('MeetNicolette_Played') &&
            !f.GetBool('NicoletteLeftClub'))
        {
            f.SetBool('NicoletteLeftClub', True,, 11);

            foreach AllActors(class'NicoletteDuClare', nico, 'DXRMissions') {
                nico.Event = '';
                nico.Destroy();
                player().ClientFlash(1,vect(2000,2000,2000));
                gen = Spawn(class'ParticleGenerator',,, nico.Location);
                gen.SetCollision(false, false, false);
                gen.SetLocation(nico.Location);
                gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
                gen.LifeSpan = 2;
                gen.particleDrawScale = 5;
                gen.riseRate = 1;
                player().PlaySound(Sound'DeusExSounds.Weapons.GasGrenadeExplode');
            }

            foreach AllActors(class'NicoletteDuClare', nico)
                nico.EnterWorld();

            foreach AllActors(class'BlackHelicopter', chopper, 'BlackHelicopter')
                chopper.EnterWorld();
        }
        break;
    }
}

function MoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local int i;
    local Actor a;
    local ScriptedPawn sp;
    local string result;

    result = g.name $ " to " $ Loc.name;
    l("Moving " $ result $ " ("$ Loc.positions[0].pos $")");

    if(g.mapName == dxr.localURL && Loc.mapName != dxr.localURL) {
        // delete from map
        for(i=0; i<ArrayCount(g.actors); i++) {
            a = g.actors[i].a;
            if(a == None) continue;
            a.Event = '';
            a.Destroy();
        }
        return;
    }
    else if(g.mapName != dxr.localURL && Loc.mapName == dxr.localURL) {
        CreateGoal(g, Loc);
    }

    for(i=0; i<ArrayCount(g.actors); i++) {
        a = g.actors[i].a;
        if(a == None) continue;
        MoveActor(a, Loc.positions[i].pos, Loc.positions[i].rot, g.actors[i].physics);
    }

    if( (Loc.bitMask & SITTING_GOAL) != 0) {
        for(i=0; i<ArrayCount(g.actors); i++) {
            sp = ScriptedPawn(g.actors[i].a);
            if(sp == None) continue;
            sp.SetOrders('Sitting');
        }
    }
}

function bool MoveActor(Actor a, vector loc, rotator rotation, EPhysics p)
{
    local ScriptedPawn sp;
    local Mover m;
    local bool success, oldbCollideWorld;
    local Vehicles v;

    l("moving " $ a $ " from (" $ a.location $ ") to (" $ loc $ ")" );
    oldbCollideWorld = a.bCollideWorld;
    if(p == PHYS_None) a.bCollideWorld = false;
    success = a.SetLocation(loc);
    if( success == false ) {
        a.bCollideWorld = oldbCollideWorld;
        warning("failed to move "$a$" to "$loc);
        return false;
    }
    a.SetRotation(rotation);
    a.SetPhysics(p);
    if(p == PHYS_None) a.bCollideWorld = oldbCollideWorld;

    sp = ScriptedPawn(a);
    v = Vehicles(a);
    m = Mover(a);

    if( sp != None ) {
        if( sp.Orders == 'Patrolling' || sp.Orders == 'Sitting' )
            sp.SetOrders('Wandering');
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
        if (!v.bInWorld){
            v.WorldPosition = v.Location;
            v.SetLocation(v.Location+vect(0,0,20000));
        }
        else a.bCollideWorld = true;
    }
    else if( m != None ) {
        m.BasePos = a.Location;
        m.BaseRot = a.Rotation;
    } else {
        a.bCollideWorld = true;
    }

    return true;
}

function bool MoveGoalTo(name goalName, int locNumber)
{
    /*local Actor goalActor,a;
    local ImportantLocation targetLoc;
    local goal targetGoal;
    local int i,locNum;
    local bool foundGoal,foundLoc;

    //Find goal actor by name
     foreach AllActors(class'Actor', a) {
#ifdef hx
        if( a.GetPropertyText("PrecessorName") == string(goalName) )
#else
        if( a.name == goalName )
#endif
        {
            goalActor = a;
            break;
        }
    }

    if (goalActor == None) {
        //Couldn't find the actual goal actor
        return False;
    }
    locNum = 0;
    for(i=0; i<ArrayCount(important_locations); i++) {
        if( dxr.localURL != important_locations[i].map_name ) continue;
        if (locNum==locNumber){
            targetLoc = important_locations[i];
            foundLoc = true;
            break;
        }
        locNum++;
    }

    if (foundLoc == false){
        //Couldn't find the target location
        return False;
    }

    for(i=0; i<ArrayCount(goals); i++) {
        if( dxr.localURL != goals[i].map_name ) continue;
        if (goals[i].actor_name==goalName){
            targetGoal = goals[i];
            foundGoal = true;
            break;
        }
    }

    if (foundGoal == false){
        //Couldn't find a goal for the specified name
        return False;
    }

    MoveActor(goalActor, targetLoc.location, targetLoc.rotation, targetGoal.physics);

    return True;*/
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
